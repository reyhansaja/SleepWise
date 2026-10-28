"""Jembatan ke artefak ML (Joblib) untuk backend Flask.

Memprioritaskan pipeline hasil model selection (`selected_pipeline.joblib` + metadata),
dengan fallback ke artefak per model dari tahap training (01-03).
"""
import json
import logging
import threading
from pathlib import Path

import joblib
import pandas as pd

from config import Config

log = logging.getLogger(__name__)
_lock = threading.Lock()

CATEGORICAL_DEFAULT = ["Gender", "Occupation", "BMI Category", "Sleep Disorder"]
NUMERICAL_DEFAULT = [
    "Age", "Sleep Duration", "Physical Activity Level", "Stress Level",
    "Heart Rate", "Daily Steps", "Systolic_BP", "Diastolic_BP",
]


class ModelUnavailable(Exception):
    """Artefak model belum tersedia / tidak bisa dimuat."""


class ModelRegistry:
    """Menyimpan pipeline model di memori dan info model yang tersedia."""

    def __init__(self, model_dir: Path | str | None = None):
        self.model_dir = Path(model_dir or Config.MODEL_DIR)
        self._loaded = False
        self._pipelines: dict[str, object] = {}
        self._names: dict[str, str] = {}
        self.metadata: dict = {}
        self.categorical = CATEGORICAL_DEFAULT
        self.numerical = NUMERICAL_DEFAULT

    # ── pemuatan artefak ──
    def _load(self):
        with _lock:
            if self._loaded:
                return
            selected_path = self.model_dir / "selected_pipeline.joblib"
            meta_path = self.model_dir / "selected_model_metadata.json"

            if selected_path.exists() and meta_path.exists():
                self.metadata = json.loads(meta_path.read_text(encoding="utf-8"))
                pipeline = joblib.load(selected_path)
                self._pipelines["selected"] = pipeline
                key = self.metadata.get("model_key", "selected")
                self._pipelines[key] = pipeline
                self._names["selected"] = self.metadata.get("model_name", key)
                self._names[key] = self._names["selected"]
                self.categorical = self.metadata.get("categorical_features", CATEGORICAL_DEFAULT)
                self.numerical = self.metadata.get("numerical_features", NUMERICAL_DEFAULT)
                log.info("Pipeline model terpilih dimuat: %s (%s)", self._names["selected"], selected_path.name)
            else:
                self._load_legacy()

            if not self._pipelines:
                raise ModelUnavailable(
                    "Artefak model tidak ditemukan di "
                    f"{self.model_dir}. Jalankan ml/src/04_model_selection.py lebih dahulu."
                )
            self._loaded = True

    def _load_legacy(self):
        """Fallback: preprocessor + model per algoritma (tanpa pipeline terpilih)."""
        pre_path = self.model_dir / "preprocessor.joblib"
        meta_path = self.model_dir / "feature_metadata.joblib"
        if not pre_path.exists():
            return

        preprocessor = joblib.load(pre_path)
        feature_meta = joblib.load(meta_path) if meta_path.exists() else {}
        self.categorical = feature_meta.get("categorical_features", CATEGORICAL_DEFAULT)
        self.numerical = feature_meta.get("numerical_features", NUMERICAL_DEFAULT)

        from sklearn.pipeline import Pipeline

        for key, filename, label in (
            ("random_forest", "random_forest_model.joblib", "Random Forest"),
            ("decision_tree", "decision_tree_model.joblib", "Decision Tree"),
        ):
            path = self.model_dir / filename
            if path.exists():
                self._pipelines[key] = Pipeline([("preprocessor", preprocessor), ("model", joblib.load(path))])
                self._names[key] = label
        self.metadata = {"model_key": "random_forest", "model_name": "Random Forest",
                         "classes": ["Average", "Good", "Poor"]}
        log.warning("selected_pipeline.joblib belum ada; memakai artefak per model.")

    # ── inferensi ──
    def resolve(self, model_name: str | None) -> str:
        self._load()
        key = (model_name or Config.DEFAULT_MODEL or "selected").strip().lower().replace(" ", "_")
        if key in self._pipelines:
            return key
        if key in {"selected", "best", "auto"}:
            if "selected" in self._pipelines:
                return "selected"
            return "random_forest" if "random_forest" in self._pipelines else next(iter(self._pipelines))
        raise ValueError(
            f"Model '{model_name}' tidak tersedia. Pilihan: {sorted(self._pipelines)} atau 'selected'."
        )

    def reload(self) -> None:
        """Paksa muat ulang artefak (dipakai setelah promote model baru)."""
        with _lock:
            self._loaded = False
            self._pipelines.clear()
            self._names.clear()

    def available_models(self) -> list[dict]:
        self._load()
        items: list[dict] = [
            {"key": key, "name": self._names.get(key, key)}
            for key in self._pipelines
            if key != "selected"
        ]
        if "selected" in self._pipelines:
            items.insert(0, {"key": "selected", "name": self._names["selected"], "is_selected": True})
        return items

    def predict(self, features: dict, model_name: str | None = None) -> dict:
        key = self.resolve(model_name)
        pipeline = self._pipelines[key]
        frame = pd.DataFrame([features])[self.categorical + self.numerical]

        prediction = str(pipeline.predict(frame)[0])
        probabilities = pipeline.predict_proba(frame)[0]
        classes = [str(c) for c in pipeline.classes_]
        probs = {cls: round(float(p), 4) for cls, p in zip(classes, probabilities)}

        return {
            "prediction": prediction,
            "confidence": round(probs.get(prediction, 0.0), 4),
            "probabilities": probs,
            "model_key": key,
            "model_name": self._names.get(key, key),
            "classes": classes,
        }


registry = ModelRegistry()
