class PredictionInput {
  final double sleepDuration;
  final int physicalActivityLevel;
  final double stressLevel;
  final int caffeineServings;
  final double nightScreenMinutes;
  final int heartRate;
  final int bmiCategory;

  const PredictionInput({
    required this.sleepDuration,
    required this.physicalActivityLevel,
    required this.stressLevel,
    required this.caffeineServings,
    required this.nightScreenMinutes,
    required this.heartRate,
    required this.bmiCategory,
  });
}
