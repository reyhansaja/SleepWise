import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/section_card.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';

class SleepCorrelationCard extends StatelessWidget {
  const SleepCorrelationCard({super.key, required this.stats});

  final SleepStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final factors = [
      _Factor(
        icon: Icons.sentiment_dissatisfied_rounded,
        title: 'Tingkat Stres Harian',
        value: stats.corrStress,
        description:
            'Korelasi negatif berarti stres lebih tinggi cenderung menurunkan skor kualitas tidur.',
      ),
      _Factor(
        icon: Icons.favorite_border_rounded,
        title: 'Detak Jantung Istirahat',
        value: stats.corrHeartRate,
        description:
            'Detak jantung istirahat lebih tinggi umumnya menandakan tubuh kurang pulih.',
      ),
      _Factor(
        icon: Icons.access_time_rounded,
        title: 'Durasi Tidur',
        value: stats.corrDuration,
        description:
            'Korelasi positif berarti durasi tidur lebih panjang cenderung menaikkan skor.',
      ),
    ];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Korelasi Faktor Tidur (ML)',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Korelasi Pearson terhadap skor • ${stats.total} prediksi',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: colors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          for (var i = 0; i < factors.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _buildFactorItem(context: context, factor: factors[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorItem({
    required BuildContext context,
    required _Factor factor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final strength = factor.value.abs();
    final badgeColor = factor.value >= 0 ? AppTheme.accent : AppTheme.accentPink;
    final direction = factor.value >= 0 ? '+' : '-';
    final label = strength >= 0.5
        ? 'Kuat'
        : strength >= 0.3
        ? 'Sedang'
        : 'Lemah';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(factor.icon, color: colors.onSurface, size: 16),
                const SizedBox(width: 8),
                Text(
                  factor.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$direction${(strength * 100).round()}% ($label)',
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Track
        Container(
          height: 5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.outline.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Description
        Text(
          factor.description,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _Factor {
  const _Factor({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String title;
  final double value;
  final String description;
}
