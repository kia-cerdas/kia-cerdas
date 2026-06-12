import 'package:flutter/material.dart';
import 'perawatan_bayi_screen.dart';
import 'perawatan_anak_bayi_screen.dart';
import 'perawatan_anak_screen.dart';
import 'perawatan_screen_integrated.dart';

class PilihPerawatanScreen extends StatelessWidget {
  final int? anakId;
  final String? anakName;
  
  const PilihPerawatanScreen({
    super.key,
    this.anakId,
    this.anakName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Perawatan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Pilih kategori perawatan',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildCard(
              context,
              icon: Icons.child_care,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              title: 'Bayi',
              subtitle: 'Panduan perawatan bayi usia 0 – 12 bulan',
              onTap: () {
                if (anakId != null && anakName != null) {
                  // Navigate to integrated screen with anak data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerawatanScreenIntegrated(
                        anakId: anakId!,
                        anakName: anakName!,
                      ),
                    ),
                  );
                } else {
                  // Navigate to static info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PerawatanBayiScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.family_restroom,
              iconColor: const Color(0xFF16A34A),
              bgColor: const Color(0xFFF0FDF4),
              title: 'Anak Bayi',
              subtitle: 'Panduan perawatan anak usia 1 tahun hingga 2 tahun',
              onTap: () {
                if (anakId != null && anakName != null) {
                  // Navigate to integrated screen with anak data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerawatanScreenIntegrated(
                        anakId: anakId!,
                        anakName: anakName!,
                      ),
                    ),
                  );
                } else {
                  // Navigate to static info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PerawatanAnakBayiScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.boy,
              iconColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFFFBEB),
              title: 'Anak',
              subtitle: 'Panduan perawatan anak usia 2 tahun hingga 6 tahun',
              onTap: () {
                if (anakId != null && anakName != null) {
                  // Navigate to integrated screen with anak data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerawatanScreenIntegrated(
                        anakId: anakId!,
                        anakName: anakName!,
                      ),
                    ),
                  );
                } else {
                  // Navigate to static info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PerawatanAnakScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}