import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/domain/entities/sleep_record.dart';

void main() {
  test('parses backend prediction row into SleepRecord', () {
    final record = SleepRecord.fromJson({
      'id': 7,
      'sleep_duration': '7.50',
      'predicted_quality': 'Good',
      'confidence': '0.9240',
      'model_name': 'Random Forest',
      'stress_level': 3,
      'heart_rate': 64,
      'created_at': '2026-05-24 07:15:00',
    });

    expect(record.id, 7);
    expect(record.quality, 'Good');
    expect(record.duration, 7.5);
    expect(record.score, 92);
    expect(record.modelName, 'Random Forest');
    expect(record.stressLevel, 3);
    expect(record.heartRate, 64);
    expect(record.date, '24 Mei 2026 • 07:15');
  });
}
