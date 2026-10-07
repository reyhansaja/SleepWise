import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class TingkatStresWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TingkatStresWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String get _statusText {
    if (value <= 3) return 'Terkontrol';
    if (value <= 6) return 'Moderat';
    return 'Tinggi';
  }

  Color get _statusColor {
    if (value <= 3) return AppTheme.success;
    if (value <= 6) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.psychology_rounded,
            title: 'Tingkat Beban Stres',
            subtitle: 'Evaluasi kelelahan emosional',
            trailing: _buildValueBadge(),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSlider(),
          const SizedBox(height: AppTheme.spacingSm),
          _buildLabels(),
        ],
      ),
    );
  }

  Widget _buildValueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.toInt()}',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' / 10',
                  style: TextStyle(
                    color: _statusColor.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '($_statusText)',
            style: TextStyle(
              color: _statusColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        // Custom gradient track
        LayoutBuilder(
          builder: (context, constraints) {
            final fraction = value / 10;
            return Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.warning, AppTheme.error],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            );
          },
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: _statusColor,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayColor: _statusColor.withValues(alpha: 0.2),
            trackHeight: 0,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '1 (Tenang)',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          '5 (Moderat)',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          '10 (Sangat Stres)',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
