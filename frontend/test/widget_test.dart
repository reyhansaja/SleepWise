import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('dashboard SleepWise menampilkan ringkasan utama', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/main')),
    );

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
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/statistics')),
    );
    await tester.pumpAndSettle();

    expect(find.text('SleepWise'), findsOneWidget);
    expect(find.text('Statistik & Tren Tidur'), findsOneWidget);
  });

  testWidgets('toggle tema halaman statistik mengganti tampilannya', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/statistics')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    final colors = Theme.of(
      tester.element(find.text('Statistik & Tren Tidur')),
    ).colorScheme;
    final title = tester.widget<Text>(find.text('Statistik & Tren Tidur'));
    final distributionTitle = tester.widget<Text>(
      find.text('Distribusi Kualitas Tidur'),
    );

    expect(colors.brightness, Brightness.light);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(title.style?.color, colors.onSurface);
    expect(distributionTitle.style?.color, colors.onSurface);
  });

  testWidgets('route riwayat menampilkan arsip prediksi tidur', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/history')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Prediksi'), findsOneWidget);
    expect(find.text('Siklus REM Optimal (1.8 jam)'), findsOneWidget);
  });

  testWidgets('toggle tema halaman riwayat mengganti tema aplikasi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/history')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    final colors = Theme.of(
      tester.element(find.text('Riwayat Prediksi')),
    ).colorScheme;
    final title = tester.widget<Text>(find.text('Riwayat Prediksi'));
    final searchField = tester.widget<TextField>(find.byType(TextField));

    expect(colors.brightness, Brightness.light);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(title.style?.color, colors.onSurface);
    expect(searchField.style?.color, colors.onSurface);
    expect(searchField.decoration?.fillColor, colors.surface);
    expect(searchField.decoration?.enabledBorder?.borderSide, BorderSide.none);
    final summaryContainer = tester.widget<Container>(
      find
          .ancestor(of: find.text('34'), matching: find.byType(Container))
          .first,
    );
    expect((summaryContainer.decoration as BoxDecoration?)?.border, isNull);
  });

  testWidgets('logout mengembalikan pengguna ke halaman login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/profile')),
    );
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

  testWidgets('toggle tema halaman profil mengubah warna profil', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/profile')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    final colors = Theme.of(
      tester.element(find.text('Sarah Nabila')),
    ).colorScheme;
    final name = tester.widget<Text>(find.text('Sarah Nabila'));
    final stat = tester.widget<Text>(find.text('88'));

    expect(colors.brightness, Brightness.light);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(name.style?.color, colors.onSurface);
    expect(stat.style?.color, colors.onSurface);
  });

  testWidgets('toggle tema mengganti tema aplikasi', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SleepWiseApp()));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.light,
    );
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
  });

  testWidgets('toggle tema juga berfungsi di halaman daftar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/register')),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.light,
    );
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    final colors = Theme.of(
      tester.element(find.text('Buat Akun Baru')),
    ).colorScheme;
    final title = tester.widget<Text>(find.text('Buat Akun Baru'));
    final nameField = tester.widget<TextField>(find.byType(TextField).first);

    expect(title.style?.color, colors.onSurface);
    expect(nameField.style?.color, colors.onSurface);
    expect(nameField.decoration?.fillColor, const Color(0xFFF9FAFB));
  });

  testWidgets('dashboard menyesuaikan warna saat tema terang aktif', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SleepWiseApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    final dashboardContext = tester.element(
      find.text('Selamat Pagi, Sarah! ✨'),
    );
    final colors = Theme.of(dashboardContext).colorScheme;
    final greeting = tester.widget<Text>(find.text('Selamat Pagi, Sarah! ✨'));
    final sleepDuration = tester.widget<Text>(find.text('7.5'));

    expect(colors.brightness, Brightness.light);
    expect(greeting.style?.color, colors.onSurface);
    expect(sleepDuration.style?.color, colors.onSurface);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
      Brightness.light,
    );

    final navigation = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    final navigationColors = Theme.of(
      tester.element(find.byType(BottomNavigationBar)),
    ).colorScheme;
    expect(navigation.backgroundColor, navigationColors.surface);
    expect(navigation.selectedItemColor, navigationColors.primary);
    expect(navigation.unselectedItemColor, navigationColors.onSurfaceVariant);
  });

  testWidgets('tombol tema dashboard mengganti tema aplikasi', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/main')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Selamat Pagi, Sarah! ✨'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Selamat Pagi, Sarah! ✨'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('toggle tema halaman prediksi mengubah tampilan input', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: SleepWiseApp(initialRoute: '/main')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prediksi'));
    await tester.pump();

    expect(find.text('Prediksi Kualitas Tidur'), findsOneWidget);
    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Detak Jantung Istirahat'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    final colors = Theme.of(
      tester.element(find.text('Detak Jantung Istirahat')),
    ).colorScheme;
    final heartRate = tester.widget<Text>(find.text('Detak Jantung Istirahat'));

    expect(colors.brightness, Brightness.light);
    expect(heartRate.style?.color, colors.onSurface);
  });
}
