import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/pilih_status_kunjungan.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/imunisasi_terlewat.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/profil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_api_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_bottom_nav.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_header.dart';

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

class _MenuLayananItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder screenBuilder;

  /// Jika diisi, baris kedua kartu menu akan menampilkan status verifikasi
  /// dinamis (sudah/belum diverifikasi) yang dicocokkan dari data ringkasan desa
  /// berdasarkan key ini, menggantikan [subtitle] statis.
  final String? verifikasiKey;

  const _MenuLayananItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screenBuilder,
    this.verifikasiKey,
  });
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _selectedNavIndex = 0;

  final List<String> allowedRoles = ['kader'];

  final RingkasanDesaApiService _ringkasanService = RingkasanDesaApiService();
  late Future<RingkasanDesaModel> _ringkasanFuture;

  final List<_MenuLayananItem> _menuLayanan = [
    _MenuLayananItem(
      title: 'Kelas Ibu Balita',
      subtitle: 'Verifikasi kehadiran',
      icon: Icons.checklist_rtl_rounded,
      color: Colors.teal,
      screenBuilder: (_) => const VerifikasiAbsensiKelasIbuBalitaScreen(),
      verifikasiKey: 'kelas_ibu_balita',
    ),
    _MenuLayananItem(
      title: 'TTD/MMS Ibu Hamil',
      subtitle: 'Rekap kepatuhan suplemen',
      icon: Icons.medication_liquid_outlined,
      color: Colors.pink,
      screenBuilder: (_) => const RekapTTDMMSKaderScreen(),
    ),
    _MenuLayananItem(
      title: 'Kelas Ibu Hamil',
      subtitle: 'Verifikasi kehadiran',
      icon: Icons.pregnant_woman_rounded,
      color: Colors.purple,
      screenBuilder: (_) => const VerifikasiAbsensiKelasIbuHamilScreen(),
      verifikasiKey: 'kelas_ibu_hamil',
    ),
    _MenuLayananItem(
      title: 'Pemantauan Ibu Hamil',
      subtitle: 'Tinjau keluhan mingguan',
      icon: Icons.monitor_heart_outlined,
      color: Colors.red,
      screenBuilder: (_) => const VerifikasiPemantauanIbuHamilScreen(),
      verifikasiKey: 'pemantauan_ibu_hamil',
    ),
    _MenuLayananItem(
      title: 'Pemantauan Ibu Nifas',
      subtitle: 'Tinjau keluhan harian',
      icon: Icons.favorite_border_rounded,
      color: const Color(0xFF7B52AB),
      screenBuilder: (_) => const VerifikasiPemantauanIbuNifasScreen(),
      verifikasiKey: 'pemantauan_ibu_nifas',
    ),
    _MenuLayananItem(
      title: 'Imunisasi Terlewat',
      subtitle: 'Anak imunisasi terlewat',
      icon: Icons.vaccines_rounded,
      color: Colors.orange,
      screenBuilder: (_) => const DaftarImunisasiTerlewatScreen(),
    ),
  ];

  bool get isAllowed {
    final role = AuthSession.role?.trim().toLowerCase();
    return allowedRoles.contains(role);
  }

  @override
  void initState() {
    super.initState();
    _ringkasanFuture = _ringkasanService.getRingkasanDesa();
  }

  @override
  void dispose() {
    _ringkasanService.dispose();
    super.dispose();
  }

  void _reloadRingkasan() {
    setState(() {
      _ringkasanFuture = _ringkasanService.getRingkasanDesa();
    });
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
        body = const DaftarImunisasiTerlewatScreen();
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
    return RefreshIndicator(
      onRefresh: () async {
        _reloadRingkasan();
        await _ringkasanFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildInfoHariIniSection(),

                  const SizedBox(height: 24),

                  const Text(
                    'Menu Layanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  _buildMenuLayananGrid(),

                  const SizedBox(height: 24),

                  _buildRingkasanDesaHeader(),

                  const SizedBox(height: 12),

                  _buildRingkasanDesaCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// INFO HARI INI (dinamis, menggantikan "Tugas Hari Ini" + "Peringatan Jadwal")
  /// Satu kartu aksi tunggal -- jumlah ibu hamil/anak sudah ditampilkan di
  /// "Ringkasan Desa", jadi di sini cukup tampilkan hal yang perlu ditindak hari ini.
  /// =========================
  Widget _buildInfoHariIniSection() {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Info Hari Ini',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          today,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        FutureBuilder<RingkasanDesaModel>(
          future: _ringkasanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildInfoCardSkeleton();
            }

            if (snapshot.hasError) {
              return _buildInfoCardError();
            }

            final jumlahPerluTindak = snapshot.data?.perluTindakLanjut ?? 0;
            final hasWarning = jumlahPerluTindak > 0;

            return _buildEscalationCard(
              title: hasWarning
                  ? '$jumlahPerluTindak kunjungan imunisasi perlu ditindak lanjut.'
                  : 'Tidak ada kunjungan Imunisasi yang perlu ditindak lanjut saat ini.',
              isWarning: hasWarning,
              icon: hasWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PilihStatusKunjunganScreen(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Memuat ringkasan desa...',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Gagal memuat ringkasan desa.',
              style: TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: _reloadRingkasan,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// MENU LAYANAN (grid rapi, scrollable bersama halaman)
  /// =========================
  Widget _buildMenuLayananGrid() {
    return FutureBuilder<RingkasanDesaModel>(
      future: _ringkasanFuture,
      builder: (context, snapshot) {
        final ringkasan = snapshot.data;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _menuLayanan.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.05,
          ),
          itemBuilder: (context, index) {
            final item = _menuLayanan[index];
            return _buildMenuGridItem(item, ringkasan);
          },
        );
      },
    );
  }

  /// Membangun baris status menu: untuk menu yang punya [verifikasiKey], tampilkan
  /// jumlah sudah/belum diverifikasi dari data ringkasan desa; selain itu pakai
  /// subtitle statis bawaan menu.
  Widget _buildMenuStatusLine(_MenuLayananItem item, RingkasanDesaModel? ringkasan) {
    if (item.verifikasiKey == null) {
      return Text(
        item.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    if (ringkasan == null) {
      return Text(
        'Memuat...',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      );
    }

    final status = ringkasan.verifikasiByKey(item.verifikasiKey!);
    if (status == null || status.total == 0) {
      return Text(
        'Belum ada data',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      );
    }

    final allVerified = status.belumVerifikasi == 0;
    return Text(
      '${status.sudahVerifikasi}/${status.total} terverifikasi',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: allVerified ? Colors.green.shade600 : Colors.orange.shade700,
      ),
    );
  }

  Widget _buildMenuGridItem(_MenuLayananItem item, RingkasanDesaModel? ringkasan) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: item.screenBuilder),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, color: item.color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _buildMenuStatusLine(item, ringkasan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// RINGKASAN DESA (dinamis)
  /// =========================
  Widget _buildRingkasanDesaHeader() {
    return FutureBuilder<RingkasanDesaModel>(
      future: _ringkasanFuture,
      builder: (context, snapshot) {
        final namaDesa = snapshot.data?.namaDesa;
        final title = (namaDesa != null && namaDesa.isNotEmpty)
            ? 'Ringkasan Desa $namaDesa'
            : 'Ringkasan Desa';

        return Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildRingkasanDesaCard() {
    return FutureBuilder<RingkasanDesaModel>(
      future: _ringkasanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Gagal memuat ringkasan desa.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _reloadRingkasan,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data ?? RingkasanDesaModel.empty();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Ibu Hamil',
                    '${data.ibuHamil.total}',
                    Colors.pink,
                  ),
                  _buildSummaryItem(
                    'Anak',
                    '${data.jumlahAnak}',
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Perlu Tindak',
                    '${data.perluTindakLanjut}',
                    Colors.red,
                  ),
                ],
              ),
              if (data.ibuHamil.total > 0) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Text(
                  'Ibu hamil per trimester',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrimesterChip('Trimester 1', data.ibuHamil.trimester1),
                    _buildTrimesterChip('Trimester 2', data.ibuHamil.trimester2),
                    _buildTrimesterChip('Trimester 3', data.ibuHamil.trimester3),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrimesterChip(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// =========================
  /// ESCALATION CARD (CLICKABLE)
  /// =========================
  Widget _buildEscalationCard({
    required String title,
    required bool isWarning,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final statusColor = isWarning ? Colors.red : Colors.green;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: statusColor, size: 26),
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
                      fontSize: 14.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk lihat detail',
                        style: TextStyle(
                          fontSize: 12.5,
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
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
