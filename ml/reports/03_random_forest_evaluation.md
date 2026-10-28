# Laporan Evaluasi Model 2: Random Forest Classifier

**Branch Git:** `feature/03-random-forest`  
**Model:** `RandomForestClassifier` (Scikit-Learn Ensemble)  
**Tujuan:** Klasifikasi Kualitas Tidur (Good / Average / Poor)  

---

## 1. Hasil Eksperimen Hyperparameter Tuning (GridSearchCV)

Validasi silang menggunakan **Stratified 5-Fold Cross Validation** dengan metrik optimasi `f1_weighted`.

* **Parameter Terbaik yang Terpilih:**
  * `n_estimators`: `50`
  * `max_depth`: `6`
  * `min_samples_split`: `5`
  * `min_samples_leaf`: `2`
  * `class_weight`: `None`
  * `max_features`: `log2`
* **Rata-rata Skor Cross-Validation (Weighted F1):** `98.68%`

---

## 2. Metrik Evaluasi Data Uji (Test Set Performance)

Ukuran data uji: 75 sampel (20% total data, stratified).

| Metrik Evaluasi | Skor (Macro Average) | Skor (Weighted Average) |
|:---|:---:|:---:|
| **Accuracy** | **100.00%** | **100.00%** |
| **Precision** | 100.00% | 100.00% |
| **Recall** | 100.00% | 100.00% |
| **F1-Score** | 100.00% | 100.00% |

### Detail Classification Report per Kelas:
```text
              precision    recall  f1-score   support

     Average       1.00      1.00      1.00        21
        Good       1.00      1.00      1.00        52
        Poor       1.00      1.00      1.00         2

    accuracy                           1.00        75
   macro avg       1.00      1.00      1.00        75
weighted avg       1.00      1.00      1.00        75

```

---

## 3. Korelasi Faktor Tidur (Feature Importance Analysis)

* File visualisasi: `reports/figures/03_random_forest_feature_importance.png`
* Sesuai dengan tampilan **"Korelasi Faktor Tidur (ML)"** pada aplikasi Flutter SleepWise:
  1. **Durasi Tidur (*Sleep Duration*)**: Berkontribusi terbesar dalam menentukan apakah tidur masuk kategori *Optimal (Good)* atau *Defisit (Poor)*.
  2. **Tingkat Stres Harian (*Stress Level*)**: Memiliki bobot pengaruh signifikan kedua terhadap gangguan keterjagaan.
  3. **Detak Jantung & Aktivitas Fisik (*Heart Rate & Physical Activity*)**: Membantu memisahkan kualitas tidur tingkat rata-rata vs optimal.

---

## 4. Perbandingan dengan Decision Tree
* Random Forest menghasilkan batas keputusan yang lebih stabil (*robust*) karena merupakan ensemble dari puluhan pohon keputusan (*bagging*).
* Menghilangkan risiko *high variance* (overfitting) yang kerap terjadi pada pohon keputusan tunggal.

---

## 5. Artifact yang Dihasilkan
1. Model biner: `models/random_forest_model.joblib`
2. Confusion Matrix: `reports/figures/03_random_forest_confusion_matrix.png`
3. Grafik Feature Importance: `reports/figures/03_random_forest_feature_importance.png`
