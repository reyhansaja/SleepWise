import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/history/data/repositories/local_history_repository.dart';
import 'package:frontend/features/history/domain/entities/sleep_record.dart';
import 'package:frontend/features/history/domain/usecases/get_sleep_history.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _getSleepHistory = const GetSleepHistory(LocalHistoryRepository());
  late final List<SleepRecord> _records;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _records = _getSleepHistory();
  }

  List<SleepRecord> get _visibleRecords {
    return _records.where((record) {
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Good Sleep' && record.quality == 'Good Sleep');
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          record.date.toLowerCase().contains(query) ||
          record.note.toLowerCase().contains(query) ||
          record.quality.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSummary(),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  _buildFilters(),
                  const SizedBox(height: 14),
                  if (_visibleRecords.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Tidak ada riwayat yang cocok.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ..._visibleRecords.map(_buildRecordCard),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Prediksi SleepWise',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              SizedBox(height: 5),
              Text(
                'Riwayat Prediksi',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Arsip evaluasi & analisis cerdas tidurmu',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Ganti Tema',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggle();
              },
              icon: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDarkMode ? const Color(0xFF60A5FA) : Colors.amber,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ekspor riwayat segera tersedia.'),
                  ),
                );
              },
              icon: const Icon(Icons.ios_share_rounded, size: 13),
              label: const Text('Ekspor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bedtime_rounded, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '34',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Riwayat',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Model terverifikasi •\nTerenkripsi diperangkat',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF45D5B0).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'Lokal\nSinkron',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.brightness == Brightness.dark
                    ? const Color(0xFF45D5B0)
                    : const Color(0xFF047857),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AKURASI\nRERATA',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 7,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '92.4%',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      style: TextStyle(color: colors.onSurface, fontSize: 11),
      decoration: InputDecoration(
        hintText: 'Cari tanggal, faktor stres, atau model...',
        hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.onSurfaceVariant,
          size: 15,
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final colors = Theme.of(context).colorScheme;
    const filters = ['Semua', 'Random Forest', 'Decision Tree', 'Good Sleep'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(SleepRecord record) {
    final colors = Theme.of(context).colorScheme;
    final qualityColor = _qualityColor(record.quality);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF75E6BE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  record.date,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.nightlight_round, size: 9, color: qualityColor),
                    const SizedBox(width: 3),
                    Text(
                      record.quality,
                      style: TextStyle(
                        color: qualityColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric(Icons.access_time_rounded, record.duration, 'Durasi'),
              _metric(Icons.star_border_rounded, record.score, 'Skor'),
              _metric(
                Icons.bedtime_outlined,
                '${record.awakenings} kcr',
                'Terbangun',
              ),
              _metric(Icons.favorite_border_rounded, record.heartRate, 'bpm'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: qualityColor,
                      size: 11,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        record.note,
                        style: TextStyle(
                          color: qualityColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Detail ›',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 15),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 8),
        ),
      ],
    );
  }

  Color _qualityColor(String quality) {
    switch (quality) {
      case 'Good Sleep':
        return const Color(0xFF34D399);
      case 'Average Sleep':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFFF87171);
    }
  }
}
