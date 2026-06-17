// lib/features/ibu/profil/presentation/screens/preeklampsia_detail.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / preeklampsia]
// Halaman penuh menampilkan detail skrining preeklampsia satu kehamilan.
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push.
// Menampilkan: score/kesimpulan risiko + hanya faktor yang POSITIF (terdeteksi).

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class PreeklampsiaDetailScreen extends StatelessWidget {
  final int nomorKehamilan;
  final Map<String, dynamic> skrining;

  const PreeklampsiaDetailScreen({
    super.key,
    required this.nomorKehamilan,
    required this.skrining,
  });

  @override
  Widget build(BuildContext context) {
    final positifTinggi = _getPositifByKategori('tinggi');
    final positifSedang = _getPositifByKategori('sedang');
    final positifFisik = _getPositifByKategori('fisik');
    final totalPositif =
        positifTinggi.length + positifSedang.length + positifFisik.length;

    final kesimpulan = _resolveKesimpulan(
      rawKesimpulan:
          skrining['kesimpulan_skrining_preeklampsia']?.toString() ?? '',
      hasRisikoTinggi: positifTinggi.isNotEmpty,
      hasRisikoSedang: positifSedang.isNotEmpty,
      hasPemeriksaanFisikBermasalah: positifFisik.isNotEmpty,
    );

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
              'Skrining Preeklampsia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              'Kehamilan ke-$nomorKehamilan',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHasilBanner(kesimpulan, totalPositif),
            const SizedBox(height: 16),
            if (totalPositif == 0) ...[
              _buildKosongCard(),
            ] else ...[
              if (positifTinggi.isNotEmpty) ...[
                _buildGrupHeader(
                  label: 'Faktor Risiko Tinggi',
                  icon: Icons.warning_rounded,
                  color: const Color(0xFFDC2626),
                  bg: AppColors.red50,
                  jumlah: positifTinggi.length,
                ),
                const SizedBox(height: 8),
                _buildFaktorList(
                  positifTinggi,
                  const Color(0xFFDC2626),
                  AppColors.red50,
                  AppColors.red100,
                ),
                const SizedBox(height: 16),
              ],
              if (positifSedang.isNotEmpty) ...[
                _buildGrupHeader(
                  label: 'Faktor Risiko Sedang',
                  icon: Icons.info_rounded,
                  color: AppColors.amber,
                  bg: AppColors.amberLight,
                  jumlah: positifSedang.length,
                ),
                const SizedBox(height: 8),
                _buildFaktorList(
                  positifSedang,
                  AppColors.amber,
                  AppColors.amberLight,
                  AppColors.orange100,
                ),
                const SizedBox(height: 16),
              ],
              if (positifFisik.isNotEmpty) ...[
                _buildGrupHeader(
                  label: 'Temuan Pemeriksaan Fisik',
                  icon: Icons.biotech_rounded,
                  color: AppColors.primary,
                  bg: AppColors.blue50,
                  jumlah: positifFisik.length,
                ),
                const SizedBox(height: 8),
                _buildFaktorList(
                  positifFisik,
                  AppColors.primary,
                  AppColors.blue50,
                  AppColors.blue100,
                ),
                const SizedBox(height: 16),
              ],
            ],
            _buildCatatan(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHasilBanner(String kesimpulan, int totalPositif) {
    final style = _resolveStyle(kesimpulan);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: style.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Skrining',
                      style: TextStyle(
                        fontSize: 11,
                        color: style.color.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kesimpulan.isEmpty ? '-' : kesimpulan,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: style.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalPositif > 0) ...[
            const SizedBox(height: 14),
            Divider(color: style.color.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.flag_rounded,
                    size: 14, color: style.color.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  '$totalPositif faktor risiko terdeteksi',
                  style: TextStyle(
                    fontSize: 13,
                    color: style.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrupHeader({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required int jumlah,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            '$jumlah',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaktorList(
    List<String> labels,
    Color color,
    Color bgLight,
    Color bgStrong,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: labels.asMap().entries.map((entry) {
          final isLast = entry.key == labels.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom:
                          BorderSide(color: color.withOpacity(0.12), width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKosongCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
        children: [
          Icon(Icons.verified_rounded,
              size: 48, color: const Color(0xFF16A34A).withOpacity(0.8)),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada faktor risiko\nyang terdeteksi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua pemeriksaan menunjukkan hasil normal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

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
              'Data ini merupakan hasil skrining preeklampsia yang dicatat '
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
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Kembalikan label faktor yang bernilai true untuk kategori tertentu.
  /// kategori: 'sedang' | 'tinggi' | 'fisik'
  List<String> _getPositifByKategori(String kategori) {
    final Map<String, String> fields;
    switch (kategori) {
      case 'tinggi':
        fields = {
          'anamnesis_riwayat_preeklampsia_sebelumnya_tinggi':
              'Riwayat preeklampsia sebelumnya',
          'anamnesis_kehamilan_multipel_tinggi': 'Kehamilan multipel',
          'anamnesis_diabetes_dalam_kehamilan_tinggi':
              'Diabetes dalam kehamilan',
          'anamnesis_hipertensi_kronik_tinggi': 'Hipertensi kronik',
          'anamnesis_penyakit_ginjal_tinggi': 'Penyakit ginjal',
          'anamnesis_penyakit_autoimun_sle_tinggi': 'Penyakit autoimun / SLE',
          'anamnesis_anti_phospholipid_syndrome_tinggi':
              'Sindrom anti-fosfolipid (APS)',
        };
        break;
      case 'sedang':
        fields = {
          'anamnesis_multipara_pasangan_baru_sedang':
              'Multipara dengan pasangan baru',
          'anamnesis_teknologi_reproduksi_berbantu_sedang':
              'Teknologi reproduksi berbantu',
          'anamnesis_umur_diatas_35_tahun_sedang': 'Umur di atas 35 tahun',
          'anamnesis_nulipara_sedang': 'Nulipara',
          'anamnesis_jarak_kehamilan_diatas_10_tahun_sedang':
              'Jarak kehamilan di atas 10 tahun',
          'anamnesis_riwayat_preeklampsia_keluarga_sedang':
              'Riwayat preeklampsia dalam keluarga',
          'anamnesis_obesitas_imt_diatas_30_sedang': 'Obesitas (IMT > 30)',
        };
        break;
      case 'fisik':
      default:
        fields = {
          'fisik_map_diatas_90_mmhg': 'MAP > 90 mmHg',
          'fisik_proteinuria_urin_celup': 'Proteinuria (urin celup)',
        };
        break;
    }

    final result = <String>[];
    fields.forEach((key, label) {
      if (skrining[key] == true) result.add(label);
    });
    return result;
  }

  /// Hitung kesimpulan skrining preeklampsia.
  /// Menyamakan logika dengan SkriningPreeklampsiaModel.kesimpulanText
  /// pada fitur Skrining Preeklampsia di menu Kehamilan:
  /// - jika ada faktor risiko TINGGI -> "Risiko tinggi"
  /// - jika ada faktor risiko SEDANG atau temuan fisik bermasalah -> "Perlu pemantauan"
  /// - jika tidak ada faktor risiko sama sekali -> "Tidak ditemukan faktor risiko"
  /// Jika backend sudah mengirim kesimpulan (tidak kosong), pakai itu.
  String _resolveKesimpulan({
    required String rawKesimpulan,
    required bool hasRisikoTinggi,
    required bool hasRisikoSedang,
    required bool hasPemeriksaanFisikBermasalah,
  }) {
    if (rawKesimpulan.trim().isNotEmpty && rawKesimpulan.trim() != '-') {
      return rawKesimpulan;
    }
    if (hasRisikoTinggi) return 'Risiko tinggi';
    if (hasRisikoSedang || hasPemeriksaanFisikBermasalah) {
      return 'Perlu pemantauan';
    }
    return 'Tidak ditemukan faktor risiko';
  }

  _KesimpulanStyle _resolveStyle(String kesimpulan) {
    final lower = kesimpulan.toLowerCase();
    if (lower.contains('tinggi')) {
      return const _KesimpulanStyle(
        color: Color(0xFFDC2626),
        bg: Color(0xFFFEF2F2),
        icon: Icons.warning_rounded,
      );
    } else if (lower.contains('sedang') || lower.contains('pantau')) {
      return const _KesimpulanStyle(
        color: Color(0xFFD97706),
        bg: Color(0xFFFEF3C7),
        icon: Icons.info_rounded,
      );
    } else {
      return const _KesimpulanStyle(
        color: Color(0xFF16A34A),
        bg: Color(0xFFECFDF5),
        icon: Icons.check_circle_rounded,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Internal helper class
// ─────────────────────────────────────────────────────────────────────────────

class _KesimpulanStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  const _KesimpulanStyle({
    required this.color,
    required this.bg,
    required this.icon,
  });
}