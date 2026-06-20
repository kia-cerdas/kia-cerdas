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
      // try {
      //   deviceFcmToken = await FirebaseMessaging.instance.getToken();
      //   debugPrint("Berhasil mendapatkan FCM Token: $deviceFcmToken");
      // } catch (e) {
      //   debugPrint("Gagal mendapatkan FCM Token: $e");
      // }
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
// AMBIL ROLE DARI SESSION YANG BARU DISIMPAN
      final role = AuthSession.role?.toLowerCase();
      Widget destination;
      if (role == 'kader') {
        destination =
            const DashboardKaderScreen();
      } else {
        destination = const DashboardScreen();
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                        'Masuk Akun KIA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gunakan email dan password untuk mengakses fitur yang membutuhkan bearer token.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email / No HP',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        // validator: (value) {
                        //   if (value == null || value.trim().isEmpty) {
                        //     return 'Identifier wajib diisi';
                        //   }
                        //   return null;
                        // },
                                                validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Identifier wajib diisi';
                          }
                          
                          final v = value.trim();
                          
                          // Cek apakah ini No HP (dimulai angka)
                          final isPhoneNumber = RegExp(r'^[0-9]').hasMatch(v);
                          
                          if (!isPhoneNumber) {
                            // Jika bukan No HP, maka WAJIB format email valid
                            final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                            if (!emailRegex.hasMatch(v)) {
                              return 'Pastikan format email benar (contoh: pengguna@gmail.com)';
                            }
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
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
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
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
