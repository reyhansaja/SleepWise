import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_view.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1022),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7778F5),
          surface: Color(0xFF192238),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardView(),
      },
    );
  }
}