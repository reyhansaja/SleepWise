import '../entities/sleep_record.dart';

abstract interface class HistoryRepository {
  Future<List<SleepRecord>> getRecords({String? token});
}
