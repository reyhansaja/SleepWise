"""Validasi payload API, inferensi model, rekomendasi, dan penyimpanan MySQL."""
import logging

from database import db
from services import recommendation_service
from services.model_loader import registry

log = logging.getLogger(__name__)

# field API -> kolom dataset
FIELD_MAP = {
    "gender": "Gender",
    "age": "Age",
    "occupation": "Occupation",
    "sleep_duration": "Sleep Duration",
    "physical_activity_level": "Physical Activity Level",
    "stress_level": "Stress Level",
    "bmi_category": "BMI Category",
    "heart_rate": "Heart Rate",
    "daily_steps": "Daily Steps",
    "sleep_disorder": "Sleep Disorder",
    "systolic_bp": "Systolic_BP",
    "diastolic_bp": "Diastolic_BP",
}

CATEGORICAL_FIELDS = ("gender", "occupation", "bmi_category", "sleep_disorder")
NUMERIC_RANGES = {
    "age": (1, 120),
    "sleep_duration": (0.0, 24.0),
    "physical_activity_level": (0, 1440),
    "stress_level": (1, 10),
    "heart_rate": (30, 220),
    "daily_steps": (0, 100000),
    "systolic_bp": (60, 260),
    "diastolic_bp": (30, 160),
}
REQUIRED_NUMERIC = ("age", "sleep_duration", "physical_activity_level", "stress_level",
                    "heart_rate", "daily_steps")
REQUIRED_CATEGORICAL = ("gender", "bmi_category")

BMI_LABELS = {"underweight", "normal", "normal weight", "overweight", "obese"}


def normalize(payload) -> tuple[dict, list[str]]:
    """Validasi dan ubah payload JSON menjadi fitur dataset siap-prediksi."""
    if not isinstance(payload, dict):
        return {}, ["Body request harus berupa objek JSON."]

    raw = {str(k).strip().lower(): v for k, v in payload.items() if k != "model"}
    errors: list[str] = []

    # Tekanan darah boleh dikirim sebagai "120/80"
    if "blood_pressure" in raw and "/" in str(raw["blood_pressure"]):
        parts = str(raw["blood_pressure"]).split("/")
        if len(parts) == 2:
            raw.setdefault("systolic_bp", parts[0])
            raw.setdefault("diastolic_bp", parts[1])

    if not raw.get("systolic_bp") or not raw.get("diastolic_bp"):
        errors.append(
            "Field 'systolic_bp' dan 'diastolic_bp' wajib diisi, "
            "atau kirim 'blood_pressure' dengan format \"120/80\"."
        )

    cleaned: dict = {}
    for field in CATEGORICAL_FIELDS:
        value = raw.get(field)
        if value is None or str(value).strip() == "":
            if field in REQUIRED_CATEGORICAL:
                errors.append(f"Field '{field}' wajib diisi.")
            continue
        text = str(value).strip()
        if field == "bmi_category":
            if text.lower() not in BMI_LABELS:
                errors.append(
                    "Field 'bmi_category' harus salah satu: Underweight, Normal, Overweight, Obese."
                )
                continue
            text = "Normal" if text.lower() == "normal weight" else text.title()
        cleaned[field] = text

    for field, (low, high) in NUMERIC_RANGES.items():
        value = raw.get(field)
        if value is None or str(value).strip() == "":
            if field in REQUIRED_NUMERIC:
                errors.append(f"Field '{field}' wajib diisi.")
            continue
        try:
            number = float(value)
        except (TypeError, ValueError):
            errors.append(f"Field '{field}' harus berupa angka.")
            continue
        if not low <= number <= high:
            errors.append(f"Field '{field}' harus di antara {low} dan {high}.")
            continue
        cleaned[field] = number if field == "sleep_duration" else int(round(number))

    cleaned["sleep_disorder"] = cleaned.get("sleep_disorder", "None")
    cleaned.setdefault("occupation", "Other")

    if "user_id" in raw and raw["user_id"] not in (None, ""):
        try:
            cleaned["user_id"] = int(raw["user_id"])
        except (TypeError, ValueError):
            errors.append("Field 'user_id' harus berupa bilangan bulat.")

    return cleaned, errors


def to_features(data: dict) -> dict:
    """Ubah data tervalidasi menjadi baris fitur dengan nama kolom dataset."""
    features = {}
    for field, column in FIELD_MAP.items():
        if field in data:
            features[column] = data[field]
    return features


def create_prediction(data: dict, model_name: str | None = None) -> dict:
    """Jalankan inferensi, susun rekomendasi, lalu simpan ke MySQL."""
    result = registry.predict(to_features(data), model_name)
    recommendations = recommendation_service.build_recommendations(result["prediction"], data)

    prediction_id = db.execute(
        """INSERT INTO predictions
           (user_id, gender, age, occupation, sleep_duration, physical_activity_level,
            stress_level, bmi_category, heart_rate, daily_steps, systolic_bp, diastolic_bp,
            sleep_disorder, predicted_quality, confidence, model_name)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
        (
            data.get("user_id"), data.get("gender"), data.get("age"), data.get("occupation"),
            data.get("sleep_duration"), data.get("physical_activity_level"), data.get("stress_level"),
            data.get("bmi_category"), data.get("heart_rate"), data.get("daily_steps"),
            data.get("systolic_bp"), data.get("diastolic_bp"), data.get("sleep_disorder"),
            result["prediction"], result["confidence"], result["model_name"],
        ),
    )

    stored_recommendations = False
    if prediction_id:
        stored_recommendations = db.execute_many(
            "INSERT INTO prediction_recommendations (prediction_id, category, message) VALUES (%s, %s, %s)",
            [(prediction_id, item.category, item.message) for item in recommendations],
        ) > 0

    return {
        "status": "success",
        "id": prediction_id,
        "stored": prediction_id is not None,
        "recommendations_stored": stored_recommendations,
        "model": result["model_name"],
        "model_key": result["model_key"],
        "prediction": result["prediction"],
        "confidence": result["confidence"],
        "probabilities": result["probabilities"],
        "recommendations": [item.as_dict() for item in recommendations],
        "input": data,
    }


def list_predictions(limit: int = 50, user_id: int | None = None) -> list[dict]:
    if user_id is None:
        return db.query_all("SELECT * FROM predictions ORDER BY id DESC LIMIT %s", (limit,))
    return db.query_all(
        "SELECT * FROM predictions WHERE user_id = %s ORDER BY id DESC LIMIT %s", (user_id, limit)
    )


def get_prediction(prediction_id: int):
    row = db.query_one("SELECT * FROM predictions WHERE id = %s", (prediction_id,))
    if row is None:
        return None
    row["recommendations"] = db.query_all(
        "SELECT category, message FROM prediction_recommendations WHERE prediction_id = %s ORDER BY id",
        (prediction_id,),
    )
    return row


def list_recommendations(prediction_id: int) -> list[dict]:
    return db.query_all(
        "SELECT category, message FROM prediction_recommendations WHERE prediction_id = %s ORDER BY id",
        (prediction_id,),
    )
