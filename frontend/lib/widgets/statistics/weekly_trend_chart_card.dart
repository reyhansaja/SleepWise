import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class DaySleepData {
  final String dayName;
  final String dayShort;
  final double duration;
  final bool isOptimal;
  final bool isWarning;

  const DaySleepData({
    required this.dayName,
    required this.dayShort,
    required this.duration,
    this.isOptimal = false,
    this.isWarning = false,
  });
}

class WeeklyTrendChartCard extends StatefulWidget {
  const WeeklyTrendChartCard({super.key});

  @override
  State<WeeklyTrendChartCard> createState() => _WeeklyTrendChartCardState();
}

class _WeeklyTrendChartCardState extends State<WeeklyTrendChartCard> {
  int _selectedIndex = 6; // Default to Minggu (Sunday)

  final List<DaySleepData> _weekData = const [
    DaySleepData(
      dayName: 'Senin',
      dayShort: 'Sen',
      duration: 6.8,
    ),
    DaySleepData(
      dayName: 'Selasa',
      dayShort: 'Sel',
      duration: 7.5,
      isOptimal: true,
    ),
    DaySleepData(
      dayName: 'Rabu',
      dayShort: 'Rab',
      duration: 5.5,
      isWarning: true,
    ),
    DaySleepData(
      dayName: 'Kamis',
      dayShort: 'Kam',
      duration: 7.2,
      isOptimal: true,
    ),
    DaySleepData(
      dayName: 'Jumat',
      dayShort: 'Jum',
      duration: 6.5,
    ),
    DaySleepData(
      dayName: 'Sabtu',
      dayShort: 'Sab',
      duration: 8.2,
      isOptimal: true,
    ),
    DaySleepData(
      dayName: 'Minggu',
      dayShort: 'Min',
      duration: 7.8,
      isOptimal: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDay = _weekData[_selectedIndex];

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
                    'Tren Durasi Mingguan',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Senin – Minggu • Zona ideal 7-8 Jam',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Optimal',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart with target line
          SizedBox(
            height: 170,
            child: Stack(
              children: [
                // Dashed / guide ideal zone line at ~7.5 hours
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: (7.5 / 10.0) * 135,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _DashedLinePainter(
                            color: AppTheme.accent.withValues(alpha: 0.35),
                          ),
                          child: const SizedBox(height: 1),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          '7-8h',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_weekData.length, (index) {
                    final data = _weekData[index];
                    final isSelected = index == _selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: _buildBarItem(data, isSelected),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer interaction info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: AppTheme.primaryLight,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pilih hari pada grafik untuk melihat rincian detail.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: AppTheme.primaryLight.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${selectedDay.dayName}: ${selectedDay.duration} Jam',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildBarItem(DaySleepData data, bool isSelected) {
    // Max scale 10 hours = 120 pixels bar height
    final barHeight = (data.duration / 10.0) * 120;

    Color barColor;
    if (isSelected) {
      barColor = AppTheme.primaryLight;
    } else if (data.isWarning) {
      barColor = AppTheme.accentPink.withValues(alpha: 0.85);
    } else if (data.isOptimal) {
      barColor = AppTheme.accent;
    } else {
      barColor = const Color(0xFF384358);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value text
        Text(
          '${data.duration}h',
          style: TextStyle(
            color: isSelected
                ? AppTheme.primaryLight
                : (data.isOptimal ? AppTheme.accent : AppTheme.textMuted),
            fontSize: 10,
            fontWeight: isSelected || data.isOptimal
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),

        // Bar container
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: isSelected ? 22 : 18,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : (data.isOptimal
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null),
          ),
        ),
        const SizedBox(height: 8),

        // Day label
        Text(
          data.dayShort,
          style: TextStyle(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
