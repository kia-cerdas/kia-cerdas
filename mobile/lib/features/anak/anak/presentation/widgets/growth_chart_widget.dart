import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';

class GrowthChartWidget extends StatefulWidget {
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

  @override
  State<GrowthChartWidget> createState() => _GrowthChartWidgetState();
}

class _GrowthChartWidgetState extends State<GrowthChartWidget> {
  bool _showMedian = true;
  bool _showDataAnak = true;
  bool _showSd2 = true;
  bool _showSd3 = true;

  double _roundDownToStep(double value, double step) {
    return (value / step).floor() * step;
  }

  double _roundUpToStep(double value, double step) {
    return (value / step).ceil() * step;
  }

  Color _statusColorByZScore(double zScore) {
    if (zScore >= -2 && zScore <= 2) {
      return const Color(0xFF0F6E56); // Normal (Hijau)
    }
    if ((zScore >= -3 && zScore < -2) || (zScore > 2 && zScore <= 3)) {
      return const Color(0xFFBA7517); // Risiko (Kuning/Oranye)
    }
    return const Color(0xFFA32D2D); // Buruk/Sangat (Merah)
  }

  bool get _isLengthChart => widget.selectedTab == 'TB/U' || widget.selectedTab == 'BB/TB';
  double get _xGridInterval => _isLengthChart ? 12.0 : 6.0;
  double get _yGridInterval => widget.selectedTab == 'TB/U' ? 10.0 : (widget.selectedTab == 'BB/TB' ? 0.5 : 1.0);
  double get _xTitleInterval => _isLengthChart ? 12.0 : 6.0;
  double get _yTitleInterval => widget.selectedTab == 'TB/U' ? 10.0 : (widget.selectedTab == 'BB/TB' ? 1.0 : 2.0);
  double get _chartAspectRatio => widget.selectedTab == 'TB/U' ? 0.82 : 1.15;
  double get _topChartPadding => widget.selectedTab == 'TB/U' ? 32.0 : 24.0;
  double get _leftTitleReservedSize => widget.selectedTab == 'TB/U' ? 24.0 : 36.0;
  double get _bottomTitleFontSize => widget.selectedTab == 'TB/U' ? 9.0 : 10.0;

  List<PertumbuhanModel> get _sortedRiwayat {
    final list = List<PertumbuhanModel>.from(widget.riwayatPertumbuhan);
    list.sort((a, b) => a.tglUkur.compareTo(b.tglUkur));
    return list;
  }

  List<FlSpot> _getLine(double Function(MasterStandarModel) selector, double limitX) {
    return widget.masterStandar
        .where((m) => m.nilaiSumbuX <= limitX)
        .map((m) {
      return FlSpot(m.nilaiSumbuX.toDouble(), selector(m));
    }).toList();
  }

  List<FlSpot> _getChildDataLine(List<PertumbuhanModel> sortedRiwayat) {
    return sortedRiwayat.map((r) {
      double x = (widget.selectedTab == 'BB/TB' || widget.selectedTab == 'BB/PB') ? r.tinggiBadan : r.usiaUkurBulan.toDouble();
      double y;
      switch (widget.selectedTab) {
        case 'BB/U':
        case 'BB/PB':
        case 'BB/TB':
          y = r.beratBadan;
          break;
        case 'PB/U':
        case 'TB/U':
          y = r.tinggiBadan;
          break;
        case 'LK/U':
          y = r.lingkarKepala;
          break;
        case 'IMT/U':
          y = r.imt;
          break;
        default:
          y = r.beratBadan;
      }
      return FlSpot(x, y);
    }).toList();
  }

  Map<String, double> _getAxisRanges(List<FlSpot> childData, double limitX) {
    final yStep = _yGridInterval;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    void processSpot(FlSpot spot) {
      if (spot.x < minX) minX = spot.x;
      if (spot.x > maxX) maxX = spot.x;
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    if (_showSd3 && widget.masterStandar.isNotEmpty) {
      _getLine((m) => m.sd3Neg, limitX).forEach(processSpot);
      _getLine((m) => m.sd3Pos, limitX).forEach(processSpot);
    }
    if (_showSd2 && widget.masterStandar.isNotEmpty) {
      _getLine((m) => m.sd2Neg, limitX).forEach(processSpot);
      _getLine((m) => m.sd2Pos, limitX).forEach(processSpot);
    }
    if (_showMedian && widget.masterStandar.isNotEmpty) {
      _getLine((m) => m.median, limitX).forEach(processSpot);
    }
    if (_showDataAnak && childData.isNotEmpty) {
      childData.forEach(processSpot);
    }

    if (minX == double.infinity) {
      minX = widget.selectedTab == 'BB/TB' ? 45.0 : 0.0;
      maxX = widget.selectedTab == 'BB/TB' ? 120.0 : 60.0;
      minY = 0.0;
      maxY = 10.0;
    }

    double xPadding = 0.0; // Padding is already added in _getLine truncation
    double yPadding = (maxY - minY) * 0.15; // 15% padding
    if (yPadding == 0) yPadding = yStep;

    return {
      'minX': minX,
      'maxX': maxX,
      'minY': _roundDownToStep((minY - yPadding).clamp(0.0, double.infinity), yStep),
      'maxY': _roundUpToStep(maxY + yPadding, yStep),
    };
  }

  @override
  Widget build(BuildContext context) {
    final sortedRiwayat = _sortedRiwayat;
    final childData = _getChildDataLine(sortedRiwayat);

    double limitX = widget.selectedTab == 'BB/TB' ? 120.0 : 60.0;
    if (childData.isNotEmpty) {
      double paddingX = widget.selectedTab == 'BB/TB' ? 3.0 : 4.0;
      limitX = childData.last.x + paddingX;
    }

    final ranges = _getAxisRanges(childData, limitX);

    final barData = <LineChartBarData>[];
    int? childIdx;

    if (_showSd3) {
      barData.add(LineChartBarData(
          spots: _getLine((m) => m.sd3Neg, limitX),
          color: Colors.black54,
          barWidth: 1.5,
          isCurved: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false)));
      barData.add(LineChartBarData(
          spots: _getLine((m) => m.sd3Pos, limitX),
          color: Colors.black54,
          barWidth: 1.5,
          isCurved: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false)));
    }

    if (_showSd2) {
      barData.add(LineChartBarData(
          spots: _getLine((m) => m.sd2Neg, limitX),
          color: Colors.red.withOpacity(0.6),
          barWidth: 1.5,
          isCurved: true,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false)));
      barData.add(LineChartBarData(
          spots: _getLine((m) => m.sd2Pos, limitX),
          color: Colors.red.withOpacity(0.6),
          barWidth: 1.5,
          isCurved: true,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false)));
    }

    if (_showMedian) {
      barData.add(LineChartBarData(
          spots: _getLine((m) => m.median, limitX),
          color: const Color(0xFF0F6E56),
          barWidth: 2,
          isCurved: true,
          dotData: const FlDotData(show: false)));
    }

    if (_showDataAnak && childData.isNotEmpty) {
      childIdx = barData.length;
      barData.add(LineChartBarData(
        spots: childData,
        color: const Color(0xFF185FA5),
        barWidth: 3,
        isCurved: true,
        belowBarData: BarAreaData(show: false),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            double zScore = 0;
            if (widget.selectedTab == 'BB/U') zScore = sortedRiwayat[index].zScoreBBU;
            else if (widget.selectedTab == 'TB/U' || widget.selectedTab == 'PB/U') zScore = sortedRiwayat[index].zScoreTBU;
            else if (widget.selectedTab == 'BB/TB' || widget.selectedTab == 'BB/PB') zScore = sortedRiwayat[index].zScoreBBTB;
            else if (widget.selectedTab == 'LK/U') zScore = sortedRiwayat[index].zScoreLKU;
            else if (widget.selectedTab == 'IMT/U') zScore = sortedRiwayat[index].zScoreIMTU;
            else zScore = sortedRiwayat[index].zScoreBBU;

            return FlDotCirclePainter(
              radius: 4.5,
              color: _statusColorByZScore(zScore),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
      ));
    }

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
                  color: const Color(0xFF185FA5).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFF185FA5)),
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
                      'KMS / WHO • ${widget.selectedTab}',
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
            child: widget.masterStandar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_chart_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          "Data standar ${widget.selectedTab} belum tersedia",
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
                            reservedSize: widget.selectedTab == 'TB/U' ? 24 : 30,
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
                              if (widget.selectedTab == 'TB/U') {
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
                        enabled: true,
                        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            if (barData.color == const Color(0xFF185FA5)) {
                              return TouchedSpotIndicatorData(
                                const FlLine(color: Colors.transparent),
                                FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                                  double zScore = 0;
                                  if (widget.selectedTab == 'BB/U') zScore = sortedRiwayat[index].zScoreBBU;
                                  else if (widget.selectedTab == 'TB/U' || widget.selectedTab == 'PB/U') zScore = sortedRiwayat[index].zScoreTBU;
                                  else if (widget.selectedTab == 'BB/TB' || widget.selectedTab == 'BB/PB') zScore = sortedRiwayat[index].zScoreBBTB;
                                  else if (widget.selectedTab == 'LK/U') zScore = sortedRiwayat[index].zScoreLKU;
                                  else if (widget.selectedTab == 'IMT/U') zScore = sortedRiwayat[index].zScoreIMTU;
                                  else zScore = sortedRiwayat[index].zScoreBBU;

                                  return FlDotCirclePainter(radius: 6, color: _statusColorByZScore(zScore), strokeWidth: 2, strokeColor: Colors.white);
                                }),
                              );
                            }
                            return TouchedSpotIndicatorData(
                              const FlLine(color: Colors.transparent),
                              const FlDotData(show: false),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => const Color(0xFF1E293B).withOpacity(0.9),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              if (childIdx == null || touchedSpot.barIndex != childIdx) {
                                return null;
                              }
                              
                              final riwayat = sortedRiwayat[touchedSpot.spotIndex];
                              double zScore = 0;
                              String status = '';
                              if (widget.selectedTab == 'BB/U') { zScore = riwayat.zScoreBBU; status = riwayat.statusBBU; }
                              else if (widget.selectedTab == 'TB/U' || widget.selectedTab == 'PB/U') { zScore = riwayat.zScoreTBU; status = riwayat.statusTBU; }
                              else if (widget.selectedTab == 'BB/TB' || widget.selectedTab == 'BB/PB') { zScore = riwayat.zScoreBBTB; status = riwayat.statusBBTB; }
                              else if (widget.selectedTab == 'LK/U') { zScore = riwayat.zScoreLKU; status = riwayat.statusLKU; }
                              else if (widget.selectedTab == 'IMT/U') { zScore = riwayat.zScoreIMTU; status = riwayat.statusIMTU; }
                              else { zScore = riwayat.zScoreBBU; status = riwayat.statusBBU; }

                              final textStyle = const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );
                              return LineTooltipItem(
                                '${_formatTooltipX(touchedSpot.x)}\n',
                                textStyle,
                                children: [
                                  TextSpan(
                                    text: 'Nilai: ${touchedSpot.y.toStringAsFixed(1)}\n',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Z-Score: ${zScore.toStringAsFixed(2)}\n',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Status: $status',
                                    style: TextStyle(
                                      color: _statusColorByZScore(zScore),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                      showingTooltipIndicators: const [],
                      lineBarsData: barData,
                      betweenBarsData: const [],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Wrap(
            runSpacing: 8,
            children: [
              _buildLegendItem('Median', const Color(0xFF0F6E56), _showMedian, () => setState(() => _showMedian = !_showMedian)),
              _buildLegendItem('Data Anak', const Color(0xFF185FA5), _showDataAnak, () => setState(() => _showDataAnak = !_showDataAnak)),
              _buildLegendItem('±2 SD', const Color(0xFFA32D2D), _showSd2, () => setState(() => _showSd2 = !_showSd2)),
              _buildLegendItem('±3 SD', Colors.black54, _showSd3, () => setState(() => _showSd3 = !_showSd3)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'X: ${widget.xAxisLabel} • Y: ${widget.yAxisLabel}',
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
    if (widget.selectedTab == 'BB/TB') {
      final rounded = value.round();
      if (rounded % 10 != 0 &&
          rounded != value.floor() &&
          rounded != value.ceil()) {
        return '';
      }
      return rounded.toString();
    }

    if (widget.selectedTab == 'TB/U') {
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

  String _formatTooltipX(double value) {
    if (widget.selectedTab == 'BB/TB') {
      return 'Tinggi: ${value.toStringAsFixed(1)} cm';
    }
    
    int totalMonths = value.round();
    if (totalMonths < 12) {
      return 'Usia: $totalMonths Bulan';
    }
    
    int years = totalMonths ~/ 12;
    int months = totalMonths % 12;
    
    if (months == 0) {
      return 'Usia: $years Tahun';
    }
    
    return 'Usia: $years Tahun $months Bulan';
  }

  Widget _buildLegendItem(String label, Color color, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.grey.shade300 : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12, 
                  color: isActive ? Colors.black87 : Colors.grey.shade500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}
