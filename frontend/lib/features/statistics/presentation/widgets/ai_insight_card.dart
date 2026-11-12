import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';

class AiInsightCard extends StatelessWidget {
  final VoidCallback? onApplyHabit;
  final SleepStats stats;

  const AiInsightCard({super.key, this.onApplyHabit, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? const [Color(0xFF1E1C38), AppTheme.cardBackground]
              : [colors.surface, colors.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryLight,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INSIGHT & KESIMPULAN AI',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                stats.total == 0
                    ? 'Belum ada data'
                    : 'Confidence ${stats.avgConfidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            _title(),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Quote body
          Text(
            '“${_body()}”',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Rekomendasi\nTerverifikasi',
                    style: TextStyle(
                      color: colors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onApplyHabit ?? () {},
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Terapkan Habit',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colors.onPrimary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title() {
    if (stats.total == 0) return 'Belum Cukup Data';
    if (stats.goodPercent >= 0.6) return 'Pola Tidur Anda Cukup Baik';
    if (stats.poorPercent >= 0.4) return 'Perlu Perbaikan Pola Tidur';
    return 'Optimalisasi Pola Tidur Anda';
  }

  String _body() {
    if (stats.total == 0) {
      return 'Lakukan prediksi kualitas tidur terlebih dahulu agar SleepWise bisa '
          'menganalisis tren dan memberikan kesimpulan.';
    }
    final durasi = stats.avgDuration.toStringAsFixed(1);
    final stres = stats.avgStress.toStringAsFixed(1);
    final baik = (stats.goodPercent * 100).round();

    final buffer = StringBuffer()
      ..write('Dari ${stats.total} prediksi, rata-rata durasi tidur Anda ')
      ..write('$durasi jam dengan skor stres $stres/10. ')
      ..write('$baik% prediksi tergolong kualitas baik. ');

    if (stats.avgDuration < 7) {
      buffer.write(
        'Menambah durasi tidur mendekati 7-8 jam berpotensi meningkatkan skor.',
      );
    } else if (stats.avgStress >= 6) {
      buffer.write(
        'Skor stres cukup tinggi; kelola stres sebelum tidur untuk hasil lebih baik.',
      );
    } else {
      buffer.write(
        'Pertahankan rutinitas tidur yang konsisten untuk menjaga hasil ini.',
      );
    }
    return buffer.toString();
  }
}
