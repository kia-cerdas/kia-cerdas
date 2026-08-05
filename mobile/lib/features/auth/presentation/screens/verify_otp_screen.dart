import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/auth/data/datasources/auth_api_services.dart';
import 'reset_password_screen.dart';


class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _service = AuthApiService();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _service.verifyOtp(widget.email, _otpController.text.trim());
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: widget.email, otp: _otpController.text.trim())),
      );
    } catch (e) {
      if (!mounted) return;
      String message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF185FA5))),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF7FAFB)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Verifikasi OTP', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF185FA5))),
                      const SizedBox(height: 8),
                      Text('Masukkan 6 digit kode yang dikirim ke\n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ""),
                        validator: (value) {
                          if (value == null || value.trim().length != 6) return 'OTP harus 6 digit';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF185FA5)),
                          onPressed: _loading ? null : _submit,
                          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verifikasi'),
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