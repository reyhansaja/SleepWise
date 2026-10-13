import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('dashboard SleepWise menampilkan ringkasan utama', (
    tester,
  ) async {
    await tester.pumpWidget(const SleepWiseApp());

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
}
