import '../../domain/entities/sleep_record.dart';
import '../../domain/repositories/history_repository.dart';

class LocalHistoryRepository implements HistoryRepository {
  const LocalHistoryRepository();

  @override
  List<SleepRecord> getRecords() {
    return const [
      SleepRecord(
        date: '24 Mei 2024 • 07:15 WIB',
        quality: 'Good Sleep',
        duration: '7.5 h',
        score: '9/10',
        awakenings: '1',
        heartRate: '64',
        note: 'Siklus REM Optimal (1.8 jam)',
      ),
      SleepRecord(
        date: '23 Mei 2024 • 06:45 WIB',
        quality: 'Good Sleep',
        duration: '7.0 h',
        score: '8/10',
        awakenings: '2',
        heartRate: '68',
        note: 'Target tidur harian tercapai',
      ),
      SleepRecord(
        date: '22 Mei 2024 • 08:00 WIB',
        quality: 'Average Sleep',
        duration: '6.2 h',
        score: '6/10',
        awakenings: '2',
        heartRate: '60',
        note: 'Jam tidur meningkat 25m',
      ),
      SleepRecord(
        date: '20 Mei 2024 • 07:30 WIB',
        quality: 'Poor Sleep',
        duration: '4.8 h',
        score: '3/10',
        awakenings: '3',
        heartRate: '90',
        note: 'Defisit tidur signifikan (2.7 jam)',
      ),
    ];
  }
}
