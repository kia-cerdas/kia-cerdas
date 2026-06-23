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

// ══════════════════════════════════════════════════════════════════
//  PROFIL MENU SCREEN
//  Halaman utama profil — menampilkan info singkat user dan
//  menu navigasi ke sub-fitur (Profil, Profil Keluarga, Kehamilan)
// ══════════════════════════════════════════════════════════════════

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

  // ──────────────────────────────────────────────────────────────
  //  ERROR STATE
  // ──────────────────────────────────────────────────────────────
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

  // ──────────────────────────────────────────────────────────────
  //  MAIN CONTENT
  // ──────────────────────────────────────────────────────────────
  Widget _buildContent(ProfilIbuModel profil) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(profil),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Grup: Data Saya ──────────────────────────
                _buildGroupLabel('Data Saya'),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  subtitle: 'Data pribadi dan akun',
                  isFirst: true,
                  isLast: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const profil_ibu.ProfilScreen(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 1,
                  color: AppColors.borderLight,
                ),
                _buildMenuCard(
                  icon: Icons.people_outline,
                  label: 'Profil Keluarga',
                  subtitle: 'Data suami dan kontak darurat',
                  isFirst: false,
                  isLast: true,
                  onTap: () {
                    // TODO: ganti dengan ProfilKeluargaScreen() bila sudah dibuat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fitur segera tersedia'),
                          duration: Duration(seconds: 2)),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ─── Grup: Riwayat ────────────────────────────
                _buildGroupLabel('Riwayat'),
                const SizedBox(height: 8),
                _buildMenuCard(
                  icon: Icons.pregnant_woman_outlined,
                  label: 'Riwayat Kehamilan',
                  subtitle: '${profil.riwayatKehamilan.length} kehamilan tercatat',
                  isFirst: true,
                  isLast: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _RiwayatKehamilanListScreen(
                        list: profil.riwayatKehamilan,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ─── Tombol Keluar ────────────────────────────
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
                    label: Text(
                        _isLoggingOut ? 'Memproses...' : 'Keluar dari Akun'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  HEADER — putih bersih, avatar circle, nama, email, badge
  // ──────────────────────────────────────────────────────────────
  Widget _buildHeader(ProfilIbuModel profil) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue100,
                border: Border.all(color: AppColors.primary, width: 2.5),
              ),
              child: Icon(Icons.person_outline,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              profil.namaLengkap.isEmpty ? 'Pengguna' : profil.namaLengkap,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profil.email,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (profil.statusKehamilan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profil.statusKehamilan,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Divider(height: 1, color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  GROUP LABEL
  // ──────────────────────────────────────────────────────────────
  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  MENU CARD ITEM  (grouped: radius hanya di ujung atas/bawah)
  // ──────────────────────────────────────────────────────────────
  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = true,
    bool isLast = true,
  }) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 12 : 0),
      topRight: Radius.circular(isFirst ? 12 : 0),
      bottomLeft: Radius.circular(isLast ? 12 : 0),
      bottomRight: Radius.circular(isLast ? 12 : 0),
    );

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: (isFirst && isLast)
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : isFirst
                    ? [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        )
                      ]
                    : isLast
                        ? [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
}

// ══════════════════════════════════════════════════════════════════
//  RIWAYAT KEHAMILAN LIST SCREEN
//  Screen inline — tidak perlu file terpisah, sudah bundled di sini
//  Menampilkan daftar kehamilan dan tap → DetailRiwayatKehamilanScreen
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
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: const Color(0xFF1A1A2E),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Kehamilan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pregnant_woman_outlined,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat kehamilan.',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500),
                  ),
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

                // Parse id
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
                          // Nomor circle
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                AppColors.blue100,
                            child: Text(
                              '$nomor',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kehamilan ke-$nomor',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 2,
                                  children: [
                                    _chip('G${item.gravida} P${item.paritas} A${item.abortus}'),
                                    if (item.hpht.isNotEmpty)
                                      _chip('HPHT: ${_formatDate(item.hpht)}'),
                                    if (item.taksiranPersalinan.isNotEmpty)
                                      _chip('HPL: ${_formatDate(item.taksiranPersalinan)}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status badge + arrow
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (item.statusKehamilan.isNotEmpty)
                                _statusBadge(item.statusKehamilan),
                              const SizedBox(height: 4),
                              Icon(Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _chip(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
  }

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
      case 'selesai':
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}