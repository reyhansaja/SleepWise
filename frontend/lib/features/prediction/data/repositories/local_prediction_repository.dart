import '../../domain/entities/prediction_input.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/prediction_repository.dart';

class LocalPredictionRepository implements PredictionRepository {
  const LocalPredictionRepository();

  @override
  PredictionResult predict(PredictionInput input) {
    var score = 100;
    final recommendations = <String>[];

    if (input.sleepDuration < 7) {
      score -= 15;
      recommendations.add('Usahakan tidur setidaknya 7 jam.');
    }
    if (input.stressLevel > 6) {
      score -= 15;
      recommendations.add('Lakukan rutinitas relaksasi sebelum tidur.');
    }
    if (input.caffeineServings > 2) {
      score -= 10;
      recommendations.add('Kurangi konsumsi kafein pada sore dan malam hari.');
    }
    if (input.nightScreenMinutes > 60) {
      score -= 10;
      recommendations.add('Batasi paparan layar satu jam sebelum tidur.');
    }
    if (input.heartRate > 80) {
      score -= 10;
      recommendations.add('Perhatikan pemulihan tubuh dan kualitas istirahat.');
    }

    final normalizedScore = score.clamp(0, 100).toInt();
    final label = normalizedScore >= 80
        ? 'Kualitas tidur baik'
        : normalizedScore >= 60
        ? 'Kualitas tidur cukup'
        : 'Perlu perhatian';

    return PredictionResult(
      score: normalizedScore,
      label: label,
      recommendations: recommendations,
    );
  }
}
