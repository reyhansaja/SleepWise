"""Smoke test backend: health, validasi input, prediksi, rekomendasi, dan alur API->MySQL.

Jalankan: .venv\\Scripts\\python.exe -m unittest discover -s backend/tests -v
"""
import io
import sys
import unittest
from pathlib import Path

BACKEND = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND))

from database import db  # noqa: E402

VALID = {
    "gender": "Female",
    "age": 29,
    "occupation": "Nurse",
    "sleep_duration": 8.0,
    "physical_activity_level": 70,
    "stress_level": 3,
    "bmi_category": "Normal",
    "blood_pressure": "118/76",
    "heart_rate": 62,
    "daily_steps": 9000,
    "sleep_disorder": "None",
}

POOR = {
    "gender": "Male",
    "age": 41,
    "occupation": "Salesperson",
    "sleep_duration": 5.5,
    "physical_activity_level": 30,
    "stress_level": 9,
    "bmi_category": "Overweight",
    "systolic_bp": 132,
    "diastolic_bp": 88,
    "heart_rate": 82,
    "daily_steps": 3000,
    "sleep_disorder": "Insomnia",
}


class PredictionApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from app import create_app

        cls.client = create_app().test_client()

    def test_health(self):
        body = self.client.get("/api/health").get_json()
        self.assertEqual(body["service"], "SleepWise Backend")
        self.assertTrue(body["models"], body.get("model_error"))

    def test_models_endpoint(self):
        body = self.client.get("/api/models").get_json()
        self.assertIn("metadata", body)
        self.assertIn(body["metadata"].get("selection_metric"), {"f1_weighted", "cv_f1_weighted"})

    def test_missing_required_field(self):
        response = self.client.post("/api/predictions", json={"gender": "Male"})
        self.assertEqual(response.status_code, 400)
        self.assertIn("details", response.get_json())

    def test_invalid_range(self):
        payload = dict(VALID, stress_level=99)
        response = self.client.post("/api/predictions", json=payload)
        self.assertEqual(response.status_code, 400)
        self.assertTrue(any("stress_level" in d for d in response.get_json()["details"]))

    def test_invalid_bmi(self):
        payload = dict(VALID, bmi_category="Gemuk")
        self.assertEqual(self.client.post("/api/predictions", json=payload).status_code, 400)

    def test_prediction_and_recommendations(self):
        response = self.client.post("/api/predictions", json=VALID)
        self.assertEqual(response.status_code, 201, response.get_json())
        body = response.get_json()
        self.assertIn(body["prediction"], {"Good", "Average", "Poor"})
        self.assertGreater(body["confidence"], 0)
        self.assertTrue(body["recommendations"])
        self.assertEqual(body["recommendations"][-1]["category"], "disclaimer")

        poor = self.client.post("/api/predictions", json=POOR).get_json()
        self.assertTrue(any(r["category"] == "stres" for r in poor["recommendations"]))
        self.assertTrue(any(r["category"] == "tekanan_darah" for r in poor["recommendations"]))

    def test_optional_fields_use_defaults(self):
        payload = dict(VALID)
        payload.pop("occupation")
        payload.pop("sleep_disorder")
        response = self.client.post("/api/predictions", json=payload)
        self.assertEqual(response.status_code, 201, response.get_json())
        self.assertIn(response.get_json()["prediction"], {"Good", "Average", "Poor"})

    def test_blood_pressure_required(self):
        payload = dict(VALID)
        payload.pop("blood_pressure")
        response = self.client.post("/api/predictions", json=payload)
        self.assertEqual(response.status_code, 400)
        self.assertTrue(any("blood_pressure" in d for d in response.get_json()["details"]))

    def test_prediction_persisted_to_mysql(self):
        if not db.available():
            self.skipTest("MySQL tidak aktif")
        response = self.client.post("/api/predictions", json=POOR)
        body = response.get_json()
        self.assertTrue(body["stored"], "prediksi harus tersimpan di MySQL")
        self.assertIsNotNone(body["id"])

        row = db.query_one("SELECT * FROM predictions WHERE id = %s", (body["id"],))
        self.assertIsNotNone(row)
        self.assertEqual(row["predicted_quality"], body["prediction"])
        self.assertEqual(row["model_name"], body["model"])

        recs = db.query_all(
            "SELECT category, message FROM prediction_recommendations WHERE prediction_id = %s",
            (body["id"],),
        )
        self.assertEqual(len(recs), len(body["recommendations"]))

        detail = self.client.get(f"/api/predictions/{body['id']}").get_json()
        self.assertEqual(detail["id"], body["id"])
        self.assertTrue(detail["recommendations"])

        history = self.client.get("/api/predictions?limit=5").get_json()
        self.assertIn(body["id"], [r["id"] for r in history["data"]])

        log_count = db.query_one(
            "SELECT COUNT(*) AS n FROM api_request_log WHERE endpoint = 'POST /api/predictions'"
        )
        self.assertGreater(log_count["n"], 0)


class TrainingApiTest(unittest.TestCase):
    """Alur ML Training: upload -> train -> riwayat -> promote."""

    RAW_CSV = Path(__file__).resolve().parents[2] / "ml" / "data" / "raw" / "Sleep_health_and_lifestyle_dataset.csv"

    @classmethod
    def setUpClass(cls):
        from app import create_app

        cls.client = create_app().test_client()
        if not cls.RAW_CSV.exists():
            raise unittest.SkipTest("dataset mentah tidak tersedia")
        with cls.RAW_CSV.open("rb") as handle:
            response = cls.client.post(
                "/api/ml/upload",
                data={"file": (io.BytesIO(handle.read()), cls.RAW_CSV.name)},
                content_type="multipart/form-data",
            )
        assert response.status_code == 201, response.get_json()
        cls.dataset = response.get_json()

    def test_upload_preview(self):
        self.assertEqual(self.dataset["rows"], 374)
        self.assertTrue(self.dataset["project_schema"])
        self.assertEqual(len(self.dataset["preview"]), 8)
        self.assertIn("Quality of Sleep", self.dataset["columns"])

    def test_reject_non_csv(self):
        response = self.client.post(
            "/api/ml/upload",
            data={"file": (io.BytesIO(b"nope"), "data.txt")},
            content_type="multipart/form-data",
        )
        self.assertEqual(response.status_code, 400)

    def test_train_returns_fair_comparison(self):
        response = self.client.post(
            "/api/ml/train",
            json={"dataset_id": self.dataset["dataset_id"], "params": {"n_estimators": 60, "folds": 3}},
        )
        self.assertEqual(response.status_code, 201, response.get_json())
        body = response.get_json()
        self.assertEqual(set(body["target_column"] for _ in [0]), {"Sleep_Quality_Class"})
        self.assertTrue(body["servable"])
        self.assertEqual(set(body["models"]), {"decision_tree", "random_forest"})
        for model in body["models"].values():
            self.assertGreaterEqual(model["test"]["accuracy"], 0.5)
            self.assertEqual(len(model["test"]["confusion_matrix"]), len(body["classes"]))
            self.assertTrue(model["artifact_path"].endswith(".joblib"))
            self.assertEqual(model["cv"]["folds"], 3)

        runs = self.client.get("/api/ml/runs").get_json()
        self.assertIn(body["run_id"], {row["run_id"] for row in runs["data"]})
        self.assertEqual(self.client.get(f"/api/ml/runs/{body['run_id']}").status_code, 200)

        promoted = self.client.post(
            f"/api/ml/runs/{body['run_id']}/promote", json={"model_key": "decision_tree"}
        )
        self.assertEqual(promoted.status_code, 200, promoted.get_json())
        self.assertEqual(promoted.get_json()["model_key"], "decision_tree")

        health = self.client.get("/api/health").get_json()
        self.assertEqual(health["selected_model"], "Decision Tree")
        prediction = self.client.post("/api/predictions", json=VALID)
        self.assertEqual(prediction.status_code, 201, prediction.get_json())


if __name__ == "__main__":
    unittest.main()
