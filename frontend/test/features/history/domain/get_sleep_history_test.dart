import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/history/data/repositories/local_history_repository.dart';
import 'package:frontend/features/history/domain/usecases/get_sleep_history.dart';

void main() {
  test('returns the local sleep history records', () {
    const getSleepHistory = GetSleepHistory(LocalHistoryRepository());

    final records = getSleepHistory();

    expect(records, hasLength(4));
    expect(records.first.quality, 'Good Sleep');
    expect(records.last.quality, 'Poor Sleep');
  });
}
