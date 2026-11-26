/// Hasil inferensi dari backend (Decision Tree / Random Forest tersimpan).
class PredictionResult {
  /// Label kelas model yang sudah diterjemahkan ke bahasa Indonesia.
  final String label;

  /// Probabilitas kelas terpilih menurut predict_proba (0..1).
  final double confidence;

  /// Probabilitas semua kelas, kunci = kelas mentah model (Good/Average/Poor).
  final Map<String, double> probabilities;

  /// Rekomendasi dari recommendation_service backend.
  final List<String> recommendations;

  /// Nama model yang menjawab (mis. 'Random Forest').
  final String modelName;

  /// Label mentah model sebelum guardrail klinis (bila berbeda dari [label]).
  final String? modelLabel;

  /// Nilai input di luar rentang data latih; prediksi jadi kurang dipercaya.
  final List<String> outOfRange;

  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.recommendations,
    required this.modelName,
    this.modelLabel,
    this.outOfRange = const [],
  });

  int get confidencePercent => (confidence * 100).round();

  bool get guardrailApplied => modelLabel != null && modelLabel != label;
}

