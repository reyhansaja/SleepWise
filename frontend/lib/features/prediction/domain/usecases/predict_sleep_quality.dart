import '../entities/prediction_input.dart';
import '../entities/prediction_result.dart';
import '../repositories/prediction_repository.dart';

class PredictSleepQuality {
  final PredictionRepository repository;

  const PredictSleepQuality(this.repository);

  Future<PredictionResult> call(PredictionInput input, {String? token}) =>
      repository.predict(input, token: token);
}
