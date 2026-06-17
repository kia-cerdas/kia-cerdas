import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/services/pertumbuhan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/repositories/pertumbuhan_repository.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/widgets/index.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/perawatan/perawatan_screen_integrated.dart';
import 'package:ta_pa2_pa3_project/features/auth/presentation/screens/login_screen.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/widgets/growth_status_widget.dart';

class DetailPertumbuhanScreen extends StatefulWidget {
  final AnakSearchModel anak;

  const DetailPertumbuhanScreen({
    Key? key,
    required this.anak,
  }) : super(key: key);

  @override
  State<DetailPertumbuhanScreen> createState() =>
      _DetailPertumbuhanScreenState();
}

class _DetailPertumbuhanScreenState extends State<DetailPertumbuhanScreen> {
  String _hitungUmur(String tanggalLahir) {
    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final now = DateTime.now();
      int bulan =
          (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
      return "$bulan bulan";
    } catch (e) {
      return "-";
    }
  }

  /// Format angka desimal: hilangkan trailing zero tidak perlu, tapi tetap
  /// tampilkan 1 desimal. Contoh: 0.6 → "0.6", 16.0 → "16.0", 6.05 → "6.1"
  /// Khusus IMT: pastikan nilai > 5 (sanity check), karena DB kadang simpan
  /// desimal terbalik (0.160 seharusnya 16.0).
  String _fmt(double value, {bool isImt = false}) {
    if (isImt && value > 0 && value < 5) {
      // Kemungkinan nilai terbalik: 0.160 harusnya 16.0
      value = value * 100;
    }
    return value.toStringAsFixed(1);
  }

  late PertumbuhanRepository _repository;

  List<PertumbuhanModel> _riwayatPertumbuhan = [];
  List<MasterStandarModel> _masterStandarBBU = [];
  List<MasterStandarModel> _masterStandarTBU = [];
  List<MasterStandarModel> _masterStandarBBTB = [];
  List<MasterStandarModel> _masterStandarIMTU = [];
  List<MasterStandarModel> _masterStandarLKU = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedTab = 'BB/U'; // Default tab

  @override
  void initState() {
    super.initState();
    _repository = PertumbuhanRepository(apiService: PertumbuhanApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parallelkan semua API calls agar tidak loading lama secara sequential
      final results = await Future.wait([
        _repository.getRiwayatPertumbuhanByAnakId(widget.anak.id),
        _repository.getMasterStandar(
            parameter: 'bb_u', jenisKelamin: widget.anak.jenisKelamin),
        _repository.getMasterStandar(
            parameter: 'tb_u', jenisKelamin: widget.anak.jenisKelamin),
        _repository.getMasterStandar(
            parameter: 'bb_tb', jenisKelamin: widget.anak.jenisKelamin),
        _repository.getMasterStandar(
            parameter: 'imt_u', jenisKelamin: widget.anak.jenisKelamin),
        _repository.getMasterStandar(
            parameter: 'lk_u', jenisKelamin: widget.anak.jenisKelamin),
      ]);

      final riwayat = results[0] as List<PertumbuhanModel>;
      // Urutkan riwayat berdasarkan tanggal ukur agar grafik linear maju
      riwayat.sort((a, b) => a.tglUkur.compareTo(b.tglUkur));

      if (mounted) {
        setState(() {
          _riwayatPertumbuhan = riwayat;
          _masterStandarBBU = results[1] as List<MasterStandarModel>;
          _masterStandarTBU = results[2] as List<MasterStandarModel>;
          _masterStandarBBTB = results[3] as List<MasterStandarModel>;
          _masterStandarIMTU = results[4] as List<MasterStandarModel>;
          _masterStandarLKU = results[5] as List<MasterStandarModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<PertumbuhanModel> _getDataForTab() => _riwayatPertumbuhan;

  List<MasterStandarModel> _getMasterForTab() {
    switch (_selectedTab) {
      case 'TB/U':
        return _masterStandarTBU;
      case 'BB/TB':
        return _masterStandarBBTB;
      case 'IMT/U':
        return _masterStandarIMTU;
      case 'LK/U':
        return _masterStandarLKU;
      case 'BB/U':
      default:
        return _masterStandarBBU;
    }
  }

  double _getZScoreForTab(PertumbuhanModel data) {
    switch (_selectedTab) {
      case 'TB/U':
        return data.zScoreTBU;
      case 'BB/TB':
        return data.zScoreBBTB;
      case 'IMT/U':
        return data.zScoreIMTU;
      case 'LK/U':
        return data.zScoreLKU;
      case 'BB/U':
      default:
        return data.zScoreBBU;
    }
  }

  String _getStatusForTab(PertumbuhanModel data) {
    switch (_selectedTab) {
      case 'TB/U':
        return data.statusTBU;
      case 'BB/TB':
        return data.statusBBTB;
      case 'IMT/U':
        return data.statusIMTU;
      case 'LK/U':
        return data.statusLKU;
      case 'BB/U':
      default:
        return data.statusBBU;
    }
  }

  String _getXAxisLabel() =>
      _selectedTab == 'BB/TB' ? 'Tinggi Badan (cm)' : 'Usia (bulan)';

  String _getYAxisLabelFull() {
    switch (_selectedTab) {
      case 'TB/U':
        return 'Tinggi Badan (cm)';
      case 'IMT/U':
        return 'Indeks Massa Tubuh (kg/m²)';
      case 'LK/U':
        return 'Lingkar Kepala (cm)';
      case 'BB/U':
      case 'BB/TB':
      default:
        return 'Berat Badan (kg)';
    }
  }

  /// Helper untuk mendapatkan deskripsi status gizi
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _riwayatPertumbuhan.isNotEmpty);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () =>
                Navigator.pop(context, _riwayatPertumbuhan.isNotEmpty),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.anak.namaAnak,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_hitungUmur(widget.anak.tanggalLahir)} • ${widget.anak.jenisKelamin}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                  strokeWidth: 3,
                ),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : _buildContentState(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null &&
                _errorMessage!.toLowerCase().contains('unauthorized')) ...[
              ElevatedButton(
                onPressed: () async {
                  // clear session and navigate to login
                  await AuthSession.clear();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Login Ulang',
                    style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentState() {
    final latest =
        _riwayatPertumbuhan.isNotEmpty ? _riwayatPertumbuhan.last : null;
    final master = _getMasterForTab();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner atas
            _buildTopStatusBanner(),
            const SizedBox(height: 16),

            // 2. Tombol Lihat Grafik (navigasi ke fullscreen chart)
            _buildViewChartCard(),
            const SizedBox(height: 18),

            // 3. Info Anak
            ChildInfoBanner(anak: widget.anak),
            const SizedBox(height: 18),

            // 4. Ringkasan Status Gizi (jika ada data)
            if (latest != null) ...[
              GrowthSummaryWidget(
                statusBBU: latest.statusBBU,
                statusTBU: latest.statusTBU,
                statusBBTB: latest.statusBBTB,
                statusIMTU: latest.statusIMTU,
                statusLKU: latest.statusLKU,
                childName: widget.anak.namaAnak,
                childAge: _hitungUmur(widget.anak.tanggalLahir),
              ),
              const SizedBox(height: 18),
            ],

            // 5. Indikator Pertumbuhan
            _buildIndicators(),
            const SizedBox(height: 18),

            // 6. Interpretasi KMS
            _buildInterpretationPanel(),
            const SizedBox(height: 18),

            // 7. Tabel Standar WHO (dinamis dari masterStandar)
            _buildWhoStandardTable(),
            const SizedBox(height: 18),

            // 8. Jadwal ke Posyandu
            _buildPosyanduScheduleCard(),
            const SizedBox(height: 18),

            // 9. Tab selector kategori
            Row(
              children: [
                Container(width: 6, height: 24, color: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                const Text(
                  'Grafik & Status Gizi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['BB/U', 'TB/U', 'BB/TB', 'IMT/U', 'LK/U']
                    .map((tab) => _buildTabButton(tab))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 10. Konten per tab (grafik + status gizi)
            if (latest != null && master.isNotEmpty) ...[
              /// Pengukuran terakhir
              _buildMeasurementInfoCard(latest),
              const SizedBox(height: 16),

              /// Grafik (animasi saat ganti tab)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: GrowthChartWidget(
                  key: ValueKey(_selectedTab),
                  riwayatPertumbuhan: _getDataForTab(),
                  masterStandar: master,
                  yAxisLabel: _getYAxisLabelFull(),
                  selectedTab: _selectedTab,
                  xAxisLabel: _getXAxisLabel(),
                ),
              ),
              const SizedBox(height: 16),

              /// Status Gizi Detail
              GrowthStatusCard(
                status: _getStatusForTab(latest),
                label: 'Status ${_selectedTab}',
                zScore: _getZScoreForTab(latest),
                description: _getStatusDescription(_getStatusForTab(latest)),
              ),
            ] else ...[
              _buildEmptyStateData(),
            ],

            const SizedBox(height: 20),

            // 11. Riwayat pengukuran
            _buildRiwayatPengukuranCard(),
            const SizedBox(height: 24),

            // 12. Tombol Perawatan
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerawatanScreenIntegrated(
                        anakId: widget.anak.id,
                        anakName: widget.anak.namaAnak,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.white, size: 14),
                ),
                label: const Text(
                  'Lihat perawatan & milestone',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateData() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Belum ada data pengukuran',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInfoCard(PertumbuhanModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚖️ Pengukuran Terakhir',
            style: TextStyle(
              fontSize: 14,
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
            childAspectRatio: 1.6,
            children: [
              MiniStatCard(
                label: 'Berat Badan',
                value: _fmt(data.beratBadan),
                unit: 'kg',
                color: const Color(0xFF2563EB),
              ),
              MiniStatCard(
                label: 'Tinggi Badan',
                value: _fmt(data.tinggiBadan),
                unit: 'cm',
                color: const Color(0xFF8b5cf6),
              ),
              MiniStatCard(
                label: 'Lingkar Kepala',
                value: _fmt(data.lingkarKepala),
                unit: 'cm',
                color: const Color(0xFF10b981),
              ),
              MiniStatCard(
                label: 'IMT',
                value: _fmt(data.imt, isImt: true),
                unit: 'kg/m²',
                color: const Color(0xFFf59e0b),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Tanggal Ukur: ${data.tglUkur}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isActive = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatPengukuranCard() {
    if (_riwayatPertumbuhan.isEmpty) return const SizedBox.shrink();

    // Pastikan terurut terbaru di atas saat ditampilkan
    final reversedData = _riwayatPertumbuhan.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat pengukuran (4 Terbaru)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ...reversedData.take(4).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isLatest =
                index == 0; // Karena sudah di reversed, 0 adalah terbaru
            return Column(
              children: [
                _buildRiwayatItem(data, isLatest),
                if (index !=
                    (reversedData.length > 4 ? 3 : reversedData.length - 1))
                  Divider(
                      color: Colors.grey.shade200, height: 16, thickness: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(PertumbuhanModel data, bool isLatest) {
    final statusText = _getStatusForTab(data);
    final statusColors = _getStatusColor(statusText);
    final dotColor = statusColors['text'] ?? (isLatest ? const Color(0xFF2563EB) : Colors.grey.shade400);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.tglUkur} · ${data.usiaUkurBulan} bln',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(
                  'BB ${_fmt(data.beratBadan)} kg · TB ${_fmt(data.tinggiBadan)} cm · LK ${_fmt(data.lingkarKepala)} cm · IMT ${_fmt(data.imt, isImt: true)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: statusColors['bg'],
                borderRadius: BorderRadius.circular(12)),
            child: Text(statusText,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColors['text'])),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF97316), // orange
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Tumbuh Optimal',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Sesuai Buku KIA 2024 — Standar WHO',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildViewChartCard() {
    return GestureDetector(
      onTap: () {
        final master = _getMasterForTab();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              appBar: AppBar(
                title: const Text('Grafik Pertumbuhan'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: GrowthChartWidget(
                  riwayatPertumbuhan: _getDataForTab(),
                  masterStandar: master,
                  yAxisLabel: _getYAxisLabelFull(),
                  selectedTab: _selectedTab,
                  xAxisLabel: _getXAxisLabel(),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.show_chart, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lihat Grafik Pertumbuhan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'BB/U, TB/U, BB/TB, IMT/U, LK/U',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 6, height: 24, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            const Text(
              '3 Indikator Pertumbuhan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _smallInfoCard(
              Icons.scale,
              'Berat Badan',
              'Ditimbang bulanan di Posyandu sampai usia 5 tahun.',
            ),
            const SizedBox(height: 8),
            _smallInfoCard(
              Icons.height,
              'Panjang/Tinggi Badan',
              'Deteksi dini stunting. <2 tahun berbaring, ≥2 tahun berdiri.',
            ),
            const SizedBox(height: 8),
            _smallInfoCard(
              Icons.circle_outlined,
              'Lingkar Kepala',
              'Dipantau berkala untuk pertumbuhan otak.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tabel Standar BB & TB Median (WHO) — dinamis dari masterStandar
  Widget _buildWhoStandardTable() {
    final masterBBU = _masterStandarBBU;
    final masterTBU = _masterStandarTBU;
    final masterLKU = _masterStandarLKU;

    const usiaList = [0, 3, 6, 9, 12, 18, 24, 36, 48, 60];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                    width: 4, height: 20, color: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Standar BB & TB Median (WHO)',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          if (masterBBU.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data standar belum tersedia.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(const Color(0xFF1E3A5F)),
                headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                dataTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.black87),
                columnSpacing: 18,
                columns: const [
                  DataColumn(label: Text('Usia')),
                  DataColumn(label: Text('BB'), numeric: true),
                  DataColumn(label: Text('TB'), numeric: true),
                  DataColumn(label: Text('LK'), numeric: true),
                ],
                rows: List.generate(usiaList.length, (i) {
                  final usia = usiaList[i];
                  final bbM =
                      masterBBU.where((m) => m.nilaiSumbuX.round() == usia);
                  final tbM =
                      masterTBU.where((m) => m.nilaiSumbuX.round() == usia);
                  final lkM =
                      masterLKU.where((m) => m.nilaiSumbuX.round() == usia);
                  final bbVal =
                      bbM.isNotEmpty ? bbM.first.median : 0.0;
                  final tbVal =
                      tbM.isNotEmpty ? tbM.first.median : 0.0;
                  final lkVal =
                      lkM.isNotEmpty ? lkM.first.median : 0.0;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                        (states) => i.isEven
                            ? Colors.grey.shade50
                            : Colors.white),
                    cells: [
                      DataCell(Text('$usia bln',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600))),
                      DataCell(Text(
                          bbVal > 0 ? bbVal.toStringAsFixed(1) : '-')),
                      DataCell(Text(
                          tbVal > 0 ? tbVal.toStringAsFixed(1) : '-')),
                      DataCell(Text(
                          lkVal > 0 ? lkVal.toStringAsFixed(1) : '-')),
                    ],
                  );
                }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'BB dalam kg, TB & LK dalam cm. Sumber: WHO Child Growth Standards.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosyanduScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_available,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal ke Posyandu',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  'Datang tiap bulan untuk timbang BB & ukur TB.\nVitamin A diberikan setiap Februari & Agustus untuk anak 6–59 bulan.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 6, height: 24, color: const Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text(
              'Interpretasi Grafik KMS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _interpretationBox(
              Colors.green.shade50,
              Colors.green.shade700,
              'Naik (N) — Sehat',
              'Garis BB naik mengikuti pita warna atau pindah ke pita di atasnya.',
            ),
            const SizedBox(height: 8),
            _interpretationBox(
              Colors.orange.shade50,
              Colors.orange.shade700,
              'Tidak Naik (T) — Waspada',
              'Garis mendatar atau turun. Konsultasi ke kader/Puskesmas.',
            ),
            const SizedBox(height: 8),
            _interpretationBox(
              Colors.red.shade50,
              Colors.red.shade700,
              'Bawah Garis Merah (BGM)',
              'Tanda gizi buruk. Segera rujuk ke fasilitas kesehatan.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _interpretationBox(
      Color bg, Color textColor, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'gizi baik':
        return {'bg': const Color(0xFFD1FAE5), 'text': const Color(0xFF059669)};
      case 'kurang':
      case 'gizi kurang':
      case 'lebih':
      case 'berisiko gizi lebih':
        return {'bg': const Color(0xFFFED7AA), 'text': const Color(0xFFD97706)};
      case 'sangat kurang':
      case 'gizi buruk':
      case 'sangat lebih':
      case 'obesitas':
        return {'bg': const Color(0xFFFECACA), 'text': const Color(0xFFDC2626)};
      default:
        return {'bg': Colors.grey.shade200, 'text': Colors.grey.shade600};
    }
  }
}
