import 'package:flutter/material.dart';

/// Top header for the Landing Page containing the SleepWise logo,
/// brand name, and the "AI HEALTH" badge.
class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand Emblem Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B3A),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF2E3258),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x336366F1),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _SleepWiseEmblemPainter(),
          ),
        ),
        const SizedBox(width: 12),

        // Brand Name
        const Text(
          'SleepWise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 12),

        // "AI HEALTH" Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0C2526),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF13423F),
              width: 1,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI',
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'HEALTH',
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the SleepWise wave + sparkle brand emblem
class _SleepWiseEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;

    // Outer subtle arc (moon crescent motif)
    final arcPaint = Paint()
      ..color = const Color(0xFF818CF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -2.4,
      3.8,
      false,
    );
    canvas.drawPath(path, arcPaint);

    // Flowing inner cyan wave
    final wavePaint = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    wavePath.moveTo(size.width * 0.32, size.height * 0.58);
    wavePath.quadraticBezierTo(
      size.width * 0.44,
      size.height * 0.70,
      size.width * 0.54,
      size.height * 0.52,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.62,
      size.height * 0.40,
      size.width * 0.70,
      size.height * 0.46,
    );
    canvas.drawPath(wavePath, wavePaint);

    // Sparkle star at top right
    final starPaint = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.fill;

    _drawFourPointStar(
      canvas,
      Offset(size.width * 0.64, size.height * 0.38),
      size.width * 0.08,
      starPaint,
    );
  }

  void _drawFourPointStar(
    Canvas canvas,
    Offset origin,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(origin.dx, origin.dy - radius);
    path.quadraticBezierTo(
      origin.dx,
      origin.dy,
      origin.dx + radius,
      origin.dy,
    );
    path.quadraticBezierTo(
      origin.dx,
      origin.dy,
      origin.dx,
      origin.dy + radius,
    );
    path.quadraticBezierTo(
      origin.dx,
      origin.dy,
      origin.dx - radius,
      origin.dy,
    );
    path.quadraticBezierTo(
      origin.dx,
      origin.dy,
      origin.dx,
      origin.dy - radius,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
