import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/screens/mpasi_materi_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/screens/mpasi_porsi_jadwal_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/screens/mpasi_resep_screen.dart';

class MpasiMenuScreen extends StatelessWidget {
  const MpasiMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MPASI',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Berdasarkan Buku KIA Terbaru 2024',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.newspaper, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Info MPASI',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MPASI diberikan bertahap sesuai perkembangan tekstur dan porsi anak',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilihan Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  context: context,
                  icon: Icons.menu_book,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.shade50,
                  title: 'Materi MPASI',
                  subtitle: 'Buku KIA 2024',
                  borderColor: Colors.blue.shade200,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MpasiMateriScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context: context,
                  icon: Icons.access_time,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.shade50,
                  title: 'Porsi & Jadwal',
                  subtitle: 'Panduan porsi dan jadwal makan anak',
                  borderColor: Colors.orange.shade200,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MpasiPorsiJadwalScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context: context,
                  icon: Icons.restaurant_menu,
                  iconColor: Colors.blue.shade700,
                  iconBgColor: Colors.blue.shade50,
                  title: 'Resep Harian',
                  subtitle: 'Resep MPASI untuk berbagai tahapan usia',
                  borderColor: Colors.grey.shade300,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MpasiResepScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
