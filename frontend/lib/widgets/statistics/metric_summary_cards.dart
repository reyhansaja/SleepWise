import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MetricSummaryCards extends StatelessWidget {
  const MetricSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.nightlight_round,
            iconColor: AppTheme.primaryLight,
            title: 'Rata Dur...',
            valueText: '7.4',
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
                const Text(
                  '+12 mnt',
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
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.spa_rounded,
            iconColor: AppTheme.secondary,
            title: 'Skor Stres',
            valueText: '3.2',
            unitText: ' /10',
            valueColor: AppTheme.accent,
            footer: const Text(
              'Rendah / Rileks',
              style: TextStyle(
                color: AppTheme.textSecondary,
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
            icon: Icons.show_chart_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Prediksi ...',
            valueText: '34',
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

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueText,
    required String unitText,
    Color? valueColor,
    required Widget footer,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.cardBorder, width: 0.5),
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
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
                    color: valueColor ?? AppTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: unitText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
