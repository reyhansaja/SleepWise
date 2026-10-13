import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class BmiWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const BmiWidget({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const List<String> _options = [
    'Underweight',
    'Normal',
    'Overweight',
    'Obese',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.accessibility_new_rounded,
            title: 'Kategori Indeks Massa Tubuh (BMI)',
            subtitle: 'Mempengaruhi fase pernapasan & ritme sirkadian',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_options.length, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    _options[index],
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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
}
