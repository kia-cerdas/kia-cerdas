// lib/features/ibu/profil/presentation/screens/detail_riwayat_kehamilan_screen.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan]
// Screen menampilkan detail lengkap satu kehamilan dari riwayat.
// Dipanggil dari ProfilIbuScreen saat ibu tap item riwayat kehamilan.
//
// PERUBAHAN:
// - Info Kehamilan & Ringkasan Persalinan: langsung tampil penuh
// - Skrining Preeklampsia: card ringkas (kesimpulan + faktor yg kena saja),
//   ada tombol "Lihat Detail" → buka halaman PreeklampsiaDetailScreen
// - Grafik Evaluasi & Grafik BB: card ringkas (2 baris terakhir),
//   ada tombol "Lihat Semua" → buka bottom sheet tabel lengkap
// - Hasil Evaluasi Kesehatan Ibu: card yang selalu tampil + Lihat Detail

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/preeklampsia_detail.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/evaluasi_kehamilan_detail.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/hasil_evaluasi_kehamilan_detail.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/riwayat_pemeriksaan_kehamilan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/riwayat_pemeriksaan_dokter_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/presentation/screens/riwayat_pemantauan_ibu_hamil_screen.dart';

class DetailRiwayatKehamilanScreen extends StatefulWidget {
  final int kehamilanId;
  final int nomorKehamilan;
  final String statusKehamilan;

  const DetailRiwayatKehamilanScreen({
    super.key,
    required this.kehamilanId,
    required this.nomorKehamilan,
    this.statusKehamilan = '',
  });

  @override
  State<DetailRiwayatKehamilanScreen> createState() =>
      _DetailRiwayatKehamilanScreenState();
}

class _DetailRiwayatKehamilanScreenState
    extends State<DetailRiwayatKehamilanScreen> {
  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
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

      // [SCOPE: modul-ibu / profil]
      // GET /modul-ibu/kehamilan/:id/detail
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/kehamilan/${widget.kehamilanId}/detail',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMsg = body['message'] ?? 'Gagal memuat detail kehamilan';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _data = body['data'] as Map<String, dynamic>?;
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
        title: Text(
          'Kehamilan ke-${widget.nomorKehamilan}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderBanner(),
                        const SizedBox(height: 16),
                        // ── Info Kehamilan: langsung tampil penuh ──
                        _buildInfoDasarCard(),
                        const SizedBox(height: 12),
                        // ── Ringkasan Persalinan: langsung tampil penuh ──
                        _buildPersalinanCard(),
                        const SizedBox(height: 12),
                        // ── Skrining Preeklampsia: card ringkas + lihat detail ──
                        _buildSkriningRingkasCard(),
                        const SizedBox(height: 12),
                        // ── Hasil Evaluasi Kesehatan Ibu: card + lihat detail ──
                        _buildHasilEvaluasiCard(),
                        const SizedBox(height: 12),
                        // ── Riwayat Pemeriksaan Kehamilan T1-T3: card + lihat detail ──
                        _buildRiwayatPemeriksaanCard(),
                        const SizedBox(height: 12),
                        //         // ── Pemeriksaan Dokter Trim 1 & 3: card + lihat detail ──
                        _buildPemeriksaanDokterCard(),
                        const SizedBox(height: 12),
                        // ── Pemantauan Ibu Hamil: hanya yang ada keluhan ──
                        _buildPemantauanIbuHamilCard(),
                        const SizedBox(height: 12),
                        // ── Grafik Evaluasi: card ringkas + lihat semua ──
                        _buildGrafikEvaluasiRingkasCard(),
                        const SizedBox(height: 12),
                        // ── Grafik BB: card ringkas + lihat semua ──
                        _buildGrafikBBRingkasCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  HEADER BANNER
  // ══════════════════════════════════════════════════════════

  Widget _buildHeaderBanner() {
    final status =
        _data?['status_kehamilan']?.toString() ?? widget.statusKehamilan;
    final hpht = _formatDate(_data?['hpht']?.toString() ?? '');
    final hpl =
        _formatDate(_data?['taksiran_persalinan']?.toString() ?? '');

    Color statusColor;
    Color statusBg;
    switch (status.toUpperCase()) {
      case 'NIFAS':
        statusColor = AppColors.amber;
        statusBg = AppColors.amberLight;
        break;
      case 'NON-AKTIF':
        statusColor = AppColors.textSecondary;
        statusBg = AppColors.surface;
        break;
      default:
        statusColor = AppColors.primary;
        statusBg = AppColors.blue50;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pregnant_woman, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Kehamilan ke-${widget.nomorKehamilan}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  status.isEmpty ? '-' : status,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _bannerStat('HPHT', hpht.isEmpty ? '-' : hpht),
              const SizedBox(width: 24),
              _bannerStat(
                  'Taksiran Lahir', hpl.isEmpty ? '-' : hpl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );

  // ══════════════════════════════════════════════════════════
  //  INFO KEHAMILAN — tampil langsung
  // ══════════════════════════════════════════════════════════

  Widget _buildInfoDasarCard() {
    final g = _data?['gravida'] ?? 0;
    final p = _data?['paritas'] ?? 0;
    final a = _data?['abortus'] ?? 0;
    final bb = (_data?['bb_awal'] as num?)?.toDouble() ?? 0.0;
    final tb = (_data?['tb'] as num?)?.toDouble() ?? 0.0;
    final imt = (_data?['imt_awal'] as num?)?.toDouble() ?? 0.0;
    final jarak =
        (_data?['jarak_kehamilan_sebelumnya'] as num?)?.toInt() ?? 0;

    return _sectionCard(
      icon: Icons.info_outline,
      title: 'Info Kehamilan',
      child: Column(
        children: [
          _infoRow('Status Obstetri', 'G$g P$p A$a'),
          _infoRow(
              'BB Awal', bb > 0 ? '${bb.toStringAsFixed(1)} kg' : '-'),
          _infoRow('TB', tb > 0 ? '${tb.toStringAsFixed(1)} cm' : '-'),
          _infoRow('IMT Awal', imt > 0 ? imt.toStringAsFixed(1) : '-'),
          _infoRow(
            'Jarak Kehamilan',
            jarak > 0 ? '$jarak bulan' : '-',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  RINGKASAN PERSALINAN — tampil langsung
  // ══════════════════════════════════════════════════════════

  Widget _buildPersalinanCard() {
    final persalinan =
        _data?['ringkasan_persalinan'] as Map<String, dynamic>?;

    if (persalinan == null) {
      return _sectionCard(
        icon: Icons.child_care_outlined,
        title: 'Ringkasan Persalinan',
        child: _emptySection('Belum ada data persalinan'),
      );
    }

    final tglLahir =
        _formatDate(persalinan['tanggal_melahirkan']?.toString() ?? '');
    final cara = persalinan['cara_melahirkan']?.toString() ?? '-';
    final penolong =
        persalinan['penolong_proses_melahirkan']?.toString() ?? '-';
    final keadaanIbu = persalinan['keadaan_ibu']?.toString() ?? '-';
    final bbBayi =
        (persalinan['bayi_berat_lahir_gram'] as num?)?.toDouble();
    final pbBayi =
        (persalinan['bayi_panjang_badan_cm'] as num?)?.toDouble();
    final jkBayi =
        persalinan['bayi_jenis_kelamin']?.toString() ?? '-';

    return _sectionCard(
      icon: Icons.child_care_outlined,
      title: 'Ringkasan Persalinan',
      child: Column(
        children: [
          _infoRow(
              'Tanggal Lahir', tglLahir.isEmpty ? '-' : tglLahir),
          _infoRow('Cara Melahirkan', cara),
          _infoRow('Penolong', penolong),
          _infoRow('Keadaan Ibu', keadaanIbu),
          _infoRow('Jenis Kelamin Bayi', jkBayi),
          _infoRow(
            'BB / PB Bayi',
            '${bbBayi != null ? "${bbBayi.toStringAsFixed(0)} g" : "-"} / '
                '${pbBayi != null ? "${pbBayi.toStringAsFixed(1)} cm" : "-"}',
          ),
          _infoRow(
            'KB Pasca Melahirkan',
            persalinan['kb_pasca_melahirkan']?.toString() ?? '-',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SKRINING PREEKLAMPSIA — card ringkas
  // ══════════════════════════════════════════════════════════

  Widget _buildSkriningRingkasCard() {
    final skrining =
        _data?['skrining_preeklampsia'] as Map<String, dynamic>?;

    if (skrining == null) {
      return _sectionCard(
        icon: Icons.monitor_heart_outlined,
        title: 'Skrining Preeklampsia',
        child: _emptySection('Belum ada data skrining preeklampsia'),
      );
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreeklampsiaDetailScreen(
            nomorKehamilan: widget.nomorKehamilan,
            skrining: skrining,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Skrining Preeklampsia',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _lihatDetailButton('Lihat Detail', () {}),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  HASIL EVALUASI KESEHATAN IBU — card ringkas + lihat detail
  // ══════════════════════════════════════════════════════════

  Widget _buildHasilEvaluasiCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HasilEvaluasiKehamilanDetailScreen(
            kehamilanId: widget.kehamilanId,
            nomorKehamilan: widget.nomorKehamilan,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hasil Evaluasi Kehamilan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _lihatDetailButton('Lihat Detail', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HasilEvaluasiKehamilanDetailScreen(
                      kehamilanId: widget.kehamilanId,
                      nomorKehamilan: widget.nomorKehamilan,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  RIWAYAT PEMERIKSAAN KEHAMILAN (T1-T3) — card ringkas + lihat detail
  //  Frontend-only: data diambil oleh RiwayatPemeriksaanKehamilanScreen
  //  langsung dari endpoint yang sudah ada
  //  (GET /modul-ibu/pemeriksaan-kehamilan?kehamilan_id=:id).
  // ══════════════════════════════════════════════════════════

  Widget _buildRiwayatPemeriksaanCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RiwayatPemeriksaanKehamilanScreen(
            kehamilanId: widget.kehamilanId,
            nomorKehamilan: widget.nomorKehamilan,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Pemeriksaan Kehamilan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Trimester I - III',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _lihatDetailButton('Lihat Detail', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiwayatPemeriksaanKehamilanScreen(
                      kehamilanId: widget.kehamilanId,
                      nomorKehamilan: widget.nomorKehamilan,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPemeriksaanDokterCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RiwayatPemeriksaanDokterScreen(
            kehamilanId: widget.kehamilanId,
            nomorKehamilan: widget.nomorKehamilan,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemeriksaan Dokter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Trimester I & III',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _lihatDetailButton('Lihat Detail', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiwayatPemeriksaanDokterScreen(
                      kehamilanId: widget.kehamilanId,
                      nomorKehamilan: widget.nomorKehamilan,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }



  // ══════════════════════════════════════════════════════════
  //  PEMANTAUAN IBU HAMIL (hanya yang ada keluhan)
  //  Frontend-only: data diambil oleh RiwayatPemantauanIbuHamilScreen
  //  dari endpoint GET /modul-ibu/pemantauan-ibu-hamil/me.
  //  Filter "ada keluhan" dilakukan di sisi Flutter.
  // ══════════════════════════════════════════════════════════

  Widget _buildPemantauanIbuHamilCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RiwayatPemantauanIbuHamilScreen(
            kehamilanId: widget.kehamilanId,
            nomorKehamilan: widget.nomorKehamilan,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemantauan Ibu Hamil',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Hanya entri dengan keluhan',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _lihatDetailButton('Lihat Detail', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RiwayatPemantauanIbuHamilScreen(
                      kehamilanId: widget.kehamilanId,
                      nomorKehamilan: widget.nomorKehamilan,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikEvaluasiRingkasCard() {
    final grafik =
        (_data?['grafik_evaluasi'] as List<dynamic>?) ?? [];

    if (grafik.isEmpty) {
      return _sectionCard(
        icon: Icons.show_chart,
        title: 'Grafik Evaluasi Kehamilan',
        child: _emptySection('Belum ada data grafik evaluasi'),
      );
    }

    // Ambil 2 data terakhir untuk preview
    final previewList = grafik.length > 2
        ? grafik.sublist(grafik.length - 2)
        : grafik;

    return _sectionCard(
      icon: Icons.show_chart,
      title: 'Grafik Evaluasi Kehamilan',
      subtitle: '${grafik.length} data pemeriksaan',
      trailingWidget:
          _lihatDetailButton('Lihat Semua', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EvaluasiKehamilanDetailScreen(
                  nomorKehamilan: widget.nomorKehamilan,
                  grafik: grafik,
                ),
              ),
            );
          }),
      child: Column(
        children: [
          // Header mini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withOpacity(0.05),
            child: Row(
              children: const [
                Expanded(
                    flex: 2,
                    child: Text('Minggu',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
                Expanded(
                    flex: 2,
                    child: Text('TFU (cm)',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
                Expanded(
                    flex: 2,
                    child: Text('DJJ',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
                Expanded(
                    flex: 3,
                    child: Text('TD (mmHg)',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
              ],
            ),
          ),
          const Divider(height: 1),
          ...previewList.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value as Map<String, dynamic>;
            final minggu = g['usia_gestasi_minggu']?.toString() ?? '-';
            final tfu = g['tinggi_fundus_uteri_cm']?.toString() ?? '-';
            final djj =
                g['denyut_jantung_bayi_x_menit']?.toString() ?? '-';
            final sistole =
                g['tekanan_darah_sistole']?.toString() ?? '';
            final diastole =
                g['tekanan_darah_diastole']?.toString() ?? '';
            final td =
                (sistole.isNotEmpty && diastole.isNotEmpty)
                    ? '$sistole/$diastole'
                    : '-';
            final isLast = i == previewList.length - 1;
            return _grafikRow(i, [minggu, tfu, djj, td],
                [2, 2, 2, 3], isLast);
          }).toList(),
          if (grafik.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '... dan ${grafik.length - 2} data lainnya',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  GRAFIK BB — card ringkas (2 baris terakhir)
  // ══════════════════════════════════════════════════════════

  Widget _buildGrafikBBRingkasCard() {
    final grafikBB =
        (_data?['grafik_bb'] as List<dynamic>?) ?? [];

    if (grafikBB.isEmpty) {
      return _sectionCard(
        icon: Icons.monitor_weight_outlined,
        title: 'Grafik Berat Badan',
        child: _emptySection('Belum ada data grafik berat badan'),
      );
    }

    final previewList = grafikBB.length > 2
        ? grafikBB.sublist(grafikBB.length - 2)
        : grafikBB;

    return _sectionCard(
      icon: Icons.monitor_weight_outlined,
      title: 'Grafik Berat Badan',
      subtitle: '${grafikBB.length} data pengukuran',
      trailingWidget:
          _lihatDetailButton('Lihat Semua', () => _showGrafikBBDetail(grafikBB)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withOpacity(0.05),
            child: Row(
              children: const [
                Expanded(
                    flex: 2,
                    child: Text('Minggu',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
                Expanded(
                    flex: 2,
                    child: Text('BB (kg)',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
                Expanded(
                    flex: 3,
                    child: Text('Status',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151)))),
              ],
            ),
          ),
          const Divider(height: 1),
          ...previewList.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value as Map<String, dynamic>;
            final minggu = g['minggu_kehamilan']?.toString() ?? '-';
            final bb =
                (g['berat_badan'] as num?)?.toStringAsFixed(1) ?? '-';
            final status = g['status']?.toString() ?? '-';
            final isLast = i == previewList.length - 1;

            Color statusColor = AppColors.textPrimary;
            if (status.toLowerCase().contains('lebih')) {
              statusColor = const Color(0xFFDC2626);
            } else if (status.toLowerCase().contains('kurang')) {
              statusColor = AppColors.amber;
            } else if (status.toLowerCase().contains('normal') ||
                status.toLowerCase().contains('ideal')) {
              statusColor = const Color(0xFF16A34A);
            }

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : AppColors.surface,
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(
                            color: Color(0xFFF3F4F6), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(minggu,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151)))),
                  Expanded(
                      flex: 2,
                      child: Text(bb,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151)))),
                  Expanded(
                      flex: 3,
                      child: Text(status,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor))),
                ],
              ),
            );
          }).toList(),
          if (grafikBB.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '... dan ${grafikBB.length - 2} data lainnya',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  BOTTOM SHEETS
  // ══════════════════════════════════════════════════════════

  // /// Bottom sheet: tabel lengkap grafik evaluasi
  // void _showGrafikEvaluasiDetail(List<dynamic> grafik) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => DraggableScrollableSheet(
  //       initialChildSize: 0.85,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.95,
  //       builder: (_, scrollController) => Container(
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius:
  //               BorderRadius.vertical(top: Radius.circular(20)),
  //         ),
  //         child: Column(
  //           children: [
  //             _sheetHandle(),
  //             _sheetTitle(Icons.show_chart,
  //                 'Grafik Evaluasi Kehamilan (${grafik.length} data)'),
  //             const Divider(height: 1),
  //             // Header tabel
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                   horizontal: 16, vertical: 8),
  //               color: AppColors.primary.withOpacity(0.05),
  //               child: Row(
  //                 children: const [
  //                   Expanded(
  //                       flex: 2,
  //                       child: Text('Mgg',
  //                           style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w700,
  //                               color: Color(0xFF374151)))),
  //                   Expanded(
  //                       flex: 2,
  //                       child: Text('TFU (cm)',
  //                           style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w700,
  //                               color: Color(0xFF374151)))),
  //                   Expanded(
  //                       flex: 2,
  //                       child: Text('DJJ',
  //                           style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w700,
  //                               color: Color(0xFF374151)))),
  //                   Expanded(
  //                       flex: 3,
  //                       child: Text('TD (mmHg)',
  //                           style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w700,
  //                               color: Color(0xFF374151)))),
  //                 ],
  //               ),
  //             ),
  //             const Divider(height: 1),
  //             Expanded(
  //               child: ListView.builder(
  //                 controller: scrollController,
  //                 itemCount: grafik.length,
  //                 itemBuilder: (_, i) {
  //                   final g = grafik[i] as Map<String, dynamic>;
  //                   final minggu =
  //                       g['usia_gestasi_minggu']?.toString() ?? '-';
  //                   final tfu =
  //                       g['tinggi_fundus_uteri_cm']?.toString() ?? '-';
  //                   final djj =
  //                       g['denyut_jantung_bayi_x_menit']?.toString() ??
  //                           '-';
  //                   final sistole =
  //                       g['tekanan_darah_sistole']?.toString() ?? '';
  //                   final diastole =
  //                       g['tekanan_darah_diastole']?.toString() ?? '';
  //                   final td = (sistole.isNotEmpty &&
  //                           diastole.isNotEmpty)
  //                       ? '$sistole/$diastole'
  //                       : '-';
  //                   return _grafikRow(
  //                       i, [minggu, tfu, djj, td], [2, 2, 2, 3], false);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
// 
  /// Bottom sheet: tabel lengkap grafik BB
  void _showGrafikBBDetail(List<dynamic> grafikBB) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _sheetHandle(),
              _sheetTitle(Icons.monitor_weight_outlined,
                  'Grafik Berat Badan (${grafikBB.length} data)'),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  children: const [
                    Expanded(
                        flex: 2,
                        child: Text('Minggu',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151)))),
                    Expanded(
                        flex: 2,
                        child: Text('BB (kg)',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151)))),
                    Expanded(
                        flex: 3,
                        child: Text('Status',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151)))),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: grafikBB.length,
                  itemBuilder: (_, i) {
                    final g = grafikBB[i] as Map<String, dynamic>;
                    final minggu =
                        g['minggu_kehamilan']?.toString() ?? '-';
                    final bb =
                        (g['berat_badan'] as num?)?.toStringAsFixed(1) ??
                            '-';
                    final status = g['status']?.toString() ?? '-';

                    Color statusColor = AppColors.textPrimary;
                    if (status.toLowerCase().contains('lebih')) {
                      statusColor = const Color(0xFFDC2626);
                    } else if (status.toLowerCase().contains('kurang')) {
                      statusColor = AppColors.amber;
                    } else if (status.toLowerCase().contains('normal') ||
                        status.toLowerCase().contains('ideal')) {
                      statusColor = const Color(0xFF16A34A);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? Colors.white
                            : AppColors.surface,
                        border: const Border(
                            bottom: BorderSide(
                                color: Color(0xFFF3F4F6), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(minggu,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151)))),
                          Expanded(
                              flex: 2,
                              child: Text(bb,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151)))),
                          Expanded(
                              flex: 3,
                              child: Text(status,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  SHARED HELPERS
  // ══════════════════════════════════════════════════════════

  Widget _sheetHandle() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _sheetTitle(IconData icon, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
            ),
          ],
        ),
      );

  Widget _grafikRow(
      int i, List<String> values, List<int> flexes, bool isLast) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: i.isEven ? Colors.white : AppColors.surface,
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: List.generate(
          values.length,
          (j) => Expanded(
            flex: flexes[j],
            child: Text(values[j],
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF374151))),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (trailingWidget != null) trailingWidget,
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _lihatDetailButton(String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right,
                  size: 14, color: AppColors.primary),
            ],
          ),
        ),
      );

  Widget _infoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
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

  Widget _emptySection(String msg) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(msg,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9CA3AF))),
        ),
      );

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
                onPressed: _loadDetail,
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
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}