// lib/features/ibu/profil/presentation/screens/riwayat_pemeriksaan_kehamilan_screen.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / pemeriksaan-kehamilan]
// Halaman riwayat Pemeriksaan Kehamilan (Trimester 1 - 3) untuk satu kehamilan.
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push.
//
// FRONTEND-ONLY.
// Data diambil langsung dari endpoint yang SUDAH ADA:
//   GET /ibu/pemeriksaan-kehamilan?kehamilan_id=:id
//   (controller.PemeriksaanKehamilan.GetByKehamilanID, route group `ibu`)
// Tidak ada perubahan/penambahan apapun di backend.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class RiwayatPemeriksaanKehamilanScreen extends StatefulWidget {
  final int kehamilanId;
  final int nomorKehamilan;

  const RiwayatPemeriksaanKehamilanScreen({
    super.key,
    required this.kehamilanId,
    required this.nomorKehamilan,
  });

  @override
  State<RiwayatPemeriksaanKehamilanScreen> createState() =>
      _RiwayatPemeriksaanKehamilanScreenState();
}

class _RiwayatPemeriksaanKehamilanScreenState
    extends State<RiwayatPemeriksaanKehamilanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMsg;
  List<Map<String, dynamic>> _riwayat = [];

  final List<String> _trimesterLabels = const [
    'Trimester I',
    'Trimester II',
    'Trimester III',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Load data ────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMsg = 'Sesi tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      // Endpoint yang sudah ada, tidak ada penambahan endpoint baru:
      // GET /ibu/pemeriksaan-kehamilan?kehamilan_id=:id
      // (route group "ibu", BUKAN "/modul-ibu")
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/ibu/pemeriksaan-kehamilan'
        '?kehamilan_id=${widget.kehamilanId}',
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 404) {
        setState(() {
          _riwayat = [];
          _isLoading = false;
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMsg = body['message']?.toString() ??
              'Gagal memuat data pemeriksaan kehamilan';
          _isLoading = false;
        });
        return;
      }

      final rawData = body['data'];
      final list = (rawData is List)
          ? rawData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      setState(() {
        _riwayat = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  int _trimesterOf(Map<String, dynamic> item) {
    final raw = (item['trimester'] ?? '')
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', ''); // "TM 1" -> "tm1", "Trimester I" -> "trimesteri"

    // Trimester III dulu, agar "iii" tidak ikut tercocok ke pengecekan "i"/"ii"
    if (raw == 't3' ||
        raw == '3' ||
        raw == 'iii' ||
        raw == 'tm3' ||
        raw == 'trimester3' ||
        raw == 'trimesteriii') {
      return 3;
    }
    if (raw == 't2' ||
        raw == '2' ||
        raw == 'ii' ||
        raw == 'tm2' ||
        raw == 'trimester2' ||
        raw == 'trimesterii') {
      return 2;
    }
    if (raw == 't1' ||
        raw == '1' ||
        raw == 'i' ||
        raw == 'tm1' ||
        raw == 'trimester1' ||
        raw == 'trimesteri') {
      return 1;
    }

    // fallback dari minggu_kehamilan jika trimester kosong/tidak dikenali
    final minggu = (item['minggu_kehamilan'] as num?)?.toInt() ?? 0;
    if (minggu > 0) {
      if (minggu <= 12) return 1;
      if (minggu <= 27) return 2;
      return 3;
    }
    return 1;
  }

  List<Map<String, dynamic>> _itemsForTrimester(int trimester) {
    final list = _riwayat.where((e) => _trimesterOf(e) == trimester).toList();

    list.sort((a, b) {
      final dateA = DateTime.tryParse(a['tanggal_periksa']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['tanggal_periksa']?.toString() ?? '');
      if (dateA != null && dateB != null) return dateA.compareTo(dateB);
      if (dateA != null) return -1;
      if (dateB != null) return 1;
      final kunjA = (a['kunjungan_ke'] as num?)?.toInt() ?? 0;
      final kunjB = (b['kunjungan_ke'] as num?)?.toInt() ?? 0;
      return kunjA.compareTo(kunjB);
    });

    return list;
  }

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

  String _tekananDarah(Map<String, dynamic> item) {
    final sistole = (item['sistole'] as num?)?.toInt() ?? 0;
    final diastole = (item['diastole'] as num?)?.toInt() ?? 0;
    if (sistole <= 0 && diastole <= 0) return '-';
    return '$sistole/$diastole mmHg';
  }

  String _numUnit(dynamic value, String unit) {
    if (value == null) return '-';
    if (value is num) {
      final asStr = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString();
      return '$asStr $unit';
    }
    return '$value $unit';
  }

  String _orDash(dynamic value) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? '-' : s;
  }

  // ── Build ────────────────────────────────────────────────────────

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
              'Riwayat Pemeriksaan Kehamilan',
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
          tabs: _trimesterLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children:
                      List.generate(3, (i) => _buildTrimesterList(i + 1)),
                ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red.shade300, size: 52),
              const SizedBox(height: 14),
              Text(
                _errorMsg ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
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

  Widget _buildTrimesterList(int trimester) {
    final items = _itemsForTrimester(trimester);

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 56,
                      color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data pemeriksaan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Data akan muncul setelah bidan atau dokter mencatat pemeriksaan kehamilan trimester ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        height: 1.5,
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildItemCard(items[i]),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final tanggal = _formatDate(item['tanggal_periksa']?.toString());
    final kunjungan = (item['kunjungan_ke'] as num?)?.toInt() ?? 0;
    final tempat = (item['tempat_periksa']?.toString() ?? '').trim();
    final statusRisiko = (item['status_risiko']?.toString() ?? '').trim();

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
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment_outlined,
                size: 22, color: AppColors.primary),
          ),
          title: Text(
            kunjungan > 0 ? 'Kunjungan ke-$kunjungan' : 'Pemeriksaan Kehamilan',
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
                if (tempat.isNotEmpty) _miniInfo(Icons.place_outlined, tempat),
                if (statusRisiko.isNotEmpty) _statusChip(statusRisiko),
              ],
            ),
          ),
          children: [
            _infoRow('Berat Badan', _numUnit(item['berat_badan'], 'kg')),
            _infoRow('Tinggi Badan', _numUnit(item['tinggi_badan'], 'cm')),
            _infoRow('LILA', _numUnit(item['lingkar_lengan_atas'], 'cm')),
            _infoRow('Tekanan Darah', _tekananDarah(item)),
            _infoRow(
                'Tinggi Rahim (TFU)', _numUnit(item['tinggi_rahim'], 'cm')),
            _infoRow('Denyut Jantung Janin',
                _numUnit(item['denyut_jantung_janin'], 'x/menit')),
            _infoRow('Letak DJJ', _orDash(item['letak_denyut_jantung_bayi'])),
            const Divider(height: 20),
            _infoRow('Imunisasi Tetanus',
                _orDash(item['status_imunisasi_tetanus'])),
            _infoRow('Konseling', _orDash(item['konseling'])),
            _infoRow('Skrining Dokter', _orDash(item['skrining_dokter'])),
            _infoRow('Tablet Tambah Darah',
                _numUnit(item['tablet_tambah_darah'], 'tablet')),
            const Divider(height: 20),
            _infoRow('Hb', _numUnit(item['tes_lab_hb'], 'g/dL')),
            _infoRow('Golongan Darah', _orDash(item['tes_golongan_darah'])),
            _infoRow('Protein Urine', _orDash(item['tes_lab_protein_urine'])),
            _infoRow(
                'Gula Darah', _numUnit(item['tes_lab_gula_darah'], 'mg/dL')),
            const Divider(height: 20),
            _infoRow('USG', _orDash(item['usg'])),
            _infoRow('Tripel Eliminasi', _orDash(item['tripel_eliminasi'])),
            _infoRow('Tata Laksana Kasus', _orDash(item['tata_laksana_kasus']),
                isLast: true),
          ],
        ),
      ),
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

  Widget _statusChip(String status) {
    Color fg;
    Color bg;
    switch (status.toUpperCase()) {
      case 'PERLU RUJUKAN':
        fg = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
        break;
      case 'PERLU TINDAKAN':
        fg = const Color(0xFFD97706);
        bg = const Color(0xFFFEF3C7);
        break;
      case 'NORMAL':
        fg = const Color(0xFF16A34A);
        bg = const Color(0xFFECFDF5);
        break;
      default:
        fg = AppColors.textSecondary;
        bg = AppColors.borderLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}