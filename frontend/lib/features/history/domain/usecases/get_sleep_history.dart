import '../entities/sleep_record.dart';
import '../repositories/history_repository.dart';

class GetSleepHistory {
  final HistoryRepository repository;

  const GetSleepHistory(this.repository);

  Future<List<SleepRecord>> call({String? token}) =>
      repository.getRecords(token: token);
}
