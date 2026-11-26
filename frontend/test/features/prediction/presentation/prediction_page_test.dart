import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/prediction/data/repositories/remote_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_result.dart';
import 'package:frontend/features/prediction/domain/repositories/prediction_repository.dart';
import 'package:frontend/features/prediction/presentation/pages/prediction_page.dart';

class _FakeRepository implements PredictionRepository {
  _FakeRepository({this.error});
  final String? error;
  PredictionInput? received;

  @override
  Future<PredictionResult> predict(PredictionInput input, {String? token}) async {
    received = input;
    if (error != null) throw PredictionException(error!);
    return const PredictionResult(
      label: 'Kualitas tidur baik',
      confidence: 0.91,
      probabilities: {'Average': 0.05, 'Good': 0.91, 'Poor': 0.04},
      recommendations: ['Pertahankan jadwal tidur.'],
      modelName: 'Random Forest',
      outOfRange: ['heart_rate = 62 di luar rentang data latih 65–86; prediksi kurang dapat dipercaya.'],
    );
  }
}

Future<void> _pumpPage(WidgetTester tester, PredictionRepository repo) async {
  tester.view.physicalSize = const Size(1000, 3600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [predictionRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: PredictionPage()),
    ),
  );
  await tester.pump();
}

Future<void> _tapPredict(WidgetTester tester) async {
  final cta = find.text('Prediksi Kualitas Tidur Sekarang');
  await tester.dragUntilVisible(
    cta,
    find.byType(CustomScrollView),
    const Offset(0, -300),
  );
  await tester.pump();
  await tester.tap(cta);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('hasil model tampil di kartu hasil, bukan SnackBar', (tester) async {
    final repo = _FakeRepository();
    await _pumpPage(tester, repo);
    await _tapPredict(tester);

    expect(find.text('Kualitas tidur baik'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    expect(find.text('Pertahankan jadwal tidur.'), findsOneWidget);
    expect(find.textContaining('Model: Random Forest'), findsOneWidget);
    expect(find.text('Input di luar rentang data latih'), findsOneWidget);
    expect(find.textContaining('heart_rate = 62'), findsOneWidget);
    expect(repo.received?.bmiCategory, 'Normal');
    expect(repo.received?.physicalActivityLevel, 45);
  });

  testWidgets('error backend tampil sebagai kotak merah di halaman', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(error: 'Tidak bisa menghubungi server (http://127.0.0.1:5000/api).'),
    );
    await _tapPredict(tester);

    expect(find.textContaining('Tidak bisa menghubungi server'), findsOneWidget);
  });
}
