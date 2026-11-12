import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';
import 'package:frontend/features/statistics/presentation/widgets/weekly_trend_chart_card.dart';

void main() {
  testWidgets('chart tidak overflow walau durasi ekstrem (>10 jam)', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final data = [
      for (var i = 0; i < 7; i++)
        DaySleepData.of('Hari $i', 'H$i', i.isEven ? 20.0 : 0.0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrendChartCard(weekData: data),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Tren Durasi Mingguan'), findsOneWidget);
  });
}
