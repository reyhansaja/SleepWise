import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class SleepDistributionCard extends StatelessWidget {
  const SleepDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribusi Kualitas Tidur',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Klasifikasi model Random Forest • 7 Hari',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  '70%\nOPTIMAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Donut Chart + Legend
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutChartPainter(
                        goodPercent: 0.70,
                        averagePercent: 0.22,
                        poorPercent: 0.08,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: AppTheme.accent.withValues(alpha: 0.9),
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '70%',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'GOOD',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(
                      dotColor: AppTheme.accent,
                      title: 'Good (Optimal)',
                      subtitle: '> 7.0 Jam rest • Rendah bangun',
                      percentage: '70%',
                      percentageColor: AppTheme.accent,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      dotColor: AppTheme.accentOrange,
                      title: 'Average (Cukup)',
                      subtitle: '6.0 - 6.9 Jam • Sedang',
                      percentage: '22%',
                      percentageColor: AppTheme.accentOrange,
                    ),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                      dotColor: AppTheme.accentPink,
                      title: 'Poor (Kurang)',
                      subtitle: '< 6.0 Jam • Restless',
                      percentage: '8%',
                      percentageColor: AppTheme.accentPink,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Footnote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppTheme.textMuted.withValues(alpha: 0.8),
                  size: 15,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Standar National Sleep Foundation: Target durasi tidur restoratif dewasa muda 7–9 jam/malam.',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color dotColor,
    required String title,
    required String subtitle,
    required String percentage,
    required Color percentageColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: percentageColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double goodPercent;
  final double averagePercent;
  final double poorPercent;

  _DonutChartPainter({
    required this.goodPercent,
    required this.averagePercent,
    required this.poorPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 11.0;
    const gapAngle = 0.05; // Gap between sections in radians

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paintGood = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintAvg = Paint()
      ..color = AppTheme.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintPoor = Paint()
      ..color = AppTheme.accentPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2; // Start from top

    // Good Arc
    double sweepGood = (2 * math.pi * goodPercent) - gapAngle;
    canvas.drawArc(rect, startAngle, sweepGood, false, paintGood);
    startAngle += sweepGood + gapAngle;

    // Average Arc
    double sweepAvg = (2 * math.pi * averagePercent) - gapAngle;
    canvas.drawArc(rect, startAngle, sweepAvg, false, paintAvg);
    startAngle += sweepAvg + gapAngle;

    // Poor Arc
    double sweepPoor = (2 * math.pi * poorPercent) - gapAngle;
    canvas.drawArc(rect, startAngle, sweepPoor, false, paintPoor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
