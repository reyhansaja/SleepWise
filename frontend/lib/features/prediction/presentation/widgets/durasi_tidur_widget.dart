import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/section_card.dart';

class DurasiTidurWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const DurasiTidurWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.bedtime_rounded,
            title: 'Durasi Tidur',
            subtitle: 'Rencana istirahat semalam',
            trailing: _buildValueBadge(context),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSlider(context),
          const SizedBox(height: AppTheme.spacingSm),
          _buildLabels(context),
        ],
      ),
    );
  }

  Widget _buildValueBadge(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value.toStringAsFixed(1),
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' Jam',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Track background
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Ideal zone indicator
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final startFraction = (7 - 3) / (12 - 3);
                  final endFraction = (8 - 3) / (12 - 3);
                  return Stack(
                    children: [
                      Positioned(
                        left: totalWidth * startFraction,
                        width: totalWidth * (endFraction - startFraction),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Active track
            LayoutBuilder(
              builder: (context, constraints) {
                final fraction = (value - 3) / (12 - 3);
                return Container(
                  height: 6,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    gradient: AppTheme.sliderGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: AppTheme.primaryLight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayColor: AppTheme.primary.withValues(alpha: 0.2),
            trackHeight: 0,
          ),
          child: Slider(
            value: value,
            min: 3,
            max: 12,
            divisions: 18,
            onChanged: onChanged,
          ),
        ),
        // Ideal zone label
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              '🟢 Zona Ideal: 7 - 8 Jam',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '3 Jam',
          style: TextStyle(color: labelColor, fontSize: 11),
        ),
        Text(
          '12 Jam',
          style: TextStyle(color: labelColor, fontSize: 11),
        ),
      ],
    );
  }
}
