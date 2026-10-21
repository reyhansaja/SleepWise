import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/statistics/presentation/widgets/ai_insight_card.dart';
import 'package:frontend/features/statistics/presentation/widgets/metric_summary_cards.dart';
import 'package:frontend/features/statistics/presentation/widgets/sleep_correlation_card.dart';
import 'package:frontend/features/statistics/presentation/widgets/sleep_distribution_card.dart';
import 'package:frontend/features/statistics/presentation/widgets/weekly_trend_chart_card.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int _selectedFilterIndex = 0; // 0: 7 Hari, 1: 30 Hari, 2: Semua

  static const List<String> _filterOptions = ['7 Hari', '30 Hari', 'Semua'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Top Bar
            SliverToBoxAdapter(child: _buildHeader()),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),

                  // Circadian Analysis Title & Synced ML Badge
                  _buildTitleSection(),
                  const SizedBox(height: 16),

                  // Filter Pills (7 Hari, 30 Hari, Semua)
                  _buildTimeframeFilter(),
                  const SizedBox(height: 16),

                  // 3 Metric Cards Row
                  const MetricSummaryCards(),
                  const SizedBox(height: 16),

                  // Distribusi Kualitas Tidur Card
                  const SleepDistributionCard(),
                  const SizedBox(height: 16),

                  // Tren Durasi Mingguan Card
                  const WeeklyTrendChartCard(),
                  const SizedBox(height: 16),

                  // Korelasi Faktor Tidur (ML) Card
                  const SleepCorrelationCard(),
                  const SizedBox(height: 16),

                  // Insight & Kesimpulan AI Card
                  AiInsightCard(
                    onApplyHabit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Habit digital bedtime diaktifkan!'),
                          backgroundColor: AppTheme.primary,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons (Download PDF & Share)
                  _buildBottomActionButtons(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header App Bar
  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Center(
                  child: Text(
                    'SW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SleepWise',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Statistik',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Ganti Tema',
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                icon: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: isDarkMode ? const Color(0xFF60A5FA) : Colors.amber,
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: colors.surface,
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person_rounded,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Circadian Analysis Title & Synced ML Badge
  Widget _buildTitleSection() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ANALISIS SIRKADIAN',
          style: TextStyle(
            color: Color(0xFF8E8AF7),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Statistik & Tren Tidur',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Synced ML',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Timeframe Filter Bar (7 Hari, 30 Hari, Semua)
  Widget _buildTimeframeFilter() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: List.generate(_filterOptions.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _filterOptions[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Download PDF & Share Action Buttons
  Widget _buildBottomActionButtons() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Download PDF Button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyiapkan laporan PDF...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_download_outlined,
                      color: colors.onSurface,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Unduh Laporan PDF',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Share Icon Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka dialog bagikan...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.share_outlined,
                color: colors.onSurface,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
