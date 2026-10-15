import '../entities/prediction_input.dart';
import '../entities/prediction_result.dart';
import '../repositories/prediction_repository.dart';

class PredictSleepQuality {
  final PredictionRepository repository;

  const PredictSleepQuality(this.repository);

  PredictionResult call(PredictionInput input) => repository.predict(input);
}
