import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/data/datasources/auth_api_services.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/presentation/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = AuthApiService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      String? deviceFcmToken;
      try {
        deviceFcmToken = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 5));
        debugPrint("Berhasil mendapatkan FCM Token: $deviceFcmToken");
      } catch (e) {
        debugPrint("Gagal mendapatkan FCM Token (skip): $e");
      }

      await _service.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        fcmToken: deviceFcmToken,
      );

      if (!mounted) return;

      final role = AuthSession.role?.toLowerCase();

      // Popup login berhasil
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Login Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Selamat datang, ${AuthSession.userName ?? "User"}!',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Widget destination;
      if (role == 'kader') {
        destination = const DashboardKaderScreen();
      } else {
        destination = const DashboardScreen();
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Extract clean error message
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      if (message.isEmpty) {
        message = 'Username/email atau password salah. Silakan coba lagi.';
      }

      // Popup login gagal
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Login Gagal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Color(0xFF185FA5), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Generasi Sehat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF185FA5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sistem Informasi Kesehatan Ibu dan Anak',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      
                      const SizedBox(height: 20),
                      Semantics(
                        identifier: 'username_input',
                        child: TextFormField(
                          key: const Key('username_input'),
                          controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Username / Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username atau email wajib diisi';
                          }

                          final v = value.trim();

                          // Jika mengandung '@', perlakukan sebagai email dan validasi formatnya.
                          // Selain itu (username biasa atau nomor hp) diterima apa adanya;
                          // backend yang menentukan apakah identifier valid.
                          if (v.contains('@')) {
                            final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                            if (!emailRegex.hasMatch(v)) {
                              return 'Pastikan format email benar (contoh: pengguna@gmail.com)';
                            }
                          }

                          return null;
                        },
                      ),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        identifier: 'password_input',
                        child: TextFormField(
                          key: const Key('password_input'),
                          controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          return null;
                        },
                      ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        identifier: 'login_button',
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                          key: const Key('login_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF185FA5),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
