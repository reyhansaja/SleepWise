import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/prediction/data/repositories/remote_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _input = PredictionInput(
  gender: 'Female',
  age: 34,
  occupation: 'Nurse',
  sleepDuration: 6.5,
  physicalActivityLevel: 45,
  stressLevel: 7,
  bmiCategory: 'Overweight',
  heartRate: 82,
  dailySteps: 6500,
  systolicBp: 125,
  diastolicBp: 82,
);

void main() {
  test('mengirim field dataset dan menerjemahkan label model', () async {
    late Map<String, dynamic> sent;
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://127.0.0.1:5000/api/predictions');
      sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'status': 'success',
          'model': 'Random Forest',
          'prediction': 'Poor',
          'model_prediction': 'Average',
          'confidence': 0.62,
          'probabilities': {'Average': 0.62, 'Good': 0.35, 'Poor': 0.03},
          'out_of_range': ['sleep_duration = 3 di luar rentang data latih 5.8–8.5; prediksi kurang dapat dipercaya.'],
          'guardrail': {'applied': true, 'reasons': ['Durasi tidur 3.0 jam < 5 jam']},
          'recommendations': [
            {'category': 'ringkasan', 'message': 'Tingkatkan durasi tidur.'},
          ],
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final result = await RemotePredictionRepository(client: client).predict(_input);

    expect(sent, {
      'gender': 'Female',
      'age': 34,
      'occupation': 'Nurse',
      'sleep_duration': 6.5,
      'physical_activity_level': 45,
      'stress_level': 7,
      'bmi_category': 'Overweight',
      'heart_rate': 82,
      'daily_steps': 6500,
      'systolic_bp': 125,
      'diastolic_bp': 82,
    });
    expect(result.label, 'Perlu perhatian');
    expect(result.modelLabel, 'Kualitas tidur cukup');
    expect(result.guardrailApplied, isTrue);
    expect(result.confidencePercent, 62);
    expect(result.modelName, 'Random Forest');
    expect(result.outOfRange, hasLength(1));
    expect(result.outOfRange.single, contains('di luar rentang data latih'));
    expect(result.recommendations, ['Tingkatkan durasi tidur.']);
  });

  test('validasi backend (400) menjadi PredictionException berisi details', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({
            'status': 'error',
            'error': 'validasi gagal',
            'details': ['Field \'daily_steps\' wajib diisi.'],
          }),
          400,
        ));

    expect(
      () => RemotePredictionRepository(client: client).predict(_input),
      throwsA(isA<PredictionException>().having(
        (e) => e.message,
        'message',
        contains('daily_steps'),
      )),
    );
  });
}
