import 'dart:math' as math;

import 'package:frontend/features/history/domain/entities/sleep_record.dart';

class DaySleepData {
  final String dayName;
  final String dayShort;
  final double duration;
  final bool isOptimal;
  final bool isWarning;

  const DaySleepData({
    required this.dayName,
    required this.dayShort,
    required this.duration,
    this.isOptimal = false,
    this.isWarning = false,
  });

  static DaySleepData of(String dayName, String dayShort, double duration) =>
      DaySleepData(
        dayName: dayName,
        dayShort: dayShort,
        duration: duration,
        isOptimal: duration >= 7.0 && duration <= 8.5,
        isWarning: duration > 0 && duration < 6.0,
      );
}

/// Agregat riwayat prediksi untuk halaman statistik.
class SleepStats {
  final int total;
  final double avgDuration;
  final double avgStress;
  final double avgConfidence; // 0-100
  final double avgHeartRate;
  final double goodPercent;
  final double averagePercent;
  final double poorPercent;
  final String dominantModel;
  final List<DaySleepData> weekly;

  /// Korelasi Pearson (nilai -1..1) antara faktor dan skor kualitas.
  final double corrStress;
  final double corrHeartRate;
  final double corrDuration;

  const SleepStats({
    required this.total,
    required this.avgDuration,
    required this.avgStress,
    required this.avgConfidence,
    required this.avgHeartRate,
    required this.goodPercent,
    required this.averagePercent,
    required this.poorPercent,
    required this.dominantModel,
    required this.weekly,
    required this.corrStress,
    required this.corrHeartRate,
    required this.corrDuration,
  });

  static const empty = SleepStats(
    total: 0,
    avgDuration: 0,
    avgStress: 0,
    avgConfidence: 0,
    avgHeartRate: 0,
    goodPercent: 0,
    averagePercent: 0,
    poorPercent: 0,
    dominantModel: '-',
    weekly: [],
    corrStress: 0,
    corrHeartRate: 0,
    corrDuration: 0,
  );

  factory SleepStats.fromRecords(List<SleepRecord> records) {
    if (records.isEmpty) return empty;

    double avg(Iterable<double> values) =>
        values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

    final total = records.length;
    final good = records.where((r) => r.quality == 'Good').length;
    final average = records.where((r) => r.quality == 'Average').length;
    final poor = records.where((r) => r.quality == 'Poor').length;

    final modelCount = <String, int>{};
    for (final r in records) {
      modelCount[r.modelName] = (modelCount[r.modelName] ?? 0) + 1;
    }
    final dominant = modelCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final scores = records.map((r) => r.score.toDouble()).toList();

    return SleepStats(
      total: total,
      avgDuration: avg(records.map((r) => r.duration)),
      avgStress: avg(records.map((r) => r.stressLevel.toDouble())),
      avgConfidence: avg(scores),
      avgHeartRate: avg(records.map((r) => r.heartRate.toDouble())),
      goodPercent: good / total,
      averagePercent: average / total,
      poorPercent: poor / total,
      dominantModel: dominant,
      weekly: _weekly(records),
      corrStress: _pearson(records.map((r) => r.stressLevel.toDouble()), scores),
      corrHeartRate: _pearson(records.map((r) => r.heartRate.toDouble()), scores),
      corrDuration: _pearson(records.map((r) => r.duration), scores),
    );
  }

  static List<DaySleepData> _weekly(List<SleepRecord> records) {
    const names = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const shorts = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final buckets = List<List<double>>.generate(7, (_) => []);
    for (final r in records) {
      final at = r.createdAt;
      if (at == null) continue;
      final day = DateTime(at.year, at.month, at.day);
      final index = day.difference(monday).inDays;
      if (index >= 0 && index < 7) buckets[index].add(r.duration);
    }

    return [
      for (var i = 0; i < 7; i++)
        DaySleepData.of(
          names[i],
          shorts[i],
          buckets[i].isEmpty
              ? 0
              : buckets[i].reduce((a, b) => a + b) / buckets[i].length,
        ),
    ];
  }

  static double _pearson(Iterable<double> xs, List<double> ys) {
    final x = xs.toList();
    if (x.length < 2 || x.length != ys.length) return 0;
    final n = x.length;
    final mx = x.reduce((a, b) => a + b) / n;
    final my = ys.reduce((a, b) => a + b) / n;
    double cov = 0, dx = 0, dy = 0;
    for (var i = 0; i < n; i++) {
      final a = x[i] - mx;
      final b = ys[i] - my;
      cov += a * b;
      dx += a * a;
      dy += b * b;
    }
    final denom = math.sqrt(dx * dy);
    return denom == 0 ? 0 : cov / denom;
  }
}
