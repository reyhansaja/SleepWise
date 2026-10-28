# SleepWise

SleepWise adalah aplikasi pendamping kesehatan tidur yang dirancang untuk
membantu pengguna memahami kualitas istirahat, melihat pola tidur, dan
mendapatkan rekomendasi kebiasaan tidur yang lebih baik. Aplikasi ini
memanfaatkan konsep ritme sirkadian serta evaluasi berbasis beberapa faktor
gaya hidup dan kondisi tubuh.

Repository ini merupakan repository utama SleepWise. Untuk saat ini,
implementasi yang tersedia masih berupa **frontend Flutter** yang berada di
folder [`frontend/`](https://github.com/reyhansaja/SleepWise/tree/main/frontend). Folder backend belum
dibuat, sehingga dokumentasi ini menjelaskan kondisi aplikasi berdasarkan
frontend yang sudah tersedia saat ini. Setelah backend ditambahkan, README ini
dapat diperluas untuk menjelaskan API, database, autentikasi sebenarnya,
deployment, dan hubungan antara frontend dengan backend.

> **Status saat ini:** frontend/prototipe interaktif. Sebagian data, hasil
> prediksi, statistik, dan riwayat masih disediakan secara lokal di dalam
> aplikasi untuk keperluan demonstrasi dan pengembangan UI.

## Daftar Isi

- [Gambaran Umum](#gambaran-umum)
- [Tujuan Aplikasi](#tujuan-aplikasi)
- [Fitur Frontend Saat Ini](#fitur-frontend-saat-ini)
- [Alur Penggunaan](#alur-penggunaan)
- [Struktur Repository](#struktur-repository)
- [Arsitektur Frontend](#arsitektur-frontend)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Menjalankan Project](#menjalankan-project)
- [Pemeriksaan dan Testing](#pemeriksaan-dan-testing)
- [Batasan Implementasi Saat Ini](#batasan-implementasi-saat-ini)
- [Rencana Pengembangan](#rencana-pengembangan)
- [Dokumentasi Frontend](#dokumentasi-frontend)

## Gambaran Umum

SleepWise memiliki konsep sebagai aplikasi pemantauan dan evaluasi tidur
personal. Pengguna diarahkan untuk:

1. mengenali kondisi tidur dan ritme sirkadian;
2. memasukkan faktor-faktor yang dapat memengaruhi kualitas tidur;
3. memperoleh skor dan label kualitas tidur;
4. membaca rekomendasi yang relevan dengan input pengguna;
5. meninjau riwayat evaluasi;
6. melihat ringkasan statistik, tren, distribusi, dan insight tidur.

Antarmuka menggunakan pendekatan dashboard dengan navigasi utama di bagian
bawah layar. Aplikasi mendukung mode terang dan mode gelap agar nyaman
digunakan pada waktu pagi maupun malam.

## Tujuan Aplikasi

SleepWise dikembangkan untuk menjadi:

- **informatif**, dengan menyajikan ringkasan dan interpretasi data tidur;
- **personal**, dengan mempertimbangkan durasi tidur, stres, aktivitas,
  kafein, paparan layar, detak jantung, dan kategori BMI;
- **mudah digunakan**, melalui form input berbentuk kartu, slider, pilihan
  kategori, dan tampilan visual;
- **terukur**, dengan skor kualitas tidur dan riwayat hasil evaluasi;
- **siap dikembangkan**, karena struktur frontend sudah memisahkan UI, aturan
  bisnis, dan sumber data melalui Clean Architecture.

SleepWise bukan pengganti diagnosis atau konsultasi tenaga kesehatan. Hasil
evaluasi pada frontend saat ini hanya merupakan estimasi aplikasi dan tidak
boleh digunakan sebagai diagnosis medis.

## Fitur Frontend Saat Ini

### 1. Landing page dan pengenalan aplikasi

Saat aplikasi dibuka, pengguna melihat landing page yang berisi identitas
SleepWise, visual ritme sirkadian, penjelasan singkat, dan tombol untuk
melanjutkan ke halaman login. Landing page menggunakan tampilan visual
bernuansa malam dengan gradient dan elemen ilustrasi yang dibuat sebagai
widget Flutter.

### 2. Halaman login dan registrasi

Frontend menyediakan tampilan:

- login menggunakan email/akun kampus dan kata sandi;
- opsi mengingat akun;
- registrasi dengan nama lengkap, email, kata sandi, dan persetujuan
  ketentuan;
- tombol navigasi antara login, registrasi, dan halaman sebelumnya;
- toggle mode terang/gelap pada halaman autentikasi.

Pada tahap ini halaman tersebut masih merupakan **UI autentikasi**. Belum ada
layanan backend yang memvalidasi kredensial, membuat akun, menyimpan sesi,
atau menghubungkan akun dengan data pengguna.

### 3. Dashboard

Dashboard menjadi halaman utama setelah pengguna masuk ke area aplikasi.
Komponen yang ditampilkan antara lain:

- sapaan dan tanggal;
- ringkasan kualitas tidur;
- durasi evaluasi tidur;
- ringkasan metrik seperti skor, durasi, detak jantung, stres, dan waktu
  penggunaan layar;
- banner untuk menuju prediksi;
- bagian statistik;
- kartu rutinitas tidur;
- tips tidur harian;
- identitas pengguna dan kontrol tema.

Sebagian isi dashboard saat ini masih berupa data tampilan statis untuk
mensimulasikan pengalaman pengguna sebelum sumber data nyata tersedia.

### 4. Prediksi kualitas tidur

Halaman prediksi memungkinkan pengguna mengisi beberapa parameter:

- durasi tidur;
- tingkat aktivitas fisik;
- tingkat stres;
- jumlah konsumsi kafein;
- durasi penggunaan layar pada malam hari;
- detak jantung;
- kategori BMI.

Setelah tombol prediksi ditekan, frontend menjalankan use case
`PredictSleepQuality` melalui `LocalPredictionRepository`. Implementasi lokal
tersebut menggunakan aturan evaluasi berbasis skor:

- skor dimulai dari 100;
- durasi tidur kurang dari 7 jam mengurangi skor;
- tingkat stres di atas ambang tertentu mengurangi skor;
- konsumsi kafein lebih dari 2 porsi mengurangi skor;
- paparan layar malam lebih dari 60 menit mengurangi skor;
- detak jantung di atas 80 BPM mengurangi skor;
- skor dibatasi pada rentang 0 sampai 100.

Hasil evaluasi menghasilkan:

- skor numerik;
- label `Kualitas tidur baik`, `Kualitas tidur cukup`, atau `Perlu perhatian`;
- daftar rekomendasi yang sesuai dengan kondisi input.

Antarmuka juga menampilkan label model seperti Random Forest dan Decision Tree
sebagai bagian dari desain produk. Namun, implementasi repository lokal yang
tersedia saat ini masih berupa aturan deterministik di sisi perangkat, bukan
pemanggilan model machine learning atau API backend.

### 5. Riwayat prediksi

Halaman riwayat menyediakan:

- daftar catatan evaluasi tidur;
- kualitas tidur;
- durasi;
- skor;
- jumlah terbangun;
- detak jantung;
- catatan tambahan;
- pencarian berdasarkan tanggal, catatan, atau kualitas;
- filter riwayat, termasuk filter `Good Sleep`;
- ringkasan jumlah riwayat;
- tombol ekspor sebagai placeholder antarmuka.

Data riwayat saat ini dikembalikan oleh `LocalHistoryRepository` sebagai data
lokal contoh. Tombol ekspor belum menghasilkan berkas; aplikasi masih
menampilkan notifikasi bahwa fitur tersebut akan tersedia kemudian.

### 6. Statistik dan analisis tidur

Halaman statistik dirancang untuk menyajikan analisis tidur dalam beberapa
bagian:

- filter rentang waktu 7 hari, 30 hari, atau semua data;
- kartu ringkasan metrik;
- distribusi kualitas tidur;
- grafik tren durasi tidur mingguan;
- korelasi faktor tidur, seperti layar malam, stres, dan aktivitas fisik;
- kartu insight dan kesimpulan;
- aksi untuk menyiapkan laporan PDF;
- aksi berbagi laporan;
- rekomendasi atau aktivasi kebiasaan bedtime digital.

Komponen-komponen ini sudah tersedia sebagai UI dan widget terpisah.
Sebagian aksi seperti pembuatan PDF, berbagi, dan sinkronisasi data masih
berupa simulasi/notifikasi sampai layanan data dan integrasi platform
ditambahkan.

### 7. Profil dan preferensi

Halaman profil menyediakan area untuk:

- informasi pengguna;
- preferensi evaluasi;
- parameter acuan algoritma;
- kendali data sensor dan integrasi akun;
- pengaturan tema;
- opsi logout pada tingkat tampilan.

Integrasi sensor seperti detak jantung dan akselerometer masih berupa
representasi UI. Belum ada koneksi ke perangkat wearable, sensor perangkat,
atau layanan akun backend.

### 8. Mode terang dan mode gelap

Tema aplikasi dikelola menggunakan Riverpod melalui `themeModeProvider`.
Pengguna dapat mengganti tema dari beberapa halaman, termasuk landing/auth,
dashboard, prediksi, riwayat, statistik, dan profil. Warna, gradient, radius,
spacing, serta `ThemeData` terpusat di [`app_theme.dart`](https://github.com/reyhansaja/SleepWise/blob/main/frontend/lib/core/theme/app_theme.dart).

## Alur Penggunaan

Alur navigasi yang tersedia saat ini adalah:

```text
Landing
  -> Login
      -> Register (opsional)
      -> MainShell
          -> Dashboard
          -> Prediksi
          -> Riwayat
          -> Statistik
          -> Profil
```

Route utama didefinisikan di
[`app_routes.dart`](https://github.com/reyhansaja/SleepWise/blob/main/frontend/lib/core/navigation/app_routes.dart).
`MainShell` menggabungkan lima tab utama melalui bottom navigation:

| Tab | Tujuan |
|---|---|
| Dashboard | Ringkasan kondisi tidur dan rekomendasi harian |
| Prediksi | Mengisi faktor tidur dan mendapatkan evaluasi kualitas |
| Riwayat | Menelusuri catatan evaluasi yang tersedia |
| Statistik | Melihat tren, distribusi, korelasi, dan insight |
| Profil | Melihat preferensi dan pengaturan pengguna |

## Struktur Repository

```text
SleepWise/
├── README.md                 # Dokumentasi repository utama
├── frontend/                 # Aplikasi Flutter SleepWise
│   ├── README.md             # Dokumentasi khusus frontend
│   ├── lib/                  # Source code Dart
│   ├── test/                 # Unit test dan widget test
│   ├── android/              # Konfigurasi platform Android
│   ├── ios/                  # Konfigurasi platform iOS
│   ├── linux/                # Konfigurasi platform Linux
│   ├── macos/                # Konfigurasi platform macOS
│   ├── web/                  # Konfigurasi platform Web
│   └── windows/              # Konfigurasi platform Windows
└── (backend/)                # Belum tersedia; akan ditambahkan kemudian
```

Folder `build/` di dalam frontend berisi artefak hasil build Flutter dan
bukan source code aplikasi. Folder tersebut tidak perlu diedit secara manual.

## Arsitektur Frontend

Frontend menggunakan pendekatan **feature-based Clean Architecture**.
Struktur source code utamanya adalah:

```text
frontend/lib/
├── main.dart
├── core/
│   ├── navigation/
│   ├── theme/
│   └── widgets/
└── features/
    ├── landing/
    ├── auth/
    ├── home/
    ├── prediction/
    ├── history/
    ├── statistics/
    └── profile/
```

### `core`

Berisi komponen lintas fitur:

- definisi route dan navigasi;
- `MainShell` dan bottom navigation;
- theme terang/gelap;
- provider pengelola tema;
- widget reusable seperti logo dan section card.

Kode di `core` sebaiknya tetap bersifat umum dan tidak berisi aturan bisnis
khusus satu fitur.

### `features`

Setiap folder di dalam `features` mewakili kemampuan produk. Beberapa fitur
memiliki layer `data`, `domain`, dan `presentation`, sedangkan fitur yang
masih berfokus pada UI dapat memiliki layer `presentation` saja.

### `domain`

Berisi aturan bisnis dan kontrak yang tidak bergantung pada Flutter UI, seperti:

- entity `PredictionInput`, `PredictionResult`, dan `SleepRecord`;
- kontrak repository;
- use case `PredictSleepQuality` dan `GetSleepHistory`.

### `data`

Berisi implementasi sumber data. Saat ini terdapat repository lokal:

- `LocalPredictionRepository`;
- `LocalHistoryRepository`.

Repository ini sengaja dipisahkan dari domain agar nantinya dapat diganti
dengan repository berbasis REST API, database lokal, atau sumber data lain
tanpa mengubah aturan bisnis dan tampilan secara besar-besaran.

### `presentation`

Berisi page dan widget Flutter yang membentuk tampilan serta interaksi
pengguna, termasuk form prediksi, kartu statistik, halaman riwayat, dan
halaman profil.

### Arah dependency

```text
presentation -> domain
data         -> domain
core         -> komponen bersama
main.dart    -> composition root aplikasi
```

Layer `domain` tidak seharusnya mengimpor `package:flutter`, dan layer `data`
tidak seharusnya bergantung langsung pada `presentation`.

## Teknologi yang Digunakan

- **Flutter** untuk framework aplikasi multi-platform.
- **Dart SDK** dengan constraint `^3.12.2` pada `pubspec.yaml`.
- **flutter_riverpod** untuk state management dan pengelolaan tema.
- **Material Design** dan Material Icons untuk komponen UI.
- **flutter_lints** untuk pemeriksaan kualitas kode.
- **Clean Architecture** untuk pemisahan aturan bisnis, data, dan tampilan.

Dependency dan versi lengkap dapat dilihat pada
[`pubspec.yaml`](https://github.com/reyhansaja/SleepWise/blob/main/frontend/pubspec.yaml).

## Menjalankan Project

### Prasyarat

Pastikan sudah terpasang:

- Flutter SDK yang kompatibel dengan constraint Dart pada
  [`pubspec.yaml`](https://github.com/reyhansaja/SleepWise/blob/main/frontend/pubspec.yaml);
- Dart SDK yang disertakan oleh Flutter;
- perangkat atau emulator untuk target yang dipilih.

Periksa instalasi Flutter dengan:

```powershell
flutter doctor
```

### Menyiapkan dependency

Jalankan perintah dari folder `frontend`:

```powershell
cd frontend
flutter pub get
```

### Menjalankan aplikasi

Untuk menjalankan pada device yang terdeteksi:

```powershell
flutter run
```

Untuk melihat daftar device:

```powershell
flutter devices
```

Untuk menjalankan pada target tertentu, gunakan device ID yang ditampilkan:

```powershell
flutter run -d <device-id>
```

Contoh target yang dapat digunakan bergantung pada environment lokal:
Android emulator, Windows desktop, Chrome/Web, iOS simulator, atau macOS.

## Pemeriksaan dan Testing

Semua perintah berikut dijalankan dari folder `frontend`.

### Analisis kode

```powershell
flutter analyze
```

Perintah ini memeriksa error Dart, import yang rusak, masalah tipe, dan lint.

### Menjalankan seluruh test

```powershell
flutter test
```

Test yang tersedia saat ini mencakup:

- widget test aplikasi;
- test use case pengambilan riwayat tidur;
- test use case prediksi kualitas tidur;
- widget test landing page.

### Menjalankan test tertentu

```powershell
flutter test test/features/prediction/domain/predict_sleep_quality_test.dart
flutter test test/features/history/domain/get_sleep_history_test.dart
flutter test test/features/landing/presentation/pages/landing_page_test.dart
```

### Pemeriksaan struktur Clean Architecture

README frontend juga menyediakan pemeriksaan manual untuk memastikan:

- folder legacy tidak lagi berisi file lama;
- domain tidak bergantung pada Flutter, data, atau presentation;
- data tidak bergantung pada presentation.

Detail dan perintah pemeriksaannya tersedia di
[`frontend/README.md`](https://github.com/reyhansaja/SleepWise/tree/main/frontend#readme).

## Batasan Implementasi Saat Ini

Karena backend belum tersedia, beberapa bagian berikut belum merupakan
implementasi production:

1. Login dan registrasi belum terhubung ke layanan autentikasi.
2. Belum ada database pengguna atau database catatan tidur.
3. Prediksi masih dijalankan dengan aturan lokal deterministik.
4. Riwayat menggunakan data contoh yang ditulis di repository lokal.
5. Belum ada sinkronisasi antarperangkat atau sinkronisasi akun.
6. Tombol ekspor, pembuatan PDF, dan berbagi laporan masih berupa placeholder
   atau notifikasi UI.
7. Integrasi sensor detak jantung, akselerometer, dan wearable belum aktif.
8. Statistik belum mengambil data pengguna secara dinamis dari server.
9. Belum ada API, konfigurasi environment backend, logging server, atau
   deployment backend di repository ini.
10. Label machine learning pada tampilan belum berarti model ML sudah
    terhubung atau dijalankan di frontend.

Batasan ini perlu dipahami ketika menjalankan demo: data yang terlihat di
aplikasi bukan data kesehatan pengguna yang tersimpan secara persisten.

## Rencana Pengembangan

Ketika backend mulai dibuat, area berikut dapat ditambahkan secara bertahap:

1. **API dan autentikasi**
   - endpoint login, registrasi, refresh token, dan logout;
   - validasi kredensial;
   - pengelolaan profil dan sesi pengguna.
2. **Penyimpanan data**
   - penyimpanan catatan tidur;
   - penyimpanan input dan hasil prediksi;
   - penyimpanan preferensi serta konfigurasi pengguna.
3. **Layanan prediksi**
   - endpoint prediksi atau layanan model;
   - versioning model;
   - pencatatan input, hasil, dan waktu evaluasi.
4. **Statistik dinamis**
   - agregasi 7 hari, 30 hari, dan seluruh periode;
   - perhitungan tren dan korelasi dari data nyata;
   - insight yang dihasilkan berdasarkan data pengguna.
5. **Integrasi perangkat**
   - wearable atau sensor kesehatan;
   - detak jantung, aktivitas, dan data gerak;
   - izin perangkat dan penanganan privasi.
6. **Keamanan dan privasi**
   - perlindungan data kesehatan;
   - secure storage token;
   - kontrol akses dan audit;
   - kebijakan privasi serta penghapusan data.
7. **Integrasi frontend-backend**
   - mengganti repository lokal dengan implementasi API;
   - state loading, error, retry, dan offline;
   - cache lokal dan sinkronisasi.

Arsitektur repository saat ini sudah menyiapkan titik penggantian tersebut
melalui kontrak repository pada layer `domain`.

## Dokumentasi Frontend

Dokumentasi teknis yang lebih khusus untuk Flutter, struktur folder, fungsi
tiap layer, serta pemeriksaan Clean Architecture tersedia di
[`frontend/README.md`](https://github.com/reyhansaja/SleepWise/tree/main/frontend#readme).

README utama ini akan menjadi tempat dokumentasi lintas komponen setelah
backend ditambahkan, sedangkan README frontend tetap berfokus pada cara kerja
dan pengembangan aplikasi Flutter.
