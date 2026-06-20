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

  // Warna utama aplikasi
  static const _primary = Color(0xFF185FA5); // AppColors.primary KIA
  static const _bgColor = Color(0xFFF1F5F9); // AppColors.scaffold KIA

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      String? deviceFcmToken;
      try {
        deviceFcmToken = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 5));
        debugPrint('Berhasil mendapatkan FCM Token: $deviceFcmToken');
      } catch (e) {
        debugPrint('Gagal mendapatkan FCM Token (skip): $e');
      }

      await _service.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        fcmToken: deviceFcmToken,
      );

      if (!mounted) return;

      final role = AuthSession.role?.toLowerCase();
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
      // Tampilkan error sebagai dialog — lebih mudah dibaca ibu hamil
      // dibanding snackbar yang cepat hilang
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 22),
              SizedBox(width: 8),
              Text(
                'Gagal Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            // Buang prefix "Exception: " yang muncul dari throw Exception(...)
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: _primary),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──
                Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 90),
                ),
                const SizedBox(height: 24),

                // ── Card login ──
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Judul
                        // const Text(
                        //   'Generasi Sehat',
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 26,
                        //     fontWeight: FontWeight.w800,
                        //     color: _primary,
                        //     letterSpacing: -0.5,
                        //   ),
                        // ),
                        // const SizedBox(height: 4),
                        // const Text(
                        //   'Sistem Informasi Kesehatan Ibu dan Anak',
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 13,
                        //     color: Color(0xFF6B7280),
                        //   ),
                        // ),
                        // const SizedBox(height: 28), 

                        // Label Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Masukkan email',
                            hintStyle:
                                const TextStyle(color: Color(0xFF9CA3AF)),
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Color(0xFF9CA3AF), size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: _primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            final v = value.trim();
                            final isPhone = RegExp(r'^[0-9]').hasMatch(v);
                            if (!isPhone) {
                              final emailRegex =
                                  RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                              if (!emailRegex.hasMatch(v)) {
                                return 'Pastikan format email benar\n(contoh: nama@gmail.com)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Label Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            hintStyle:
                                const TextStyle(color: Color(0xFF9CA3AF)),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Color(0xFF9CA3AF), size: 20),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: _primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFEF4444), width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Login
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFD1D5DB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Masuk'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
