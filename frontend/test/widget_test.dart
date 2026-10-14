import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('dashboard SleepWise menampilkan ringkasan utama', (
    tester,
  ) async {
    await tester.pumpWidget(const SleepWiseApp(initialRoute: '/main'));

    expect(find.text('SleepWise'), findsOneWidget);
    expect(find.text('Selamat Pagi, Sarah! ✨'), findsOneWidget);
    expect(find.text('7.5'), findsOneWidget);
    expect(find.text('Ringkasan Statistik'), findsOneWidget);
    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Prediksi'), findsOneWidget);
  });

  testWidgets('navigasi tab statistik menampilkan analisis sirkadian', (
    tester,
  ) async {
    await tester.pumpWidget(const SleepWiseApp(initialRoute: '/statistics'));
    await tester.pumpAndSettle();

    expect(find.text('SleepWise'), findsOneWidget);
    expect(find.text('Statistik & Tren Tidur'), findsOneWidget);
  });

  testWidgets('route riwayat menampilkan arsip prediksi tidur', (tester) async {
    await tester.pumpWidget(const SleepWiseApp(initialRoute: '/history'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Prediksi'), findsOneWidget);
    expect(find.text('Siklus REM Optimal (1.8 jam)'), findsOneWidget);
  });

  testWidgets('logout mengembalikan pengguna ke halaman login', (tester) async {
    await tester.pumpWidget(const SleepWiseApp(initialRoute: '/profile'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Keluar dari Akun'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Keluar dari Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang Kembali'), findsOneWidget);
  });
}
