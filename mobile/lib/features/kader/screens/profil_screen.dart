// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
// // import 'edukasi_detail_screen.dart';

// class ProfilScreen extends StatefulWidget {
//   const ProfilScreen({Key? key}) : super(key: key);

//   @override
//   State<ProfilScreen> createState() => _ProfilScreenState();
// }

// class _ProfilScreenState extends State<ProfilScreen> {
//   Future<void> _logout() async {
//     await AuthSession.clear();
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         // leading: IconButton(
//         //   icon: const Icon(
//         //     Icons.arrow_back_ios_new,
//         //     color: Color(0xFF1E293B),
//         //     size: 20,
//         //   ),
//         //   onPressed: () => Navigator.pop(context),
//         // ),
//         title: const Text(
//           'Profil',
//           style: TextStyle(
//             color: Color(0xFF1E293B),
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1.0),
//           child: Container(
//             color: Colors.grey.shade200,
//             height: 1.0,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _logout,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFEF4444),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Logout',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/widgets/confirm_helper.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import '../models/kader_profil_model.dart';
import '../services/kader_profil_api_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({Key? key}) : super(key: key);

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _apiService = KaderProfilApiService();
  Future<KaderProfilModel>? _futureProfil;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    if (AuthSession.token == null || AuthSession.token!.isEmpty) {
      await AuthSession.initialize();
    }
    if (!mounted) return;
    if (AuthSession.token == null || AuthSession.token!.isEmpty) {
      _navigateToLogin();
      return;
    }
    setState(() {
      _futureProfil = _apiService.getProfilSaya();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _konfirmasiLogout() async {
    if (_isLoggingOut) return;
    
    final confirmed = await context.showConfirm(
      title: 'Keluar Akun',
      message: 'Apakah kamu yakin ingin keluar dari akun kader ini?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
    );

    if (!confirmed) return;
    _doLogout();
  }

  Future<void> _doLogout() async {
    setState(() => _isLoggingOut = true);
    await AuthSession.clear();
    if (mounted) _navigateToLogin();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Kader',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _futureProfil == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<KaderProfilModel>(
              future: _futureProfil,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                return _buildContent(snapshot.data!);
              },
            ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            const Text('Gagal memuat profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProfil,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTTL(String tempat, String tanggal) {
    if (tempat.isEmpty && tanggal.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      final ttlTempat = tempat.isEmpty ? '-' : tempat;
      return '$ttlTempat, ${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return '$tempat, $tanggal';
    }
  }

  Widget _buildContent(KaderProfilModel profil) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Biru ──
          Container(
            width: double.infinity,
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profil.namaLengkap.isEmpty
                                ? 'Kader'
                                : profil.namaLengkap,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Kader Posyandu',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _statusChipWhite(profil.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // ── Data Pribadi ──
                _buildSectionCard(
                  icon: Icons.person_outline,
                  title: 'Data Pribadi',
                  children: [
                    _buildInfoRow('NIK', profil.nik),
                    _buildInfoRow('Nama Lengkap', profil.namaLengkap),
                    _buildInfoRow('Jenis Kelamin', profil.jenisKelamin),
                    _buildInfoRow('Tempat, Tgl Lahir', _formatTTL(profil.tempatLahir, profil.tanggalLahir)),
                    _buildInfoRow('Golongan Darah', profil.golonganDarah),
                    _buildInfoRow('Agama', profil.agama),
                    _buildInfoRow('Pendidikan Terakhir', profil.pendidikanTerakhir),
                    _buildInfoRow('Pekerjaan', profil.pekerjaan),
                    _buildInfoRow('No. Telepon', profil.telepon),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Alamat ──
                _buildSectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  children: [
                    _buildInfoRow('Dusun', profil.dusun),
                    _buildInfoRow('Desa / Kelurahan', profil.desa),
                    _buildInfoRow('Kecamatan', profil.kecamatan),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Info Posyandu ──
                _buildSectionCard(
                  icon: Icons.local_hospital_outlined,
                  title: 'Tugas Posyandu',
                  children: [
                    _buildInfoRow('Nama Posyandu', profil.posyanduNama),
                    _buildInfoRow(
                      'Terdaftar Sejak',
                      _formatDate(profil.createdAt),
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Tombol Logout ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoggingOut ? null : _konfirmasiLogout,
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.logout, size: 18),
                    label: Text(_isLoggingOut ? 'Memproses...' : 'Keluar dari Akun'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
    
  }

  // ── Helpers ──

  Widget _statusChipWhite(String status) {
    final text = status.isEmpty ? '-' : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ]),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E)),
            ),
          ),
        ],
      ),
    );
  }
}