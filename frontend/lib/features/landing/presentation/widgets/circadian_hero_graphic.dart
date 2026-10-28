import 'package:flutter/material.dart';

/// Graphic widget representing circadian rhythm / celestial cycle.
/// Designed with subtle concentric rings and ambient glow matching SleepWise aesthetic.
class CircadianHeroGraphic extends StatelessWidget {
  final double size;

  const CircadianHeroGraphic({
    super.key,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ambient glow
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F4F46E5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Outer ring
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x334B5E80),
                  width: 1.5,
                ),
              ),
            ),

            // Middle ring
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x1F818CF8),
                  width: 1.0,
                ),
              ),
            ),

            // Main dark celestial disc
            Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF151B2E),
                    Color(0xFF0E1322),
                  ],
                  stops: [0.3, 1.0],
                ),
                border: Border.all(
                  color: const Color(0x38334155),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
            ),

            // Inner subtle core disc
            Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF192035),
                    Color(0xFF101524),
                  ],
                ),
                border: Border.all(
                  color: const Color(0x2264748B),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
