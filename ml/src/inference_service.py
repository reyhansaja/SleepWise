"""
Prediction Service Module for SleepWise (Flask & React / Flutter Integration)
SleepWise ML Pipeline
"""

import os
import joblib
import pandas as pd
import numpy as np


class SleepWisePredictor:
    def __init__(self, models_dir: str = None):
        if models_dir is None:
            models_dir = os.path.join(os.path.dirname(__file__), "..", "models")

        self.models_dir = os.path.abspath(models_dir)
        self.preprocessor_path = os.path.join(self.models_dir, "preprocessor.joblib")
        self.dt_path = os.path.join(self.models_dir, "decision_tree_model.joblib")
        self.rf_path = os.path.join(self.models_dir, "random_forest_model.joblib")

        print("[INFO] Memuat preprocessor dan model...")
        self.preprocessor = joblib.load(self.preprocessor_path)
        self.dt_model = joblib.load(self.dt_path)
        self.rf_model = joblib.load(self.rf_path)
        print("[INFO] Seluruh model siap digunakan untuk inferensi!")

    def _prepare_dataframe(self, input_dict: dict) -> pd.DataFrame:
        """
        Menyiapkan DataFrame dari input dictionary (JSON payload).
        Format input diharapkan:
        {
            "gender": "Female",
            "age": 29,
            "occupation": "Nurse",
            "sleep_duration": 7.5,
            "physical_activity_level": 60,
            "stress_level": 3,
            "bmi_category": "Normal",
            "heart_rate": 68,
            "daily_steps": 8000,
            "sleep_disorder": "None",
            "blood_pressure": "120/80"  # atau systolic_bp & diastolic_bp langsung
        }
        """
        # Parsing Blood Pressure jika dikirim format '120/80'
        if "blood_pressure" in input_dict and "/" in str(input_dict["blood_pressure"]):
            bp_parts = str(input_dict["blood_pressure"]).split("/")
            systolic = int(bp_parts[0])
            diastolic = int(bp_parts[1])
        else:
            systolic = int(input_dict.get("systolic_bp", 120))
            diastolic = int(input_dict.get("diastolic_bp", 80))

        # BMI standarisasi
        bmi = input_dict.get("bmi_category", "Normal")
        if bmi == "Normal Weight":
            bmi = "Normal"

        data = {
            "Gender": [input_dict.get("gender", "Male")],
            "Occupation": [input_dict.get("occupation", "Engineer")],
            "BMI Category": [bmi],
            "Sleep Disorder": [input_dict.get("sleep_disorder", "None")],
            "Age": [int(input_dict.get("age", 30))],
            "Sleep Duration": [float(input_dict.get("sleep_duration", 7.0))],
            "Physical Activity Level": [int(input_dict.get("physical_activity_level", 50))],
            "Stress Level": [int(input_dict.get("stress_level", 5))],
            "Heart Rate": [int(input_dict.get("heart_rate", 70))],
            "Daily Steps": [int(input_dict.get("daily_steps", 6000))],
            "Systolic_BP": [systolic],
            "Diastolic_BP": [diastolic]
        }

        return pd.DataFrame(data)

    def predict(self, input_data: dict, model_type: str = "random_forest") -> dict:
        """
        Melakukan inferensi prediksi kualitas tidur.
        model_type: 'random_forest' atau 'decision_tree'
        """
        df_input = self._prepare_dataframe(input_data)
        X_trans = self.preprocessor.transform(df_input)

        # Ambil nama fitur yang cocok dengan input model
        cat_features = ['Gender', 'Occupation', 'BMI Category', 'Sleep Disorder']
        num_features = ['Age', 'Sleep Duration', 'Physical Activity Level', 'Stress Level',
                        'Heart Rate', 'Daily Steps', 'Systolic_BP', 'Diastolic_BP']
        cat_names = self.preprocessor.named_transformers_['cat'].get_feature_names_out(cat_features).tolist()
        all_features = cat_names + num_features
        X_trans_df = pd.DataFrame(X_trans, columns=all_features)

        if model_type == "decision_tree":
            model = self.dt_model
            model_name = "Decision Tree"
        else:
            model = self.rf_model
            model_name = "Random Forest"

        prediction = model.predict(X_trans_df)[0]
        probabilities = model.predict_proba(X_trans_df)[0]
        class_index = list(model.classes_).index(prediction)
        confidence = float(probabilities[class_index])

        # Formatting label untuk UI Flutter SleepWise
        ui_badge_map = {
            "Good": "Good (Optimal)",
            "Average": "Average (Cukup)",
            "Poor": "Poor (Kurang)"
        }
        ui_badge = ui_badge_map.get(prediction, prediction)

        # Rekomendasi Sirkadian AI (selaras dengan screenshot UI SleepWise)
        recommendations = {
            "Good": "Pola istirahat Anda optimal dan ritme sirkadian stabil. Pertahankan rutinitas waktu tidur.",
            "Average": "Kualitas tidur cukup, namun terdapat potensi peningkatan. Batasi kafein sore hari dan kurangi screen-time.",
            "Poor": "Terdeteksi defisit tidur signifikan atau tingkat stres tinggi. Prioritaskan tidur minimal 7 jam dan relaksasi pra-istirahat."
        }

        return {
            "status": "success",
            "model_used": model_name,
            "prediction": prediction,
            "ui_badge": ui_badge,
            "confidence": round(confidence * 100, 1),
            "probabilities": {cls: round(prob * 100, 1) for cls, prob in zip(model.classes_, probabilities)},
            "recommendation": recommendations.get(prediction, "")
        }


# Pengujian Mandiri (Smoke Test)
if __name__ == "__main__":
    predictor = SleepWisePredictor()

    sample_input = {
        "gender": "Female",
        "age": 24,
        "occupation": "Software Engineer",
        "sleep_duration": 7.4,
        "physical_activity_level": 60,
        "stress_level": 3,
        "bmi_category": "Normal",
        "blood_pressure": "118/78",
        "heart_rate": 65,
        "daily_steps": 8500,
        "sleep_disorder": "None"
    }

    print("\n--- Test Inferensi Random Forest ---")
    result_rf = predictor.predict(sample_input, model_type="random_forest")
    print(result_rf)

    print("\n--- Test Inferensi Decision Tree ---")
    result_dt = predictor.predict(sample_input, model_type="decision_tree")
    print(result_dt)
