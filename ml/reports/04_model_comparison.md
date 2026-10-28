# Laporan Model Selection: Decision Tree vs Random Forest

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
| Random Forest **(terpilih)** | 98.68% ± 1.26% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% |
| Decision Tree | 98.64% ± 0.70% | 98.67% | 98.73% | 98.67% | 98.46% | 88.11% |

Grafik: `reports\figures\04_model_comparison.png`  
Data mentah tabel: `reports\04_model_comparison.csv`

---

## 3. Model Terpilih

**Random Forest** (`random_forest`), dipilih karena CV `f1_weighted` = **98.68%**
(± 1.26%), dibanding Decision Tree
98.64% pada lipatan yang sama.

Seleksi memakai skor validasi silang, bukan skor test set, agar pemilihan tidak
memanfaatkan data uji (*optimistic selection bias*).

### Detail Classification Report (data uji 75 sampel)
```text
              precision    recall  f1-score   support

     Average       1.00      1.00      1.00        21
        Good       1.00      1.00      1.00        52
        Poor       1.00      1.00      1.00         2

    accuracy                           1.00        75
   macro avg       1.00      1.00      1.00        75
weighted avg       1.00      1.00      1.00        75

```

Confusion matrix (baris = aktual, kolom = prediksi, urutan ['Average', 'Good', 'Poor']):
```text
[[21  0  0]
 [ 0 52  0]
 [ 0  0  2]]
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
