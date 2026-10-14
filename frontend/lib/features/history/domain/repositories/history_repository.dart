import '../entities/sleep_record.dart';

abstract interface class HistoryRepository {
  List<SleepRecord> getRecords();
}
