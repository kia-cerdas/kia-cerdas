import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/auth/data/datasources/auth_api_services.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_ibu_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/services/profil_ibu_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/profil_ibu_screen.dart'
    as profil_ibu;
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/detail_riwayat_kehamilan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/profil_keluarga_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
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
            child:
                Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
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
      await _authService.logout();
    } catch (_) {
      await AuthSession.clear();
    } finally {
      if (mounted) _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        // ── HEADER BIRU ─────────────────────────────────────────
        _buildHeader(profil),

        // ── MENU LIST ───────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildMenuTile(
                      icon: Icons.person_outline,
                      label: 'Profil Ibu',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const profil_ibu.ProfilScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.people_outline,
                      label: 'Profil Keluarga',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfilKeluargaScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuTile(
                      icon: Icons.history_outlined,
                      label: 'Riwayat Kehamilan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _RiwayatKehamilanListScreen(
                            list: profil.riwayatKehamilan,
                          ),
                        ),
                      ),
                    ),
                    // ruang agar tidak tertutup tombol keluar
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // ── TOMBOL KELUAR — menempel di bawah ─────────────
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoggingOut ? null : _konfirmasiLogout,
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.logout, size: 18, color: AppColors.danger),
                    label: Text(
                      _isLoggingOut ? 'Memproses...' : 'Keluar Akun',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(ProfilIbuModel profil) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
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
                          ? 'Pengguna'
                          : profil.namaLengkap,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profil.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    if (profil.statusKehamilan.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Text(
                          profil.statusKehamilan,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── MENU TILE ─────────────────────────────────────────────────
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      color: Colors.white,
      child: Divider(
        height: 1,
        thickness: 1,
        indent: 20,
        endIndent: 20,
        color: AppColors.borderLight,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  RIWAYAT KEHAMILAN LIST SCREEN  (inline, tidak perlu file baru)
// ══════════════════════════════════════════════════════════════════

class _RiwayatKehamilanListScreen extends StatelessWidget {
  final List<RiwayatKehamilanSingkat> list;

  const _RiwayatKehamilanListScreen({required this.list});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
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
      body: Column(children: [
        // ── HEADER PUTIH ─────────────────────────────────────────────
        Container(
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
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF1E293B), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF185FA5).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.history_outlined,
                            color: Color(0xFF185FA5), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Kehamilan',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Daftar riwayat kehamilan ibu',
                            style: TextStyle(
                              color: Color(0xFF64748B),
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
        ),
        // ── KONTEN ───────────────────────────────────────────────────
        Expanded(child: list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pregnant_woman_outlined,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada riwayat kehamilan.',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = list[index];
                final nomor = index + 1;

                final int id;
                if (item.id is int) {
                  id = item.id as int;
                } else if (item.id is String) {
                  id = int.tryParse(item.id as String) ?? 0;
                } else {
                  id = 0;
                }

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailRiwayatKehamilanScreen(
                          kehamilanId: id,
                          nomorKehamilan: nomor,
                          statusKehamilan: item.statusKehamilan,
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.blue100,
                            child: Text(
                              '$nomor',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kehamilan ke-$nomor',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 2,
                                  children: [
                                    _infoText(
                                        'G${item.gravida} P${item.paritas} A${item.abortus}'),
                                    if (item.hpht.isNotEmpty)
                                      _infoText(
                                          'HPHT: ${_formatDate(item.hpht)}'),
                                    if (item.taksiranPersalinan.isNotEmpty)
                                      _infoText(
                                          'HPL: ${_formatDate(item.taksiranPersalinan)}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (item.statusKehamilan.isNotEmpty)
                                _statusBadge(item.statusKehamilan),
                              const SizedBox(height: 4),
                              Icon(Icons.chevron_right,
                                  size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ),
      ]),
    );
  }

  Widget _infoText(String text) => Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'hamil':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'nifas':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}