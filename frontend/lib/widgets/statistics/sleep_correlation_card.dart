import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class SleepCorrelationCard extends StatelessWidget {
  const SleepCorrelationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Korelasi Faktor Tidur (ML)',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Random Forest Shapley Importance Values',
                    style: TextStyle(
                      color: AppTheme.textMuted,
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
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.primaryLight,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Factor 1: Durasi Layar Malam
          _buildFactorItem(
            icon: Icons.phone_android_rounded,
            title: 'Durasi Layar Malam',
            badgeText: '-42% (Korelasi Negatif Kuat)',
            badgeColor: AppTheme.accentPink,
            progress: 0.42,
            description:
                'Tiap >45 mnt screen-time menunda fase deep sleep ±26 menit.',
          ),
          const SizedBox(height: 18),

          // Factor 2: Tingkat Stres Harian
          _buildFactorItem(
            icon: Icons.sentiment_dissatisfied_rounded,
            title: 'Tingkat Stres Harian',
            badgeText: '-28% (Pengaruh Signifikan)',
            badgeColor: AppTheme.accentOrange,
            progress: 0.28,
            description:
                'Stres tinggi (>6/10) meningkatkan frekuensi terbangun spontan.',
          ),
          const SizedBox(height: 18),

          // Factor 3: Aktivitas Fisik Sore
          _buildFactorItem(
            icon: Icons.directions_run_rounded,
            title: 'Aktivitas Fisik Sore',
            badgeText: '+35% (Korelasi Positif Kuat)',
            badgeColor: AppTheme.accent,
            progress: 0.35,
            description:
                'Olahraga sedang (16.00-18.00) mempercepat onset kantuk alami.',
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required double progress,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              badgeText,
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
            color: AppTheme.surfaceBorder,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
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
          description,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
