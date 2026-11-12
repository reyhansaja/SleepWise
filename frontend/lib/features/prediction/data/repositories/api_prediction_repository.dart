import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../auth/data/auth_service.dart';
import '../../domain/entities/prediction_input.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/prediction_repository.dart';

/// Label kualitas dari backend (Good/Average/Poor) -> teks Indonesia.
const _labels = {
  'Good': 'Kualitas tidur baik',
  'Average': 'Kualitas tidur cukup',
  'Poor': 'Perlu perhatian',
};

class ApiPredictionRepository implements PredictionRepository {
  ApiPredictionRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// ponytail: form belum mengumpulkan gender/usia/langkah/tekanan darah, jadi
  /// dipakai nilai wajar. Tambah field ke PredictionInput + widget saat form
  /// memang perlu data itu (akurasi model ikut naik).
  static const _defaults = {
    'gender': 'Male',
    'age': 30,
    'occupation': 'Other',
    'daily_steps': 8000,
    'systolic_bp': 120,
    'diastolic_bp': 80,
    'sleep_disorder': 'None',
  };

  static const _bmi = ['Underweight', 'Normal', 'Overweight', 'Obese'];
  // Indeks widget aktivitas fisik -> menit/hari (skema dataset).
  static const _activityMinutes = [20, 45, 90];

  Map<String, dynamic> payload(PredictionInput input) => {
        ..._defaults,
        'sleep_duration': input.sleepDuration,
        'physical_activity_level': _activityMinutes[input.physicalActivityLevel.clamp(0, 2)],
        'stress_level': input.stressLevel.round().clamp(1, 10),
        'heart_rate': input.heartRate,
        'bmi_category': _bmi[input.bmiCategory.clamp(0, 3)],
      };

  @override
  Future<PredictionResult> predict(PredictionInput input, {String? token}) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$apiBase/predictions'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload(input)),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw PredictionException('Tidak bisa menghubungi server ($apiBase).\n$e');
    }

    final data = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 && res.statusCode != 201) {
      final details = (data['details'] as List?)?.join(', ');
      throw PredictionException(
        details ?? (data['error'] as String?) ?? 'Prediksi gagal (${res.statusCode}).',
      );
    }

    final quality = data['prediction'] as String? ?? 'Average';
    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0;

    return PredictionResult(
      score: (confidence * 100).round(),
      label: _labels[quality] ?? quality,
      recommendations: [
        for (final item in (data['recommendations'] as List? ?? const []))
          if (item is Map && item['message'] != null) item['message'] as String,
      ],
    );
  }
}

final predictionRepositoryProvider =
    Provider<PredictionRepository>((ref) => ApiPredictionRepository());

class PredictionException implements Exception {
  PredictionException(this.message);
  final String message;

  @override
  String toString() => message;
}
