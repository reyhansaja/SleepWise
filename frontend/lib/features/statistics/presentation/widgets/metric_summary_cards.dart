import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';

class MetricSummaryCards extends StatelessWidget {
  const MetricSummaryCards({super.key, required this.stats});

  final SleepStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stress = stats.avgStress;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context: context,
            icon: Icons.nightlight_round,
            iconColor: AppTheme.primaryLight,
            title: 'Rata Dur...',
            valueText: stats.avgDuration.toStringAsFixed(1),
            unitText: ' Jam',
            footer: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.accent,
                  size: 13,
                ),
                const SizedBox(width: 3),
                Text(
                  '${stats.total} catatan',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context: context,
            icon: Icons.spa_rounded,
            iconColor: AppTheme.secondary,
            title: 'Skor Stres',
            valueText: stress.toStringAsFixed(1),
            unitText: ' /10',
            valueColor: AppTheme.accent,
            footer: Text(
              _stressLabel(stress),
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context: context,
            icon: Icons.show_chart_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Prediksi ...',
            valueText: '${stats.total}',
            unitText: ' Log',
            valueColor: AppTheme.accentOrange,
            footer: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.accent,
                  size: 13,
                ),
                const SizedBox(width: 3),
                const Text(
                  'Validated',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _stressLabel(double value) {
    if (value < 4) return 'Rendah / Rileks';
    if (value < 7) return 'Sedang';
    return 'Tinggi';
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueText,
    required String unitText,
    Color? valueColor,
    required Widget footer,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: valueText,
                  style: TextStyle(
                    color: valueColor ?? colors.onSurface,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: unitText,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          footer,
        ],
      ),
    );
  }
}
