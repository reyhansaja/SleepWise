import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/history_page.dart';

void main() {
  runApp(const SleepWiseApp());
}

class SleepWiseApp extends StatelessWidget {
  const SleepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          surface: Color(0xFF121826),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}