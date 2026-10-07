import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('SleepWise app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SleepWiseApp());

    expect(find.text('SleepWise'), findsOneWidget);
    expect(find.text('Prediksi Kualitas Tidur'), findsOneWidget);
  });
}
