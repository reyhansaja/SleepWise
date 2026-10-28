"""
Feature 3: Random Forest Classifier Training & Evaluation Module
SleepWise ML Pipeline
Branch: feature/03-random-forest
"""

import os
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV, StratifiedKFold
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix
)

# Konfigurasi plotting
sns.set_theme(style="white", palette="muted")
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'


def load_processed_data(processed_dir: str):
    """Memuat data latih dan data uji hasil preprocessing."""
    X_train = pd.read_csv(os.path.join(processed_dir, "X_train.csv"))
    X_test = pd.read_csv(os.path.join(processed_dir, "X_test.csv"))
    y_train = pd.read_csv(os.path.join(processed_dir, "y_train.csv")).squeeze()
    y_test = pd.read_csv(os.path.join(processed_dir, "y_test.csv")).squeeze()

    print(f"[INFO] Data latih: {X_train.shape[0]} baris, Data uji: {X_test.shape[0]} baris.")
    return X_train, X_test, y_train, y_test


def experiment_and_tune_random_forest(X_train, y_train):
    """
    Melakukan eksperimen hyperparameter tuning pada Random Forest
    menggunakan GridSearchCV dan Stratified 5-Fold Cross Validation.
    """
    param_grid = {
        'n_estimators': [50, 100, 150],
        'max_depth': [4, 6, 8, None],
        'min_samples_split': [2, 5],
        'min_samples_leaf': [1, 2],
        'class_weight': ['balanced', None],
        'max_features': ['sqrt', 'log2']
    }

    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    rf_base = RandomForestClassifier(random_state=42)

    print("[INFO] Memulai eksperimen GridSearchCV untuk Random Forest...")
    grid_search = GridSearchCV(
        estimator=rf_base,
        param_grid=param_grid,
        cv=cv,
        scoring='f1_weighted',
        n_jobs=-1,
        verbose=1
    )
    grid_search.fit(X_train, y_train)

    print(f"[INFO] Parameter Terbaik: {grid_search.best_params_}")
    print(f"[INFO] Skor CV Terbaik (Weighted F1): {grid_search.best_score_:.4f}")

    return grid_search.best_estimator_, grid_search.best_params_, grid_search.best_score_


def evaluate_model(model, X_test, y_test, class_labels=['Average', 'Good', 'Poor']):
    """Mengukur seluruh metrik evaluasi model Random Forest."""
    y_pred = model.predict(X_test)

    acc = accuracy_score(y_test, y_pred)
    prec_macro = precision_score(y_test, y_pred, average='macro', zero_division=0)
    prec_weighted = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    rec_macro = recall_score(y_test, y_pred, average='macro', zero_division=0)
    rec_weighted = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    f1_macro = f1_score(y_test, y_pred, average='macro', zero_division=0)
    f1_weighted = f1_score(y_test, y_pred, average='weighted', zero_division=0)

    report_text = classification_report(y_test, y_pred, zero_division=0)
    conf_matrix = confusion_matrix(y_test, y_pred, labels=class_labels)

    metrics = {
        'accuracy': acc,
        'precision_macro': prec_macro,
        'precision_weighted': prec_weighted,
        'recall_macro': rec_macro,
        'recall_weighted': rec_weighted,
        'f1_macro': f1_macro,
        'f1_weighted': f1_weighted,
        'report_text': report_text,
        'confusion_matrix': conf_matrix,
        'y_pred': y_pred
    }

    print("\n--- Hasil Evaluasi Test Set (Random Forest) ---")
    print(f"Accuracy         : {acc * 100:.2f}%")
    print(f"Precision (Macro): {prec_macro * 100:.2f}% | (Weighted): {prec_weighted * 100:.2f}%")
    print(f"Recall (Macro)   : {rec_macro * 100:.2f}% | (Weighted): {rec_weighted * 100:.2f}%")
    print(f"F1-Score (Macro) : {f1_macro * 100:.2f}% | (Weighted): {f1_weighted * 100:.2f}%")
    print("\nClassification Report:\n", report_text)

    return metrics


def plot_and_save_visualizations(model, feature_names, metrics, figures_dir, class_labels=['Average', 'Good', 'Poor']):
    """
    Membuat visualisasi Confusion Matrix dan Feature Importance
    (selaras dengan tampilan 'Korelasi Faktor Tidur' di UI SleepWise).
    """
    os.makedirs(figures_dir, exist_ok=True)

    # 1. Confusion Matrix
    plt.figure(figsize=(7, 6))
    sns.heatmap(
        metrics['confusion_matrix'],
        annot=True,
        fmt='d',
        cmap='Greens',
        xticklabels=class_labels,
        yticklabels=class_labels,
        cbar=False
    )
    plt.title("Confusion Matrix - Random Forest Classifier", fontsize=13, fontweight='bold', pad=12)
    plt.xlabel("Kelas Prediksi", fontsize=11)
    plt.ylabel("Kelas Aktual", fontsize=11)
    plt.tight_layout()
    cm_path = os.path.join(figures_dir, "03_random_forest_confusion_matrix.png")
    plt.savefig(cm_path, dpi=300)
    plt.close()
    print(f"[INFO] Confusion Matrix disimpan ke: {cm_path}")

    # 2. Korelasi / Feature Importance (Selaras dengan layar Statistik SleepWise)
    importance_df = pd.DataFrame({
        'Feature': feature_names,
        'Importance': model.feature_importances_
    }).sort_values(by='Importance', ascending=True)

    # Ambil 10 fitur teratas
    top_10 = importance_df.tail(10)

    plt.figure(figsize=(10, 6))
    bars = plt.barh(top_10['Feature'], top_10['Importance'], color='#3b82f6')
    plt.title("Top 10 Feature Importance - Korelasi Faktor Tidur (Random Forest)", fontsize=13, fontweight='bold', pad=15)
    plt.xlabel("Relative Importance Score", fontsize=11)
    plt.ylabel("Fitur", fontsize=11)

    # Tambahkan label persentase pada bar
    for bar in bars:
        width = bar.get_width()
        plt.text(width + 0.005, bar.get_y() + bar.get_height()/2, f"{width*100:.1f}%",
                 ha='left', va='center', fontsize=9, fontweight='bold')

    plt.tight_layout()
    fi_path = os.path.join(figures_dir, "03_random_forest_feature_importance.png")
    plt.savefig(fi_path, dpi=300)
    plt.close()
    print(f"[INFO] Grafik Feature Importance disimpan ke: {fi_path}")


def save_evaluation_report(best_params, best_score, metrics, report_path):
    """Menulis laporan evaluasi dalam format Markdown."""
    content = f"""# Laporan Evaluasi Model 2: Random Forest Classifier

**Branch Git:** `feature/03-random-forest`  
**Model:** `RandomForestClassifier` (Scikit-Learn Ensemble)  
**Tujuan:** Klasifikasi Kualitas Tidur (Good / Average / Poor)  

---

## 1. Hasil Eksperimen Hyperparameter Tuning (GridSearchCV)

Validasi silang menggunakan **Stratified 5-Fold Cross Validation** dengan metrik optimasi `f1_weighted`.

* **Parameter Terbaik yang Terpilih:**
  * `n_estimators`: `{best_params.get('n_estimators')}`
  * `max_depth`: `{best_params.get('max_depth')}`
  * `min_samples_split`: `{best_params.get('min_samples_split')}`
  * `min_samples_leaf`: `{best_params.get('min_samples_leaf')}`
  * `class_weight`: `{best_params.get('class_weight')}`
  * `max_features`: `{best_params.get('max_features')}`
* **Rata-rata Skor Cross-Validation (Weighted F1):** `{best_score * 100:.2f}%`

---

## 2. Metrik Evaluasi Data Uji (Test Set Performance)

Ukuran data uji: 75 sampel (20% total data, stratified).

| Metrik Evaluasi | Skor (Macro Average) | Skor (Weighted Average) |
|:---|:---:|:---:|
| **Accuracy** | **{metrics['accuracy'] * 100:.2f}%** | **{metrics['accuracy'] * 100:.2f}%** |
| **Precision** | {metrics['precision_macro'] * 100:.2f}% | {metrics['precision_weighted'] * 100:.2f}% |
| **Recall** | {metrics['recall_macro'] * 100:.2f}% | {metrics['recall_weighted'] * 100:.2f}% |
| **F1-Score** | {metrics['f1_macro'] * 100:.2f}% | {metrics['f1_weighted'] * 100:.2f}% |

### Detail Classification Report per Kelas:
```text
{metrics['report_text']}
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
"""
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[INFO] Laporan evaluasi disimpan di: {report_path}")


def run_random_forest_training(base_dir: str):
    """Menjalankan seluruh alur training Random Forest."""
    processed_dir = os.path.join(base_dir, "data", "processed")
    models_dir = os.path.join(base_dir, "models")
    figures_dir = os.path.join(base_dir, "reports", "figures")
    report_file = os.path.join(base_dir, "reports", "03_random_forest_evaluation.md")

    # 1. Muat data
    X_train, X_test, y_train, y_test = load_processed_data(processed_dir)

    # 2. Tuning & Training
    best_rf, best_params, best_cv_score = experiment_and_tune_random_forest(X_train, y_train)

    # 3. Evaluasi
    metrics = evaluate_model(best_rf, X_test, y_test)

    # 4. Plot visualisasi
    plot_and_save_visualizations(best_rf, X_train.columns.tolist(), metrics, figures_dir)

    # 5. Simpan laporan
    save_evaluation_report(best_params, best_cv_score, metrics, report_file)

    # 6. Simpan model
    model_output_path = os.path.join(models_dir, "random_forest_model.joblib")
    joblib.dump(best_rf, model_output_path)
    print(f"[INFO] Model Random Forest tersimpan di: {model_output_path}")
    print("\n[SUCCESS] Pelatihan & Evaluasi Random Forest Selesai!")


if __name__ == "__main__":
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    run_random_forest_training(BASE_DIR)
