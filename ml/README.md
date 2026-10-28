# SleepWise - Machine Learning Analytics Module

Proyek Machine Learning untuk klasifikasi dan prediksi kualitas tidur (*Circadian & Sleep Quality Analytics*), disesuaikan dengan antarmuka aplikasi mobile **SleepWise** (Flutter) serta arsitektur backend **Flask** dan frontend web **React**.

---

## Struktur Repositori & Pemisahan Fitur

Repositori ini telah dipisahkan secara modular per fitur agar mudah dikerjakan dan di-push ke GitHub sesuai branch fitur masing-masing:

```text
sleepwise_ml/
├── data/
│   ├── raw/
│   │   └── Sleep_health_and_lifestyle_dataset.csv     # Dataset mentah Kaggle
│   └── processed/
│       ├── sleep_cleaned.csv                          # Dataset hasil pembersihan (374 baris)
│       ├── X_train.csv / X_test.csv                   # Data fitur latih & uji
│       └── y_train.csv / y_test.csv                   # Target klasifikasi 3 kelas
├── models/
│   ├── preprocessor.joblib                            # Pipeline OneHotEncoder & StandardScaler
│   ├── decision_tree_model.joblib                     # Model Decision Tree terlatih
│   ├── random_forest_model.joblib                     # Model Random Forest terlatih
│   └── feature_metadata.joblib                        # Skema fitur untuk backend Flask
├── notebooks/
│   ├── 01_eda_and_preprocessing.ipynb                 # Notebook EDA & Preprocessing
│   ├── 02_decision_tree_experiments.ipynb             # Notebook eksperimen Decision Tree
│   └── 03_random_forest_experiments.ipynb             # Notebook eksperimen Random Forest
├── reports/
│   ├── figures/
│   │   ├── 01_eda_distributions.png                   # Grafik distribusi target & fitur
│   │   ├── 01_eda_correlations.png                    # Heatmap korelasi numerik
│   │   ├── 02_decision_tree_confusion_matrix.png      # Confusion Matrix Model 1
│   │   ├── 02_decision_tree_tree_plot.png             # Visualisasi struktur pohon
│   │   ├── 03_random_forest_confusion_matrix.png      # Confusion Matrix Model 2
│   │   └── 03_random_forest_feature_importance.png    # Korelasi faktor tidur (Feature Importance)
│   ├── 01_feature_documentation.md                    # Dokumentasi lengkap fitur dataset
│   ├── 02_decision_tree_evaluation.md                 # Laporan evaluasi Decision Tree
│   └── 03_random_forest_evaluation.md                 # Laporan evaluasi Random Forest
├── src/
│   ├── 01_preprocessing.py                            # Skrip otomatisasi Preprocessing & EDA
│   ├── 02_train_decision_tree.py                      # Skrip pelatihan & evaluasi Decision Tree
│   ├── 03_train_random_forest.py                      # Skrip pelatihan & evaluasi Random Forest
│   └── inference_service.py                           # Jembatan inferensi JSON untuk Flask API
├── requirements.txt                                   # Daftar dependensi Python
└── README.md                                          # Dokumentasi proyek & panduan branch Git
```

---

## Panduan Branch Git (Sesuai Fitur)

Untuk mengunggah kode ke GitHub secara bertahap sesuai fitur tugas, ikuti alur branch berikut:

### 1. Inisialisasi Git & Branch Utama
```bash
git init
git add README.md requirements.txt .gitignore
git commit -m "chore: initial commit structure"
git branch -M main
```

### 2. Fitur 1: Dataset & Preprocessing (`feature/01-data-preprocessing`)
```bash
git checkout -b feature/01-data-preprocessing
git add src/01_preprocessing.py notebooks/01_eda_and_preprocessing.ipynb reports/01_feature_documentation.md reports/figures/01_* models/preprocessor.joblib
git commit -m "feat(data): implement preprocessing pipeline, eda visualizations, and feature documentation"
git push -u origin feature/01-data-preprocessing
```

### 3. Fitur 2: Model Decision Tree (`feature/02-decision-tree`)
```bash
git checkout main
git checkout -b feature/02-decision-tree
git add src/02_train_decision_tree.py notebooks/02_decision_tree_experiments.ipynb reports/02_decision_tree_evaluation.md reports/figures/02_* models/decision_tree_model.joblib
git commit -m "feat(model): implement Decision Tree training, hyperparameter tuning, and evaluation metrics"
git push -u origin feature/02-decision-tree
```

### 4. Fitur 3: Model Random Forest (`feature/03-random-forest`)
```bash
git checkout main
git checkout -b feature/03-random-forest
git add src/03_train_random_forest.py notebooks/03_random_forest_experiments.ipynb reports/03_random_forest_evaluation.md reports/figures/03_* models/random_forest_model.joblib
git commit -m "feat(model): implement Random Forest classifier, feature importance correlation, and evaluation"
git push -u origin feature/03-random-forest
```

### 5. Integrasi Backend Flask (`feature/04-backend-integration`)
```bash
git checkout main
git checkout -b feature/04-backend-integration
git add src/inference_service.py
git commit -m "feat(api): create predictor service to connect ML models with Flask and React/Flutter"
git push -u origin feature/04-backend-integration
```

---

## Cara Menjalankan Modul Secara Mandiri

### 1. Instalasi Dependensi
```bash
pip install -r requirements.txt
```

### 2. Menjalankan Preprocessing & Visualisasi EDA
```bash
python src/01_preprocessing.py
```
* Menghasilkan dataset bersih `data/processed/sleep_cleaned.csv`.
* Menghasilkan pipeline encoder & scaler `models/preprocessor.joblib`.
* Menyimpan grafik ke `reports/figures/01_eda_*.png`.

### 3. Menjalankan Training Decision Tree
```bash
python src/02_train_decision_tree.py
```
* Melakukan `GridSearchCV` 5-fold cross validation.
* Mengukur akurasi, precision, recall, F1-score, dan confusion matrix.
* Menyimpan model ke `models/decision_tree_model.joblib`.

### 4. Menjalankan Training Random Forest
```bash
python src/03_train_random_forest.py
```
* Melatih ensemble pohon keputusan dengan tuning parameter.
* Menghasilkan bobot pengaruh faktor tidur (*Feature Importance*).
* Menyimpan model ke `models/random_forest_model.joblib`.

### 5. Menguji Service Prediksi (Simulasi Flask API)
```bash
python src/inference_service.py
```
* Menguji inferensi end-to-end dari raw JSON ke format respons yang siap dikonsumsi oleh Flutter dan React.
