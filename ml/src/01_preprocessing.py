"""
Feature 1: Dataset & Preprocessing Module
SleepWise ML Pipeline
Branch: feature/01-data-preprocessing
"""

import os
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer

# Konfigurasi plotting
sns.set_theme(style="whitegrid", palette="muted")
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'


def load_raw_data(filepath: str) -> pd.DataFrame:
    """Membaca file raw dataset CSV."""
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"File dataset tidak ditemukan: {filepath}")
    df = pd.read_csv(filepath)
    print(f"[INFO] Dataset berhasil dimuat: {df.shape[0]} baris, {df.shape[1]} kolom.")
    return df


def clean_dataset(df: pd.DataFrame, drop_feature_duplicates: bool = False) -> pd.DataFrame:
    """
    Membersihkan data:
    1. Memeriksa integritas kolom 'Person ID'.
    2. Menangani nilai kosong pada 'Sleep Disorder' (diisi 'None' = tidak ada gangguan tidur).
    3. Standarisasi 'BMI Category' ('Normal Weight' disatukan menjadi 'Normal').
    4. Memecah 'Blood Pressure' menjadi 'Systolic_BP' dan 'Diastolic_BP' (tipe int).
    5. Menghapus baris duplikat (opsional/terdokumentasi).
    6. Menambahkan label target 3 kategori (Poor, Average, Good) sesuai antarmuka SleepWise.
    """
    df_cleaned = df.copy()

    # 1. Hapus Person ID (karena hanya identifier responden)
    if 'Person ID' in df_cleaned.columns:
        df_cleaned.drop(columns=['Person ID'], inplace=True)

    # 2. Imputasi nilai kosong pada Sleep Disorder
    # Pada dataset asli, responden tanpa gangguan tidur tercatat NaN
    missing_disorder = df_cleaned['Sleep Disorder'].isnull().sum()
    df_cleaned['Sleep Disorder'] = df_cleaned['Sleep Disorder'].fillna('None')
    print(f"[INFO] Mengisi {missing_disorder} nilai kosong pada 'Sleep Disorder' dengan 'None'.")

    # 3. Standarisasi kategori BMI ('Normal Weight' -> 'Normal')
    df_cleaned['BMI Category'] = df_cleaned['BMI Category'].replace({
        'Normal Weight': 'Normal'
    })

    # 4. Split fitur gabungan Blood Pressure menjadi Systolic dan Diastolic
    if 'Blood Pressure' in df_cleaned.columns:
        bp_split = df_cleaned['Blood Pressure'].astype(str).str.split('/', expand=True)
        df_cleaned['Systolic_BP'] = bp_split[0].astype(int)
        df_cleaned['Diastolic_BP'] = bp_split[1].astype(int)
        df_cleaned.drop(columns=['Blood Pressure'], inplace=True)

    # 5. Penanganan Duplikat
    # Pada survei klinis/gaya hidup, responden berbeda dapat memiliki nilai atribut yang sama.
    # Jika drop_feature_duplicates=True, baris dengan atribut kembar akan dieliminasi.
    duplicate_count = df_cleaned.duplicated().sum()
    print(f"[INFO] Jumlah baris dengan nilai fitur identik: {duplicate_count}")
    if drop_feature_duplicates and duplicate_count > 0:
        df_cleaned.drop_duplicates(inplace=True)
        print(f"[INFO] {duplicate_count} baris duplikat fitur telah dihapus.")
    else:
        print("[INFO] Seluruh data responden dipertahankan untuk representasi populasi.")

    # 6. Pemetaan Target Klasifikasi 3 Kategori (SleepWise UI Alignment)
    # Poor (1-5), Average (6), Good (7-10)
    def map_sleep_quality(score):
        if score <= 5:
            return 'Poor'
        elif score == 6:
            return 'Average'
        else:
            return 'Good'

    df_cleaned['Sleep_Quality_Class'] = df_cleaned['Quality of Sleep'].apply(map_sleep_quality)

    print(f"[INFO] Data cleaning selesai. Ukuran akhir: {df_cleaned.shape}")
    print("[INFO] Distribusi Target 'Sleep_Quality_Class':")
    print(df_cleaned['Sleep_Quality_Class'].value_counts())

    return df_cleaned


def generate_eda_figures(df_cleaned: pd.DataFrame, output_dir: str):
    """Membuat visualisasi EDA: distribusi data dan korelasi antar fitur."""
    os.makedirs(output_dir, exist_ok=True)

    # Figure 1: Distribusi Target & Fitur Utama
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # A. Distribusi Target Kualitas Tidur (Kategori)
    target_counts = df_cleaned['Sleep_Quality_Class'].value_counts()
    colors = ['#4ade80', '#fbbf24', '#f87171']  # Hijau (Good), Kuning (Average), Merah (Poor)
    axes[0, 0].pie(target_counts, labels=target_counts.index, autopct='%1.1f%%',
                   startangle=140, colors=colors, explode=(0.03, 0.03, 0.05))
    axes[0, 0].set_title("Distribusi Kategori Kualitas Tidur (UI SleepWise)", fontsize=13, fontweight='bold')

    # B. Hubungan Durasi Tidur & Kualitas Tidur
    sns.boxplot(
        x='Sleep_Quality_Class', y='Sleep Duration', hue='Sleep_Quality_Class',
        data=df_cleaned, ax=axes[0, 1], palette=colors, order=['Poor', 'Average', 'Good'], legend=False
    )
    axes[0, 1].set_title("Durasi Tidur vs Kategori Kualitas Tidur", fontsize=13, fontweight='bold')
    axes[0, 1].set_xlabel("Kategori Kualitas Tidur")
    axes[0, 1].set_ylabel("Durasi Tidur (Jam)")

    # C. Tingkat Stres per Kategori Kualitas Tidur
    sns.barplot(
        x='Sleep_Quality_Class', y='Stress Level', hue='Sleep_Quality_Class',
        data=df_cleaned, ax=axes[1, 0], palette=colors, order=['Poor', 'Average', 'Good'],
        errorbar=None, legend=False
    )
    axes[1, 0].set_title("Rata-rata Tingkat Stres per Kategori", fontsize=13, fontweight='bold')
    axes[1, 0].set_xlabel("Kategori Kualitas Tidur")
    axes[1, 0].set_ylabel("Skor Stres (1-10)")

    # D. Aktivitas Fisik vs Detak Jantung
    sns.scatterplot(
        x='Physical Activity Level', y='Heart Rate', hue='Sleep_Quality_Class',
        data=df_cleaned, ax=axes[1, 1], palette={'Good': '#16a34a', 'Average': '#d97706', 'Poor': '#dc2626'}
    )
    axes[1, 1].set_title("Aktivitas Fisik vs Detak Jantung", fontsize=13, fontweight='bold')
    axes[1, 1].set_xlabel("Tingkat Aktivitas Fisik (Menit/Hari)")
    axes[1, 1].set_ylabel("Detak Jantung (BPM)")

    plt.tight_layout()
    dist_path = os.path.join(output_dir, "01_eda_distributions.png")
    plt.savefig(dist_path, dpi=300)
    plt.close()
    print(f"[INFO] Grafik EDA distribusi disimpan di: {dist_path}")

    # Figure 2: Matriks Korelasi Fitur Numerik
    plt.figure(figsize=(10, 8))
    numeric_cols = df_cleaned.select_dtypes(include=[np.number]).columns
    corr_matrix = df_cleaned[numeric_cols].corr()
    sns.heatmap(corr_matrix, annot=True, fmt=".2f", cmap='Blues', square=True, cbar_kws={'shrink': .8})
    plt.title("Matriks Korelasi Fitur Numerik Kualitas Tidur", fontsize=14, fontweight='bold', pad=15)
    plt.tight_layout()
    corr_path = os.path.join(output_dir, "01_eda_correlations.png")
    plt.savefig(corr_path, dpi=300)
    plt.close()
    print(f"[INFO] Grafik korelasi disimpan di: {corr_path}")


def build_preprocessor(categorical_features: list, numerical_features: list) -> ColumnTransformer:
    """Membangun ColumnTransformer dengan OneHotEncoder dan StandardScaler."""
    preprocessor = ColumnTransformer(
        transformers=[
            ('cat', OneHotEncoder(handle_unknown='ignore', sparse_output=False), categorical_features),
            ('num', StandardScaler(), numerical_features)
        ],
        remainder='drop'
    )
    return preprocessor


def run_pipeline(raw_csv_path: str, base_dir: str, drop_duplicates: bool = False):
    """Menjalankan keseluruhan alur data preparation dan preprocessing."""
    data_processed_dir = os.path.join(base_dir, "data", "processed")
    models_dir = os.path.join(base_dir, "models")
    figures_dir = os.path.join(base_dir, "reports", "figures")

    os.makedirs(data_processed_dir, exist_ok=True)
    os.makedirs(models_dir, exist_ok=True)
    os.makedirs(figures_dir, exist_ok=True)

    # 1. Muat & Bersihkan
    raw_df = load_raw_data(raw_csv_path)
    cleaned_df = clean_dataset(raw_df, drop_feature_duplicates=drop_duplicates)

    # Simpan dataset bersih
    cleaned_csv_path = os.path.join(data_processed_dir, "sleep_cleaned.csv")
    cleaned_df.to_csv(cleaned_csv_path, index=False)
    print(f"[INFO] Dataset bersih disimpan ke: {cleaned_csv_path}")

    # 2. Buat EDA Visualizations
    generate_eda_figures(cleaned_df, figures_dir)

    # 3. Fitur dan Target
    categorical_features = ['Gender', 'Occupation', 'BMI Category', 'Sleep Disorder']
    numerical_features = [
        'Age', 'Sleep Duration', 'Physical Activity Level', 'Stress Level',
        'Heart Rate', 'Daily Steps', 'Systolic_BP', 'Diastolic_BP'
    ]
    target_column = 'Sleep_Quality_Class'

    X = cleaned_df[categorical_features + numerical_features]
    y = cleaned_df[target_column]

    # 4. Train-Test Split (80% train, 20% test, stratified)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # 5. Fit Preprocessor
    preprocessor = build_preprocessor(categorical_features, numerical_features)
    preprocessor.fit(X_train)

    # Transformasi
    X_train_transformed = preprocessor.transform(X_train)
    X_test_transformed = preprocessor.transform(X_test)

    # Ambil nama fitur setelah one-hot encoding
    cat_feature_names = preprocessor.named_transformers_['cat'].get_feature_names_out(categorical_features).tolist()
    all_feature_names = cat_feature_names + numerical_features

    # Konversi ke DataFrame
    X_train_df = pd.DataFrame(X_train_transformed, columns=all_feature_names, index=X_train.index)
    X_test_df = pd.DataFrame(X_test_transformed, columns=all_feature_names, index=X_test.index)

    # Simpan hasil split siap latih
    X_train_df.to_csv(os.path.join(data_processed_dir, "X_train.csv"), index=False)
    X_test_df.to_csv(os.path.join(data_processed_dir, "X_test.csv"), index=False)
    y_train.to_csv(os.path.join(data_processed_dir, "y_train.csv"), index=False)
    y_test.to_csv(os.path.join(data_processed_dir, "y_test.csv"), index=False)

    # Simpan dataset split tanpa transformasi (untuk interpretasi Decision Tree)
    X_train.to_csv(os.path.join(data_processed_dir, "X_train_raw.csv"), index=False)
    X_test.to_csv(os.path.join(data_processed_dir, "X_test_raw.csv"), index=False)

    # 6. Simpan Preprocessor Artifact
    preprocessor_path = os.path.join(models_dir, "preprocessor.joblib")
    joblib.dump(preprocessor, preprocessor_path)
    print(f"[INFO] Preprocessor pipeline disimpan di: {preprocessor_path}")

    # Simpan juga metadata fitur untuk integrasi Flask
    feature_meta = {
        'categorical_features': categorical_features,
        'numerical_features': numerical_features,
        'all_feature_names': all_feature_names,
        'classes': ['Poor', 'Average', 'Good']
    }
    joblib.dump(feature_meta, os.path.join(models_dir, "feature_metadata.joblib"))

    print("\n[SUCCESS] Pipeline Preprocessing Berhasil Selesai!")


if __name__ == "__main__":
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    RAW_DATA_PATH = os.path.join(BASE_DIR, "data", "raw", "Sleep_health_and_lifestyle_dataset.csv")
    # drop_duplicates=False menjaga keutuhan 374 responden survei klinis
    run_pipeline(RAW_DATA_PATH, BASE_DIR, drop_duplicates=False)
