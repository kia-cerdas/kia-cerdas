import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/widgets/growth_status_widget.dart';

/// CONTOH INTEGRASI: Tambahkan widget ini ke DetailPertumbuhanScreen
/// Letakkan setelah section grafik dan sebelum section riwayat

class GrowthStatusSection extends StatelessWidget {
  final PertumbuhanModel? latest;
  final String selectedTab;
  final String childName;
  final String childAge;

  const GrowthStatusSection({
    Key? key,
    required this.latest,
    required this.selectedTab,
    required this.childName,
    required this.childAge,
  }) : super(key: key);

  /// Helper untuk mendapatkan deskripsi status
  String _getStatusDescription(String status) {
    final lower = status.toLowerCase();

    if (lower.contains('baik') || lower.contains('normal')) {
      return 'Status pertumbuhan anak Anda sangat baik. Terus pertahankan pola asuh dan nutrisi yang optimal.';
    } else if (lower.contains('kurang')) {
      return 'Pertumbuhan anak perlu diperhatikan. Tingkatkan asupan nutrisi dan lakukan pemeriksaan berkala.';
    } else if (lower.contains('buruk') || lower.contains('sangat')) {
      return 'Status pertumbuhan anak memerlukan intervensi medis segera. Hubungi petugas kesehatan terdekat.';
    } else if (lower.contains('risiko')) {
      return 'Ada risiko gangguan pertumbuhan. Lakukan monitoring lebih ketat dan konsultasi dengan tenaga kesehatan.';
    } else if (lower.contains('pendek')) {
      return 'Tinggi badan anak lebih pendek dari standar. Monitor pertumbuhan tinggi badan secara berkala.';
    } else if (lower.contains('stunting')) {
      return 'Anak menunjukkan gejala stunting. Segera konsultasi dengan dokter dan tingkatkan nutrisi.';
    } else if (lower.contains('obesitas') || lower.contains('lebih')) {
      return 'Berat badan anak cenderung berlebih. Kelola asupan kalori dan tingkatkan aktivitas fisik.';
    }

    return 'Monitoring status pertumbuhan anak secara berkala sangat penting untuk perkembangan optimal.';
  }

  @override
  Widget build(BuildContext context) {
    if (latest == null) {
      return const SizedBox.shrink();
    }

    // Tentukan status dan Z-Score berdasarkan tab yang dipilih
    late String status;
    late double zScore;
    late String statusDescription;

    switch (selectedTab) {
      case 'TB/U':
        status = latest!.statusTBU;
        zScore = latest!.zScoreTBU;
        break;
      case 'IMT/U':
        status = latest!.statusIMTU;
        zScore = latest!.zScoreIMTU;
        break;
      case 'LK/U':
        status = latest!.statusLKU;
        zScore = latest!.zScoreLKU;
        break;
      case 'BB/TB':
        status = latest!.statusBBTB;
        zScore = latest!.zScoreBBTB;
        break;
      case 'BB/U':
      default:
        status = latest!.statusBBU;
        zScore = latest!.zScoreBBU;
        break;
    }

    statusDescription = _getStatusDescription(status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// RINGKASAN STATUS GIZI
          GrowthSummaryWidget(
            statusBBU: latest!.statusBBU,
            statusTBU: latest!.statusTBU,
            statusBBTB: latest!.statusBBTB,
            childName: childName,
            childAge: childAge,
          ),
          const SizedBox(height: 20),

          /// STATUS GIZI DETAIL (SESUAI TAB YANG DIPILIH)
          GrowthStatusCard(
            status: status,
            label: 'Status ${selectedTab}',
            zScore: zScore,
            description: statusDescription,
          ),
          const SizedBox(height: 20),

          /// MINI STATS PENGUKURAN TERAKHIR
          Text(
            'Pengukuran Terakhir',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              MiniStatCard(
                label: 'Berat Badan',
                value: latest!.beratBadan.toStringAsFixed(1),
                unit: 'kg',
                color: const Color(0xFF2563EB),
              ),
              MiniStatCard(
                label: 'Tinggi Badan',
                value: latest!.tinggiBadan.toStringAsFixed(1),
                unit: 'cm',
                color: const Color(0xFF8b5cf6),
              ),
              MiniStatCard(
                label: 'Lingkar Kepala',
                value: latest!.lingkarKepala.toStringAsFixed(1),
                unit: 'cm',
                color: const Color(0xFF10b981),
              ),
              MiniStatCard(
                label: 'IMT',
                value: latest!.imt.toStringAsFixed(1),
                unit: 'kg/m²',
                color: const Color(0xFFf59e0b),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// CARA PENGGUNAAN DI DetailPertumbuhanScreen:
///
/// 1. Import di bagian atas file:
///    import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/widgets/growth_status_widget.dart';
///    import 'path/to/growth_status_section.dart';
///
/// 2. Ganti section ZScoreCardWidget dengan:
///    GrowthStatusSection(
///      latest: latest,
///      selectedTab: _selectedTab,
///      childName: widget.anak.namaAnak,
///      childAge: _hitungUmur(widget.anak.tanggalLahir),
///    ),
///
/// 3. Atau letakkan setelah GrowthChartWidget dalam SingleChildScrollView:
///    SingleChildScrollView(
///      child: Padding(
///        padding: const EdgeInsets.all(20),
///        child: Column(
///          crossAxisAlignment: CrossAxisAlignment.start,
///          children: [
///            // ... existing widgets ...
///            GrowthChartWidget(...),
///            GrowthStatusSection(
///              latest: latest,
///              selectedTab: _selectedTab,
///              childName: widget.anak.namaAnak,
///              childAge: _hitungUmur(widget.anak.tanggalLahir),
///            ),
///            // ... rest of widgets ...
///          ],
///        ),
///      ),
///    ),
