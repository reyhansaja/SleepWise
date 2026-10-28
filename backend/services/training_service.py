"""Training service: upload dataset, latih DT + RF dengan split identik, simpan artefak.

Memakai cleaner & preprocessor dari ml/src/01_preprocessing.py agar artefak hasil
training web konsisten dengan dataset proyek dan bisa dipakai endpoint prediksi.
"""
import importlib.util
import json
import logging
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path

import joblib
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import StratifiedKFold, cross_validate, train_test_split
from sklearn.pipeline import Pipeline

from config import PROJECT_DIR, Config
from database import db

log = logging.getLogger(__name__)

RUNS_DIR = Path(Config.MODEL_DIR) / "runs"
PROJECT_SCHEMA_TARGET = "Sleep_Quality_Class"
PROJECT_CATEGORICAL = ["Gender", "Occupation", "BMI Category", "Sleep Disorder"]
PROJECT_NUMERICAL = [
    "Age", "Sleep Duration", "Physical Activity Level", "Stress Level",
    "Heart Rate", "Daily Steps", "Systolic_BP", "Diastolic_BP",
]
RAW_HINTS = {"Quality of Sleep", "BMI Category", "Sleep Disorder"}


class TrainingError(Exception):
    """Input dataset/parameter tidak valid."""


# ── pemuatan modul preprocessing proyek (single source of truth) ──
_preprocessing_module = None


def preprocessing_module():
    global _preprocessing_module
    if _preprocessing_module is None:
        path = Path(PROJECT_DIR) / "ml" / "src" / "01_preprocessing.py"
        spec = importlib.util.spec_from_file_location("sleepwise_preprocessing", path)
        if spec is None or spec.loader is None:
            raise TrainingError(f"Modul preprocessing tidak ditemukan: {path}")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        _preprocessing_module = module
    return _preprocessing_module


# ── upload & preview ──
def save_upload(file_storage) -> dict:
    filename = Path(file_storage.filename or "").name
    if not filename.lower().endswith(".csv"):
        raise TrainingError("Hanya file .csv yang diterima.")

    blob = file_storage.read(Config.MAX_UPLOAD_BYTES + 1)
    if len(blob) > Config.MAX_UPLOAD_BYTES:
        raise TrainingError(f"Ukuran file melebihi batas {Config.MAX_UPLOAD_BYTES // (1024 * 1024)} MB.")

    upload_dir = Path(Config.UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)
    dataset_id = uuid.uuid4().hex[:12]
    path = upload_dir / f"{dataset_id}_{filename}"
    path.write_bytes(blob)

    try:
        df = pd.read_csv(path)
    except Exception as exc:  # noqa: BLE001 - pesan diteruskan ke pengguna
        path.unlink(missing_ok=True)
        raise TrainingError(f"CSV tidak dapat dibaca: {exc}") from exc

    if df.empty or len(df) < 20:
        path.unlink(missing_ok=True)
        raise TrainingError("Dataset terlalu kecil; minimal 20 baris.")
    if len(df) > Config.MAX_UPLOAD_ROWS:
        path.unlink(missing_ok=True)
        raise TrainingError(f"Baris dataset melebihi batas {Config.MAX_UPLOAD_ROWS}.")

    preview = df.head(8).where(pd.notna(df.head(8)), None)
    return {
        "dataset_id": dataset_id,
        "dataset_filename": filename,
        "rows": int(len(df)),
        "columns": [str(c) for c in df.columns],
        "dtypes": {str(c): str(t) for c, t in df.dtypes.items()},
        "missing": {str(c): int(df[c].isna().sum()) for c in df.columns},
        "preview": json.loads(preview.to_json(orient="records")),
        "project_schema": RAW_HINTS.issubset(set(df.columns)),
        "target_suggestion": "Quality of Sleep" if RAW_HINTS.issubset(set(df.columns)) else str(df.columns[-1]),
    }


def dataset_path(dataset_id: str) -> Path:
    """Cari file upload berdasarkan id (mencegah path traversal dari input user)."""
    if not dataset_id or not dataset_id.isalnum():
        raise TrainingError("dataset_id tidak valid.")
    matches = list(Path(Config.UPLOAD_DIR).glob(f"{dataset_id}_*.csv"))
    if not matches:
        raise TrainingError("Dataset tidak ditemukan; unggah ulang.")
    return matches[0]


def list_uploads() -> list[dict]:
    upload_dir = Path(Config.UPLOAD_DIR)
    if not upload_dir.exists():
        return []
    items = []
    for path in sorted(upload_dir.glob("*.csv"), key=lambda p: p.stat().st_mtime, reverse=True)[:30]:
        dataset_id, _, name = path.name.partition("_")
        items.append({
            "dataset_id": dataset_id,
            "dataset_filename": name,
            "size_bytes": path.stat().st_size,
            "uploaded_at": datetime.fromtimestamp(path.stat().st_mtime, timezone.utc).isoformat(timespec="seconds"),
        })
    return items


# ── persiapan data ──
def prepare(df: pd.DataFrame, target_column: str | None) -> dict:
    """Kembalikan X, y, daftar fitur, dan status kompatibilitas dengan API prediksi."""
    if RAW_HINTS.issubset(set(df.columns)):
        cleaned = preprocessing_module().clean_dataset(df)
        target = PROJECT_SCHEMA_TARGET if PROJECT_SCHEMA_TARGET in cleaned.columns else None
        if target is None:
            raise TrainingError("Gagal menurunkan label kualitas tidur dari kolom 'Quality of Sleep'.")
        categorical = [c for c in PROJECT_CATEGORICAL if c in cleaned.columns]
        numerical = [c for c in PROJECT_NUMERICAL if c in cleaned.columns]
        servable = not set(PROJECT_CATEGORICAL + PROJECT_NUMERICAL) - set(cleaned.columns)
        source = "project-schema"
    else:
        if not target_column or target_column not in df.columns:
            raise TrainingError(
                "Pilih kolom target. Dataset ini tidak memakai skema proyek "
                "(butuh 'Quality of Sleep', 'BMI Category', 'Sleep Disorder')."
            )
        cleaned = df.copy()
        target = target_column
        features = [c for c in cleaned.columns if c != target]
        categorical = [c for c in features if cleaned[c].dtype == object or str(cleaned[c].dtype) == "category"]
        numerical = [c for c in features if c not in categorical]
        servable = False
        source = "generic"

    if not categorical and not numerical:
        raise TrainingError("Dataset tidak memiliki fitur selain kolom target.")

    cleaned = cleaned.dropna(subset=[target])
    y = cleaned[target].astype(str)
    if y.nunique() < 2:
        raise TrainingError("Kolom target harus memiliki minimal 2 kelas.")
    if len(cleaned) < 30:
        raise TrainingError("Setelah pembersihan, data tersisa kurang dari 30 baris.")

    X = cleaned[categorical + numerical]
    return {
        "X": X, "y": y, "target": target,
        "categorical": categorical, "numerical": numerical,
        "servable": servable, "source": source, "rows": int(len(X)),
    }


# ── training ──
def _models(params: dict) -> dict:
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.tree import DecisionTreeClassifier

    shared = {
        "random_state": int(params.get("random_state", 42)),
        "min_samples_leaf": int(params.get("min_samples_leaf", 1)),
    }
    max_depth = params.get("max_depth")
    shared: dict = {"max_depth": int(max_depth) if max_depth not in (None, "", "None") else None}

    return {
        "random_forest": {
            "name": "Random Forest",
            "estimator": RandomForestClassifier(
                n_estimators=int(params.get("n_estimators", 200)), n_jobs=-1, **shared
            ),
        },
        "decision_tree": {
            "name": "Decision Tree",
            "estimator": DecisionTreeClassifier(**shared),
        },
    }


def _evaluate(pipeline, X_test, y_test, labels) -> dict:
    y_pred = pipeline.predict(X_test)
    return {
        "accuracy": float(accuracy_score(y_test, y_pred)),
        "precision_weighted": float(precision_score(y_test, y_pred, average="weighted", zero_division=0)),
        "recall_weighted": float(recall_score(y_test, y_pred, average="weighted", zero_division=0)),
        "f1_weighted": float(f1_score(y_test, y_pred, average="weighted", zero_division=0)),
        "f1_macro": float(f1_score(y_test, y_pred, average="macro", zero_division=0)),
        "confusion_matrix": confusion_matrix(y_test, y_pred, labels=labels).tolist(),
        "report": classification_report(y_test, y_pred, labels=labels, output_dict=True, zero_division=0),
    }


def _feature_importance(preprocessor, categorical, numerical, values, top: int = 10) -> list[dict]:
    """Jumlahkan importance hasil one-hot kembali ke kolom aslinya."""
    try:
        encoded = list(preprocessor.get_feature_names_out())
    except Exception:  # noqa: BLE001
        encoded = [f"f{i}" for i in range(len(values))]

    totals: dict[str, float] = {}
    for name, value in zip(encoded, values):
        body = name.split("__", 1)[-1]
        source = next((col for col in categorical if body.startswith(f"{col}_")), None)
        if source is None:
            source = body if body in numerical else next(
                (col for col in numerical if body.startswith(col)), body
            )
        totals[source] = totals.get(source, 0.0) + float(value)

    ranked = sorted(totals.items(), key=lambda kv: kv[1], reverse=True)[:top]
    return [{"feature": k, "importance": round(v, 4)} for k, v in ranked]


def run_training(dataset_id: str, target_column: str | None = None, params: dict | None = None) -> dict:
    params = params or {}
    started = time.perf_counter()
    path = dataset_path(dataset_id)
    df = pd.read_csv(path)
    prepared = prepare(df, target_column)

    X, y = prepared["X"], prepared["y"]
    test_size = float(params.get("test_size", 0.2))
    if not 0.1 <= test_size <= 0.4:
        raise TrainingError("test_size harus antara 0.1 dan 0.4.")
    random_state = int(params.get("random_state", 42))
    folds = int(params.get("folds", 5))
    if not 2 <= folds <= 10:
        raise TrainingError("folds harus antara 2 dan 10.")
    if y.value_counts().min() < folds:
        folds = max(2, int(y.value_counts().min()))

    stratify = y if y.value_counts().min() >= 2 else None
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=stratify
    )

    preprocessor = preprocessing_module().build_preprocessor(prepared["categorical"], prepared["numerical"])
    pipeline_for = lambda estimator: Pipeline([("preprocessor", preprocessor), ("model", estimator)])  # noqa: E731

    run_id = f"{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}-{uuid.uuid4().hex[:6]}"
    run_dir = RUNS_DIR / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    labels = sorted(y.unique())
    cv = StratifiedKFold(n_splits=folds, shuffle=True, random_state=random_state)
    results = {}
    for key, info in _models(params).items():
        model_started = time.perf_counter()
        pipeline = pipeline_for(info["estimator"])
        scores = cross_validate(
            pipeline, X_train, y_train, cv=cv,
            scoring={"accuracy": "accuracy", "f1_weighted": "f1_weighted", "f1_macro": "f1_macro"},
            n_jobs=-1,
        )
        pipeline.fit(X_train, y_train)
        metrics = _evaluate(pipeline, X_test, y_test, labels)
        artifact = run_dir / f"{key}.joblib"
        joblib.dump(pipeline, artifact)

        importance = []
        estimator = pipeline.named_steps["model"]
        if hasattr(estimator, "feature_importances_"):
            importance = _feature_importance(
                pipeline.named_steps["preprocessor"], prepared["categorical"],
                prepared["numerical"], estimator.feature_importances_,
            )

        results[key] = {
            "model_key": key,
            "model_name": info["name"],
            "cv": {
                "folds": folds,
                "accuracy_mean": float(scores["test_accuracy"].mean()),
                "accuracy_std": float(scores["test_accuracy"].std()),
                "f1_weighted_mean": float(scores["test_f1_weighted"].mean()),
                "f1_weighted_std": float(scores["test_f1_weighted"].std()),
                "f1_macro_mean": float(scores["test_f1_macro"].mean()),
            },
            "test": metrics,
            "feature_importance": importance,
            "artifact_path": str(artifact),
            "duration_ms": int((time.perf_counter() - model_started) * 1000),
        }

    selected = max(results, key=lambda k: (results[k]["cv"]["f1_weighted_mean"], results[k]["test"]["accuracy"]))
    metadata = {
        "run_id": run_id,
        "dataset_id": dataset_id,
        "dataset_filename": path.name.split("_", 1)[-1],
        "source": prepared["source"],
        "servable": prepared["servable"],
        "target_column": prepared["target"],
        "categorical_features": prepared["categorical"],
        "numerical_features": prepared["numerical"],
        "rows": prepared["rows"],
        "classes": labels,
        "split": {"test_size": test_size, "random_state": random_state, "folds": folds,
                  "train_rows": int(len(X_train)), "test_rows": int(len(X_test))},
        "params": {k: params.get(k) for k in ("n_estimators", "max_depth", "min_samples_leaf")},
        "models": results,
        "selected_model": selected,
        "duration_ms": int((time.perf_counter() - started) * 1000),
        "created_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }
    (run_dir / "run.json").write_text(json.dumps(metadata, indent=2, default=str), encoding="utf-8")
    _record_run(metadata)
    return metadata


def _record_run(metadata: dict) -> None:
    rows = [
        (
            metadata["run_id"], metadata["dataset_filename"], metadata["rows"],
            metadata["target_column"], key, info["model_name"],
            info["test"]["accuracy"], info["test"]["f1_weighted"],
            info["cv"]["f1_weighted_mean"], info["artifact_path"], info["duration_ms"],
        )
        for key, info in metadata["models"].items()
    ]
    db.execute_many(
        """INSERT INTO training_runs
           (run_id, dataset_filename, dataset_rows, target_column, model_key, model_name,
            accuracy, f1_weighted, cv_f1_weighted, artifact_path, duration_ms)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
        rows,
    )


def list_runs(limit: int = 20) -> list[dict]:
    return db.query_all(
        """SELECT run_id, dataset_filename, dataset_rows, target_column, model_key, model_name,
                  accuracy, f1_weighted, cv_f1_weighted, duration_ms, created_at
           FROM training_runs ORDER BY id DESC LIMIT %s""",
        (limit,),
    )


def get_run(run_id: str) -> dict | None:
    if not run_id.replace("-", "").isalnum():
        return None
    path = RUNS_DIR / run_id / "run.json"
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def promote(run_id: str, model_key: str) -> dict:
    """Jadikan pipeline hasil training sebagai model aktif untuk endpoint prediksi."""
    metadata = get_run(run_id)
    if metadata is None:
        raise TrainingError("Run tidak ditemukan.")
    if not metadata.get("servable"):
        raise TrainingError(
            "Run ini dilatih dari dataset tanpa skema proyek, sehingga tidak kompatibel "
            "dengan endpoint prediksi. Latih dengan dataset asli SleepWise untuk mengaktifkannya."
        )
    info = metadata["models"].get(model_key)
    if info is None:
        raise TrainingError(f"Model '{model_key}' tidak ada pada run ini.")

    model_dir = Path(Config.MODEL_DIR)
    model_dir.mkdir(parents=True, exist_ok=True)
    backup_dir = model_dir / "runs" / "_previous"
    backup_dir.mkdir(parents=True, exist_ok=True)
    for name in ("selected_pipeline.joblib", "selected_model_metadata.json"):
        current = model_dir / name
        if current.exists():
            current.replace(backup_dir / name)

    joblib.dump(joblib.load(info["artifact_path"]), model_dir / "selected_pipeline.joblib")
    payload = {
        "model_key": model_key,
        "model_name": info["model_name"],
        "selection_metric": "cv_f1_weighted",
        "selection_rule": "dipilih manual dari halaman ML Training",
        "pipeline_path": str(model_dir / "selected_pipeline.joblib"),
        "classes": metadata["classes"],
        "categorical_features": metadata["categorical_features"],
        "numerical_features": metadata["numerical_features"],
        "all_feature_names": _feature_names(metadata),
        "cv": info["cv"],
        "test_metrics": {k: v for k, v in info["test"].items()
                         if k not in ("confusion_matrix", "report")},
        "comparison": [
            {
                "model": m["model_name"],
                "model_key": key,
                "cv_f1_weighted": m["cv"]["f1_weighted_mean"],
                "cv_f1_weighted_std": m["cv"]["f1_weighted_std"],
                "cv_accuracy": m["cv"]["accuracy_mean"],
                "cv_f1_macro": m["cv"]["f1_macro_mean"],
                "test_accuracy": m["test"]["accuracy"],
                "test_precision_weighted": m["test"]["precision_weighted"],
                "test_recall_weighted": m["test"]["recall_weighted"],
                "test_f1_weighted": m["test"]["f1_weighted"],
                "test_f1_macro": m["test"]["f1_macro"],
            }
            for key, m in metadata["models"].items()
        ],
        "selected_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source_run": run_id,
    }
    (model_dir / "selected_model_metadata.json").write_text(
        json.dumps(payload, indent=2, default=str), encoding="utf-8"
    )

    from services.model_loader import registry

    registry.reload()
    return payload


def _feature_names(metadata: dict) -> list[str]:
    """Hitung ulang nama fitur hasil one-hot (harus sama urutannya dengan preprocessor)."""
    pre = preprocessing_module()
    preprocessor = pre.build_preprocessor(metadata["categorical_features"], metadata["numerical_features"])
    # preprocessor belum di-fit; ambil nama kategori unik dari dataset agar konsisten
    import pandas as pd

    df = pd.read_csv(dataset_path(metadata["dataset_id"]))
    prepared = prepare(df, metadata["target_column"])
    preprocessor.fit(prepared["X"])
    cat_names = preprocessor.named_transformers_["cat"].get_feature_names_out(
        metadata["categorical_features"]
    ).tolist()
    return cat_names + metadata["numerical_features"]
