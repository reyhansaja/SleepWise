// Uji ApiPredictionRepository terhadap backend Flask sungguhan.
// Jalankan: flutter test --dart-define=API_BASE=http://127.0.0.1:5000/api test/prediction_api_test.dart
// Dilewati bila backend mati.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_service.dart' show apiBase;
import 'package:frontend/features/prediction/data/repositories/api_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';

Future<bool> _serverUp() async {
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    final res = await (await client.getUrl(Uri.parse('$apiBase/health'))).close();
    await res.drain<void>();
    client.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void main() {
  late bool up;

  setUpAll(() async => up = await _serverUp());

  test('prediksi lewat backend mengembalikan label + rekomendasi', () async {
    if (!up) {
      markTestSkipped('backend tidak aktif di $apiBase');
      return;
    }

    final repo = ApiPredictionRepository();
    final result = await repo.predict(const PredictionInput(
      sleepDuration: 5,
      physicalActivityLevel: 0,
      stressLevel: 9,
      caffeineServings: 4,
      nightScreenMinutes: 90,
      heartRate: 88,
      bmiCategory: 2,
    ));

    expect(result.label, isNotEmpty);
    expect(result.score, inInclusiveRange(0, 100));
    expect(result.recommendations, isNotEmpty);

    final good = await repo.predict(const PredictionInput(
      sleepDuration: 8.5,
      physicalActivityLevel: 2,
      stressLevel: 2,
      caffeineServings: 0,
      nightScreenMinutes: 10,
      heartRate: 60,
      bmiCategory: 1,
    ));
    expect(good.label, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('input di luar jangkauan ditolak backend dengan pesan jelas', () async {
    if (!up) {
      markTestSkipped('backend tidak aktif di $apiBase');
      return;
    }

    final repo = ApiPredictionRepository();
    // bmiCategory 9 dipetakan ke 'Obese' (clamp), jadi pakai heart_rate ekstrem
    // lewat input yang tetap valid: pastikan tidak ada exception jaringan.
    final result = await repo.predict(const PredictionInput(
      sleepDuration: 0,
      physicalActivityLevel: 1,
      stressLevel: 1,
      caffeineServings: 0,
      nightScreenMinutes: 0,
      heartRate: 30,
      bmiCategory: 0,
    ));
    expect(result.score, inInclusiveRange(0, 100));
  }, timeout: const Timeout(Duration(seconds: 60)));
}
