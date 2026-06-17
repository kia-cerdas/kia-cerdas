import 'package:flutter/material.dart';
import 'anak/cari_anak_screen.dart';

/// Wrapper screen untuk navigasi langsung ke CariAnakScreen   
class TumbuhKembangScreen extends StatelessWidget {
  const TumbuhKembangScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigasi langsung ke CariAnakScreen saat screen dibuild
    Future.microtask(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CariAnakScreen(),
        ),
      );
    });

    // Tampilkan loading indicator saat navigasi berlangsung
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
