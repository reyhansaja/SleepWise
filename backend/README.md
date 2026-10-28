# SleepWise Backend (Flask + MySQL)

API prediksi kualitas tidur yang memakai model hasil `ml/src/04_model_selection.py`
(pipeline Joblib: preprocessing + model terpilih), menyimpan input & hasil ke MySQL,
dan mengembalikan rekomendasi berbasis aturan.

## Struktur

```text
backend/
├── app.py                          # create_app(), CORS, error handler JSON
├── config.py                       # .env -> path artefak, kredensial MySQL
├── requirements.txt
├── .env.example                    # salin menjadi .env
├── database/
│   ├── db.py                       # koneksi, query, init_schema (gagal-lunak)
│   └── schema.sql                  # predictions, prediction_recommendations, api_request_log
├── services/
│   ├── model_loader.py             # muat selected_pipeline.joblib + metadata
│   ├── prediction_service.py       # validasi input, inferensi, simpan MySQL
│   └── recommendation_service.py   # logika rekomendasi dari hasil prediksi
├── routes/
│   ├── health_routes.py            # /api/health, /api/models
│   └── prediction_routes.py        # /api/predictions...
└── tests/test_api.py               # unittest: validasi, prediksi, alur API->MySQL
```

## Menjalankan

```powershell
# sekali di root repo: buat venv + dependensi
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r ml/requirements.txt mysql-connector-python python-dotenv

# artefak model (harus ada sebelum backend dijalankan)
python ml/src/04_model_selection.py

# backend
cd backend
copy .env.example .env
python app.py            # http://127.0.0.1:5000
```

Database dibuat sekali (tabel dibuat otomatis saat startup):

```sql
CREATE DATABASE sleepwise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Bila MySQL mati, backend tetap melayani prediksi; field `stored` bernilai `false`.

## Endpoint

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/health` | status backend, MySQL, model aktif |
| GET | `/api/models` | model yang tersedia + metadata model selection |
| POST | `/api/predictions` | prediksi + rekomendasi + simpan ke MySQL |
| GET | `/api/predictions?limit=50&user_id=1` | riwayat prediksi |
| GET | `/api/predictions/<id>` | detail prediksi + rekomendasi tersimpan |
| GET | `/api/predictions/<id>/recommendations` | daftar rekomendasi |
| POST | `/api/ml/upload` | unggah CSV, dapat preview + nilai kosong |
| GET | `/api/ml/uploads` | daftar dataset yang pernah diunggah |
| POST | `/api/ml/train` | latih Decision Tree + Random Forest (split & CV identik) |
| GET | `/api/ml/runs` | riwayat training (MySQL `training_runs`) |
| GET | `/api/ml/runs/<run_id>` | detail satu run (metrik, confusion matrix, feature importance) |
| POST | `/api/ml/runs/<run_id>/promote` | jadikan pipeline run ini model aktif API prediksi |

### Contoh request

```bash
curl -X POST http://127.0.0.1:5000/api/predictions \
  -H "Content-Type: application/json" \
  -d '{"gender":"Female","age":29,"occupation":"Nurse",
       "sleep_duration":8.0,"physical_activity_level":70,"stress_level":3,
       "bmi_category":"Normal","blood_pressure":"118/76",
       "heart_rate":62,"daily_steps":9000,"sleep_disorder":"None"}'
```

Field `blood_pressure` (`"120/80"`) boleh diganti `systolic_bp` + `diastolic_bp`.
Opsional: `"model": "decision_tree"` untuk memakai artefak per algoritma
(jika tersedia), default memakai model terpilih.

### Contoh respons

```json
{
  "status": "success",
  "id": 7,
  "stored": true,
  "model": "Random Forest",
  "prediction": "Good",
  "confidence": 0.9442,
  "probabilities": {"Average": 0.0358, "Good": 0.9442, "Poor": 0.02},
  "recommendations": [
    {"category": "ringkasan", "message": "Kualitas tidur Anda optimal. ..."},
    {"category": "disclaimer", "message": "Hasil ini estimasi model machine learning, bukan diagnosis medis."}
  ]
}
```

## Validasi input

| Field | Aturan |
| --- | --- |
| `gender`, `occupation`, `bmi_category`, `sleep_disorder` | teks; `bmi_category` salah satu Underweight/Normal/Overweight/Obese (`Normal Weight` dinormalkan) |
| `age` | 1-120 |
| `sleep_duration` | 0-24 jam |
| `physical_activity_level` | 0-1440 menit/hari |
| `stress_level` | 1-10 |
| `heart_rate` | 30-220 bpm |
| `daily_steps` | 0-100000 |
| `systolic_bp` / `diastolic_bp` | 60-260 / 30-160 mmHg, wajib (boleh diganti `blood_pressure`: `"120/80"`) |

Field wajib: `gender`, `bmi_category`, `age`, `sleep_duration`,
`physical_activity_level`, `stress_level`, `heart_rate`, `daily_steps`, serta
tekanan darah. `occupation` dan `sleep_disorder` opsional (default `Other` / `None`).
Error validasi -> HTTP 400 dengan daftar `details` per field.

## Test

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s backend/tests -v
```

Test alur MySQL otomatis `skip` bila MySQL tidak aktif.

## ML Training (web)

Halaman training berbasis React + Tailwind ada di [`web/`](../web/README.md):
upload CSV → atur hyperparameter → bandingkan DT vs RF → aktifkan model.
Endpoint training memakai cleaner & preprocessor dari `ml/src/01_preprocessing.py`,
menyimpan artefak ke `ml/models/runs/<run_id>/`, dan mencatat riwayat ke tabel
`training_runs`. Dataset dengan skema proyek (`Quality of Sleep`, `BMI Category`,
`Sleep Disorder`) menghasilkan model yang bisa diaktifkan; dataset lain hanya
untuk eksperimen karena skema fiturnya berbeda dari API prediksi.
