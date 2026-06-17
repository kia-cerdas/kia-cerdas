// lib/features/ibu/profil/presentation/screens/riwayat_pemeriksaan_dokter_screen.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / pemeriksaan-dokter]
// Halaman riwayat Pemeriksaan Dokter (Trimester 1 & 3) untuk satu kehamilan.
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push.
//
// FRONTEND-ONLY. Tidak ada perubahan backend apapun.
// Menggunakan endpoint yang SUDAH ADA (route group `modul-ibu`):
//   GET /modul-ibu/pemeriksaan-dokter-trimester-1/all  → list semua T1 milik ibu
//   GET /modul-ibu/pemeriksaan-dokter-trimester-3/all  → list semua T3 milik ibu
// Filter by kehamilan_id dilakukan di frontend.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class RiwayatPemeriksaanDokterScreen extends StatefulWidget {
  final int kehamilanId;
  final int nomorKehamilan;

  const RiwayatPemeriksaanDokterScreen({
    super.key,
    required this.kehamilanId,
    required this.nomorKehamilan,
  });

  @override
  State<RiwayatPemeriksaanDokterScreen> createState() =>
      _RiwayatPemeriksaanDokterScreenState();
}

class _RiwayatPemeriksaanDokterScreenState
    extends State<RiwayatPemeriksaanDokterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loadingT1 = true;
  String? _errorT1;
  List<Map<String, dynamic>> _listT1 = [];

  bool _loadingT3 = true;
  String? _errorT3;
  List<Map<String, dynamic>> _listT3 = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadT1();
    _loadT3();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Load data ──────────────────────────────────────────────────

  Future<void> _loadT1() async {
    setState(() {
      _loadingT1 = true;
      _errorT1 = null;
    });
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        setState(() {
          _errorT1 = 'Sesi tidak ditemukan. Silakan login ulang.';
          _loadingT1 = false;
        });
        return;
      }

      // GET /modul-ibu/pemeriksaan-dokter-trimester-1/all
      // Endpoint sudah ada, return semua data T1 milik ibu (lintas kehamilan).
      // Filter by kehamilan_id di frontend.
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.pemeriksaanDokterTrimester1All}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 404) {
        setState(() {
          _listT1 = [];
          _loadingT1 = false;
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorT1 = body['message']?.toString() ??
              'Gagal memuat data pemeriksaan dokter trimester I';
          _loadingT1 = false;
        });
        return;
      }

      final rawData = body['data'];
      final allList = (rawData is List)
          ? rawData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      // Filter hanya untuk kehamilan ini
      final filtered = allList
          .where((e) =>
              (e['kehamilan_id'] as num?)?.toInt() == widget.kehamilanId)
          .toList();

      filtered.sort((a, b) {
        final da = DateTime.tryParse(a['tanggal_periksa']?.toString() ?? '');
        final db = DateTime.tryParse(b['tanggal_periksa']?.toString() ?? '');
        if (da != null && db != null) return da.compareTo(db);
        return 0;
      });

      setState(() {
        _listT1 = filtered;
        _loadingT1 = false;
      });
    } catch (e) {
      setState(() {
        _errorT1 = 'Terjadi kesalahan: $e';
        _loadingT1 = false;
      });
    }
  }

  Future<void> _loadT3() async {
    setState(() {
      _loadingT3 = true;
      _errorT3 = null;
    });
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        setState(() {
          _errorT3 = 'Sesi tidak ditemukan. Silakan login ulang.';
          _loadingT3 = false;
        });
        return;
      }

      // GET /modul-ibu/pemeriksaan-dokter-trimester-3/all
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.pemeriksaanDokterTrimester3All}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 404) {
        setState(() {
          _listT3 = [];
          _loadingT3 = false;
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorT3 = body['message']?.toString() ??
              'Gagal memuat data pemeriksaan dokter trimester III';
          _loadingT3 = false;
        });
        return;
      }

      final rawData = body['data'];
      final allList = (rawData is List)
          ? rawData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      // Filter hanya untuk kehamilan ini
      final filtered = allList
          .where((e) =>
              (e['kehamilan_id'] as num?)?.toInt() == widget.kehamilanId)
          .toList();

      filtered.sort((a, b) {
        final da = DateTime.tryParse(a['tanggal_periksa']?.toString() ?? '');
        final db = DateTime.tryParse(b['tanggal_periksa']?.toString() ?? '');
        if (da != null && db != null) return da.compareTo(db);
        return 0;
      });

      setState(() {
        _listT3 = filtered;
        _loadingT3 = false;
      });
    } catch (e) {
      setState(() {
        _errorT3 = 'Terjadi kesalahan: $e';
        _loadingT3 = false;
      });
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '-';
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  String _str(dynamic value) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? '-' : s;
  }

  String _numUnit(dynamic value, String unit) {
    if (value == null) return '-';
    if (value is num) {
      final s = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString();
      return '$s $unit';
    }
    final s = value.toString().trim();
    return s.isEmpty ? '-' : '$s $unit';
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemeriksaan Dokter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              'Kehamilan ke-${widget.nomorKehamilan}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Trimester I'),
            Tab(text: 'Trimester III'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabT1(),
          _buildTabT3(),
        ],
      ),
    );
  }

  // ── Tab Trimester 1 ────────────────────────────────────────────

  Widget _buildTabT1() {
    if (_loadingT1) return const Center(child: CircularProgressIndicator());
    if (_errorT1 != null) return _buildError(_errorT1!, _loadT1);
    if (_listT1.isEmpty) {
      return _buildEmpty('Belum ada data pemeriksaan dokter trimester I.');
    }

    return RefreshIndicator(
      onRefresh: _loadT1,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _listT1.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildItemCardT1(_listT1[i], i + 1),
      ),
    );
  }

  Widget _buildItemCardT1(Map<String, dynamic> d, int index) {
    final tanggal = _formatDate(d['tanggal_periksa']?.toString());
    final dokter = _str(d['nama_dokter']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5ECF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          title: Text(
            'Kunjungan ke-$index',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _miniInfo(Icons.calendar_today, tanggal),
                if (dokter != '-') _miniInfo(Icons.person_outline, dokter),
              ],
            ),
          ),
          children: [
            _dividerLabel('Informasi Umum'),
            _infoRow('Anamnesa', _str(d['konsep_anamnesa_pemeriksaan'])),
            _dividerLabel('Pemeriksaan Fisik'),
            _infoRow('Konjungtiva', _str(d['fisik_konjungtiva'])),
            _infoRow('Sklera', _str(d['fisik_sklera'])),
            _infoRow('Kulit', _str(d['fisik_kulit'])),
            _infoRow('Leher', _str(d['fisik_leher'])),
            _infoRow('Gigi & Mulut', _str(d['fisik_gigi_mulut'])),
            _infoRow('THT', _str(d['fisik_tht'])),
            _infoRow('Dada — Jantung', _str(d['fisik_dada_jantung'])),
            _infoRow('Dada — Paru', _str(d['fisik_dada_paru'])),
            _infoRow('Perut', _str(d['fisik_perut'])),
            _infoRow('Tungkai', _str(d['fisik_tungkai'])),
            _dividerLabel('Umur Kehamilan & HPL'),
            _infoRow('HPHT', _formatDate(d['hpht']?.toString())),
            _infoRow('Keteraturan Haid', _str(d['keteraturan_haid'])),
            _infoRow('UK (HPHT)', _numUnit(d['umur_hamil_hpht_minggu'], 'minggu')),
            _infoRow('HPL (HPHT)', _formatDate(d['hpl_berdasarkan_hpht']?.toString())),
            _infoRow('UK (USG)', _numUnit(d['umur_hamil_usg_minggu'], 'minggu')),
            _infoRow('HPL (USG)', _formatDate(d['hpl_berdasarkan_usg']?.toString())),
            _dividerLabel('USG Trimester I'),
            _infoRow('Jumlah GS', _str(d['usg_jumlah_gs'])),
            _infoRow('Diameter GS', _join3(
                _numUnit(d['usg_diameter_gs_cm'], 'cm'),
                _numUnit(d['usg_diameter_gs_minggu'], 'minggu'),
                _numUnit(d['usg_diameter_gs_hari'], 'hari'))),
            _infoRow('Jumlah Bayi', _str(d['usg_jumlah_bayi'])),
            _infoRow('CRL', _join3(
                _numUnit(d['usg_crl_cm'], 'cm'),
                _numUnit(d['usg_crl_minggu'], 'minggu'),
                _numUnit(d['usg_crl_hari'], 'hari'))),
            _infoRow('Letak Produk Kehamilan', _str(d['usg_letak_produk_kehamilan'])),
            _infoRow('Pulsasi Jantung', _str(d['usg_pulsasi_jantung'])),
            _infoRow('Temuan Abnormal', _str(d['usg_kecurigaan_temuan_abnormal'])),
            _infoRow('Keterangan Abnormal', _str(d['usg_keterangan_temuan_abnormal']),
                isLast: true),
          ],
        ),
      ),
    );
  }

  // ── Tab Trimester 3 ────────────────────────────────────────────

  Widget _buildTabT3() {
    if (_loadingT3) return const Center(child: CircularProgressIndicator());
    if (_errorT3 != null) return _buildError(_errorT3!, _loadT3);
    if (_listT3.isEmpty) {
      return _buildEmpty('Belum ada data pemeriksaan dokter trimester III.');
    }

    return RefreshIndicator(
      onRefresh: _loadT3,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _listT3.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildItemCardT3(_listT3[i], i + 1),
      ),
    );
  }

  Widget _buildItemCardT3(Map<String, dynamic> d, int index) {
    final tanggal = _formatDate(d['tanggal_periksa']?.toString());
    final dokter = _str(d['nama_dokter']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5ECF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          title: Text(
            'Kunjungan ke-$index',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _miniInfo(Icons.calendar_today, tanggal),
                if (dokter != '-') _miniInfo(Icons.person_outline, dokter),
              ],
            ),
          ),
          children: [
            _dividerLabel('Informasi Umum'),
            _infoRow('Anamnesa', _str(d['konsep_anamnesa_pemeriksaan'])),
            _dividerLabel('Pemeriksaan Fisik'),
            _infoRow('Konjungtiva', _str(d['fisik_konjungtiva'])),
            _infoRow('Sklera', _str(d['fisik_sklera'])),
            _infoRow('Kulit', _str(d['fisik_kulit'])),
            _infoRow('Leher', _str(d['fisik_leher'])),
            _infoRow('Gigi & Mulut', _str(d['fisik_gigi_mulut'])),
            _infoRow('THT', _str(d['fisik_tht'])),
            _infoRow('Dada — Jantung', _str(d['fisik_dada_jantung'])),
            _infoRow('Dada — Paru', _str(d['fisik_dada_paru'])),
            _infoRow('Perut', _str(d['fisik_perut'])),
            _infoRow('Tungkai', _str(d['fisik_tungkai'])),
            _dividerLabel('USG Trimester III'),
            _infoRow('USG T3 Dilakukan', _str(d['usg_trimester_3_dilakukan'])),
            _infoRow('UK berdasarkan USG T1', _numUnit(d['uk_berdasarkan_usg_trimester_1_minggu'], 'minggu')),
            _infoRow('UK berdasarkan HPHT', _numUnit(d['uk_berdasarkan_hpht_minggu'], 'minggu')),
            _infoRow('UK berdasarkan Biometri T3', _numUnit(d['uk_berdasarkan_biometri_usg_trimester_3_minggu'], 'minggu')),
            _infoRow('Selisih UK ≥ 3 Minggu', _str(d['selisih_uk_3_minggu_atau_lebih'])),
            _infoRow('Jumlah Bayi', _str(d['usg_jumlah_bayi'])),
            _infoRow('Letak Bayi', _str(d['usg_letak_bayi'])),
            _infoRow('Presentasi Bayi', _str(d['usg_presentasi_bayi'])),
            _infoRow('Keadaan Bayi', _str(d['usg_keadaan_bayi'])),
            _infoRow('DJJ', _buildDjjStr(d)),
            _infoRow('Lokasi Plasenta', _str(d['usg_lokasi_plasenta'])),
            _infoRow('Cairan Ketuban (SDP)', _join2(
                _numUnit(d['usg_cairan_ketuban_sdp_cm'], 'cm'),
                _str(d['usg_cairan_ketuban_status']))),
            _infoRow('Temuan Abnormal', _str(d['usg_kecurigaan_temuan_abnormal'])),
            _infoRow('Keterangan Abnormal', _str(d['usg_keterangan_temuan_abnormal'])),
            _dividerLabel('Biometri Janin'),
            _infoRow('BPD', _join2(_numUnit(d['biometri_bpd_cm'], 'cm'), _numUnit(d['biometri_bpd_minggu'], 'minggu'))),
            _infoRow('HC', _join2(_numUnit(d['biometri_hc_cm'], 'cm'), _numUnit(d['biometri_hc_minggu'], 'minggu'))),
            _infoRow('AC', _join2(_numUnit(d['biometri_ac_cm'], 'cm'), _numUnit(d['biometri_ac_minggu'], 'minggu'))),
            _infoRow('FL', _join2(_numUnit(d['biometri_fl_cm'], 'cm'), _numUnit(d['biometri_fl_minggu'], 'minggu'))),
            _infoRow('EFW / TBJ',
                _join2(_numUnit(d['biometri_efw_tbj_gram'], 'gram'), _numUnit(d['biometri_efw_tbj_minggu'], 'minggu')),
                isLast: true),
          ],
        ),
      ),
    );
  }

  // ── String helpers ─────────────────────────────────────────────

  String _join2(String a, String b) {
    final parts = [a, b].where((s) => s != '-').toList();
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  String _join3(String a, String b, String c) {
    final parts = [a, b, c].where((s) => s != '-').toList();
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  String _buildDjjStr(Map<String, dynamic> d) {
    final nilai = d['usg_djj_nilai'];
    final status = _str(d['usg_djj_status']);
    final parts = <String>[];
    if (nilai != null) parts.add('$nilai x/menit');
    if (status != '-') parts.add(status);
    return parts.isEmpty ? '-' : parts.join(' — ');
  }

  // ── Shared Widgets ─────────────────────────────────────────────

  Widget _buildError(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 52),
            const SizedBox(height: 14),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
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

  Widget _buildEmpty(String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 56,
                  color: AppColors.textSecondary.withOpacity(0.35)),
              const SizedBox(height: 16),
              Text('Belum Ada Data',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _dividerLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3)),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.primary.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 165,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ),
        ],
      ),
    );
  }
}