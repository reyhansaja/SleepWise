import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/domain/entities/sleep_record.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';

SleepRecord _record({
  required String quality,
  required double duration,
  required int stress,
  required int heartRate,
  required int score,
  required DateTime at,
}) =>
    SleepRecord(
      id: 1,
      date: '',
      quality: quality,
      modelName: 'Decision Tree',
      userNama: 'Tester',
      duration: duration,
      score: score,
      stressLevel: stress,
      heartRate: heartRate,
      createdAt: at,
    );

void main() {
  test('SleepStats menghitung agregat dan distribusi dari riwayat', () {
    final now = DateTime.now();
    final stats = SleepStats.fromRecords([
      _record(quality: 'Good', duration: 8, stress: 2, heartRate: 60, score: 90, at: now),
      _record(quality: 'Good', duration: 7, stress: 3, heartRate: 65, score: 80, at: now),
      _record(quality: 'Poor', duration: 5, stress: 9, heartRate: 85, score: 40, at: now),
    ]);

    expect(stats.total, 3);
    expect(stats.avgDuration, closeTo(6.667, 0.01));
    expect(stats.avgStress, closeTo(4.667, 0.01));
    expect(stats.avgConfidence, closeTo(70, 0.01));
    expect(stats.goodPercent, closeTo(2 / 3, 0.001));
    expect(stats.poorPercent, closeTo(1 / 3, 0.001));
    expect(stats.dominantModel, 'Decision Tree');
    // Stres naik -> skor turun: korelasi negatif.
    expect(stats.corrStress, lessThan(0));
    // Durasi naik -> skor naik: korelasi positif.
    expect(stats.corrDuration, greaterThan(0));
    expect(stats.weekly, hasLength(7));
  });

  test('SleepStats kosong saat tidak ada riwayat', () {
    final stats = SleepStats.fromRecords([]);
    expect(stats.total, 0);
    expect(stats.weekly, isEmpty);
    expect(stats.avgDuration, 0);
  });
}
