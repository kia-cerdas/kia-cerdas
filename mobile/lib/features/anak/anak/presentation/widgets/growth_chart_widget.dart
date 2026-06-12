import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';

class GrowthChartWidget extends StatelessWidget {
  final List<PertumbuhanModel> riwayatPertumbuhan;
  final List<MasterStandarModel> masterStandar;
  final String yAxisLabel;
  final String selectedTab;
  final String xAxisLabel;

  const GrowthChartWidget({
    Key? key,
    required this.riwayatPertumbuhan,
    required this.masterStandar,
    required this.yAxisLabel,
    required this.selectedTab,
    required this.xAxisLabel,
  }) : super(key: key);

  double _roundDownToStep(double value, double step) {
    return (value / step).floor() * step;
  }

  double _roundUpToStep(double value, double step) {
    return (value / step).ceil() * step;
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('baik') || lower.contains('normal')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('kurang') ||
        lower.contains('risiko') ||
        lower.contains('pendek')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('buruk') ||
        lower.contains('sangat') ||
        lower.contains('stunting') ||
        lower.contains('obesitas')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF2563EB);
  }

  bool get _isLengthChart => selectedTab == 'TB/U' || selectedTab == 'BB/TB';

  double get _xGridInterval => _isLengthChart ? 12.0 : 6.0;

  double get _yGridInterval => selectedTab == 'TB/U' ? 10.0 : (selectedTab == 'BB/TB' ? 0.5 : 1.0);

  double get _xTitleInterval => _isLengthChart ? 12.0 : 6.0;

  double get _yTitleInterval => selectedTab == 'TB/U' ? 10.0 : (selectedTab == 'BB/TB' ? 1.0 : 2.0);

  double get _chartAspectRatio => selectedTab == 'TB/U' ? 0.82 : 1.15;

  double get _leftTitleReservedSize => selectedTab == 'TB/U' ? 54.0 : 40.0;

  double get _bottomTitleFontSize => selectedTab == 'TB/U' ? 8.5 : 10.0;

  double get _topChartPadding => selectedTab == 'TB/U' ? 8.0 : 14.0;

  /// Helper: Mengurutkan riwayat agar sinkron dengan index di grafik
  List<PertumbuhanModel> get _sortedRiwayat {
    final sorted = List<PertumbuhanModel>.from(riwayatPertumbuhan);
    sorted.sort((a, b) {
      double aX =
          selectedTab == 'BB/TB' ? a.tinggiBadan : a.usiaUkurBulan.toDouble();
      double bX =
          selectedTab == 'BB/TB' ? b.tinggiBadan : b.usiaUkurBulan.toDouble();
      return aX.compareTo(bX);
    });
    return sorted;
  }

  /// Ekstrak data anak ke bentuk titik (FlSpot)
  List<FlSpot> _getChildDataLine() {
    final sorted = _sortedRiwayat;
    if (sorted.isEmpty) return [];

    return sorted.map((r) {
      double xValue =
          selectedTab == 'BB/TB' ? r.tinggiBadan : r.usiaUkurBulan.toDouble();
      double yValue;

      switch (selectedTab) {
        case 'TB/U':
          yValue = r.tinggiBadan;
          break;
        case 'IMT/U':
          yValue = r.imt;
          break;
        case 'LK/U':
          yValue = r.lingkarKepala;
          break;
        case 'BB/U':
        case 'BB/TB':
        default:
          yValue = r.beratBadan;
          break;
      }
      return FlSpot(xValue, yValue);
    }).toList();
  }

  /// Helper untuk mengambil nilai Z-Score
  double _getZScoreForTab(PertumbuhanModel data) {
    switch (selectedTab) {
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

  /// Helper untuk garis standar WHO
  List<FlSpot> _getLine(double Function(MasterStandarModel) selector) {
    if (masterStandar.isEmpty) return [];
    return masterStandar
        .map((m) => FlSpot(m.nilaiSumbuX, selector(m)))
        .toList();
  }

  /// Menentukan batas maksimal/minimal grafik agar pas di layar
  Map<String, dynamic> _getAxisRanges() {
    final childData = _getChildDataLine();
    final allSpots = [
      ..._getLine((m) => m.sd3Neg),
      ..._getLine((m) => m.sd3Pos),
      ...childData,
    ];

    if (allSpots.isEmpty) {
      return {'minX': 0.0, 'maxX': 60.0, 'minY': 0.0, 'maxY': 20.0};
    }

    final xStep = selectedTab == 'BB/TB' ? 5.0 : 6.0;
    final yStep = selectedTab == 'TB/U'
      ? 5.0
      : (selectedTab == 'BB/TB' ? 0.5 : 1.0);

    final rawMinX =
        selectedTab == 'BB/TB' ? 45.0 : masterStandar.first.nilaiSumbuX;
    final rawMaxX =
        selectedTab == 'BB/TB' ? 120.0 : masterStandar.last.nilaiSumbuX;

    double minY = allSpots.first.y;
    double maxY = allSpots.first.y;

    for (final spot in allSpots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    return {
      'minX': _roundDownToStep(rawMinX, xStep),
      'maxX': _roundUpToStep(rawMaxX, xStep),
      'minY':
          _roundDownToStep((minY - yStep).clamp(0.0, double.infinity), yStep),
      'maxY': _roundUpToStep(maxY + yStep, yStep),
    };
  }

  @override
  Widget build(BuildContext context) {
    final childData = _getChildDataLine();
    final sortedRiwayat = _sortedRiwayat;
    final ranges = _getAxisRanges();

    // Setup Bar/Garis
    final barData = [
      LineChartBarData(
          spots: _getLine((m) => m.sd3Neg),
          color: Colors.black54,
          barWidth: 1.5,
          isCurved: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false)),
      LineChartBarData(
          spots: _getLine((m) => m.sd3Pos),
          color: Colors.black54,
          barWidth: 1.5,
          isCurved: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false)),
      LineChartBarData(
          spots: _getLine((m) => m.sd2Neg),
          color: Colors.red.withOpacity(0.6),
          barWidth: 1.5,
          isCurved: true,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false)),
      LineChartBarData(
          spots: _getLine((m) => m.sd2Pos),
          color: Colors.red.withOpacity(0.6),
          barWidth: 1.5,
          isCurved: true,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false)),
      LineChartBarData(
          spots: _getLine((m) => m.median),
          color: const Color(0xFF22C55E),
          barWidth: 2,
          isCurved: true,
          dotData: const FlDotData(show: false)),

      // Index 5: Data Anak (Garis Biru)
      if (childData.isNotEmpty)
        LineChartBarData(
          spots: childData,
          color: const Color(0xFF2563EB),
          barWidth: 3,
          isCurved: true,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF2563EB).withOpacity(0.08),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4.5,
              color: _statusColor(sortedRiwayat[index].statusBBU),
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
    ];

    // Ambil index keberapa garis anak berada
    final int childBarIndex = barData.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Pertumbuhan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'KMS / WHO • $selectedTab',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _topChartPadding),
          AspectRatio(
            aspectRatio: _chartAspectRatio,
            child: masterStandar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_chart_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          "Data standar $selectedTab belum tersedia",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: _yGridInterval,
                        verticalInterval: _xGridInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.16),
                          strokeWidth: 0.7,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.12),
                          strokeWidth: 0.7,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: selectedTab == 'TB/U' ? 24 : 30,
                            interval: _xTitleInterval,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                _formatBottomTitle(value),
                                style: TextStyle(
                                  fontSize: _bottomTitleFontSize,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _leftTitleReservedSize,
                            interval: _yTitleInterval,
                            getTitlesWidget: (value, meta) {
                              if (selectedTab == 'TB/U') {
                                final rounded = value.round();
                                if (rounded % 10 != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  rounded.toString(),
                                  style: TextStyle(
                                    fontSize: 9.0,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }

                              return Text(
                                value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      minX: ranges['minX'],
                      maxX: ranges['maxX'],
                      minY: ranges['minY'],
                      maxY: ranges['maxY'],
                      lineTouchData: LineTouchData(
                        enabled: false,
                      ),
                      showingTooltipIndicators: const [],
                      lineBarsData: barData,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Wrap(
            runSpacing: 8,
            children: [
              _buildLegendItem('Median', const Color(0xFF22C55E), false),
              _buildLegendItem('Data Anak', const Color(0xFF2563EB), false),
              _buildLegendItem('±2 SD', const Color(0xFFEF4444), true),
              _buildLegendItem('±3 SD', Colors.black54, true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'X: $xAxisLabel • Y: $yAxisLabel',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBottomTitle(double value) {
    if (selectedTab == 'BB/TB') {
      final rounded = value.round();
      if (rounded % 10 != 0 &&
          rounded != value.floor() &&
          rounded != value.ceil()) {
        return '';
      }
      return rounded.toString();
    }

    if (selectedTab == 'TB/U') {
      final rounded = value.round();
      if (rounded % 12 != 0) {
        return '';
      }
      return rounded.toString();
    }

    final rounded = value.round();
    if (rounded % 6 != 0) {
      return '';
    }
    return rounded.toString();
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}
