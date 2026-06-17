// lib/features/ibu/profil/presentation/screens/hasil_evaluasi_kehamilan_detail.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / hasil-evaluasi-kesehatan-ibu]
// Halaman penuh menampilkan detail Evaluasi Kesehatan Ibu satu kehamilan.
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push.
// Menampilkan: risiko + faktor riwayat penyakit, perilaku, riwayat keluarga,
// imunisasi TT, inspeksi fisik, dan data antropometri.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class HasilEvaluasiKehamilanDetailScreen extends StatefulWidget {
  final int kehamilanId;
  final int nomorKehamilan;

  const HasilEvaluasiKehamilanDetailScreen({
    super.key,
    required this.kehamilanId,
    required this.nomorKehamilan,
  });

  @override
  State<HasilEvaluasiKehamilanDetailScreen> createState() =>
      _HasilEvaluasiKehamilanDetailScreenState();
}

class _HasilEvaluasiKehamilanDetailScreenState
    extends State<HasilEvaluasiKehamilanDetailScreen> {
  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

      // GET /modul-ibu/evaluasi-kesehatan-ibu/kehamilan/:id
      // CATATAN: controller backend (EvaluasiKesehatanIbu.GetByKehamilanID)
      // membaca kehamilan_id dari QUERY PARAM (bukan dari path :id), dan
      // mengembalikan `data` berupa LIST (bisa lebih dari satu evaluasi
      // untuk kehamilan yang sama). Path :id tetap diisi agar cocok dengan
      // pola route, sedangkan query param `kehamilan_id` yang benar-benar
      // dipakai oleh backend.
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/evaluasi-kesehatan-ibu/kehamilan/${widget.kehamilanId}'
        '?kehamilan_id=${widget.kehamilanId}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 404) {
        setState(() {
          _data = null;
          _isLoading = false;
        });
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMsg = body['message'] ?? 'Gagal memuat data evaluasi';
          _isLoading = false;
        });
        return;
      }

      final rawData = body['data'];
      Map<String, dynamic>? evaluasi;

      if (rawData is List) {
        // Backend mengembalikan list evaluasi untuk kehamilan ini.
        // Ambil 1 data evaluasi yang paling baru.
        final list = rawData
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        if (list.isNotEmpty) {
          list.sort((a, b) {
            final createdA = DateTime.tryParse(
                a['created_at']?.toString() ?? '');
            final createdB = DateTime.tryParse(
                b['created_at']?.toString() ?? '');
            if (createdA != null && createdB != null) {
              return createdB.compareTo(createdA); // terbaru duluan
            }
            final idA = (a['id'] as num?)?.toInt() ?? 0;
            final idB = (b['id'] as num?)?.toInt() ?? 0;
            return idB.compareTo(idA); // id terbesar duluan
          });
          evaluasi = list.first;
        }
      } else if (rawData is Map) {
        evaluasi = Map<String, dynamic>.from(rawData);
      }

      setState(() {
        _data = evaluasi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

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
              'Hasil Evaluasi Kehamilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              'Kehamilan ke-${widget.nomorKehamilan}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildError()
              : _data == null
                  ? _buildKosong()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRisikoBanner(),
                            const SizedBox(height: 16),
                            _buildAntropometriCard(),
                            const SizedBox(height: 12),
                            _buildImunisasiTTCard(),
                            const SizedBox(height: 12),
                            _buildRiwayatPenyakitCard(),
                            const SizedBox(height: 12),
                            _buildPerilakuBerisikoCard(),
                            const SizedBox(height: 12),
                            _buildRiwayatKeluargaCard(),
                            const SizedBox(height: 12),
                            _buildInspeksiFisikCard(),
                            const SizedBox(height: 12),
                            _buildCatatan(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RISIKO BANNER
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildRisikoBanner() {
    final d = _data!;

    // Hitung skor risiko di Flutter (mirror logika backend evaluasi_kehamilan_rule.go)
    final riwayatPositif = _getRiwayatPositif();
    final perilakuPositif = _getPerilakuPositif();
    final keluargaPositif = _getKeluargaPositif();

    int score = riwayatPositif.length * 2 + perilakuPositif.length + keluargaPositif.length;

    // Faktor bobot tinggi
    if (d['riwayat_hipertensi'] == true) score += 2;
    if (d['riwayat_diabetes'] == true) score += 2;
    if (d['riwayat_jantung'] == true) score += 2;

    final String levelRisiko;
    final Color risikoColor;
    final Color risikoBg;
    final IconData risikoIcon;

    if (score >= 7) {
      levelRisiko = 'Risiko Tinggi';
      risikoColor = const Color(0xFFDC2626);
      risikoBg = const Color(0xFFFEF2F2);
      risikoIcon = Icons.warning_rounded;
    } else if (score >= 3) {
      levelRisiko = 'Perlu Pemantauan';
      risikoColor = const Color(0xFFD97706);
      risikoBg = const Color(0xFFFEF3C7);
      risikoIcon = Icons.info_rounded;
    } else {
      levelRisiko = 'Risiko Rendah';
      risikoColor = const Color(0xFF16A34A);
      risikoBg = const Color(0xFFECFDF5);
      risikoIcon = Icons.check_circle_rounded;
    }

    final totalFaktor = riwayatPositif.length + perilakuPositif.length + keluargaPositif.length;

    final tanggal = _formatDate(d['tanggal_periksa']?.toString() ?? '');
    final dokter = d['nama_dokter']?.toString() ?? '';
    final faskes = d['fasilitas_kesehatan']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: risikoBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: risikoColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: risikoColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(risikoIcon, color: risikoColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Evaluasi',
                      style: TextStyle(
                        fontSize: 11,
                        color: risikoColor.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      levelRisiko,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: risikoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalFaktor > 0) ...[
            const SizedBox(height: 14),
            Divider(color: risikoColor.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.flag_rounded,
                    size: 14, color: risikoColor.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  '$totalFaktor faktor risiko terdeteksi',
                  style: TextStyle(
                    fontSize: 13,
                    color: risikoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (tanggal.isNotEmpty || dokter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: risikoColor.withOpacity(0.15), height: 1),
            const SizedBox(height: 10),
            if (tanggal.isNotEmpty)
              _bannerMeta(Icons.calendar_today_rounded, 'Tanggal Periksa', tanggal, risikoColor),
            if (dokter.isNotEmpty) ...[
              const SizedBox(height: 4),
              _bannerMeta(Icons.person_rounded, 'Dokter', dokter, risikoColor),
            ],
            if (faskes.isNotEmpty) ...[
              const SizedBox(height: 4),
              _bannerMeta(Icons.local_hospital_rounded, 'Fasilitas', faskes, risikoColor),
            ],
          ],
        ],
      ),
    );
  }

  Widget _bannerMeta(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  ANTROPOMETRI
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildAntropometriCard() {
    final d = _data!;
    final tb = d['tb_cm']?.toString() ?? '-';
    final bb = d['bb_kg']?.toString() ?? '-';
    final imt = d['imt_kategori']?.toString() ?? '-';
    final lila = d['lila_cm']?.toString() ?? '-';

    return _sectionCard(
      icon: Icons.straighten_rounded,
      title: 'Data Antropometri',
      child: Column(
        children: [
          _infoRow('Tinggi Badan', tb != '-' ? '$tb cm' : '-'),
          _infoRow('Berat Badan', bb != '-' ? '$bb kg' : '-'),
          _infoRow('Kategori IMT', imt),
          _infoRow('Lingkar Lengan (LILA)', lila != '-' ? '$lila cm' : '-',
              isLast: true),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  IMUNISASI TT
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildImunisasiTTCard() {
    final d = _data!;
    final ttList = <String>[];
    if (d['status_tt_1'] == true) ttList.add('TT1');
    if (d['status_tt_2'] == true) ttList.add('TT2');
    if (d['status_tt_3'] == true) ttList.add('TT3');
    if (d['status_tt_4'] == true) ttList.add('TT4');
    if (d['status_tt_5'] == true) ttList.add('TT5');
    final covid = d['imunisasi_lainnya_covid19']?.toString() ?? '';

    return _sectionCard(
      icon: Icons.vaccines_rounded,
      title: 'Imunisasi Tetanus Toxoid (TT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ttList.isEmpty
                ? Text('Belum ada imunisasi TT',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary))
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ttList
                        .map((t) => _chip(t, AppColors.primary, AppColors.blue50))
                        .toList(),
                  ),
          ),
          if (covid.isNotEmpty) ...[
            Divider(height: 1, color: const Color(0xFFF3F4F6)),
            _infoRow('COVID-19', covid, isLast: true),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RIWAYAT PENYAKIT
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildRiwayatPenyakitCard() {
    final positif = _getRiwayatPositif();
    final lainnya = _data!['riwayat_kesehatan_lainnya']?.toString() ?? '';

    return _sectionCard(
      icon: Icons.medical_information_rounded,
      title: 'Riwayat Penyakit Ibu',
      child: positif.isEmpty && lainnya.isEmpty
          ? _emptySection('Tidak ada riwayat penyakit')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (positif.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: positif
                          .map((l) => _chip(l, const Color(0xFFDC2626),
                              const Color(0xFFFEF2F2)))
                          .toList(),
                    ),
                  if (lainnya.isNotEmpty) ...[
                    if (positif.isNotEmpty) const SizedBox(height: 10),
                    Text(
                      'Lainnya: $lainnya',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  PERILAKU BERISIKO
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPerilakuBerisikoCard() {
    final positif = _getPerilakuPositif();
    final lainnya = _data!['perilaku_lainnya']?.toString() ?? '';

    return _sectionCard(
      icon: Icons.warning_amber_rounded,
      title: 'Perilaku Berisiko',
      child: positif.isEmpty && lainnya.isEmpty
          ? _emptySection('Tidak ada perilaku berisiko')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (positif.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: positif
                          .map((l) => _chip(l, const Color(0xFFD97706),
                              const Color(0xFFFEF3C7)))
                          .toList(),
                    ),
                  if (lainnya.isNotEmpty) ...[
                    if (positif.isNotEmpty) const SizedBox(height: 10),
                    Text(
                      'Lainnya: $lainnya',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RIWAYAT KELUARGA
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildRiwayatKeluargaCard() {
    final positif = _getKeluargaPositif();
    final lainnya = _data!['keluarga_lainnya']?.toString() ?? '';

    return _sectionCard(
      icon: Icons.family_restroom_rounded,
      title: 'Riwayat Penyakit Keluarga',
      child: positif.isEmpty && lainnya.isEmpty
          ? _emptySection('Tidak ada riwayat penyakit keluarga')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (positif.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: positif
                          .map((l) => _chip(l, AppColors.primary,
                              AppColors.blue50))
                          .toList(),
                    ),
                  if (lainnya.isNotEmpty) ...[
                    if (positif.isNotEmpty) const SizedBox(height: 10),
                    Text(
                      'Lainnya: $lainnya',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  INSPEKSI FISIK
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildInspeksiFisikCard() {
    final d = _data!;
    return _sectionCard(
      icon: Icons.biotech_rounded,
      title: 'Inspeksi Fisik',
      child: Column(
        children: [
          _infoRow('Porsio', d['inspeksi_porsio']?.toString() ?? '-'),
          _infoRow('Uretra', d['inspeksi_uretra']?.toString() ?? '-'),
          _infoRow('Vagina', d['inspeksi_vagina']?.toString() ?? '-'),
          _infoRow('Vulva', d['inspeksi_vulva']?.toString() ?? '-'),
          _infoRow('Fluksus', d['inspeksi_fluksus']?.toString() ?? '-'),
          _infoRow('Fluor', d['inspeksi_fluor']?.toString() ?? '-',
              isLast: true),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  CATATAN
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCatatan() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue200.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data ini merupakan hasil evaluasi kesehatan ibu yang dicatat '
              'oleh tenaga kesehatan pada kehamilan ini. Konsultasikan dengan '
              'dokter atau bidan untuk penjelasan lebih lanjut.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  HELPERS — data extraction
  // ─────────────────────────────────────────────────────────────────────────────

  List<String> _getRiwayatPositif() {
    final d = _data!;
    final map = {
      'riwayat_alergi': 'Alergi',
      'riwayat_asma': 'Asma',
      'riwayat_autoimun': 'Autoimun',
      'riwayat_diabetes': 'Diabetes',
      'riwayat_hepatitis_b': 'Hepatitis B',
      'riwayat_hipertensi': 'Hipertensi',
      'riwayat_jantung': 'Penyakit Jantung',
      'riwayat_jiwa': 'Gangguan Jiwa',
      'riwayat_sifilis': 'Sifilis',
      'riwayat_tb': 'Tuberkulosis (TB)',
    };
    return map.entries
        .where((e) => d[e.key] == true)
        .map((e) => e.value)
        .toList();
  }

  List<String> _getPerilakuPositif() {
    final d = _data!;
    final map = {
      'perilaku_aktivitas_fisik_kurang': 'Aktivitas fisik kurang',
      'perilaku_alkohol': 'Konsumsi alkohol',
      'perilaku_kosmetik_berbahaya': 'Kosmetik berbahaya',
      'perilaku_merokok': 'Merokok',
      'perilaku_obat_teratogenik': 'Obat teratogenik',
      'perilaku_pola_makan_berisiko': 'Pola makan berisiko',
    };
    return map.entries
        .where((e) => d[e.key] == true)
        .map((e) => e.value)
        .toList();
  }

  List<String> _getKeluargaPositif() {
    final d = _data!;
    final map = {
      'keluarga_alergi': 'Alergi',
      'keluarga_asma': 'Asma',
      'keluarga_autoimun': 'Autoimun',
      'keluarga_diabetes': 'Diabetes',
      'keluarga_hepatitis_b': 'Hepatitis B',
      'keluarga_hipertensi': 'Hipertensi',
      'keluarga_jantung': 'Penyakit Jantung',
      'keluarga_jiwa': 'Gangguan Jiwa',
      'keluarga_sifilis': 'Sifilis',
      'keluarga_tb': 'Tuberkulosis (TB)',
    };
    return map.entries
        .where((e) => d[e.key] == true)
        .map((e) => e.value)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  WIDGET HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(
              value.isEmpty || value == 'null' ? '-' : value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _emptySection(String msg) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(msg,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ),
      );

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety_outlined,
                size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data evaluasi kesehatan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Data akan muncul setelah bidan atau dokter\nmencatat hasil evaluasi kesehatan ibu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
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
                onPressed: _load,
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

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}