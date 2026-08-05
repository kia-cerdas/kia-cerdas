import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/auth/data/datasources/auth_api_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = AuthApiService();
  
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _service.resetPassword(widget.email, widget.otp, _newPasswordController.text, _confirmPasswordController.text);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah. Silakan login.'), backgroundColor: Colors.green));
      
      // Kembali ke halaman Login menghapus semua rute sebelumnya
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                      const Text('Buat Password Baru', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF185FA5))),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscure1,
                        decoration: InputDecoration(
                          labelText: 'Password Baru', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure1 = !_obscure1)),
                        ),
                        validator: (value) => (value == null || value.length < 6) ? 'Minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure2 = !_obscure2)),
                        ),
                        validator: (value) => (value != _newPasswordController.text) ? 'Password tidak cocok' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF185FA5)),
                          onPressed: _loading ? null : _submit,
                          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan Password'),
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