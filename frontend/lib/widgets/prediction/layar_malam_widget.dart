import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class LayarMalamWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const LayarMalamWidget({
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
            icon: Icons.phone_android_rounded,
            title: 'Layar Malam',
            subtitle: 'Sebelum merebahkan diri',
            trailing: _buildValueBadge(),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accentBlue,
              inactiveTrackColor: AppTheme.surfaceBorder,
              thumbColor: AppTheme.accentBlue,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 4,
              ),
              overlayColor: AppTheme.accentBlue.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 180,
              divisions: 36,
              onChanged: onChanged,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 mnt', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Text('180 mnt', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${value.toInt()}',
              style: const TextStyle(
                color: AppTheme.accentBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' mnt',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
