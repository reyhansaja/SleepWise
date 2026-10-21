import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart'; // import provider tema global Anda

void main() {
  runApp(
    // Wajib dibungkus ProviderScope agar Riverpod aktif secara global
    const ProviderScope(
      child: SleepWiseApp(),
    ),
  );
}

class SleepWiseApp extends ConsumerWidget {
  final String initialRoute;

  const SleepWiseApp({
    super.key,
    this.initialRoute = AppRoutes.initialRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau status tema dari Riverpod (true = dark, false = light)
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SleepWise',
      debugShowCheckedModeBanner: false,
      // Daftarkan kedua tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Ganti mode secara otomatis mengikuti perubahan provider
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}