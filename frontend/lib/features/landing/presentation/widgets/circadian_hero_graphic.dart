import 'package:flutter/material.dart';

/// Graphic widget representing circadian rhythm / celestial cycle
/// with the prominent SleepWise brand logo in the center.
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
                    color: Color(0x334F46E5),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Color(0x2638BDF8),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Outer subtle celestial ring
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
              width: size * 0.84,
              height: size * 0.84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x26818CF8),
                  width: 1.0,
                ),
              ),
            ),

            // Center SleepWise Logo
            Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1B4A),
                border: Border.all(
                  color: const Color(0x4D818CF8),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.nightlight_round,
                        size: 60,
                        color: Color(0xFF38BDF8),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
