import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/pemantauan_menu_screen.dart';
import 'warna_tinja_screen.dart';
import 'warna_air_kencing_screen.dart';
import 'tanda_bahaya_screen.dart';
import 'lila_screen.dart';
import 'perawatan/perawatan_perkembangan_screen.dart';
import 'deteksi_gejala_darurat_screen.dart';

class MenuPemantauanScreen extends StatelessWidget {
  // const MenuPemantauanScreen({Key? key}) : super(key: key);
  final Map<String, dynamic> anak;

  const MenuPemantauanScreen({
    super.key,
    required this.anak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Perkembangan Anak',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Section
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFE0E7FF),
                    child: const Center(
                      child: Icon(
                        Icons.health_and_safety,
                        color: Color(0xFF4F46E5),
                        size: 64,
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cek Kesehatan Mandiri',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Pantau kondisi si kecil secara rutin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Cards
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                child: Column(
                  children: [
                    // MENU 5: PERAWATAN
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeteksiGejalaDaruratScreen(anak: anak),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: _menuCard(
                        icon: Icons.notification_important_rounded,
                        title: 'Deteksi Gejala Darurat',
                        subtitle: 'Deteksi cepat gejala tanpa rentang usia',
                        color: const Color(0xFFFFF1F2),
                        iconBgColor: const Color(0xFFFFE4E6),
                        iconColor: const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // MENU 1: WARNA TINJA
                    // MENU 3: TANDA BAHAYA
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PemantauanMenuScreen(anak: anak),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: _menuCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Skrining Tanda Bahaya',
                        subtitle: 'Bayi 0-28 Hari & Balita 29 Hari-5 Thn',
                        color: const Color(0xFFFEF2F2),
                        iconBgColor: const Color(0xFFFEE2E2),
                        iconColor: const Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // MENU: DETEKSI GEJALA DARURAT
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerawatanPerkembanganScreen(anak: anak),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: _menuCard(
                        icon: Icons.medical_services_outlined,
                        title: 'Perawatan Perkembangan',
                        subtitle: 'Pantau perkembangan dan pola asuh anak',
                        // color: const Color(0xFFF0FDF4),
                        // iconBgColor: const Color(0xFFD1FAE5),
                        // iconColor: const Color(0xFF10B981),
                        color: const Color(0xFFFFF7ED),
                        iconBgColor: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WarnaTinjaScreen(anak: anak),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: _menuCard(
                        icon: Icons.baby_changing_station,
                        title: 'Cek Warna Tinja',
                        subtitle: 'Input usia 2 mgg, 1 bln, 2-4 bln',
                        color: const Color(0xFFFFF7ED),
                        iconBgColor: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // MENU 2: WARNA AIR KENCING
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WarnaAirKencingScreen()),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: _menuCard(
                        icon: Icons.water_drop_outlined,
                        title: 'Warna Air Kencing',
                        subtitle: 'Pemantauan hidrasi 12 - 24 Bulan',
                        // color: const Color(0xFFFFF7ED),
                        // iconBgColor: const Color(0xFFFFEDD5),
                        // iconColor: const Color(0xFFEA580C),
                        color: const Color(0xFFF0FDF4),
                        iconBgColor: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                    // const SizedBox(height: 12),
                    // // MENU 4: LINGKAR LENGAN ATAS (LiLA)
                    // InkWell(
                    //   onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => const LilaScreen()),
                    //     // MaterialPageRoute(builder: (_) => const LilaScreen()),
                    //   ),
                    //   borderRadius: BorderRadius.circular(16),
                    //   child: _menuCard(
                    //     icon: Icons.pattern,
                    //     title: 'Pola Asuh',
                    //     subtitle: 'Informasi terkait pola asuh anak',
                    //     color: const Color(0xFFF5F3FF),
                    //     iconBgColor: const Color(0xFFEDE9FE),
                    //     iconColor: const Color(0xFF7C3AED),
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconBgColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 28),
        ],
      ),
    );
  }
}
