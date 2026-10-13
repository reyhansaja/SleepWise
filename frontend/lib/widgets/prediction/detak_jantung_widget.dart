import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class DetakJantungWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const DetakJantungWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String get _statusText {
    if (value >= 60 && value <= 100) return 'Normal: 60-100';
    if (value < 60) return 'Rendah';
    return 'Tinggi';
  }

  Color get _statusColor {
    if (value >= 60 && value <= 100) return AppTheme.success;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.accentPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Detak Jantung Istirahat',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                          child: Text(
                            _statusText,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Resting Heart Rate (RHR)',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // BPM input
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: TextField(
                  controller: TextEditingController(text: '$value'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (text) {
                    final parsed = int.tryParse(text);
                    if (parsed != null) onChanged(parsed);
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'bpm',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              // Heart icon
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: AppTheme.accentPink.withValues(alpha: 0.5),
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
