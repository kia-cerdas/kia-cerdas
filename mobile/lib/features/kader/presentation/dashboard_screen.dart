import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/pilih_status_kunjungan.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/profil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_bottom_nav.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_header.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/riwayat_skrining_tanda_bahaya_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_balita_screen.dart';
// Bagian Ibu
import 'package:ta_pa2_pa3_project/features/kader/screens/ttd_mms/rekap_ttd_mms_kader_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_nifas_screen.dart';

class DashboardKaderScreen extends StatefulWidget {
  const DashboardKaderScreen({super.key});

  @override
  State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _selectedNavIndex = 0;

  final List<String> allowedRoles = ['kader'];

  bool get isAllowed {
    final role = AuthSession.role?.trim().toLowerCase();
    return allowedRoles.contains(role);
  }

  @override
  Widget build(BuildContext context) {
    if (!isAllowed) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 72, color: Colors.red.shade300),
                const SizedBox(height: 20),
                const Text(
                  'Akses Ditolak',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Halaman ini hanya dapat diakses oleh kader.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget body;

    switch (_selectedNavIndex) {
      case 0:
        body = _buildHomeBody();
        break;
      case 1:
        body = const Center(child: Text('Kunjungan'));
        break;
      case 2:
        body = const ProfilScreen();
        break;
      default:
        body = _buildHomeBody();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: body,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// HEADER (BALIK LAGI)
          const DashboardHeader(),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tugas Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildTaskInfoCard(
                  title: 'Posyandu Melati',
                  subtitle: 'Pencatatan aktivitas kader',
                  time: '08:30',
                  icon: Icons.local_hospital_outlined,
                  color: Colors.teal,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Peringatan Jadwal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildEscalationCard(
                  title: 'Ada jadwal kunjungan yang perlu dilakukan segera.',
                  level: 'Sedang',
                  icon: Icons.warning_amber_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PilihStatusKunjunganScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Verifikasi Skrining',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildFeatureActionCard(
                  title: 'Periksa hasil skrining tanda bahaya anak.',
                  subtitle:
                      'Tinjau pengisian ibu dan berikan status verifikasi di sini.',
                  icon: Icons.fact_check_rounded,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RiwayatSkriningTandaBahayaScreen(
                          showAllRecords: true,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildFeatureActionCard(
                  title: 'Verifikasi Kelas Ibu Balita.',
                  subtitle:
                      'Tinjau dan verifikasi kehadiran pada Kelas Ibu Balita.',
                  icon: Icons.checklist_rtl_rounded,
                  accentColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerifikasiAbsensiKelasIbuBalitaScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),



                _buildFeatureActionCard(
                  title: 'Pemantauan TTD/MMS Ibu Hamil.',
                  subtitle: 'Lihat rekap kepatuhan minum suplemen ibu hamil di wilayah kamu.',
                  icon: Icons.medication_liquid_outlined,
                  accentColor: Colors.pink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RekapTTDMMSKaderScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildFeatureActionCard(
                  title: 'Verifikasi Kelas Ibu Hamil.',
                  subtitle: 'Tinjau dan verifikasi kehadiran ibu hamil di kelas.',
                  icon: Icons.pregnant_woman_rounded,
                  accentColor: Colors.pink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerifikasiAbsensiKelasIbuHamilScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                  _buildFeatureActionCard(
                    title: 'Pemantauan Ibu Hamil.',
                    subtitle:
                        'Tinjau laporan keluhan mingguan ibu hamil dan tandai sudah ditinjau.',
                    icon: Icons.monitor_heart_outlined,
                    accentColor: Colors.pink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerifikasiPemantauanIbuHamilScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildFeatureActionCard(
                    title: 'Pemantauan Ibu Nifas.',
                    subtitle:
                        'Tinjau laporan keluhan harian ibu nifas dan tandai sudah ditinjau.',
                    icon: Icons.favorite_border_rounded,
                    accentColor: Color(0xFF7B52AB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerifikasiPemantauanIbuNifasScreen(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                const Text(
                  'Ringkasan Desa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Ibu Hamil', '12', Colors.pink),
                      _buildSummaryItem('Anak', '45', Colors.blue),
                      _buildSummaryItem('Perlu Tindak', '3', Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// INFO CARD (NON CLICKABLE)
  /// =========================
  Widget _buildTaskInfoCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ESCALATION CARD (CLICKABLE)
  /// =========================
  Widget _buildFeatureActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.12),
              accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Buka verifikasi',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscalationCard({
    required String title,
    required String level,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    Color statusColor = level == 'Penting' ? Colors.red : Colors.orange;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: statusColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk lihat detail',
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
