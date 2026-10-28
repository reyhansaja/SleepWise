# Dokumentasi Fitur & Preprocessing Dataset (SleepWise ML)

**Branch Git Terkait:** `feature/01-data-preprocessing`  
**Dataset Asal:** `Sleep_health_and_lifestyle_dataset.csv`  
**Ukuran Dataset:** 374 Baris, 13 Kolom Mentah $\rightarrow$ 14 Kolom Bersih  

---

## 1. Latar Belakang & Keselarasan dengan Antarmuka Aplikasi (SleepWise)

Pada antarmuka aplikasi Flutter **SleepWise**:
* Layar **Statistik & Tren Tidur** menampilkan pembagian distribusi kualitas tidur menjadi 3 segmen:
  1. **Good (Optimal)**: Representasi kualitas istirahat tinggi (> 7.0 jam istirahat).
  2. **Average (Cukup)**: Rentang istirahat moderat (6.0 - 6.9 jam).
  3. **Poor (Kurang)**: Kualitas istirahat rendah / defisit (< 6.0 jam).
* Layar **Riwayat Prediksi** menampilkan badge status: `Good Sleep`, `Average Sleep`, dan `Poor Sleep`, serta nilai akurasi rerata model (92.4%).

Untuk menyelaraskan output model Machine Learning dengan kebutuhan tampilan aplikasi, target prediksi dikelompokkan ke dalam 3 kelas (`Sleep_Quality_Class`) sekaligus mempertahankan nilai skor mentah (`Quality of Sleep`, skala 1–10).

---

## 2. Definisi Fitur Input

Berikut adalah daftar seluruh fitur yang digunakan dalam pelatihan model:

| No | Nama Fitur Asli | Nama Fitur Bersih | Tipe Data | Kategori | Deskripsi & Satuan | Nilai / Rentang Nilai |
|:---|:---|:---|:---|:---|:---|:---|
| 1 | `Gender` | `Gender` | Kategorikal | Demografi | Jenis kelamin responden | `Male`, `Female` |
| 2 | `Age` | `Age` | Numerik | Demografi | Usia responden dalam tahun | 27 – 59 Tahun |
| 3 | `Occupation` | `Occupation` | Kategorikal | Profil Profesi | Jenis pekerjaan / profesi | `Doctor`, `Nurse`, `Engineer`, `Lawyer`, `Teacher`, `Accountant`, `Salesperson`, dll. |
| 4 | `Sleep Duration` | `Sleep Duration` | Numerik | Sirkadian | Total durasi tidur harian (Jam) | 5.8 – 8.5 Jam |
| 5 | `Physical Activity Level` | `Physical Activity Level` | Numerik | Gaya Hidup | Tingkat aktivitas fisik harian (Menit/hari) | 30 – 90 Menit |
| 6 | `Stress Level` | `Stress Level` | Numerik | Psikologis | Indeks stres subjektif | Skala 1 – 10 (1 = Rendah, 10 = Tinggi) |
| 7 | `BMI Category` | `BMI Category` | Kategorikal | Kesehatan | Kategori indeks massa tubuh | `Normal`, `Overweight`, `Obese` |
| 8 | `Blood Pressure` | `Systolic_BP` | Numerik | Klinis | Tekanan darah sistolik (mmHg) | 115 – 142 mmHg |
| 9 | `Blood Pressure` | `Diastolic_BP` | Numerik | Klinis | Tekanan darah diastolik (mmHg) | 75 – 95 mmHg |
| 10 | `Heart Rate` | `Heart Rate` | Numerik | Sensor/Klinis | Detak jantung saat istirahat (BPM) | 65 – 86 BPM |
| 11 | `Daily Steps` | `Daily Steps` | Numerik | Gaya Hidup | Jumlah langkah kaki harian | 3,000 – 10,000 Langkah |
| 12 | `Sleep Disorder` | `Sleep Disorder` | Kategorikal | Riwayat Medis | Diagnosis gangguan tidur | `None` (Normal), `Sleep Apnea`, `Insomnia` |

---

## 3. Fitur Target Prediksi

* **Nama Fitur Asli:** `Quality of Sleep` (Skor numerik 4 – 9 pada dataset).
* **Nama Fitur Target Klasifikasi:** `Sleep_Quality_Class`
* **Logika Pemetaan (Threshold Rule):**
  * $\le 5 \rightarrow$ **`Poor`** (Kualitas buruk / defisit istirahat)
  * $= 6 \rightarrow$ **`Average`** (Kualitas cukup / moderat)
  * $\ge 7 \rightarrow$ **`Good`** (Kualitas optimal / prima)
* **Distribusi Kelas Target:**
  * `Good`: 257 sampel (68.7%)
  * `Average`: 105 sampel (28.1%)
  * `Poor`: 12 sampel (3.2%)

---

## 4. Tahapan Data Preprocessing

1. **Penanganan Missing Values:**
   * Kolom `Sleep Disorder` memiliki 219 baris kosong (`NaN`). Dalam konteks medis survei ini, `NaN` merepresentasikan responden sehat tanpa gangguan tidur. Nilai ini diimputasi dengan string `"None"`.
2. **Standarisasi Kategori Kardinal:**
   * Kategori `'Normal Weight'` pada `BMI Category` memiliki makna klinis yang identik dengan `'Normal'`. Dilakukan penyatuan menjadi `'Normal'`.
3. **Pemisahan Fitur Majemuk (*Feature Splitting*):**
   * Kolom `Blood Pressure` berformat string (`"126/83"`) dipisahkan menjadi dua fitur numerik terpisah: `Systolic_BP` dan `Diastolic_BP` bertipe *integer*.
4. **Penanganan Duplikasi Data:**
   * Diperiksa integritas `Person ID` (tidak ada ID ganda).
   * Nilai kombinasi fitur yang identik antar responden tetap dipertahankan guna merefleksikan frekuensi riil profil kesehatan pada populasi penelitian.
5. **Encoding Data Kategorikal & Scaling:**
   * Fitur kategorikal (`Gender`, `Occupation`, `BMI Category`, `Sleep Disorder`) di-encode menggunakan **One-Hot Encoding** (`handle_unknown='ignore'`).
   * Fitur numerik distandarisasi menggunakan **StandardScaler** untuk mencegah bias skala numerik besar (seperti `Daily Steps` vs `Sleep Duration`).
   * Seluruh pipeline transformasi dibungkus dalam `ColumnTransformer` dan disimpan sebagai artifact `models/preprocessor.joblib`.
6. **Strategi Pembagian Data (*Train-Test Split*):**
   * Rasio: 80% Data Latih (299 sampel), 20% Data Uji (75 sampel).
   * Metode: `stratify=y` dengan `random_state=42` untuk menjamin proporsi kelas minoritas (`Poor`) tetap seimbang di data uji.
