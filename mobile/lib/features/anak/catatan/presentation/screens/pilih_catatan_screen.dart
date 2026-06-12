import 'package:flutter/material.dart';
import 'catatan_menu_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/presentation/screens/Input_bbl.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/screens/anak/pilih_anak_screen.dart';

const _kPrimary   = Color(0xFF185FA5);
const _kPrimaryBg = Color(0xFFE8F1FB);

class PilihCatatanScreen extends StatelessWidget {
  final int anakId;
  final String anakName;
  final String usiaTeks;

  const PilihCatatanScreen({
    Key? key,
    required this.anakId,
    required this.anakName,
    required this.usiaTeks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Catatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Banner ──────────────────────────────
            Container(
              width: double.infinity,
              color: _kPrimary,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan Tumbuh Kembang Anak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Catatan kesehatan untuk memantau pertumbuhan,\nperkembangan, dan kondisi anak secara berkala.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu Cards ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: [
                  _buildMenuCard(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'Bayi Baru Lahir (BBL)',
                    subtitle:
                        'Masukkan data Bayi Baru Lahir sebagai awal pemantauan kesehatan.',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputBblScreen(
                          namaAnak: anakName,
                          usiaTeks: usiaTeks,
                          anakId: anakId.toString(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'Riwayat Catatan Kesehatan',
                    subtitle:
                        'Lihat riwayat catatan kesehatan, gigi, dan LiLA anak.',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CatatanMenuScreen(
                          anakId: anakId,
                          anakName: anakName,
                          usiaTeks: usiaTeks,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: _kPrimary),
              ),
              const SizedBox(width: 14),
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}