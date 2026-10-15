class PredictionResult {
  final int score;
  final String label;
  final List<String> recommendations;

  const PredictionResult({
    required this.score,
    required this.label,
    required this.recommendations,
  });
}
