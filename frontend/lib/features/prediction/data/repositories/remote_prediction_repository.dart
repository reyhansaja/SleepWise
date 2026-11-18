import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/prediction_input.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/prediction_repository.dart';

/// Base URL API: override dengan `--dart-define=API_BASE=http://host:5000/api`.
/// Default 127.0.0.1 berlaku juga di HP lewat `adb reverse tcp:5000 tcp:5000`.
String apiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE');
  return fromEnv.isNotEmpty ? fromEnv : 'http://127.0.0.1:5000/api';
}

/// Kelas model backend -> bahasa aplikasi.
const _labelTable = {
  'Good': 'Kualitas tidur baik',
  'Average': 'Kualitas tidur cukup',
  'Poor': 'Perlu perhatian',
};

class PredictionException implements Exception {
  final String message;
  const PredictionException(this.message);

  @override
  String toString() => message;
}

/// Repositori inferensi nyata: POST /api/predictions ke backend Flask.
class RemotePredictionRepository implements PredictionRepository {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  RemotePredictionRepository({
    http.Client? client,
    String? baseUrl,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? apiBaseUrl()).replaceAll(RegExp(r'/+$'), ''),
        _timeout = timeout ?? const Duration(seconds: 10);

  /// Nama field harus sama dengan yang divalidasi backend/services/prediction_service.py.
  static Map<String, dynamic> payload(PredictionInput input) => {
        'gender': input.gender,
        'age': input.age,
        'occupation': input.occupation,
        'sleep_duration': input.sleepDuration,
        'physical_activity_level': input.physicalActivityLevel,
        'stress_level': input.stressLevel,
        'bmi_category': input.bmiCategory,
        'heart_rate': input.heartRate,
        'daily_steps': input.dailySteps,
        'systolic_bp': input.systolicBp,
        'diastolic_bp': input.diastolicBp,
      };

  @override
  Future<PredictionResult> predict(PredictionInput input) async {
    final uri = Uri.parse('$_baseUrl/predictions');
    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload(input)),
          )
          .timeout(_timeout);
    } catch (error) {
      // Di HP, 127.0.0.1 baru sampai ke laptop lewat `adb reverse`; tunnel itu
      // hilang setiap kabel dicabut, jadi pesannya dibuat bisa ditindaklanjuti.
      final hint = _baseUrl.contains('127.0.0.1') || _baseUrl.contains('localhost')
          ? '\nPastikan backend jalan, dan untuk HP jalankan: adb reverse tcp:5000 tcp:5000'
          : '';
      throw PredictionException('Tidak bisa menghubungi server ($_baseUrl).\n$error$hint');
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw PredictionException('Respons server tidak valid (HTTP ${response.statusCode}).');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final details = (body['details'] as List?)?.whereType<String>().join(' ');
      final error = (body['error'] as String?) ?? 'permintaan ditolak server';
      throw PredictionException(
        details == null || details.isEmpty ? error : '$error: $details',
      );
    }

    final rawLabel = (body['prediction'] as String?) ?? '';
    final rawModelLabel = body['model_prediction'] as String?;
    final probabilities = ((body['probabilities'] as Map?) ?? const {}).map(
      (key, value) => MapEntry('$key', (value as num?)?.toDouble() ?? 0.0),
    );
    final recommendations = ((body['recommendations'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => '${item['message'] ?? ''}')
        .where((text) => text.isNotEmpty)
        .toList();

    return PredictionResult(
      label: _labelTable[rawLabel] ?? rawLabel,
      confidence: (body['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: probabilities,
      recommendations: recommendations,
      modelName: (body['model'] as String?) ?? 'Model',
      modelLabel: rawModelLabel == null ? null : (_labelTable[rawModelLabel] ?? rawModelLabel),
      outOfRange: ((body['out_of_range'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

/// Halaman membaca provider ini (bukan membuat repositori sendiri) agar bisa
/// di-override fake pada widget test.
final predictionRepositoryProvider = Provider<PredictionRepository>(
  (ref) => RemotePredictionRepository(),
);
