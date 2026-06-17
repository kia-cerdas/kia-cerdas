// lib/features/ibu/profil/presentation/screens/evaluasi_kehamilan_detail.dart
// [SCOPE: modul-ibu / profil / riwayat-kehamilan / evaluasi-kehamilan]
// Halaman penuh menampilkan seluruh data Grafik Evaluasi Kehamilan satu kehamilan.
// Dipanggil dari DetailRiwayatKehamilanScreen via Navigator.push
// (menggantikan bottom sheet _showGrafikEvaluasiDetail).
// Setiap baris data ditampilkan sebagai card ringkas berisi semua field yang tersedia.

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class EvaluasiKehamilanDetailScreen extends StatelessWidget {
  final int nomorKehamilan;

  /// List<Map<String, dynamic>> dari grafik_evaluasi pada response API.
  /// Field yang dipakai:
  ///   tanggal_bulan_tahun, usia_gestasi_minggu,
  ///   tinggi_fundus_uteri_cm, denyut_jantung_bayi_x_menit,
  ///   tekanan_darah_sistole, tekanan_darah_diastole, nadi_per_menit,
  ///   gerakan_bayi, urin_protein, urin_reduksi,
  ///   hemoglobin, tablet_tambah_darah, kalsium, aspirin,
  ///   kategori_risiko, penjelasan_hasil_grafik
  final List<dynamic> grafik;

  const EvaluasiKehamilanDetailScreen({
    super.key,
    required this.nomorKehamilan,
    required this.grafik,
  });

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
              'Evaluasi Kehamilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              'Kehamilan ke-$nomorKehamilan · ${grafik.length} data',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: grafik.isEmpty
          ? _buildKosong()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: grafik.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final g = grafik[i] as Map<String, dynamic>;
                return _buildEntryCard(i + 1, g);
              },
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  ENTRY CARD
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEntryCard(int urutan, Map<String, dynamic> g) {
    final tanggal = _formatDate(g['tanggal_bulan_tahun']?.toString() ?? '');
    final minggu = g['usia_gestasi_minggu']?.toString() ?? '-';
    final tfu = g['tinggi_fundus_uteri_cm']?.toString() ?? '-';
    final djj = g['denyut_jantung_bayi_x_menit']?.toString() ?? '-';
    final sistole = g['tekanan_darah_sistole']?.toString() ?? '';
    final diastole = g['tekanan_darah_diastole']?.toString() ?? '';
    final td = (sistole.isNotEmpty && diastole.isNotEmpty)
        ? '$sistole/$diastole mmHg'
        : '-';
    final nadi = g['nadi_per_menit']?.toString() ?? '-';
    final gerakanBayi = g['gerakan_bayi']?.toString() ?? '-';
    final urinProtein = g['urin_protein']?.toString() ?? '-';
    final urinReduksi = g['urin_reduksi']?.toString() ?? '-';
    final hb = g['hemoglobin']?.toString() ?? '-';
    final ttd = g['tablet_tambah_darah']?.toString() ?? '-';
    final kalsium = g['kalsium']?.toString() ?? '-';
    final aspirin = g['aspirin']?.toString() ?? '-';
    final kategoriRisiko = g['kategori_risiko']?.toString() ?? '';
    final penjelasan = g['penjelasan_hasil_grafik']?.toString() ?? '';

    final risikoStyle = _resolveRisikoStyle(kategoriRisiko);

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
          // ── Header card: nomor urut + tanggal + minggu ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$urutan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tanggal.isNotEmpty ? tanggal : 'Tanggal tidak tersedia',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (minggu != '-') ...[
                        const SizedBox(height: 2),
                        Text(
                          'Usia gestasi $minggu minggu',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Badge kategori risiko (jika ada)
                if (kategoriRisiko.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: risikoStyle.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: risikoStyle.color.withOpacity(0.35)),
                    ),
                    child: Text(
                      _labelRisiko(kategoriRisiko),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: risikoStyle.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Body: grid field-field utama ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: TFU, DJJ
                Row(
                  children: [
                    _buildFieldCell(
                        icon: Icons.straighten_rounded,
                        label: 'TFU',
                        value: tfu != '-' ? '$tfu cm' : '-',
                        flex: 1),
                    const SizedBox(width: 10),
                    _buildFieldCell(
                        icon: Icons.favorite_border_rounded,
                        label: 'DJJ',
                        value: djj != '-' ? '$djj x/mnt' : '-',
                        flex: 1),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 2: TD, Nadi
                Row(
                  children: [
                    _buildFieldCell(
                        icon: Icons.monitor_heart_rounded,
                        label: 'Tekanan Darah',
                        value: td,
                        flex: 1),
                    const SizedBox(width: 10),
                    _buildFieldCell(
                        icon: Icons.speed_rounded,
                        label: 'Nadi',
                        value: nadi != '-' ? '$nadi x/mnt' : '-',
                        flex: 1),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 3: Gerakan Bayi, Urin Protein
                Row(
                  children: [
                    _buildFieldCell(
                        icon: Icons.child_care_rounded,
                        label: 'Gerakan Bayi',
                        value: _capitalize(gerakanBayi),
                        valueColor: _gerakanBayiColor(gerakanBayi),
                        flex: 1),
                    const SizedBox(width: 10),
                    _buildFieldCell(
                        icon: Icons.science_outlined,
                        label: 'Urin Protein',
                        value: _capitalize(urinProtein),
                        flex: 1),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 4: Urin Reduksi, Hemoglobin
                Row(
                  children: [
                    _buildFieldCell(
                        icon: Icons.biotech_rounded,
                        label: 'Urin Reduksi',
                        value: _capitalize(urinReduksi),
                        flex: 1),
                    const SizedBox(width: 10),
                    _buildFieldCell(
                        icon: Icons.opacity_rounded,
                        label: 'Hemoglobin',
                        value: hb != '-' ? '$hb g/dL' : '-',
                        valueColor: _hbColor(hb),
                        flex: 1),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 5: Tablet Tambah Darah, Kalsium
                Row(
                  children: [
                    _buildFieldCell(
                        icon: Icons.medication_outlined,
                        label: 'Tablet Tambah Darah',
                        value: ttd != '-' ? '$ttd tablet' : '-',
                        flex: 1),
                    const SizedBox(width: 10),
                    _buildFieldCell(
                        icon: Icons.vaccines_outlined,
                        label: 'Kalsium',
                        value: _capitalize(kalsium),
                        flex: 1),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris 6: Aspirin (full width)
                _buildFieldCell(
                    icon: Icons.local_pharmacy_outlined,
                    label: 'Aspirin',
                    value: _capitalize(aspirin),
                    flex: 1,
                    fullWidth: true),

                // Penjelasan (jika ada)
                if (penjelasan.isNotEmpty && penjelasan != '-') ...[
                  const SizedBox(height: 14),
                  _buildPenjelasanBox(penjelasan),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  WIDGET HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFieldCell({
    required IconData icon,
    required String label,
    required String value,
    required int flex,
    Color? valueColor,
    bool fullWidth = false,
  }) {
    final cell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primary.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: cell) : Expanded(flex: flex, child: cell);
  }

  Widget _buildPenjelasanBox(String teks) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blue200.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teks,
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

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data evaluasi kehamilan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Data akan muncul setelah bidan mencatat\nhasil pemeriksaan.',
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

  // ─────────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split('T').first.split('-');
      if (parts.length < 3) return raw;
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final d = int.tryParse(parts[2]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final y = parts[0];
      return '$d ${months[m]} $y';
    } catch (_) {
      return raw;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty || s == '-') return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Color? _gerakanBayiColor(String v) {
    final lower = v.toLowerCase();
    if (lower.contains('kurang')) return const Color(0xFFDC2626);
    if (lower.contains('normal')) return const Color(0xFF16A34A);
    return null;
  }

  Color? _hbColor(String hb) {
    final val = double.tryParse(hb);
    if (val == null) return null;
    if (val < 11.0) return const Color(0xFFDC2626); // anemia
    if (val < 12.0) return const Color(0xFFD97706); // borderline
    return const Color(0xFF16A34A);
  }

  String _labelRisiko(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('tinggi')) return 'Risiko Tinggi';
    if (lower.contains('sedang')) return 'Risiko Sedang';
    if (lower.contains('rendah')) return 'Risiko Rendah';
    return _capitalize(kategori);
  }

  _RisikoStyle _resolveRisikoStyle(String kategori) {
    final lower = kategori.toLowerCase();
    if (lower.contains('tinggi')) {
      return const _RisikoStyle(
          color: Color(0xFFDC2626), bg: Color(0xFFFEF2F2));
    } else if (lower.contains('sedang')) {
      return const _RisikoStyle(
          color: Color(0xFFD97706), bg: Color(0xFFFEF3C7));
    } else {
      return const _RisikoStyle(
          color: Color(0xFF16A34A), bg: Color(0xFFECFDF5));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Internal helper class
// ─────────────────────────────────────────────────────────────────────────────

class _RisikoStyle {
  final Color color;
  final Color bg;
  const _RisikoStyle({required this.color, required this.bg});
}