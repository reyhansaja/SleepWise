# Laporan Evaluasi Model 1: Decision Tree Classifier

**Branch Git:** `feature/02-decision-tree`  
**Model:** `DecisionTreeClassifier` (Scikit-Learn)  
**Tujuan:** Klasifikasi Kualitas Tidur (Good / Average / Poor)  

---

## 1. Hasil Eksperimen Hyperparameter Tuning (GridSearchCV)

Validasi silang menggunakan **Stratified 5-Fold Cross Validation** dengan metrik optimasi `f1_weighted`.

* **Parameter Terbaik yang Terpilih:**
  * `criterion`: `gini`
  * `max_depth`: `3`
  * `min_samples_split`: `10`
  * `min_samples_leaf`: `1`
  * `class_weight`: `None`
* **Rata-rata Skor Cross-Validation (Weighted F1):** `98.64%`

---

## 2. Metrik Evaluasi Data Uji (Test Set Performance)

Ukuran data uji: 75 sampel (20% total data, stratified).

| Metrik Evaluasi | Skor (Macro Average) | Skor (Weighted Average) |
|:---|:---:|:---:|
| **Accuracy** | **98.67%** | **98.67%** |
| **Precision** | 98.48% | 98.73% |
| **Recall** | 83.33% | 98.67% |
| **F1-Score** | 88.11% | 98.46% |

### Detail Classification Report per Kelas:
```text
              precision    recall  f1-score   support

     Average       0.95      1.00      0.98        21
        Good       1.00      1.00      1.00        52
        Poor       1.00      0.50      0.67         2

    accuracy                           0.99        75
   macro avg       0.98      0.83      0.88        75
weighted avg       0.99      0.99      0.98        75

```

---

## 3. Analisis Confusion Matrix

* File visualisasi: `reports/figures/02_decision_tree_confusion_matrix.png`
* Model Decision Tree menunjukkan daya separasi yang sangat tegas antar kategori kualitas tidur, terutama karena fitur `Sleep Duration` dan `Stress Level` menjadi pemisah utama pada simpul akar (*root node*).
* Model ini ringan, sangat cepat untuk inferensi real-time di backend Flask, dan transparan (dapat dijelaskan dengan diagram pohon).

---

## 4. Artifact yang Dihasilkan
1. Model biner: `models/decision_tree_model.joblib`
2. Confusion Matrix: `reports/figures/02_decision_tree_confusion_matrix.png`
3. Visualisasi Pohon: `reports/figures/02_decision_tree_tree_plot.png`
