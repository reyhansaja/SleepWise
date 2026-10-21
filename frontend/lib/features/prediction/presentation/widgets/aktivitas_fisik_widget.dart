import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/section_card.dart';

class AktivitasFisikWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AktivitasFisikWidget({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const List<Map<String, String>> _options = [
    {'label': 'Ringan', 'duration': '< 30 mnt'},
    {'label': 'Sedang', 'duration': '30-60 mnt'},
    {'label': 'Intensif', 'duration': '> 60 mnt'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.directions_run_rounded,
            title: 'Aktivitas Fisik',
            subtitle: 'Gerak aktif & olahraga harian',
            trailing: _buildSelectedBadge(context),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: List.generate(_options.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: index < _options.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.2)
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : colors.outlineVariant,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _options[index]['duration']!,
                          style: TextStyle(
                            color: isSelected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _options[index]['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedBadge(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = _options[selectedIndex]['label']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
