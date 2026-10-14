import 'package:flutter/material.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SleepWiseApp());
}

class SleepWiseApp extends StatelessWidget {
  final String initialRoute;

  const SleepWiseApp({super.key, this.initialRoute = AppRoutes.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
