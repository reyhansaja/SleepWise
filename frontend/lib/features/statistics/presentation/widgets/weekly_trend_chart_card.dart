import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/section_card.dart';
import 'package:frontend/features/statistics/domain/entities/sleep_stats.dart';

class WeeklyTrendChartCard extends StatefulWidget {
  const WeeklyTrendChartCard({super.key, required this.weekData});

  final List<DaySleepData> weekData;

  @override
  State<WeeklyTrendChartCard> createState() => _WeeklyTrendChartCardState();
}

class _WeeklyTrendChartCardState extends State<WeeklyTrendChartCard> {
  int? _selectedIndex;

  List<DaySleepData> get _weekData => widget.weekData;

  int get _effectiveIndex {
    if (_weekData.isEmpty) return 0;
    if (_selectedIndex != null && _selectedIndex! < _weekData.length) {
      return _selectedIndex!;
    }
    // Default ke hari terakhir yang punya data.
    final last = _weekData.lastIndexWhere((d) => d.duration > 0);
    return last >= 0 ? last : _weekData.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_weekData.isEmpty) {
      return const SizedBox.shrink();
    }
    final selectedDay = _weekData[_effectiveIndex];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Durasi Mingguan',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Senin – Minggu • Zona ideal 7-8 Jam',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                  Text(
                    'Optimal',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(_weekData.length, (index) {
                    final data = _weekData[index];
                    final isSelected = index == _effectiveIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: _buildBarItem(data, isSelected, colors),
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
              color: colors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app_outlined, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih hari pada grafik untuk melihat rincian detail.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
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
                      '${selectedDay.dayName}: ${selectedDay.duration.toStringAsFixed(1)} Jam',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildBarItem(DaySleepData data, bool isSelected, ColorScheme colors) {
    // Skala 10 jam = 120 px; di-clamp agar durasi ekstrem tidak overflow.
    final barHeight = (data.duration / 10.0 * 120).clamp(0.0, 120.0);

    Color barColor;
    if (isSelected) {
      barColor = AppTheme.primaryLight;
    } else if (data.isWarning) {
      barColor = AppTheme.accentPink.withValues(alpha: 0.85);
    } else if (data.isOptimal) {
      barColor = AppTheme.accent;
    } else {
      barColor = colors.surfaceContainerHighest;
    }

    return Column(
      children: [
        // Value text
        Text(
          data.duration > 0 ? '${data.duration.toStringAsFixed(1)}h' : '-',
          style: TextStyle(
            color: isSelected
                ? colors.primary
                : (data.isOptimal ? AppTheme.accent : colors.onSurfaceVariant),
            fontSize: 10,
            fontWeight: isSelected || data.isOptimal
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),

        // Bar container — Expanded + Align supaya tinggi sisa dipakai, tidak overflow.
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 22 : 18,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(color: colors.onSurface, width: 1.5)
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
          ),
        ),
        const SizedBox(height: 8),

        // Day label
        Text(
          data.dayShort,
          style: TextStyle(
            color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
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
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
