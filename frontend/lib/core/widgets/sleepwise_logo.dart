import 'package:flutter/material.dart';

class SleepWiseLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool isCircle;
  final bool showShadow;
  final bool showBorder;

  const SleepWiseLogo({
    super.key,
    this.size = 70,
    this.borderRadius,
    this.isCircle = false,
    this.showShadow = true,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = isCircle ? size / 2 : (borderRadius ?? size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4A),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(effectiveRadius),
        border: showBorder
            ? Border.all(
                color: const Color(0xFF2E3258),
                width: size > 40 ? 1.5 : 1.0,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0x336366F1),
                  blurRadius: size * 0.25,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.nightlight_round,
                size: size * 0.5,
                color: const Color(0xFF38BDF8),
              ),
            );
          },
        ),
      ),
    );
  }
}
