// lib/features/ibu/profil/presentation/screens/riwayat_pemantauan_ibu_hamil_screen.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / pemantauan-ibu-hamil]
//
// Halaman riwayat Pemantauan Ibu Hamil — hanya menampilkan entri yang
// memiliki minimal satu keluhan (salah satu field bool == true).
//
// FRONTEND-ONLY untuk tampilan; membutuhkan endpoint baru di backend:
//   GET /modul-ibu/pemantauan-ibu-hamil/by-kehamilan/:kehamilan_id
// (tambahan di controller, usecase, repository, dan routes — lihat file backend)
//
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// ─────────────────────────────────────────────────────────────
//  MODEL LOKAL  (hanya untuk kebutuhan screen ini)
// ─────────────────────────────────────────────────────────────

class _PemantauanItem {
  final int id;
  final int mingguKehamilan;
  final bool demamLebih2Hari;
  final bool sakitKepala;
  final bool cemasBerlebih;
  final bool resikoTB;
  final bool gerakanBayiKurang;
  final bool nyeriPerut;
  final bool cairanJalanLahir;
  final bool masalahKemaluan;
  final bool diareBerulang;
  final DateTime? createdAt;
  final String namaKader;
  final String tanggalVerifikasi;

  const _PemantauanItem({
    required this.id,
    required this.mingguKehamilan,
    required this.demamLebih2Hari,
    required this.sakitKepala,
    required this.cemasBerlebih,
    required this.resikoTB,
    required this.gerakanBayiKurang,
    required this.nyeriPerut,
    required this.cairanJalanLahir,
    required this.masalahKemaluan,
    required this.diareBerulang,
    this.createdAt,
    this.namaKader = '',
    this.tanggalVerifikasi = '',
  });

  factory _PemantauanItem.fromJson(Map<String, dynamic> j) {
    return _PemantauanItem(
      id: j['id'] ?? 0,
      mingguKehamilan: j['minggu_kehamilan'] ?? 0,
      demamLebih2Hari: j['demam_lebih_2_hari'] ?? false,
      sakitKepala: j['sakit_kepala'] ?? false,
      cemasBerlebih: j['cemas_berlebih'] ?? false,
      resikoTB: j['resiko_tb'] ?? false,
      gerakanBayiKurang: j['gerakan_bayi_kurang'] ?? false,
      nyeriPerut: j['nyeri_perut'] ?? false,
      cairanJalanLahir: j['cairan_jalan_lahir'] ?? false,
      masalahKemaluan: j['masalah_kemaluan'] ?? false,
      diareBerulang: j['diare_berulang'] ?? false,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      namaKader: j['nama_kader']?.toString() ?? '',
      tanggalVerifikasi: _readDate(j['tanggal_verifikasi']),
    );
  }

  /// Ada keluhan jika setidaknya satu field bool bernilai true.
  bool get adaKeluhan =>
      demamLebih2Hari ||
      sakitKepala ||
      cemasBerlebih ||
      resikoTB ||
      gerakanBayiKurang ||
      nyeriPerut ||
      cairanJalanLahir ||
      masalahKemaluan ||
      diareBerulang;

  bool get sudahDiverifikasi =>
      namaKader.isNotEmpty && tanggalVerifikasi.isNotEmpty;

  /// Daftar keluhan yang aktif (true) sebagai label.
  List<String> get keluhanAktif {
    final list = <String>[];
    if (demamLebih2Hari) list.add('Demam > 2 hari');
    if (sakitKepala) list.add('Sakit kepala');
    if (cemasBerlebih) list.add('Cemas berlebih');
    if (resikoTB) list.add('Risiko TBC');
    if (gerakanBayiKurang) list.add('Gerakan bayi kurang');
    if (nyeriPerut) list.add('Nyeri perut');
    if (cairanJalanLahir) list.add('Cairan jalan lahir');
    if (masalahKemaluan) list.add('Masalah kemaluan');
    if (diareBerulang) list.add('Diare berulang');
    return list;
  }
}

String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}

// ─────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────

class RiwayatPemantauanIbuHamilScreen extends StatefulWidget {
  final int kehamilanId;
  final int nomorKehamilan;

  const RiwayatPemantauanIbuHamilScreen({
    super.key,
    required this.kehamilanId,
    required this.nomorKehamilan,
  });

  @override
  State<RiwayatPemantauanIbuHamilScreen> createState() =>
      _RiwayatPemantauanIbuHamilScreenState();
}

class _RiwayatPemantauanIbuHamilScreenState
    extends State<RiwayatPemantauanIbuHamilScreen> {
  bool _isLoading = true;
  String? _errorMsg;

  /// Hanya entri yang ada keluhan (adaKeluhan == true).
  List<_PemantauanItem> _dataKeluhan = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Fetch & filter ──────────────────────────────────────────

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

      // Endpoint baru: GET /modul-ibu/pemantauan-ibu-hamil/by-kehamilan/:kehamilan_id
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil/by-kehamilan/${widget.kehamilanId}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMsg = body['message']?.toString() ??
              'Gagal memuat data pemantauan';
          _isLoading = false;
        });
        return;
      }

      final rawList = (body['data'] as List<dynamic>?) ?? [];
      final semua = rawList
          .map((e) => _PemantauanItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // ── Filter: hanya yang ada keluhan ──
      final denganKeluhan = semua.where((e) => e.adaKeluhan).toList();

      // Urutkan dari minggu terbaru ke terlama
      denganKeluhan.sort(
        (a, b) => b.mingguKehamilan.compareTo(a.mingguKehamilan),
      );

      setState(() {
        _dataKeluhan = denganKeluhan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  // ── Build ───────────────────────────────────────────────────

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
              'Pemantauan Ibu Hamil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Kehamilan ke-${widget.nomorKehamilan}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _dataKeluhan.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
                ),
    );
  }

  // ── List ────────────────────────────────────────────────────

  Widget _buildList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _dataKeluhan.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCard(_dataKeluhan[i]),
    );
  }

  Widget _buildCard(_PemantauanItem item) {
    final tanggal = item.createdAt != null
        ? _formatDate(item.createdAt!)
        : '-';

    return Container(
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
          // ── Header card ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Minggu ${item.mingguKehamilan}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tanggal,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                if (item.sudahDiverifikasi)
                  _verifikasiChip()
                else
                  _belumVerifikasiChip(),
              ],
            ),
          ),

          // ── Keluhan ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Keluhan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: item.keluhanAktif
                  .map((k) => _keluhanChip(k))
                  .toList(),
            ),
          ),

          // ── Info verifikasi kader (jika sudah) ──
          if (item.sudahDiverifikasi) ...[
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Diverifikasi oleh ${item.namaKader}'
                      '${item.tanggalVerifikasi.isNotEmpty ? " · ${item.tanggalVerifikasi}" : ""}',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Widgets kecil ───────────────────────────────────────────

  Widget _keluhanChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 12, color: Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifikasiChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 12, color: AppColors.secondary),
          const SizedBox(width: 3),
          Text(
            'Terverifikasi',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _belumVerifikasiChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.orange100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Belum diverifikasi',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.warning),
      ),
    );
  }

  // ── Empty & Error ───────────────────────────────────────────

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 56, color: AppColors.secondary),
              const SizedBox(height: 14),
              Text(
                'Tidak ada keluhan tercatat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Semua pemantauan tidak menunjukkan keluhan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
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
  }

  // ── Helper tanggal ──────────────────────────────────────────

  String _formatDate(DateTime dt) {
    const bulan = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }
}