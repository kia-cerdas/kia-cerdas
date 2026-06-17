import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/grafik_peningkatan_bb_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_peningkatan_bb_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// ─── Palet warna — identik dengan TFU/DJJ ────────────────────────────────────
class _C {
  static const primary = Color(0xFF1A73E8);
  static const accent = Color(0xFF34A853);
  static const warning = Color(0xFFF9AB00);
  static const danger = Color(0xFFD93025);
  static const surface = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF1F3F8);
  static const border = Color(0xFFE0E7F0);
  static const textMain = Color(0xFF1C2B4A);
  static const textSub = Color(0xFF6B7C93);
  static const zoneBB = Color(0xFFE3F2FD);
  static const zoneBBEdge = Color(0xFF90CAF9);
}

class GrafikPeningkatanBBScreen extends StatefulWidget {
  const GrafikPeningkatanBBScreen({super.key});

  @override
  State<GrafikPeningkatanBBScreen> createState() =>
      _GrafikPeningkatanBBScreenState();
}

class _GrafikPeningkatanBBScreenState
    extends State<GrafikPeningkatanBBScreen> {
  final _service = GrafikPeningkatanBBApiService();
  late Future<GrafikBBResponseModel> _future;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _future = _service.getGrafikBBV2();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'normal':
        return _C.accent;
      case 'lebih':
        return _C.danger;
      case 'kurang':
        return _C.warning;
      default:
        return _C.textSub;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'normal':
        return 'Normal';
      case 'lebih':
        return 'Di atas normal';
      case 'kurang':
        return 'Di bawah normal';
      default:
        return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'normal':
        return Icons.check_circle_rounded;
      case 'lebih':
        return Icons.keyboard_arrow_up_rounded;
      case 'kurang':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        // backgroundColor: AppColors.primary,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Grafik Berat Badan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: FutureBuilder<GrafikBBResponseModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _C.primary),
            );
          }
          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.monitor_weight_rounded,
              title: 'Gagal memuat data',
              message:
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(GrafikBBResponseModel data) {
    final points = data.grafikBb;

    if (points.isEmpty) {
      return _EmptyState(
        icon: Icons.monitor_weight_rounded,
        title: 'Belum ada data berat badan',
        message:
            'Data berat badan akan muncul setelah\ntenaga kesehatan mencatat pengukuran BB.',
        extra: _buildInfoKategori(data),
      );
    }

    final normalCount = points.where((e) => e.status == 'normal').length;
    final kurangCount = points.where((e) => e.status == 'kurang').length;
    final lebihCount = points.where((e) => e.status == 'lebih').length;
    final latest = points.last;

    final minX = points
            .map((e) => e.mingguKehamilan)
            .reduce((a, b) => a < b ? a : b)
            .toDouble() -
        1;
    final maxX = points
            .map((e) => e.mingguKehamilan)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        1;

    final allKenaikan = points.map((e) => e.kenaikanDariAwal).toList();
    final dataMax = allKenaikan.reduce((a, b) => a > b ? a : b);
    final batasMaxAkhir =
        points.map((e) => e.batasMax).reduce((a, b) => a > b ? a : b);
    const minY = -1.0;
    final maxY = (dataMax > batasMaxAkhir ? dataMax : batasMaxAkhir) + 2;

    final yRange = maxY - minY;
    final interval = yRange <= 8
        ? 1.0
        : yRange <= 16
            ? 2.0
            : yRange <= 30
                ? 4.0
                : 5.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BBLatestBanner(
            point: latest,
            bbAwal: data.bbAwal,
            statusColor: _statusColor,
            statusLabel: _statusLabel,
          ),
          const SizedBox(height: 14),

          _buildStatRow(
            total: points.length,
            normal: normalCount,
            kurang: kurangCount,
            lebih: lebihCount,
          ),
          const SizedBox(height: 14),

          _buildInfoKategori(data),
          const SizedBox(height: 14),

          _SectionCard(
            title: 'Grafik Kenaikan Berat Badan',
            subtitle: 'Zona biru = rentang kenaikan normal berdasarkan IMT',
            child: SizedBox(
              height: 300,
              child: LineChart(
                _bbChartData(points, minX, maxX, minY, maxY, interval, data),
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Legend — diubah jadi list vertikal yang lebih jelas
          _buildLegend(),
          const SizedBox(height: 14),

          _BBKlinisInfo(
            targetMin: data.targetMin,
            targetMax: data.targetMax,
            imtKategori: data.imtKategori,
          ),
          const SizedBox(height: 14),

          if (data.penjelasanHasilGrafik.isNotEmpty) ...[
            _PenjelasanCard(teks: data.penjelasanHasilGrafik),
            const SizedBox(height: 14),
          ],

          _buildSectionHeader(
              'Riwayat Pengukuran BB', '${points.length} catatan'),
          const SizedBox(height: 10),

          ...points.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return _BBVisitCard(
              point: p,
              index: i,
              bbAwal: data.bbAwal,
              isSelected: _selectedIndex == i,
              statusColor: _statusColor,
              statusLabel: _statusLabel,
              statusIcon: _statusIcon,
              onTap: () => setState(() {
                _selectedIndex = _selectedIndex == i ? null : i;
              }),
            );
          }),
        ],
      ),
    );
  }

  LineChartData _bbChartData(
    List<GrafikBBPointModel> points,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double interval,
    GrafikBBResponseModel data,
  ) {
    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: interval,
        verticalInterval: 4,
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
            child: Text('kg (kenaikan)',
                style: TextStyle(fontSize: 9, color: _C.textSub)),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: const TextStyle(fontSize: 10, color: _C.textSub),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Minggu',
                style: TextStyle(fontSize: 9, color: _C.textSub)),
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
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          fromIndex: 0,
          toIndex: 1,
          color: _C.zoneBB.withOpacity(0.8),
        ),
      ],
      lineBarsData: [
        LineChartBarData(
          isCurved: false,
          color: _C.danger.withOpacity(0.7),
          barWidth: 1.8,
          dotData: const FlDotData(show: false),
          dashArray: [8, 5],
          spots: points
              .map((e) => FlSpot(e.mingguKehamilan.toDouble(), e.batasMin))
              .toList(),
        ),
        LineChartBarData(
          isCurved: false,
          color: _C.danger.withOpacity(0.7),
          barWidth: 1.8,
          dotData: const FlDotData(show: false),
          dashArray: [8, 5],
          spots: points
              .map((e) => FlSpot(e.mingguKehamilan.toDouble(), e.batasMax))
              .toList(),
        ),
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.3,
          color: _C.primary,
          barWidth: 2.8,
          shadow: const Shadow(
            color: Color(0x331A73E8),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) {
              final p = points.firstWhere(
                (e) => e.mingguKehamilan == spot.x.toInt(),
                orElse: () => points.first,
              );
              Color dotStroke;
              switch (p.status) {
                case 'kurang':
                  dotStroke = _C.warning;
                  break;
                case 'lebih':
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
              .map((e) =>
                  FlSpot(e.mingguKehamilan.toDouble(), e.kenaikanDariAwal))
              .toList(),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }

  // ── Legend diubah jadi list vertikal yang jelas ─────────────────────────
  Widget _buildLegend() {
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
            title: 'Kenaikan BB Aktual',
            desc: 'Garis biru menunjukkan kenaikan berat badan ibu dari awal kehamilan',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: SizedBox(
              width: 28,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(height: 14, color: _C.zoneBB),
                  CustomPaint(
                    size: const Size(28, 3),
                    painter: _DashedPainter(_C.zoneBBEdge),
                  ),
                ],
              ),
            ),
            title: 'Zona Normal',
            desc: 'Area biru muda adalah rentang kenaikan BB yang dianjurkan sesuai IMT ibu',
          ),
          const SizedBox(height: 10),
          _legendRow(
            indicator: CustomPaint(
              size: const Size(28, 3),
              painter: _DashedPainter(_C.danger),
            ),
            title: 'Batas Kritis',
            desc: 'Garis merah putus-putus adalah batas atas dan bawah zona normal — jika kenaikan BB melewati garis ini perlu perhatian',
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
                  style:
                      const TextStyle(fontSize: 11, color: _C.textSub, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoKategori(GrafikBBResponseModel data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monitor_weight_rounded,
                color: _C.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.imtKategori,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textMain),
                ),
                const SizedBox(height: 2),
                Text(
                  'BB awal: ${data.bbAwal.toStringAsFixed(1)} kg  •  Target kenaikan: ${data.targetMin.toStringAsFixed(1)}–${data.targetMax.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required int total,
    required int normal,
    required int kurang,
    required int lebih,
  }) {
    return Row(
      children: [
        _StatChip(value: total, label: 'Total', color: _C.primary),
        const SizedBox(width: 8),
        _StatChip(value: normal, label: 'Normal', color: _C.accent),
        const SizedBox(width: 8),
        _StatChip(
            value: kurang,
            label: 'Di bawah normal',
            color: kurang > 0 ? _C.warning : _C.textSub),
        const SizedBox(width: 8),
        _StatChip(
            value: lebih,
            label: 'Di atas normal',
            color: lebih > 0 ? _C.danger : _C.textSub),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: _C.textMain)),
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
// BANNER BB TERKINI
// ══════════════════════════════════════════════════════════════════════════════

class _BBLatestBanner extends StatelessWidget {
  final GrafikBBPointModel point;
  final double bbAwal;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;

  const _BBLatestBanner({
    required this.point,
    required this.bbAwal,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(point.status);
    final sl = statusLabel(point.status);

    Color bgColor;
    switch (point.status) {
      case 'kurang':
        bgColor = const Color(0xFFFFF8E1);
        break;
      case 'lebih':
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        bgColor = const Color(0xFFE8F5E9);
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: sc.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.monitor_weight_rounded, color: sc, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berat Badan Terakhir',
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
                      point.beratBadan.toStringAsFixed(1),
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
                        'kg',
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
                  'Kenaikan: +${point.kenaikanDariAwal.toStringAsFixed(1)} kg dari awal (${bbAwal.toStringAsFixed(1)} kg)',
                  style: const TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
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
                'Minggu ${point.mingguKehamilan}',
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
// INFO KLINIS BB
// ══════════════════════════════════════════════════════════════════════════════

class _BBKlinisInfo extends StatelessWidget {
  final double targetMin;
  final double targetMax;
  final String imtKategori;

  const _BBKlinisInfo({
    required this.targetMin,
    required this.targetMax,
    required this.imtKategori,
  });

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
                'Panduan Kenaikan BB',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textMain),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRow(
            color: _C.accent,
            icon: Icons.check_circle_rounded,
            label: 'Normal',
            value:
                '${targetMin.toStringAsFixed(1)}–${targetMax.toStringAsFixed(1)} kg',
            desc: 'Target kenaikan BB selama kehamilan sesuai IMT',
          ),
          const SizedBox(height: 8),
          _buildRow(
            color: _C.warning,
            icon: Icons.keyboard_arrow_down_rounded,
            label: 'Di bawah normal',
            value: '< ${targetMin.toStringAsFixed(1)} kg',
            desc: 'Kenaikan di bawah standar, perlu evaluasi nutrisi',
          ),
          const SizedBox(height: 8),
          _buildRow(
            color: _C.danger,
            icon: Icons.keyboard_arrow_up_rounded,
            label: 'Di atas normal',
            value: '> ${targetMax.toStringAsFixed(1)} kg',
            desc: 'Kenaikan berlebihan, risiko komplikasi meningkat',
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
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
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(width: 6),
                  Text(value,
                      style: const TextStyle(fontSize: 11, color: _C.textSub)),
                ],
              ),
              Text(desc,
                  style: const TextStyle(fontSize: 10, color: _C.textSub)),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KARTU KUNJUNGAN BB — dengan detail saat di-tap
// ══════════════════════════════════════════════════════════════════════════════

class _BBVisitCard extends StatelessWidget {
  final GrafikBBPointModel point;
  final int index;
  final double bbAwal;
  final bool isSelected;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final IconData Function(String) statusIcon;
  final VoidCallback onTap;

  const _BBVisitCard({
    required this.point,
    required this.index,
    required this.bbAwal,
    required this.isSelected,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(point.status);
    final sl = statusLabel(point.status);
    final si = statusIcon(point.status);

    final range = point.batasMax - point.batasMin;
    double progressVal;
    if (range <= 0) {
      progressVal = 0.5;
    } else if (point.kenaikanDariAwal < point.batasMin) {
      progressVal = 0.0;
    } else if (point.kenaikanDariAwal > point.batasMax) {
      progressVal = 1.0;
    } else {
      progressVal = (point.kenaikanDariAwal - point.batasMin) / range;
    }
    final isAbnormal = point.status != 'normal';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? sc.withOpacity(0.5) : _C.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected ? sc.withOpacity(0.12) : const Color(0x0A000000),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header utama card
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        Icon(Icons.monitor_weight_rounded, color: sc, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Minggu ${point.mingguKehamilan}',
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
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              point.beratBadan.toStringAsFixed(1),
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
                                'kg',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _C.textSub,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '+${point.kenaikanDariAwal.toStringAsFixed(1)} kg dari awal',
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
                        Container(
                            height: 6,
                            width: double.infinity,
                            color: _C.border),
                        Container(height: 6, color: _C.zoneBB),
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
                      Text(
                        '${point.batasMin.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 9, color: _C.textSub),
                      ),
                      if (isAbnormal)
                        Text(
                          point.status == 'kurang'
                              ? '${(point.batasMin - point.kenaikanDariAwal).toStringAsFixed(1)} kg di bawah batas'
                              : '${(point.kenaikanDariAwal - point.batasMax).toStringAsFixed(1)} kg di atas batas',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: sc),
                        ),
                      Text(
                        '${point.batasMax.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 9, color: _C.textSub),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Detail section — muncul saat di-tap
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _buildDetail(sc, point),
              crossFadeState: isSelected
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),

            // Toggle arrow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
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

  Widget _buildDetail(Color sc, GrafikBBPointModel point) {
    final selisihBbAwal = point.beratBadan - bbAwal;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sc.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sc.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengukuran',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: sc),
          ),
          const SizedBox(height: 8),
          _detailRow(
            label: 'Berat Badan',
            value: '${point.beratBadan.toStringAsFixed(1)} kg',
          ),
          _detailRow(
            label: 'BB Awal Kehamilan',
            value: '${bbAwal.toStringAsFixed(1)} kg',
          ),
          _detailRow(
            label: 'Kenaikan dari Awal',
            value: '${selisihBbAwal >= 0 ? '+' : ''}${selisihBbAwal.toStringAsFixed(1)} kg',
            valueColor: sc,
          ),
          _detailRow(
            label: 'Zona Normal (minggu ini)',
            value:
                '${point.batasMin.toStringAsFixed(1)} – ${point.batasMax.toStringAsFixed(1)} kg kenaikan',
          ),
          _detailRow(
            label: 'Status',
            value: statusLabel(point.status),
            valueColor: sc,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: _C.textSub)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? _C.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: _C.border.withOpacity(0.6)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET HELPERS
// ══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
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
            Text(label, style: const TextStyle(fontSize: 9, color: _C.textSub)),
          ],
        ),
      ),
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
            _C.accent.withOpacity(0.06),
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
  final Widget? extra;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
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
            if (extra != null) ...[
              const SizedBox(height: 20),
              extra!,
            ],
          ],
        ),
      ),
    );
  }
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