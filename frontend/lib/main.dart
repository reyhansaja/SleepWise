import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard_view.dart';

// Entry point aplikasi mengatur tema global dan membuka halaman dashboard.
void main() {
  runApp(const SleepWiseApp());
}

// Aplikasi utama mendaftarkan tema serta DashboardView sebagai halaman awal.
class SleepWiseApp extends StatelessWidget {
  const SleepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1022),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7778F5),
          surface: Color(0xFF192238),
        ),
        useMaterial3: true,
      ),
      home: const DashboardView(),
    );
  }
}
