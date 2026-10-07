import 'package:flutter/material.dart';

class SleepWiseLogo extends StatelessWidget {
  final double size;

  const SleepWiseLogo({super.key, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: const Color(0xFF232D42), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2638BDF8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/images/logo.png', // Ganti dengan lokasi logo Anda di assets
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Placeholder otomatis jika logo belum diunggah
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