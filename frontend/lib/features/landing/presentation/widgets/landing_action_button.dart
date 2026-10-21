import 'package:flutter/material.dart';

/// Primary call-to-action button on the Landing Page.
/// Renders the pill-shaped "Lanjut ➔" button with smooth ink ripple and shadow.
class LandingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const LandingActionButton({
    super.key,
    required this.onPressed,
    this.label = 'Lanjut',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6E7CF6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x666E7CF6),
            blurRadius: 24,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF151838),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF151838),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
