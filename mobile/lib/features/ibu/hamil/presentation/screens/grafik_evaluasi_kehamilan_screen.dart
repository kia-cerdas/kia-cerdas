import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/grafik_evaluasi_kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_evaluasi_kehamilan_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// ─── Palet warna konsisten ────────────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFF1A73E8);
  static const accent    = Color(0xFF34A853);
  static const warning   = Color(0xFFF9AB00);
  static const danger    = Color(0xFFD93025);
  static const surface   = Color(0xFFFFFFFF);
  static const bg        = Color(0xFFF1F3F8);
  static const border    = Color(0xFFE0E7F0);
  static const textMain  = Color(0xFF1C2B4A);
  static const textSub   = Color(0xFF6B7C93);
  static const zone      = Color(0xFFE8F5E9); // zona normal hijau muda
  static const zoneEdge  = Color(0xFF81C784);
  static const normalLine= Color(0xFF2E7D32);

  // Khusus DJJ
  static const djjBlue   = Color(0xFF0D47A1); // garis DJJ lebih gelap
  static const zoneDJJ   = Color(0xFFE3F2FD); // zona normal DJJ biru muda
  static const zoneDJJEdge = Color(0xFF90CAF9);
  static const bradiCardBg = Color(0xFFFFF3E0);
  static const takiCardBg  = Color(0xFFFFEBEE);
  static const normalCardBg = Color(0xFFE8F5E9);
}

class GrafikEvaluasiKehamilanScreen extends StatefulWidget {
  const GrafikEvaluasiKehamilanScreen({super.key});

  @override
  State<GrafikEvaluasiKehamilanScreen> createState() =>
      _GrafikEvaluasiKehamilanScreenState();
}

class _GrafikEvaluasiKehamilanScreenState
    extends State<GrafikEvaluasiKehamilanScreen>
    with SingleTickerProviderStateMixin {
  final _service = GrafikEvaluasiKehamilanApiService();
  late Future<GrafikEvaluasiKehamilanResponseModel> _future;
  late TabController _tabController;

  int? _selectedTFUIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _future = _service.getGrafikV2();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _service.dispose();
    super.dispose();
  }

  // ─── helpers ─────────────────────────────────────────────────────────────
  String _fmtDate(String value) {
    if (value.isEmpty) return '-';
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'normal':      return _C.accent;
      case 'tinggi':      return _C.danger;
      case 'rendah':      return _C.warning;
      case 'bradikardia': return _C.warning;
      case 'takikardia':  return _C.danger;
      default:            return _C.textSub;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'normal':         return 'Normal';
      case 'tinggi':         return 'Di atas normal';
      case 'rendah':         return 'Di bawah normal';
      case 'bradikardia':    return 'Bradikardia';
      case 'takikardia':     return 'Takikardia';
      case 'tidak_ada_data': return 'Belum diukur';
      default:               return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'normal':      return Icons.check_circle_rounded;
      case 'tinggi':
      case 'rendah':
      case 'bradikardia':
      case 'takikardia':  return Icons.warning_rounded;
      default:            return Icons.help_outline_rounded;
    }
  }

  // ─── build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: FutureBuilder<GrafikEvaluasiKehamilanResponseModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _C.primary),
            );
          }
          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat data',
              message: snapshot.error
                  .toString()
                  .replaceFirst('Exception: ', ''),
            );
          }
          final data = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTFUTab(data),
              _buildDJJTab(data),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // backgroundColor: _C.primary,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Evaluasi Kehamilan',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.55),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Tinggi Fundus (TFU)'),
          Tab(text: 'Denyut Jantung (DJJ)'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB TFU
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTFUTab(GrafikEvaluasiKehamilanResponseModel data) {
    final points = data.grafikTfu;
    if (points.isEmpty) {
      return const _EmptyState(
        icon: Icons.show_chart_rounded,
        title: 'Belum ada data TFU',
        message: 'Data Tinggi Fundus Uteri akan muncul setelah\npemeriksaan kehamilan dilakukan.',
      );
    }

    final withTFU = points.where((e) => e.tfu != null).toList();
    final allY = [
      ...withTFU.map((e) => e.tfu!),
      ...points.map((e) => e.upper),
      ...points.map((e) => e.lower),
    ];
    final minX  = points.map((e) => e.usia).reduce((a, b) => a < b ? a : b).toDouble() - 1;
    final maxX  = points.map((e) => e.usia).reduce((a, b) => a > b ? a : b).toDouble() + 1;
    final minY  = (allY.reduce((a, b) => a < b ? a : b) - 3).clamp(0, 999).toDouble();
    final maxY  = allY.reduce((a, b) => a > b ? a : b) + 3;

    final normalCount   = points.where((e) => e.statusTFU == 'normal').length;
    final abnormalCount = points.where((e) => e.statusTFU == 'tinggi' || e.statusTFU == 'rendah').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(
            total: points.length,
            normal: normalCount,
            abnormal: abnormalCount,
            labelNormal: 'Kunjungan Normal',
            labelAbnormal: 'Perlu Perhatian',
          ),
          const SizedBox(height: 14),

          _SectionCard(
            title: 'Grafik Tinggi Fundus Uteri',
            subtitle: 'Zona hijau = rentang normal (±2 cm dari usia kehamilan)',
            child: SizedBox(
              height: 300,
              child: LineChart(
                _tfuChartData(points, withTFU, minX, maxX, minY, maxY),
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildTFULegend(),
          const SizedBox(height: 20),

          if (data.penjelasanHasilGrafik != null &&
              data.penjelasanHasilGrafik!.isNotEmpty) ...[
            _PenjelasanCard(teks: data.penjelasanHasilGrafik!),
            const SizedBox(height: 20),
          ],

          _buildSectionHeader('Riwayat Kunjungan', '${points.length} catatan'),
          const SizedBox(height: 10),

          ...points.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return _TFUVisitCard(
              point: p,
              index: i,
              isSelected: _selectedTFUIndex == i,
              formatDate: _fmtDate,
              statusColor: _statusColor,
              statusLabel: _statusLabel,
              statusIcon: _statusIcon,
              onTap: () => setState(() {
                _selectedTFUIndex = _selectedTFUIndex == i ? null : i;
              }),
            );
          }),
        ],
      ),
    );
  }

  LineChartData _tfuChartData(
    List<GrafikTFUPointModel> all,
    List<GrafikTFUPointModel> withTFU,
    double minX, double maxX, double minY, double maxY,
  ) {
    return LineChartData(
      minX: minX, maxX: maxX, minY: minY, maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 2,
        getDrawingHorizontalLine: (_) => FlLine(
          color: _C.border,
          strokeWidth: 0.8,
        ),
        getDrawingVerticalLine: (_) => FlLine(
          color: _C.border.withOpacity(0.5),
          strokeWidth: 0.8,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('cm', style: TextStyle(fontSize: 9, color: _C.textSub)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 4,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 10, color: _C.textSub),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Minggu', style: TextStyle(fontSize: 9, color: _C.textSub)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 4,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 10, color: _C.textSub),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: _C.border, width: 1),
          bottom: BorderSide(color: _C.border, width: 1),
        ),
      ),
      betweenBarsData: [
        BetweenBarsData(
          fromIndex: 1,
          toIndex: 2,
          color: _C.zone.withOpacity(0.7),
        ),
      ],
      lineBarsData: [
        // Garis normal referensi
        LineChartBarData(
          isCurved: true,
          color: _C.normalLine,
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          dashArray: [6, 4],
          spots: all.map((e) => FlSpot(e.usia.toDouble(), e.normal)).toList(),
        ),
        // Batas atas
        LineChartBarData(
          isCurved: true,
          color: _C.zoneEdge,
          barWidth: 1.2,
          dotData: const FlDotData(show: false),
          dashArray: [4, 4],
          spots: all.map((e) => FlSpot(e.usia.toDouble(), e.upper)).toList(),
        ),
        // Batas bawah
        LineChartBarData(
          isCurved: true,
          color: _C.zoneEdge,
          barWidth: 1.2,
          dotData: const FlDotData(show: false),
          dashArray: [4, 4],
          spots: all.map((e) => FlSpot(e.usia.toDouble(), e.lower)).toList(),
        ),
        // TFU aktual
        LineChartBarData(
          isCurved: true,
          color: _C.primary,
          barWidth: 2.5,
          shadow: const Shadow(
            color: Color(0x331A73E8),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, bar, index) {
              final p = withTFU.firstWhere(
                (e) => e.usia == spot.x.toInt(),
                orElse: () => withTFU.first,
              );
              final dotColor = p.statusTFU == 'normal'
                  ? _C.accent
                  : (p.statusTFU == 'tidak_ada_data' ? _C.textSub : _C.danger);
              return FlDotCirclePainter(
                radius: 5,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: dotColor,
              );
            },
          ),
          spots: withTFU.map((e) => FlSpot(e.usia.toDouble(), e.tfu!)).toList(),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }

  // ── Legend TFU — list vertikal yang jelas (sama seperti grafik BB) ────────
  Widget _buildTFULegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Grafik',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: _C.textMain),
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: 'TFU Aktual',
            desc:
                'Garis biru menunjukkan pengukuran Tinggi Fundus Uteri (TFU) ibu dari setiap kunjungan',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: CustomPaint(
              size: const Size(28, 3),
              painter: _DashedPainter(_C.normalLine),
            ),
            title: 'Referensi Normal',
            desc:
                'Garis putus-putus hijau tua adalah nilai TFU ideal sesuai usia kehamilan (cm ≈ minggu)',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: SizedBox(
              width: 28,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(height: 14, color: _C.zone),
                  CustomPaint(
                    size: const Size(28, 3),
                    painter: _DashedPainter(_C.zoneEdge),
                  ),
                ],
              ),
            ),
            title: 'Batas ±2 cm',
            desc:
                'Area hijau muda adalah rentang toleransi normal — TFU di luar area ini perlu evaluasi lebih lanjut',
          ),
        ],
      ),
    );
  }

  Widget _legendRow({
    required Widget indicator,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Center(child: indicator),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain)),
              const SizedBox(height: 2),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 11, color: _C.textSub, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB DJJ
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDJJTab(GrafikEvaluasiKehamilanResponseModel data) {
    final points = data.grafikDjj;
    if (points.isEmpty) {
      return const _EmptyState(
        icon: Icons.monitor_heart_rounded,
        title: 'Belum ada data DJJ',
        message: 'Data Denyut Jantung Janin biasanya dicatat\nmulai Trimester 3 (pemeriksaan dokter).',
      );
    }

    final minX = points.map((e) => e.usia).reduce((a, b) => a < b ? a : b).toDouble() - 1;
    final maxX = points.map((e) => e.usia).reduce((a, b) => a > b ? a : b).toDouble() + 1;

    final normalCount    = points.where((e) => e.statusDJJ == 'normal').length;
    final bradiCount     = points.where((e) => e.statusDJJ == 'bradikardia').length;
    final takiCount      = points.where((e) => e.statusDJJ == 'takikardia').length;
    final abnormalCount  = bradiCount + takiCount;

    // DJJ terkini untuk info header
    final latest = points.last;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner DJJ terkini ──
          _DJJLatestBanner(point: latest, statusColor: _statusColor, statusLabel: _statusLabel),
          const SizedBox(height: 14),

          // ── Stat row ──
          _buildDJJStatRow(
            total: points.length,
            normal: normalCount,
            bradi: bradiCount,
            taki: takiCount,
          ),
          const SizedBox(height: 14),

          // ── Grafik ──
          _SectionCard(
            title: 'Grafik Denyut Jantung Janin',
            subtitle: 'Zona biru = rentang normal 110–160 x/menit',
            child: SizedBox(
              height: 300,
              child: LineChart(
                _djjChartData(points, minX, maxX),
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildDJJLegend(),
          const SizedBox(height: 10),

          // ── Keterangan klinis ──
          _DJJKlinisInfo(),
          const SizedBox(height: 20),

          // ── Header riwayat ──
          _buildSectionHeader('Riwayat Pemeriksaan DJJ', '${points.length} data'),
          const SizedBox(height: 10),

          // ── Kartu per pemeriksaan ──
          ...points.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return _DJJVisitCard(
              point: p,
              index: i,
              formatDate: _fmtDate,
              statusColor: _statusColor,
              statusLabel: _statusLabel,
              statusIcon: _statusIcon,
            );
          }),
        ],
      ),
    );
  }

  LineChartData _djjChartData(
    List<GrafikDJJPointModel> points,
    double minX, double maxX,
  ) {
    // Tentukan minY/maxY dinamis berdasarkan data, dengan padding
    final allDJJ = points.map((e) => e.djj.toDouble()).toList();
    final dataMin = allDJJ.reduce((a, b) => a < b ? a : b);
    final dataMax = allDJJ.reduce((a, b) => a > b ? a : b);
    final minY = (dataMin - 20).clamp(60.0, 110.0);
    final maxY = (dataMax + 20).clamp(160.0, 220.0);

    return LineChartData(
      minX: minX, maxX: maxX, minY: minY, maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 2,
        getDrawingHorizontalLine: (v) => FlLine(
          color: (v == 110 || v == 160)
              ? _C.danger.withOpacity(0.5)
              : _C.border.withOpacity(0.6),
          strokeWidth: (v == 110 || v == 160) ? 1.8 : 0.8,
        ),
        getDrawingVerticalLine: (_) =>
            FlLine(color: _C.border.withOpacity(0.4), strokeWidth: 0.8),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('x/mnt', style: TextStyle(fontSize: 9, color: _C.textSub)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 10,
            getTitlesWidget: (v, _) {
              final isBound = v == 110 || v == 160;
              return Text(
                v.toInt().toString(),
                style: TextStyle(
                  fontSize: isBound ? 10 : 9,
                  color: isBound ? _C.danger : _C.textSub,
                  fontWeight: isBound ? FontWeight.w800 : FontWeight.normal,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Minggu', style: TextStyle(fontSize: 9, color: _C.textSub)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 2,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(fontSize: 10, color: _C.textSub),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: _C.border, width: 1),
          bottom: BorderSide(color: _C.border, width: 1),
        ),
      ),
      betweenBarsData: [
        // Zona normal biru muda antara batas atas (index 0) dan batas bawah (index 1)
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          color: _C.zoneDJJ.withOpacity(0.8),
        ),
      ],
      lineBarsData: [
        // Batas atas 160 (index 0 untuk betweenBarsData)
        LineChartBarData(
          isCurved: false,
          color: _C.danger.withOpacity(0.7),
          barWidth: 1.8,
          dotData: const FlDotData(show: false),
          dashArray: [8, 5],
          spots: [FlSpot(minX, 160), FlSpot(maxX, 160)],
        ),
        // Batas bawah 110 (index 1 untuk betweenBarsData)
        LineChartBarData(
          isCurved: false,
          color: _C.danger.withOpacity(0.7),
          barWidth: 1.8,
          dotData: const FlDotData(show: false),
          dashArray: [8, 5],
          spots: [FlSpot(minX, 110), FlSpot(maxX, 110)],
        ),
        // DJJ aktual (index 2)
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.3,
          color: _C.djjBlue,
          barWidth: 2.8,
          shadow: const Shadow(
            color: Color(0x440D47A1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) {
              final p = points.firstWhere(
                (e) => e.usia == spot.x.toInt(),
                orElse: () => points.first,
              );
              Color dotStroke;
              switch (p.statusDJJ) {
                case 'bradikardia':
                  dotStroke = _C.warning;
                  break;
                case 'takikardia':
                  dotStroke = _C.danger;
                  break;
                default:
                  dotStroke = _C.accent;
              }
              return FlDotCirclePainter(
                radius: 5.5,
                color: Colors.white,
                strokeWidth: 2.8,
                strokeColor: dotStroke,
              );
            },
          ),
          spots: points
              .map((e) => FlSpot(e.usia.toDouble(), e.djj.toDouble()))
              .toList(),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }

  // ── Legend DJJ — list vertikal yang jelas (sama seperti TFU & BB) ─────────
  Widget _buildDJJLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Grafik',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: _C.textMain),
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: _C.djjBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: 'DJJ Aktual',
            desc:
                'Garis biru tua menunjukkan nilai Denyut Jantung Janin yang tercatat di setiap kunjungan',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: SizedBox(
              width: 28,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(height: 14, color: _C.zoneDJJ),
                  CustomPaint(
                    size: const Size(28, 3),
                    painter: _DashedPainter(_C.zoneDJJEdge),
                  ),
                ],
              ),
            ),
            title: 'Zona Normal (110–160)',
            desc:
                'Area biru muda adalah rentang DJJ yang sehat — janin dikatakan normal jika berada di zona ini',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: CustomPaint(
              size: const Size(28, 3),
              painter: _DashedPainter(_C.danger),
            ),
            title: 'Batas Kritis',
            desc:
                'Garis merah putus-putus adalah batas atas (160) dan batas bawah (110) — DJJ di luar batas ini perlu penanganan segera',
          ),
        ],
      ),
    );
  }

  // ─── helper widgets ───────────────────────────────────────────────────────

  Widget _buildStatRow({
    required int total,
    required int normal,
    required int abnormal,
    required String labelNormal,
    required String labelAbnormal,
  }) {
    return Row(
      children: [
        _StatChip(value: total,    label: 'Total',       color: _C.primary),
        const SizedBox(width: 8),
        _StatChip(value: normal,   label: labelNormal,   color: _C.accent),
        const SizedBox(width: 8),
        _StatChip(
            value: abnormal,
            label: labelAbnormal,
            color: abnormal > 0 ? _C.danger : _C.textSub),
      ],
    );
  }

  Widget _buildDJJStatRow({
    required int total,
    required int normal,
    required int bradi,
    required int taki,
  }) {
    return Row(
      children: [
        _StatChip(value: total,  label: 'Total',        color: _C.primary),
        const SizedBox(width: 8),
        _StatChip(value: normal, label: 'Normal',       color: _C.accent),
        const SizedBox(width: 8),
        _StatChip(value: bradi,  label: 'Bradikardia',  color: bradi > 0 ? _C.warning : _C.textSub),
        const SizedBox(width: 8),
        _StatChip(value: taki,   label: 'Takikardia',   color: taki > 0 ? _C.danger : _C.textSub),
      ],
    );
  }

  Widget _buildLegend({required List<_LegendItem> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.solid
                ? Container(
                    width: 18, height: 3,
                    decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2)))
                : CustomPaint(
                    size: const Size(18, 3),
                    painter: _DashedPainter(item.color)),
            const SizedBox(width: 6),
            Text(item.label,
                style: const TextStyle(fontSize: 11, color: _C.textMain)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: _C.textMain),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(badge,
              style: const TextStyle(
                  fontSize: 11,
                  color: _C.primary,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BANNER DJJ TERKINI
// ══════════════════════════════════════════════════════════════════════════════

class _DJJLatestBanner extends StatelessWidget {
  final GrafikDJJPointModel point;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;

  const _DJJLatestBanner({
    required this.point,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(point.statusDJJ);
    final sl = statusLabel(point.statusDJJ);

    Color bgColor;
    switch (point.statusDJJ) {
      case 'bradikardia':
        bgColor = _C.bradiCardBg;
        break;
      case 'takikardia':
        bgColor = _C.takiCardBg;
        break;
      default:
        bgColor = _C.normalCardBg;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sc.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sc.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon jantung
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: sc.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.monitor_heart_rounded, color: sc, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DJJ Terakhir Tercatat',
                  style: TextStyle(
                      fontSize: 11,
                      color: _C.textSub,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${point.djj}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: sc,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'x/menit',
                        style: TextStyle(
                            fontSize: 13,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Normal: ${point.lower}–${point.upper} x/menit',
                  style: const TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
          // Status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sc,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sl,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Minggu ${point.usia}',
                style: const TextStyle(fontSize: 11, color: _C.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INFO KLINIS DJJ
// ══════════════════════════════════════════════════════════════════════════════

class _DJJKlinisInfo extends StatelessWidget {
  const _DJJKlinisInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: _C.primary),
              SizedBox(width: 6),
              Text(
                'Interpretasi DJJ',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textMain),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildKlinisRow(
            color: _C.accent,
            icon: Icons.check_circle_rounded,
            label: 'Normal',
            value: '110–160 x/menit',
            desc: 'Jantung janin berdetak dalam batas sehat',
          ),
          const SizedBox(height: 8),
          _buildKlinisRow(
            color: _C.warning,
            icon: Icons.keyboard_arrow_down_rounded,
            label: 'Bradikardia',
            value: '< 110 x/menit',
            desc: 'Denyut terlalu lambat, perlu evaluasi segera',
          ),
          const SizedBox(height: 8),
          _buildKlinisRow(
            color: _C.danger,
            icon: Icons.keyboard_arrow_up_rounded,
            label: 'Takikardia',
            value: '> 160 x/menit',
            desc: 'Denyut terlalu cepat, segera konsultasikan',
          ),
        ],
      ),
    );
  }

  Widget _buildKlinisRow({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    required String desc,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 11, color: _C.textSub),
                  ),
                ],
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 10, color: _C.textSub),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KARTU KUNJUNGAN TFU
// ══════════════════════════════════════════════════════════════════════════════

class _TFUVisitCard extends StatelessWidget {
  final GrafikTFUPointModel point;
  final int index;
  final bool isSelected;
  final String Function(String) formatDate;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final IconData Function(String) statusIcon;
  final VoidCallback onTap;

  const _TFUVisitCard({
    required this.point,
    required this.index,
    required this.isSelected,
    required this.formatDate,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(point.statusTFU);
    final sl = statusLabel(point.statusTFU);
    final si = statusIcon(point.statusTFU);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? sc.withOpacity(0.6) : _C.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: sc.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4))]
              : [const BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _C.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _C.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minggu ${point.usia}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _C.textMain),
                        ),
                        Text(
                          formatDate(point.tanggalPeriksa),
                          style: const TextStyle(
                              fontSize: 12, color: _C.textSub),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(si, size: 13, color: sc),
                        const SizedBox(width: 4),
                        Text(sl,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sc)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(
                children: [
                  _DataPill(
                    icon: Icons.straighten_rounded,
                    label: 'TFU',
                    value: point.tfu != null
                        ? '${point.tfu!.toStringAsFixed(1)} cm'
                        : '-',
                    color: _C.primary,
                  ),
                  const SizedBox(width: 8),
                  _DataPill(
                    icon: Icons.favorite_rounded,
                    label: 'Tekanan Darah',
                    value: point.tekananDarah.isNotEmpty
                        ? point.tekananDarah
                        : '-',
                    color: _C.danger,
                  ),
                  const SizedBox(width: 8),
                  _DataPill(
                    icon: Icons.water_drop_rounded,
                    label: 'Hb',
                    value: point.hemoglobin != null
                        ? '${point.hemoglobin!.toStringAsFixed(1)} g/dL'
                        : '-',
                    color: _C.warning,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isSelected
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Column(
                  children: [
                    const Divider(height: 1, color: _C.border),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailRow(
                            label: 'Protein Urine',
                            value: point.urinProtein.isNotEmpty
                                ? point.urinProtein
                                : '-',
                          ),
                        ),
                        Expanded(
                          child: _DetailRow(
                            label: 'Tablet TTD',
                            value: point.tabletTambahDarah != null
                                ? '${point.tabletTambahDarah} tablet'
                                : '-',
                          ),
                        ),
                        Expanded(
                          child: _DetailRow(
                            label: 'Gerakan Bayi',
                            value: point.gerakanBayi == null
                                ? '-'
                                : (point.gerakanBayi == 'kurang'
                                    ? '⚠️ Kurang'
                                    : '✅ Normal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(13)),
              ),
              child: Center(
                child: Icon(
                  isSelected
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: _C.textSub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KARTU KUNJUNGAN DJJ (ENHANCED)
// ══════════════════════════════════════════════════════════════════════════════

class _DJJVisitCard extends StatelessWidget {
  final GrafikDJJPointModel point;
  final int index;
  final String Function(String) formatDate;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final IconData Function(String) statusIcon;

  const _DJJVisitCard({
    required this.point,
    required this.index,
    required this.formatDate,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(point.statusDJJ);
    final sl = statusLabel(point.statusDJJ);
    final si = statusIcon(point.statusDJJ);

    final djj = point.djj;
    final lower = point.lower;
    final upper = point.upper;
    final range = upper - lower;
    double progressVal;
    if (djj < lower) {
      progressVal = 0.0;
    } else if (djj > upper) {
      progressVal = 1.0;
    } else {
      progressVal = (djj - lower) / range;
    }
    final isAbnormal = point.statusDJJ != 'normal';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Ikon jantung
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.monitor_heart_rounded, color: sc, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Minggu ${point.usia}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textMain),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: sc.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(si, size: 12, color: sc),
                                  const SizedBox(width: 3),
                                  Text(sl,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: sc)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          formatDate(point.tanggalPeriksa),
                          style: const TextStyle(fontSize: 11, color: _C.textSub),
                        ),
                        const SizedBox(height: 8),
                        // Nilai DJJ besar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$djj',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: sc,
                                height: 1.0,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                'x/menit',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _C.textSub,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${point.lower}–${point.upper}',
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textSub),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar zona normal
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        // Background abu
                        Container(
                          height: 6,
                          width: double.infinity,
                          color: _C.border,
                        ),
                        // Zona normal (antara 0.0 dan 1.0)
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: _C.zoneDJJ,
                            ),
                          ),
                        ),
                        // Posisi DJJ
                        FractionallySizedBox(
                          widthFactor: progressVal.clamp(0.0, 1.0),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isAbnormal
                                      ? sc.withOpacity(0.4)
                                      : _C.accent.withOpacity(0.4),
                                  isAbnormal ? sc : _C.accent,
                                ],
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${point.lower}',
                          style: const TextStyle(
                              fontSize: 9, color: _C.textSub)),
                      if (isAbnormal)
                        Text(
                          djj < lower
                              ? '${lower - djj} di bawah batas'
                              : '${djj - upper} di atas batas',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: sc),
                        ),
                      Text('${point.upper}',
                          style: const TextStyle(
                              fontSize: 9, color: _C.textSub)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET HELPER
// ══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          const BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.textMain)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: _C.textSub)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatChip(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(fontSize: 9, color: _C.textSub)),
          ],
        ),
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DataPill(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _C.textMain),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.textSub)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _C.textMain)),
      ],
    );
  }
}

class _PenjelasanCard extends StatelessWidget {
  final String teks;

  const _PenjelasanCard({required this.teks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.primary.withOpacity(0.08),
            _C.accent.withOpacity(0.06)
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _C.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan dari Tenaga Kesehatan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  teks,
                  style: const TextStyle(
                      fontSize: 13, color: _C.textMain, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState(
      {required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: _C.primary),
            ),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _C.textMain)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _C.textSub, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final bool solid;

  const _LegendItem(
      {required this.color, required this.label, required this.solid});
}

class _DashedPainter extends CustomPainter {
  final Color color;
  const _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 5, 0), paint);
      x += 9;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}