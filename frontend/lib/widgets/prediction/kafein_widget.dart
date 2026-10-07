import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/section_card.dart';

class KafeinWidget extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const KafeinWidget({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.coffee_rounded,
            title: 'Kafein',
            subtitle: 'Asupan kopi / teh',
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(Icons.remove, onDecrement),
              const SizedBox(width: AppTheme.spacingXl),
              Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Cangkir',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingXl),
              _buildButton(Icons.add, onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}
