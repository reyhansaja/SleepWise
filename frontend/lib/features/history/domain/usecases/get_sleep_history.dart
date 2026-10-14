import '../entities/sleep_record.dart';
import '../repositories/history_repository.dart';

class GetSleepHistory {
  final HistoryRepository repository;

  const GetSleepHistory(this.repository);

  List<SleepRecord> call() => repository.getRecords();
}
