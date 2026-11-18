import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/section_card.dart';

/// Field yang dibutuhkan dataset SleepWise tapi belum ada di form lama:
/// gender, usia, pekerjaan, langkah harian, tekanan darah.
class ProfilKlinisWidget extends StatelessWidget {
  final String gender;
  final int age;
  final String occupation;
  final int dailySteps;
  final int systolicBp;
  final int diastolicBp;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<String> onOccupationChanged;
  final ValueChanged<int> onDailyStepsChanged;
  final ValueChanged<int> onSystolicChanged;
  final ValueChanged<int> onDiastolicChanged;

  const ProfilKlinisWidget({
    super.key,
    required this.gender,
    required this.age,
    required this.occupation,
    required this.dailySteps,
    required this.systolicBp,
    required this.diastolicBp,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onOccupationChanged,
    required this.onDailyStepsChanged,
    required this.onSystolicChanged,
    required this.onDiastolicChanged,
  });

  /// Occupation yang dikenal one-hot encoder model (lihat all_feature_names).
  static const List<String> occupations = [
    'Accountant',
    'Doctor',
    'Engineer',
    'Lawyer',
    'Manager',
    'Nurse',
    'Sales Representative',
    'Salesperson',
    'Scientist',
    'Software Engineer',
    'Teacher',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.badge_rounded,
            title: 'Profil & Data Klinis',
            subtitle: 'Fitur dataset: gender, usia, pekerjaan, langkah, tekanan darah',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              _buildChoice(context, 'Laki-laki', 'Male'),
              const SizedBox(width: AppTheme.spacingSm),
              _buildChoice(context, 'Perempuan', 'Female'),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          DropdownButton<String>(
            value: occupations.contains(occupation) ? occupation : occupations.first,
            isExpanded: true,
            dropdownColor: colors.surfaceContainerHighest,
            underline: Container(height: 1, color: colors.outlineVariant),
            items: [
              for (final item in occupations)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) {
              if (value != null) onOccupationChanged(value);
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildSlider(
            context,
            label: 'Usia',
            valueText: '$age tahun',
            value: age.toDouble(),
            min: 18,
            max: 80,
            divisions: 62,
            onChanged: (v) => onAgeChanged(v.round()),
          ),
          _buildSlider(
            context,
            label: 'Langkah harian',
            valueText: '$dailySteps langkah',
            value: dailySteps.toDouble(),
            min: 0,
            max: 20000,
            divisions: 40,
            onChanged: (v) => onDailyStepsChanged(v.round()),
          ),
          _buildSlider(
            context,
            label: 'Sistolik',
            valueText: '$systolicBp mmHg',
            value: systolicBp.toDouble(),
            min: 80,
            max: 200,
            divisions: 24,
            onChanged: (v) => onSystolicChanged(v.round()),
          ),
          _buildSlider(
            context,
            label: 'Diastolik',
            valueText: '$diastolicBp mmHg',
            value: diastolicBp.toDouble(),
            min: 50,
            max: 130,
            divisions: 16,
            onChanged: (v) => onDiastolicChanged(v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildChoice(BuildContext context, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onGenderChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.2)
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isSelected ? AppTheme.primary : colors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
