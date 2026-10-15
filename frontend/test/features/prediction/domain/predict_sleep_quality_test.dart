import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/prediction/data/repositories/local_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';
import 'package:frontend/features/prediction/domain/usecases/predict_sleep_quality.dart';

void main() {
  test('returns a lower score and recommendation for poor sleep inputs', () {
    const predictSleepQuality = PredictSleepQuality(
      LocalPredictionRepository(),
    );

    final result = predictSleepQuality(
      const PredictionInput(
        sleepDuration: 5,
        physicalActivityLevel: 0,
        stressLevel: 8,
        caffeineServings: 4,
        nightScreenMinutes: 90,
        heartRate: 85,
        bmiCategory: 1,
      ),
    );

    expect(result.score, lessThan(80));
    expect(result.label, isNotEmpty);
    expect(result.recommendations, isNotEmpty);
  });
}
