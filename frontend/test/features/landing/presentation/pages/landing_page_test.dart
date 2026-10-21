import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('landing page tampil saat aplikasi baru dibuka', (tester) async {
    // Jalankan aplikasi dengan route bawaan (initialRoute)
    await tester.pumpWidget(const SleepWiseApp());
    await tester.pumpAndSettle();

    // Verifikasi branding dan header
    expect(find.text('SleepWise'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('HEALTH'), findsOneWidget);

    // Verifikasi tag dan konten utama
    expect(find.text('Analisis Cerdas Sirkadian'), findsOneWidget);
    expect(find.text('Tidur Optimal,'), findsOneWidget);
    expect(find.text('Bangun Berenergi'), findsOneWidget);
    expect(
      find.text(
        'Pahami ritme sirkadian dan optimalkan kualitas istirahat harian Anda dengan analisis cerdas Machine Learning.',
      ),
      findsOneWidget,
    );

    // Verifikasi tombol lanjut dan footer
    expect(find.text('Lanjut'), findsOneWidget);
    expect(
      find.text('© 2026 SleepWise • On-Device AI Sleep Assistant'),
      findsOneWidget,
    );
  });

  testWidgets('menekan tombol Lanjut mengarahkan ke halaman login', (
    tester,
  ) async {
    await tester.pumpWidget(const SleepWiseApp());
    await tester.pumpAndSettle();

    final lanjutButton = find.text('Lanjut');
    expect(lanjutButton, findsOneWidget);

    // Pastikan tombol terlihat dan lakukan klik
    await tester.ensureVisible(lanjutButton);
    await tester.pumpAndSettle();
    await tester.tap(lanjutButton);
    await tester.pumpAndSettle();

    // Verifikasi masuk ke halaman login
    expect(find.text('Selamat Datang Kembali'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
