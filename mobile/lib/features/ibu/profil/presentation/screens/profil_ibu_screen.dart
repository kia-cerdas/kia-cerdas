import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_ibu_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/services/profil_ibu_api_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _service = ProfilIbuApiService();
  Future<ProfilIbuModel>? _futureProfil;

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
      _futureProfil = _service.getProfilSaya();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: _futureProfil == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<ProfilIbuModel>(
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
            Text('Gagal memuat profil',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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

  Widget _buildContent(ProfilIbuModel profil) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  icon: Icons.person_outline,
                  title: 'Data Pribadi',
                  children: [
                    _buildInfoRow('NIK', profil.nik),
                    _buildInfoRow('Nama Lengkap', profil.namaLengkap),
                    _buildInfoRow(
                      'Tempat, Tgl Lahir',
                      (profil.tempatLahir.isEmpty && profil.tanggalLahir.isEmpty)
                          ? '-'
                          : '${profil.tempatLahir.isEmpty ? '-' : profil.tempatLahir}, ${_formatDate(profil.tanggalLahir)}',
                    ),
                    _buildInfoRow('Golongan Darah', profil.golonganDarah),
                    _buildInfoRow('Agama', profil.agama),
                    _buildInfoRow('Status Perkawinan', profil.statusPerkawinan),
                    _buildInfoRow('Pendidikan Terakhir', profil.pendidikanTerakhir),
                    _buildInfoRow('Pekerjaan', profil.pekerjaan, isLast: true),
                  ],
                ),

                const SizedBox(height: 14),

                _buildSectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  children: [
                    _buildInfoRow('Dusun', profil.dusun),
                    _buildInfoRow('Desa / Kelurahan', profil.desa),
                    _buildInfoRow('Kecamatan', profil.kecamatan, isLast: true),
                  ],
                ),

                const SizedBox(height: 14),

                _buildSectionCard(
                  icon: Icons.account_circle_outlined,
                  title: 'Akun',
                  children: [
                    _buildInfoRow('Email', profil.email),
                    _buildInfoRow(
                      'No. Telepon',
                      profil.nomorTelepon.isNotEmpty
                          ? profil.nomorTelepon
                          : profil.nomorTeleponPenduduk,
                      isLast: true,
                    ),
                  ],
                ),

                // Tampilkan status kehamilan di konten jika ada
                if (profil.statusKehamilan.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    icon: Icons.pregnant_woman_outlined,
                    title: 'Status Kehamilan',
                    children: [
                      _buildInfoRow('Status', profil.statusKehamilan, isLast: true),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── HEADER PUTIH (konsisten dengan absensi/edukasi) ───────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_outline,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Ibu',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Data diri & informasi akun',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

  // ── SECTION CARD ──────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ]),
          ),
          Container(height: 1, color: const Color(0xFFEEF2F7)),
          ...children,
        ],
      ),
    );
  }

  // ── INFO ROW ──────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: const Color(0xFFF1F5F9)),
          ),
      ],
    );
  }
}