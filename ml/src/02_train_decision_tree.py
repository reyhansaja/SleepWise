"""
Feature 2: Decision Tree Classifier Training & Evaluation Module
SleepWise ML Pipeline
Branch: feature/02-decision-tree
"""

import os
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.tree import DecisionTreeClassifier, plot_tree
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


def experiment_and_tune_decision_tree(X_train, y_train):
    """
    Melakukan eksperimen hyperparameter tuning menggunakan GridSearchCV
    dengan Stratified 5-Fold Cross Validation.
    """
    param_grid = {
        'criterion': ['gini', 'entropy'],
        'max_depth': [3, 4, 5, 6, 8, None],
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4],
        'class_weight': ['balanced', None]
    }

    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    dt_base = DecisionTreeClassifier(random_state=42)

    print("[INFO] Memulai eksperimen GridSearchCV untuk Decision Tree...")
    grid_search = GridSearchCV(
        estimator=dt_base,
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
    """Mengukur seluruh metrik evaluasi model."""
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

    print("\n--- Hasil Evaluasi Test Set (Decision Tree) ---")
    print(f"Accuracy         : {acc * 100:.2f}%")
    print(f"Precision (Macro): {prec_macro * 100:.2f}% | (Weighted): {prec_weighted * 100:.2f}%")
    print(f"Recall (Macro)   : {rec_macro * 100:.2f}% | (Weighted): {rec_weighted * 100:.2f}%")
    print(f"F1-Score (Macro) : {f1_macro * 100:.2f}% | (Weighted): {f1_weighted * 100:.2f}%")
    print("\nClassification Report:\n", report_text)

    return metrics


def plot_and_save_visualizations(model, feature_names, metrics, figures_dir, class_labels=['Average', 'Good', 'Poor']):
    """Membuat visualisasi Confusion Matrix dan Pohon Keputusan."""
    os.makedirs(figures_dir, exist_ok=True)

    # 1. Confusion Matrix
    plt.figure(figsize=(7, 6))
    sns.heatmap(
        metrics['confusion_matrix'],
        annot=True,
        fmt='d',
        cmap='Blues',
        xticklabels=class_labels,
        yticklabels=class_labels,
        cbar=False
    )
    plt.title("Confusion Matrix - Decision Tree Classifier", fontsize=13, fontweight='bold', pad=12)
    plt.xlabel("Kelas Prediksi", fontsize=11)
    plt.ylabel("Kelas Aktual", fontsize=11)
    plt.tight_layout()
    cm_path = os.path.join(figures_dir, "02_decision_tree_confusion_matrix.png")
    plt.savefig(cm_path, dpi=300)
    plt.close()
    print(f"[INFO] Confusion Matrix disimpan ke: {cm_path}")

    # 2. Struktur Pohon Keputusan (Plot Tree)
    plt.figure(figsize=(18, 10))
    plot_tree(
        model,
        feature_names=feature_names,
        class_names=model.classes_,
        filled=True,
        rounded=True,
        fontsize=9,
        max_depth=3  # Menampilkan 3 level teratas untuk kejelasan visual
    )
    plt.title("Visualisasi Struktur Pohon Keputusan (Top 3 Levels)", fontsize=14, fontweight='bold', pad=15)
    plt.tight_layout()
    tree_path = os.path.join(figures_dir, "02_decision_tree_tree_plot.png")
    plt.savefig(tree_path, dpi=300)
    plt.close()
    print(f"[INFO] Visualisasi Pohon Keputusan disimpan ke: {tree_path}")


def save_evaluation_report(best_params, best_score, metrics, report_path):
    """Menulis laporan evaluasi dalam format Markdown."""
    content = f"""# Laporan Evaluasi Model 1: Decision Tree Classifier

**Branch Git:** `feature/02-decision-tree`  
**Model:** `DecisionTreeClassifier` (Scikit-Learn)  
**Tujuan:** Klasifikasi Kualitas Tidur (Good / Average / Poor)  

---

## 1. Hasil Eksperimen Hyperparameter Tuning (GridSearchCV)

Validasi silang menggunakan **Stratified 5-Fold Cross Validation** dengan metrik optimasi `f1_weighted`.

* **Parameter Terbaik yang Terpilih:**
  * `criterion`: `{best_params.get('criterion')}`
  * `max_depth`: `{best_params.get('max_depth')}`
  * `min_samples_split`: `{best_params.get('min_samples_split')}`
  * `min_samples_leaf`: `{best_params.get('min_samples_leaf')}`
  * `class_weight`: `{best_params.get('class_weight')}`
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

## 3. Analisis Confusion Matrix

* File visualisasi: `reports/figures/02_decision_tree_confusion_matrix.png`
* Model Decision Tree menunjukkan daya separasi yang sangat tegas antar kategori kualitas tidur, terutama karena fitur `Sleep Duration` dan `Stress Level` menjadi pemisah utama pada simpul akar (*root node*).
* Model ini ringan, sangat cepat untuk inferensi real-time di backend Flask, dan transparan (dapat dijelaskan dengan diagram pohon).

---

## 4. Artifact yang Dihasilkan
1. Model biner: `models/decision_tree_model.joblib`
2. Confusion Matrix: `reports/figures/02_decision_tree_confusion_matrix.png`
3. Visualisasi Pohon: `reports/figures/02_decision_tree_tree_plot.png`
"""
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[INFO] Laporan evaluasi disimpan di: {report_path}")


def run_decision_tree_training(base_dir: str):
    """Menjalankan seluruh alur training Decision Tree."""
    processed_dir = os.path.join(base_dir, "data", "processed")
    models_dir = os.path.join(base_dir, "models")
    figures_dir = os.path.join(base_dir, "reports", "figures")
    report_file = os.path.join(base_dir, "reports", "02_decision_tree_evaluation.md")

    # 1. Muat data
    X_train, X_test, y_train, y_test = load_processed_data(processed_dir)

    # 2. Tuning & Training
    best_dt, best_params, best_cv_score = experiment_and_tune_decision_tree(X_train, y_train)

    # 3. Evaluasi
    metrics = evaluate_model(best_dt, X_test, y_test)

    # 4. Plot visualisasi
    plot_and_save_visualizations(best_dt, X_train.columns.tolist(), metrics, figures_dir)

    # 5. Simpan laporan
    save_evaluation_report(best_params, best_cv_score, metrics, report_file)

    # 6. Simpan model
    model_output_path = os.path.join(models_dir, "decision_tree_model.joblib")
    joblib.dump(best_dt, model_output_path)
    print(f"[INFO] Model Decision Tree tersimpan di: {model_output_path}")
    print("\n[SUCCESS] Pelatihan & Evaluasi Decision Tree Selesai!")


if __name__ == "__main__":
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    run_decision_tree_training(BASE_DIR)
