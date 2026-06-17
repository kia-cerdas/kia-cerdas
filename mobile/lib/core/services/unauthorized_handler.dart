// lib/core/services/unauthorized_handler.dart
//
// Cara pakai di API service:
//   if (response.statusCode == 401) {
//     await UnauthorizedHandler.handle();
//     throw Exception('Sesi berakhir. Silakan login ulang.');
//   }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';

class UnauthorizedHandler {
  UnauthorizedHandler._();

  /// Navigator key ini harus didaftarkan ke MaterialApp di app.dart.
  /// Contoh: navigatorKey: UnauthorizedHandler.navigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Panggil ini ketika API mengembalikan status 401.
  /// Akan clear session lalu redirect ke LoginScreen (hapus semua route).
  static Future<void> handle() async {
    await AuthSession.clear();

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Pastikan tidak ada dialog/bottomsheet yang masih terbuka
    navigatorKey.currentState?.popUntil((route) => route.isFirst);

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );

    // Tampilkan snackbar info ke user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesi Anda telah berakhir. Silakan login ulang.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }
}