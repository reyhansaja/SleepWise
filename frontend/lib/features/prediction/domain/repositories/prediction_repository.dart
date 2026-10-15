import '../entities/prediction_input.dart';
import '../entities/prediction_result.dart';

abstract interface class PredictionRepository {
  PredictionResult predict(PredictionInput input);
}
