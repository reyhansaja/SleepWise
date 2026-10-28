"""
Feature 4: Model Selection Module
SleepWise ML Pipeline
Branch: feature/04-model-selection

Membandingkan Decision Tree dan Random Forest secara adil:
- memakai hasil preprocessing dan pembagian data yang identik (X_train/X_test dari 01_preprocessing.py);
- memakai lipatan cross-validation yang sama untuk kedua model;
- memakai metrik dan ambang evaluasi yang sama;
- memilih model berdasarkan metric cross-validation (bukan test set, agar tidak bocor);
- menyimpan model + pipeline preprocessing dalam satu artefak Joblib;
- menguji fungsi prediksi dengan input baru.
"""

import json
import os
import time
from datetime import datetime, timezone

import joblib
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import StratifiedKFold, cross_validate
from sklearn.pipeline import Pipeline

CLASS_LABELS = ["Average", "Good", "Poor"]
MODEL_FILES = {
    "decision_tree": ("decision_tree_model.joblib", "Decision Tree"),
    "random_forest": ("random_forest_model.joblib", "Random Forest"),
}
METRIC_KEYS = ["accuracy", "precision_weighted", "recall_weighted", "f1_weighted",
               "precision_macro", "recall_macro", "f1_macro"]
SELECTION_METRIC = "f1_weighted"  # metrik utama pemilihan model (cross-validation)


def load_artifacts(base_dir: str) -> dict:
    """Muat preprocessor, metadata fitur, dua model, dan data split yang sama."""
    models_dir = os.path.join(base_dir, "models")
    processed_dir = os.path.join(base_dir, "data", "processed")

    preprocessor = joblib.load(os.path.join(models_dir, "preprocessor.joblib"))
    feature_meta = joblib.load(os.path.join(models_dir, "feature_metadata.joblib"))

    models = {}
    for key, (filename, label) in MODEL_FILES.items():
        path = os.path.join(models_dir, filename)
        if not os.path.exists(path):
            raise FileNotFoundError(f"Model {label} belum ada: {path}. Jalankan training dahulu.")
        models[key] = {
            "name": label,
            "model": joblib.load(path),
            "path": path,
            "preprocessor": preprocessor,
        }

    data = {
        "X_train": pd.read_csv(os.path.join(processed_dir, "X_train.csv")),
        "X_test": pd.read_csv(os.path.join(processed_dir, "X_test.csv")),
        "y_train": pd.read_csv(os.path.join(processed_dir, "y_train.csv")).squeeze(),
        "y_test": pd.read_csv(os.path.join(processed_dir, "y_test.csv")).squeeze(),
    }
    print(f"[INFO] Data split identik: train {data['X_train'].shape[0]} baris, "
          f"test {data['X_test'].shape[0]} baris, {data['X_train'].shape[1]} fitur.")
    return {"preprocessor": preprocessor, "feature_meta": feature_meta, **data, "models": models}


def evaluate_on_test(model, X_test, y_test) -> dict:
    """Metrik evaluasi pada data uji yang sama untuk semua model."""
    started = time.perf_counter()
    y_pred = model.predict(X_test)
    latency_ms = (time.perf_counter() - started) * 1000

    return {
        "accuracy": accuracy_score(y_test, y_pred),
        "precision_weighted": precision_score(y_test, y_pred, average="weighted", zero_division=0),
        "recall_weighted": recall_score(y_test, y_pred, average="weighted", zero_division=0),
        "f1_weighted": f1_score(y_test, y_pred, average="weighted", zero_division=0),
        "precision_macro": precision_score(y_test, y_pred, average="macro", zero_division=0),
        "recall_macro": recall_score(y_test, y_pred, average="macro", zero_division=0),
        "f1_macro": f1_score(y_test, y_pred, average="macro", zero_division=0),
        "confusion_matrix": confusion_matrix(y_test, y_pred, labels=CLASS_LABELS),
        "report_text": classification_report(y_test, y_pred, labels=CLASS_LABELS, zero_division=0),
        "latency_ms_per_75_samples": latency_ms,
    }


def cross_validate_on_train(model, X_train, y_train, folds: int = 5) -> dict:
    """Cross-validation dengan lipatan identik untuk setiap model."""
    cv = StratifiedKFold(n_splits=folds, shuffle=True, random_state=42)
    scores = cross_validate(
        model, X_train, y_train, cv=cv,
        scoring={"accuracy": "accuracy", "f1_weighted": "f1_weighted", "f1_macro": "f1_macro"},
        n_jobs=-1,
    )
    return {
        "folds": folds,
        "accuracy_mean": float(scores["test_accuracy"].mean()),
        "accuracy_std": float(scores["test_accuracy"].std()),
        "f1_weighted_mean": float(scores["test_f1_weighted"].mean()),
        "f1_weighted_std": float(scores["test_f1_weighted"].std()),
        "f1_macro_mean": float(scores["test_f1_macro"].mean()),
        "f1_macro_std": float(scores["test_f1_macro"].std()),
    }


def build_comparison_table(results: dict) -> pd.DataFrame:
    """Tabel perbandingan model: CV (pemilihan) + test set (pelaporan)."""
    rows = []
    for key, result in results.items():
        test = result["test"]
        cv = result["cv"]
        rows.append({
            "model_key": key,
            "model": result["name"],
            "cv_f1_weighted": cv["f1_weighted_mean"],
            "cv_f1_weighted_std": cv["f1_weighted_std"],
            "cv_accuracy": cv["accuracy_mean"],
            "cv_f1_macro": cv["f1_macro_mean"],
            "test_accuracy": test["accuracy"],
            "test_precision_weighted": test["precision_weighted"],
            "test_recall_weighted": test["recall_weighted"],
            "test_f1_weighted": test["f1_weighted"],
            "test_f1_macro": test["f1_macro"],
        })
    table = pd.DataFrame(rows).set_index("model")
    return table.sort_values("cv_f1_weighted", ascending=False)


def select_best_model(table: pd.DataFrame, results: dict) -> str:
    """
    Pilih model: metrik utama CV f1_weighted; seri -> test f1_weighted -> CV f1_macro.
    Model dengan performa lebih rendah dipilih hanya jika metrik utama benar-benar seri.
    """
    ranked = table.sort_values(
        ["cv_f1_weighted", "test_f1_weighted", "cv_f1_macro"], ascending=False
    )
    best_name = ranked.index[0]
    return next(key for key, result in results.items() if result["name"] == best_name)


def plot_comparison(table: pd.DataFrame, figures_dir: str) -> str:
    """Bar chart perbandingan metrik kedua model."""
    os.makedirs(figures_dir, exist_ok=True)
    metrics = ["cv_f1_weighted", "test_accuracy", "test_precision_weighted",
               "test_recall_weighted", "test_f1_weighted"]
    labels = ["CV F1 (weighted)", "Test Accuracy", "Test Precision", "Test Recall", "Test F1"]

    fig, ax = plt.subplots(figsize=(11, 5.5))
    positions = np.arange(len(metrics))
    width = 0.38
    for i, (name, row) in enumerate(table.iterrows()):
        values = [row[m] * 100 for m in metrics]
        bars = ax.bar(positions + (i - 0.5) * width, values, width, label=name)
        ax.bar_label(bars, fmt="%.2f", fontsize=8, padding=2)

    ax.set_xticks(positions, labels)
    ax.set_ylim(0, 112)
    ax.set_ylabel("Skor (%)")
    ax.set_title("Perbandingan Model Decision Tree vs Random Forest (Split & Metrik Identik)",
                 fontsize=13, fontweight="bold")
    ax.legend(loc="lower right")
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    path = os.path.join(figures_dir, "04_model_comparison.png")
    plt.savefig(path, dpi=300)
    plt.close()
    return path


def save_selected_model(best_key: str, artifacts: dict, results: dict, model_dir: str) -> str:
    """Simpan model terpilih + preprocessing sebagai satu pipeline Joblib."""
    pipeline = Pipeline([
        ("preprocessor", artifacts["preprocessor"]),
        ("model", results[best_key]["model"]),
    ])
    path = os.path.join(model_dir, "selected_pipeline.joblib")
    joblib.dump(pipeline, path)
    print(f"[INFO] Pipeline model terpilih disimpan: {path}")
    return path


def save_selected_metadata(best_key: str, artifacts: dict, results: dict, table: pd.DataFrame,
                           model_dir: str, pipeline_path: str) -> str:
    """Metadata model terpilih untuk dibaca backend Flask."""
    best = results[best_key]
    metadata = {
        "model_key": best_key,
        "model_name": best["name"],
        "selection_metric": SELECTION_METRIC,
        "selection_rule": "cv_f1_weighted > test_f1_weighted > cv_f1_macro",
        "pipeline_path": pipeline_path,
        "classes": CLASS_LABELS,
        "categorical_features": artifacts["feature_meta"]["categorical_features"],
        "numerical_features": artifacts["feature_meta"]["numerical_features"],
        "all_feature_names": artifacts["feature_meta"]["all_feature_names"],
        "cv": best["cv"],
        "test_metrics": {k: best["test"][k] for k in METRIC_KEYS},
        "comparison": table.reset_index().to_dict(orient="records"),
        "selected_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }
    path = os.path.join(model_dir, "selected_model_metadata.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2, default=float)
    print(f"[INFO] Metadata model terpilih disimpan: {path}")
    return path


def write_report(table: pd.DataFrame, best_key: str, results: dict, report_path: str,
                 figure_path: str, csv_path: str) -> str:
    """Laporan Markdown: tabel perbandingan, alasan pemilihan, metrik test."""
    best = results[best_key]
    others = [r for k, r in results.items() if k != best_key]
    runner_up = others[0] if others else best

    rows = []
    for name, row in table.iterrows():
        mark = " **(terpilih)**" if name == best["name"] else ""
        rows.append(
            f"| {name}{mark} | {row['cv_f1_weighted']*100:.2f}% ± {row['cv_f1_weighted_std']*100:.2f}% "
            f"| {row['test_accuracy']*100:.2f}% | {row['test_precision_weighted']*100:.2f}% "
            f"| {row['test_recall_weighted']*100:.2f}% | {row['test_f1_weighted']*100:.2f}% "
            f"| {row['test_f1_macro']*100:.2f}% |"
        )

    content = f"""# Laporan Model Selection: Decision Tree vs Random Forest

**Branch Git:** `feature/04-model-selection`  
**Tujuan:** Memilih satu model untuk endpoint prediksi Flask atas dasar perbandingan yang adil.

---

## 1. Kontrol Keadilan Perbandingan

| Aspek | Perlakuan |
|:---|:---|
| Data latih/uji | Identik, dari `data/processed/X_train.csv` & `X_test.csv` (split 80/20, `random_state=42`, `stratify=y`) |
| Preprocessing | Identik, `preprocessor.joblib` (OneHotEncoder + StandardScaler) yang di-fit hanya pada data latih |
| Cross-validation | `StratifiedKFold(n_splits=5, shuffle=True, random_state=42)` — lipatan sama untuk kedua model |
| Metrik | Accuracy, Precision, Recall, F1 (weighted & macro) dengan definisi yang sama |
| Hyperparameter | Dituning terpisah dengan protokol sama (`GridSearchCV`, 5-fold, `f1_weighted`) |
| Metrik pemilihan | **CV `f1_weighted`** — test set tidak dipakai memilih, hanya melaporkan |

---

## 2. Tabel Perbandingan Model

| Model | CV F1-weighted | Test Accuracy | Test Precision (w) | Test Recall (w) | Test F1 (w) | Test F1 (macro) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
{chr(10).join(rows)}

Grafik: `{os.path.relpath(figure_path, os.path.dirname(os.path.dirname(report_path)))}`  
Data mentah tabel: `{os.path.relpath(csv_path, os.path.dirname(os.path.dirname(report_path)))}`

---

## 3. Model Terpilih

**{best['name']}** (`{best_key}`), dipilih karena CV `f1_weighted` = **{best['cv']['f1_weighted_mean']*100:.2f}%**
(± {best['cv']['f1_weighted_std']*100:.2f}%), dibanding {runner_up['name']}
{runner_up['cv']['f1_weighted_mean']*100:.2f}% pada lipatan yang sama.

Seleksi memakai skor validasi silang, bukan skor test set, agar pemilihan tidak
memanfaatkan data uji (*optimistic selection bias*).

### Detail Classification Report (data uji {sum(sum(r) for r in best['test']['confusion_matrix'])} sampel)
```text
{best['test']['report_text']}
```

Confusion matrix (baris = aktual, kolom = prediksi, urutan {CLASS_LABELS}):
```text
{best['test']['confusion_matrix']}
```

---

## 4. Artefak yang Dihasilkan

1. `models/selected_pipeline.joblib` — pipeline lengkap (preprocessing + model terpilih), satu artefak untuk inferensi.
2. `models/selected_model_metadata.json` — nama model, metrik, daftar fitur, kelas, dan tabel perbandingan.
3. `reports/04_model_comparison.md` (laporan ini) dan `reports/04_model_comparison.csv`.
4. `reports/figures/04_model_comparison.png`.

Catatan: kedua model sudah dituning pada data latih yang sama, sehingga skor test
yang tinggi (termasuk kemungkinan 100%) harus dibaca sebagai performa pada dataset
ini, bukan jaminan performa pada data pasien baru. Kelas `Poor` hanya memiliki
sangat sedikit sampel, sehingga F1 macro lebih sensitif daripada accuracy.
"""
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[INFO] Laporan perbandingan disimpan: {report_path}")
    return report_path


def test_prediction_with_new_input(pipeline: Pipeline, metadata: dict, models: dict) -> list[dict]:
    """Uji fungsi prediksi pada input baru (bukan baris dari data uji)."""
    samples = [
        {
            "label": "Tidur cukup, stres rendah",
            "data": {"Gender": "Female", "Age": 29, "Occupation": "Nurse", "Sleep Duration": 8.0,
                     "Physical Activity Level": 70, "Stress Level": 3, "BMI Category": "Normal",
                     "Heart Rate": 62, "Daily Steps": 9000, "Systolic_BP": 118,
                     "Diastolic_BP": 76, "Sleep Disorder": "None"},
        },
        {
            "label": "Durasi kurang, stres tinggi",
            "data": {"Gender": "Male", "Age": 41, "Occupation": "Salesperson", "Sleep Duration": 5.5,
                     "Physical Activity Level": 30, "Stress Level": 9, "BMI Category": "Overweight",
                     "Heart Rate": 82, "Daily Steps": 3000, "Systolic_BP": 132,
                     "Diastolic_BP": 88, "Sleep Disorder": "Insomnia"},
        },
        {
            "label": "Sedang, aktivitas tinggi",
            "data": {"Gender": "Male", "Age": 35, "Occupation": "Engineer", "Sleep Duration": 6.5,
                     "Physical Activity Level": 90, "Stress Level": 6, "BMI Category": "Normal",
                     "Heart Rate": 70, "Daily Steps": 12000, "Systolic_BP": 125,
                     "Diastolic_BP": 82, "Sleep Disorder": "None"},
        },
    ]

    columns = metadata["categorical_features"] + metadata["numerical_features"]
    results = []
    for sample in samples:
        frame = pd.DataFrame([sample["data"]])[columns]
        started = time.perf_counter()
        prediction = pipeline.predict(frame)[0]
        probabilities = pipeline.predict_proba(frame)[0]
        elapsed_ms = (time.perf_counter() - started) * 1000
        confidence = float(probabilities[list(pipeline.classes_).index(prediction)])
        result = {
            "sample": sample["label"],
            "prediction": str(prediction),
            "confidence": round(confidence * 100, 2),
            "probabilities": {str(c): round(float(p) * 100, 2)
                              for c, p in zip(pipeline.classes_, probabilities)},
            "latency_ms": round(elapsed_ms, 2),
        }
        results.append(result)
        print(f"[PREDIKSI] {sample['label']}: {result['prediction']} "
              f"({result['confidence']:.1f}%) dalam {result['latency_ms']:.1f} ms")

    # Kontras perilaku kedua model pada input yang sama (kontrol 'adil')
    print("\n[INFO] Perbandingan prediksi DT vs RF pada input uji yang sama:")
    preprocessor = models["decision_tree"]["preprocessor"]
    for sample in samples:
        frame = pd.DataFrame([sample["data"]])[columns]
        transformed = pd.DataFrame(
            preprocessor.transform(frame), columns=metadata["all_feature_names"]
        )
        dt_pred = models["decision_tree"]["model"].predict(transformed)[0]
        rf_pred = models["random_forest"]["model"].predict(transformed)[0]
        print(f"  - {sample['label']}: DT={dt_pred} | RF={rf_pred}")

    return results


def run_model_selection(base_dir: str) -> dict:
    """Alur lengkap: muat artefak -> evaluasi adil -> pilih -> simpan -> uji prediksi."""
    models_dir = os.path.join(base_dir, "models")
    figures_dir = os.path.join(base_dir, "reports", "figures")
    reports_dir = os.path.join(base_dir, "reports")
    os.makedirs(figures_dir, exist_ok=True)

    artifacts = load_artifacts(base_dir)

    results = {}
    for key, info in artifacts["models"].items():
        print(f"\n[INFO] Evaluasi {info['name']}...")
        results[key] = {
            "name": info["name"],
            "model": info["model"],
            "cv": cross_validate_on_train(info["model"], artifacts["X_train"], artifacts["y_train"]),
            "test": evaluate_on_test(info["model"], artifacts["X_test"], artifacts["y_test"]),
        }
        print(f"  CV F1-weighted : {results[key]['cv']['f1_weighted_mean']*100:.2f}% "
              f"(± {results[key]['cv']['f1_weighted_std']*100:.2f}%)")
        print(f"  Test accuracy  : {results[key]['test']['accuracy']*100:.2f}% | "
              f"F1-weighted: {results[key]['test']['f1_weighted']*100:.2f}%")

    table = build_comparison_table(results)
    print("\n=== TABEL PERBANDINGAN MODEL ===")
    print(table.round(4).to_string())

    csv_path = os.path.join(reports_dir, "04_model_comparison.csv")
    table.to_csv(csv_path)
    print(f"[INFO] Tabel perbandingan disimpan: {csv_path}")

    best_key = select_best_model(table, results)
    print(f"\n[SUCCESS] Model terpilih: {results[best_key]['name']} ({best_key})")

    pipeline_path = save_selected_model(best_key, artifacts, results, models_dir)
    metadata_path = save_selected_metadata(best_key, artifacts, results, table, models_dir, pipeline_path)
    figure_path = plot_comparison(table, figures_dir)
    report_path = write_report(table, best_key, results, os.path.join(reports_dir, "04_model_comparison.md"),
                               figure_path, csv_path)

    pipeline = joblib.load(pipeline_path)
    with open(metadata_path, encoding="utf-8") as f:
        metadata = json.load(f)
    print("\n=== UJI FUNGSI PREDIKSI DENGAN INPUT BARU ===")
    test_prediction_with_new_input(pipeline, metadata, artifacts["models"])

    return {
        "table": table,
        "selected": best_key,
        "selected_name": results[best_key]["name"],
        "pipeline_path": pipeline_path,
        "metadata_path": metadata_path,
        "report_path": report_path,
        "figure_path": figure_path,
        "csv_path": csv_path,
    }


if __name__ == "__main__":
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    run_model_selection(BASE_DIR)
