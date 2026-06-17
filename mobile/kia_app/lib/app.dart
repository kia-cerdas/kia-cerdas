import 'package:flutter/material.dart';
import 'core/services/auth_session.dart';
import 'core/services/unauthorized_handler.dart';
import 'core/themes/app_theme.dart';
import 'core/services/notification_service.dart';

import 'features/auth/presentation/screens/login_screen.dart';

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/kader/presentation/dashboard_screen.dart';

import 'core/routes/navigator_key.dart';

class KiaApp extends StatelessWidget {
  const KiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi KIA Cerdas',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      // navigatorKey: UnauthorizedHandler.navigatorKey,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    /// Belum login
    if (!AuthSession.isLoggedIn) {
      return const LoginScreen();
    }

    final role = AuthSession.role?.trim().toLowerCase();

    /// Redirect berdasarkan role
    switch (role) {
      case 'kader':
        return const DashboardKaderScreen();

      case 'ibu':
        return const DashboardScreen();

      default:
        return const LoginScreen();
    }
  }
}
