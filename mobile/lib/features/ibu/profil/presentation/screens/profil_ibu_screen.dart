// lib/features/ibu/profil/presentation/screens/profil_ibu_screen.dart

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/data/datasources/auth_api_services.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/widgets/ibu_gradient_header.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_ibu_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/services/profil_ibu_api_service.dart';


class ProfilIbuScreen extends StatefulWidget {
  const ProfilIbuScreen({super.key});

  @override
  State<ProfilIbuScreen> createState() => _ProfilIbuScreenState();
}

class _ProfilIbuScreenState extends State<ProfilIbuScreen>
    with AutomaticKeepAliveClientMixin {
  final _service = ProfilIbuApiService();
  final _authService = AuthApiService();
  Future<ProfilIbuModel>? _futureProfil;
  bool _isLoggingOut = false;

  @override
  bool get wantKeepAlive => false;

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
    _authService.dispose();
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

  void _konfirmasiLogout() {
    if (_isLoggingOut) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _doLogout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await _authService.logout(); // clears AuthSession + SharedPreferences
    } catch (_) {
      // Clear anyway even if request fails
      await AuthSession.clear();
    } finally {
      if (mounted) _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: IbuGradientHeader(
        title: 'Profil Saya',
        subtitle: 'Data pribadi & riwayat kehamilan',
        actions: [
          IconButton(
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: _isLoggingOut ? null : _konfirmasiLogout,
          ),
        ],
      ),
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
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarHeader(profil),
          const SizedBox(height: 20),
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
                    : '${profil.tempatLahir.isEmpty ? '-' : profil.tempatLahir}'
                        ', ${_formatDate(profil.tanggalLahir)}',
              ),
              _buildInfoRow('Golongan Darah', profil.golonganDarah),
              _buildInfoRow('Agama', profil.agama),
              _buildInfoRow('Status Perkawinan', profil.statusPerkawinan),
              _buildInfoRow('Pendidikan Terakhir', profil.pendidikanTerakhir),
              _buildInfoRow('Pekerjaan', profil.pekerjaan),
            ],
          ),
          const SizedBox(height: 16),
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
              ),
              _buildInfoRow(
                'Status Kehamilan',
                profil.statusKehamilan.isEmpty ? '-' : profil.statusKehamilan,
                chip: _statusChip(profil.statusKehamilan),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRiwayatKehamilan(profil.riwayatKehamilan),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader(ProfilIbuModel profil) {
    final nama = profil.namaLengkap.isNotEmpty
        ? profil.namaLengkap
        : AuthSession.userName ?? '-';
    final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary,
          child: Text(inisial,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(profil.email.isNotEmpty ? profil.email : '-',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
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
              color: AppColors.shadow,
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
                  style: TextStyle(
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

  Widget _buildInfoRow(String label, String value, {Widget? chip}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: chip ??
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'hamil':
        bg = AppColors.blue100;
        fg = AppColors.primary;
        break;
      case 'nifas':
        bg = AppColors.orange100;
        fg = AppColors.warning;
        break;
      case 'selesai':
        bg = AppColors.green100;
        fg = AppColors.secondary;
        break;
      default:
        bg = AppColors.borderLight;
        fg = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.isEmpty ? '-' : status,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildRiwayatKehamilan(List<RiwayatKehamilanSingkat> list) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
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
              Icon(Icons.history, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Riwayat Kehamilan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${list.length} kehamilan',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Divider(height: 1),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('Belum ada riwayat kehamilan.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _buildRiwayatItem(list[i], i + 1),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(RiwayatKehamilanSingkat item, int nomor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.blue100,
              child: Text('$nomor',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 8),
            Text('Kehamilan ke-$nomor',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const Spacer(),
            if (item.statusKehamilan.isNotEmpty)
              _statusChip(item.statusKehamilan),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _miniInfo('G${item.gravida} P${item.paritas} A${item.abortus}',
                  Icons.pregnant_woman),
              if (item.hpht.isNotEmpty)
                _miniInfo(
                    'HPHT: ${_formatDate(item.hpht)}', Icons.calendar_today),
              if (item.taksiranPersalinan.isNotEmpty)
                _miniInfo('HPL: ${_formatDate(item.taksiranPersalinan)}',
                    Icons.event),
              if (item.bbAwal > 0)
                _miniInfo('BB: ${item.bbAwal.toStringAsFixed(1)} kg',
                    Icons.monitor_weight_outlined),
              if (item.tb > 0)
                _miniInfo(
                    'TB: ${item.tb.toStringAsFixed(1)} cm', Icons.height),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(text,
            style:
                TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}