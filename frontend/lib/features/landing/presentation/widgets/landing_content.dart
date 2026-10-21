import 'package:flutter/material.dart';

/// Content section for the Landing Page featuring the circadian analysis tag,
/// primary headline, and descriptive subtext.
class LandingContent extends StatelessWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category / Tag Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2338),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF293552),
              width: 1,
            ),
          ),
          child: const Text(
            'Analisis Cerdas Sirkadian',
            style: TextStyle(
              color: Color(0xFFC3CDDF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Main Headline
        const Text(
          'Tidur Optimal,',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'serif',
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bangun Berenergi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF818CF8),
            fontFamily: 'serif',
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),

        // Subtitle Description
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: const Text(
            'Pahami ritme sirkadian dan optimalkan kualitas istirahat harian Anda dengan analisis cerdas Machine Learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
              height: 1.55,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
