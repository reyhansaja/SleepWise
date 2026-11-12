class SleepRecord {
  final int id;
  final String date;
  final String quality; // Good / Average / Poor (raw dari backend)
  final String modelName;
  final String userNama;
  final double duration;
  final int score; // confidence 0-100
  final int stressLevel;
  final int heartRate;
  final DateTime? createdAt;

  const SleepRecord({
    required this.id,
    required this.date,
    required this.quality,
    required this.modelName,
    required this.userNama,
    required this.duration,
    required this.score,
    required this.stressLevel,
    required this.heartRate,
    this.createdAt,
  });

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_at']?.toString() ?? '';
    final confidence = _num(json['confidence']) ?? 0;
    return SleepRecord(
      id: _num(json['id'])?.toInt() ?? 0,
      date: _formatDate(rawDate),
      quality: json['predicted_quality'] as String? ?? 'Average',
      modelName: json['model_name'] as String? ?? '-',
      userNama: json['user_nama'] as String? ?? 'Anonim',
      duration: _num(json['sleep_duration'])?.toDouble() ?? 0,
      score: (confidence * 100).round(),
      stressLevel: _num(json['stress_level'])?.toInt() ?? 0,
      heartRate: _num(json['heart_rate'])?.toInt() ?? 0,
      createdAt: DateTime.tryParse(rawDate.replaceFirst(' ', 'T')),
    );
  }
}

// MySQL DECIMAL bisa dikirim sebagai string ("7.50") atau num.
num? _num(Object? value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '');

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatDate(String raw) {
  final dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (dt == null) return raw;
  final jam = dt.hour.toString().padLeft(2, '0');
  final menit = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${_bulan[dt.month - 1]} ${dt.year} • $jam:$menit';
}
