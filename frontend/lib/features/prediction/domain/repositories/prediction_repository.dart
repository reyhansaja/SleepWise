import '../entities/prediction_input.dart';
import '../entities/prediction_result.dart';

abstract interface class PredictionRepository {
  /// [token] = token login (opsional, dikirim sebagai Bearer bila ada).
  Future<PredictionResult> predict(PredictionInput input, {String? token});
}
