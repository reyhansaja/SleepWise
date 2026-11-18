import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/prediction/data/repositories/remote_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';
import 'package:http/http.dart' as http;

/// Uji integrasi ke backend sungguhan: dilewati (bukan gagal) bila server mati.
///
/// Jalankan backend dulu: `cd backend && ../.venv/Scripts/python.exe app.py`.
void main() {
  test('POST /api/predictions mengembalikan kelas + probabilitas model', () async {
    final base = apiBaseUrl();
    http.Response health;
    try {
      health = await http
          .get(Uri.parse('${base.replaceAll(RegExp(r'/+$'), '')}/health'))
          .timeout(const Duration(seconds: 3));
    } catch (error) {
      markTestSkipped('backend tidak berjalan di $base ($error)');
      return;
    }
    if (health.statusCode != 200) {
      markTestSkipped('backend tidak sehat (HTTP ${health.statusCode})');
      return;
    }

    const input = PredictionInput(
      gender: 'Male',
      age: 45,
      occupation: 'Engineer',
      sleepDuration: 7.5,
      physicalActivityLevel: 60,
      stressLevel: 2,
      bmiCategory: 'Normal',
      heartRate: 65,
      dailySteps: 9000,
      systolicBp: 120,
      diastolicBp: 80,
    );

    final result = await RemotePredictionRepository().predict(input);

    expect(result.label, isIn(['Kualitas tidur baik', 'Kualitas tidur cukup', 'Perlu perhatian']));
    expect(result.modelName, isNotEmpty);
    expect(result.confidence, inInclusiveRange(0.0, 1.0));
    expect(result.probabilities.values.reduce((a, b) => a + b), closeTo(1.0, 0.01));
    expect(result.recommendations, isNotEmpty);
  });
}
