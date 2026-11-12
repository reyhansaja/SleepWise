import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_service.dart';
import '../../history/data/repositories/api_history_repository.dart';
import '../../history/domain/entities/sleep_record.dart';
import '../domain/entities/sleep_stats.dart';

/// 0 = 7 hari, 1 = 30 hari, 2 = semua.
const statisticsFilterOptions = ['7 Hari', '30 Hari', 'Semua'];

const _daysPerFilter = [7, 30, 0];

final statisticsProvider =
    FutureProvider.autoDispose.family<SleepStats, int>((ref, filterIndex) async {
  final token = ref.watch(authSessionProvider)?.token;
  final records = await ref
      .watch(historyRepositoryProvider)
      .getRecords(token: token);

  final days = _daysPerFilter[filterIndex.clamp(0, 2)];
  return SleepStats.fromRecords(
    days == 0 ? records : _withinDays(records, days),
  );
});

List<SleepRecord> _withinDays(List<SleepRecord> records, int days) {
  final cutoff = DateTime.now().subtract(Duration(days: days));
  return records
      .where((r) => r.createdAt == null || r.createdAt!.isAfter(cutoff))
      .toList();
}
