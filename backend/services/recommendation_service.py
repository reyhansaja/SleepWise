"""Logika rekomendasi berdasarkan hasil prediksi dan input pengguna.

Rekomendasi berbasis aturan klinis umum (edukatif, bukan diagnosis medis).
"""
from dataclasses import dataclass


@dataclass(frozen=True)
class Recommendation:
    category: str
    message: str

    def as_dict(self) -> dict:
        return {"category": self.category, "message": self.message}


BASE_MESSAGE = {
    "Good": "Kualitas tidur Anda optimal. Pertahankan jadwal tidur dan bangun yang konsisten.",
    "Average": "Kualitas tidur cukup, masih ada ruang perbaikan pada durasi dan kebiasaan pra-tidur.",
    "Poor": "Kualitas tidur rendah. Prioritaskan perbaikan durasi tidur dan manajemen stres.",
}


def build_recommendations(prediction: str, data: dict) -> list[Recommendation]:
    """Susun daftar rekomendasi dari kategori prediksi + kondisi input."""
    items = [Recommendation("ringkasan", BASE_MESSAGE.get(prediction, BASE_MESSAGE["Average"]))]

    duration = data.get("sleep_duration")
    if duration is not None and duration < 7:
        items.append(Recommendation(
            "durasi_tidur",
            f"Durasi tidur {duration:.1f} jam. Usahakan 7-9 jam per malam untuk pemulihan optimal.",
        ))
    elif duration is not None and duration > 9:
        items.append(Recommendation(
            "durasi_tidur",
            "Durasi tidur melebihi 9 jam. Tidur berlebihan dapat menandakan kualitas tidur yang tidak efisien.",
        ))

    stress = data.get("stress_level")
    if stress is not None and stress >= 7:
        items.append(Recommendation(
            "stres",
            f"Tingkat stres {stress}/10 tergolong tinggi. Coba relaksasi pernapasan atau meditasi 10 menit sebelum tidur.",
        ))
    elif stress is not None and stress >= 5:
        items.append(Recommendation(
            "stres",
            "Tingkat stres sedang. Sisihkan waktu wind-down 30 menit tanpa pekerjaan sebelum tidur.",
        ))

    activity = data.get("physical_activity_level")
    if activity is not None and activity < 30:
        items.append(Recommendation(
            "aktivitas_fisik",
            "Aktivitas fisik harian rendah. Tambahkan jalan kaki 20-30 menit, hindari 2 jam sebelum tidur.",
        ))

    heart_rate = data.get("heart_rate")
    if heart_rate is not None and heart_rate > 80:
        items.append(Recommendation(
            "detak_jantung",
            f"Detak jantung {heart_rate} bpm tergolong tinggi saat istirahat. Pantau pemulihan dan kurangi kafein.",
        ))

    steps = data.get("daily_steps")
    if steps is not None and steps < 4000:
        items.append(Recommendation(
            "langkah_harian",
            f"Langkah harian {steps}. Target 7000-10000 langkah berkaitan dengan kualitas tidur lebih baik.",
        ))

    systolic = data.get("systolic_bp")
    diastolic = data.get("diastolic_bp")
    if systolic is not None and diastolic is not None:
        if systolic >= 140 or diastolic >= 90:
            items.append(Recommendation(
                "tekanan_darah",
                f"Tekanan darah {systolic}/{diastolic} mmHg termasuk tinggi. Konsultasikan ke tenaga kesehatan.",
            ))
        elif systolic >= 130 or diastolic >= 85:
            items.append(Recommendation(
                "tekanan_darah",
                f"Tekanan darah {systolic}/{diastolic} mmHg di atas normal. Pantau tekanan darah dan batasi garam.",
            ))

    bmi = str(data.get("bmi_category", "")).lower()
    if bmi in {"overweight", "obese"}:
        items.append(Recommendation(
            "bmi",
            "Kategori BMI di atas normal berkaitan dengan risiko gangguan napas saat tidur.",
        ))

    disorder = str(data.get("sleep_disorder", "None")).lower()
    if disorder not in {"none", "none (tidak ada)", "", "-"}:
        items.append(Recommendation(
            "gangguan_tidur",
            f"Riwayat {data.get('sleep_disorder')} perlu diperhatikan; pemantauan tenaga kesehatan disarankan.",
        ))

    items.append(Recommendation(
        "disclaimer",
        "Hasil ini estimasi model machine learning, bukan diagnosis medis.",
    ))
    return items
