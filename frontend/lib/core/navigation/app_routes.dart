import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import 'main_shell.dart';

abstract final class AppRoutes {
  static const initialRoute = '/login';

  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/main': (context) => const MainShell(),
    '/dashboard': (context) => const MainShell(initialIndex: 0),
    '/predict': (context) => const MainShell(initialIndex: 1),
    '/history': (context) => const MainShell(initialIndex: 2),
    '/statistics': (context) => const MainShell(initialIndex: 3),
    '/profile': (context) => const MainShell(initialIndex: 4),
  };
}
