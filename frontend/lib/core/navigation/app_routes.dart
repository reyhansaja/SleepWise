import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import 'main_shell.dart';

abstract final class AppRoutes {
  static const landing = '/landing';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const dashboard = '/dashboard';
  static const predict = '/predict';
  static const history = '/history';
  static const statistics = '/statistics';
  static const profile = '/profile';

  static const initialRoute = landing;

  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LandingPage(),
    landing: (context) => const LandingPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    main: (context) => const MainShell(),
    dashboard: (context) => const MainShell(initialIndex: 0),
    predict: (context) => const MainShell(initialIndex: 1),
    history: (context) => const MainShell(initialIndex: 2),
    statistics: (context) => const MainShell(initialIndex: 3),
    profile: (context) => const MainShell(initialIndex: 4),
  };
}
