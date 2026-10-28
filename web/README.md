# SleepWise · Web ML Training

Halaman training model (React + Vite + Tailwind CSS v4) untuk:
upload dataset CSV → preview → atur hyperparameter → latih Decision Tree & Random Forest
dengan split identik → lihat tabel perbandingan, confusion matrix, feature importance →
aktifkan model terpilih sebagai model API prediksi.

## Menjalankan

```powershell
# 1. backend (terminal 1)
cd backend
python app.py                     # http://127.0.0.1:5000

# 2. web (terminal 2)
cd web
npm install
npm run dev                       # http://127.0.0.1:5173
```

Vite mem-proxy `/api/*` ke `http://127.0.0.1:5000` (lihat `vite.config.js`),
jadi tidak perlu konfigurasi CORS tambahan saat development.

## Alur di halaman

1. **Dataset** — tarik/klik file CSV. Backend mengembalikan jumlah baris, kolom,
   nilai kosong per kolom, dan preview 8 baris.
   - Dataset skema proyek (`Quality of Sleep`, `BMI Category`, `Sleep Disorder`)
     memakai cleaner `ml/src/01_preprocessing.py`: label diturunkan otomatis menjadi
     `Good/Average/Poor`, `Blood Pressure` dipecah, `Normal Weight` → `Normal`.
   - Dataset lain boleh dipakai untuk eksperimen, tetapi tidak bisa diaktifkan
     untuk endpoint prediksi karena skema fiturnya berbeda.
2. **Konfigurasi** — `n_estimators`, `max_depth`, `min_samples_leaf`, `test_size`,
   `folds`, `random_state`. Kedua model memakai split, preprocessor, dan lipatan CV
   yang sama.
3. **Hasil** — kartu metrik (CV F1, test accuracy/F1, F1 macro), confusion matrix,
   metrik per kelas, feature importance RF, dan tombol **Aktifkan** per model.
4. **Riwayat** — 10 run terakhir dari tabel MySQL `training_runs`, tombol detail
   membuka ulang `run.json`.

## Struktur

```text
web/
├── index.html
├── vite.config.js               # plugin react + tailwind, proxy /api
├── package.json
└── src/
    ├── main.jsx
    ├── index.css                # @import "tailwindcss" + tema
    ├── App.jsx                  # state upload/train/hasil/riwayat
    ├── lib/api.js               # wrapper fetch + helper format persen
    └── components/
        ├── ui.jsx               # Card, Pill, Button, Stat, Spinner, Alert
        ├── UploadPanel.jsx
        ├── TrainPanel.jsx
        ├── ResultsPanel.jsx     # tabel perbandingan, confusion matrix, importance
        └── RunsPanel.jsx
```

## Build produksi

```powershell
npm run build      # hasil di web/dist
npm run preview
```

Responsif: grid berubah 1 kolom (mobile) → 2–4 kolom (tablet/desktop), tabel
dibungkus `overflow-x-auto`.
