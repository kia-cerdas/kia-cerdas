import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import 'package:ta_pa2_pa3_project/core/routes/navigator_key.dart';

bool _isTokenExpiredHandled = false;

Future<void> handleTokenExpired() async {
  if (_isTokenExpiredHandled) return;
  _isTokenExpiredHandled = true;

  final context = navigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Token Anda telah kadaluarsa. Silakan login kembali.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) async {
      await AuthSession.clear();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      _isTokenExpiredHandled = false;
    });
  } else {
    await AuthSession.clear();
    _isTokenExpiredHandled = false;
  }
}
