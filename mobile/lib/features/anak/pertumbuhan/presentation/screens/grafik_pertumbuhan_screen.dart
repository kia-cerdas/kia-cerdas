import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/repositories/pertumbuhan_repository.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/services/pertumbuhan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/widgets/growth_chart_widget.dart';
import 'package:ta_pa2_pa3_project/core/widgets/child_profile_card.dart';

class GrafikPertumbuhanScreen extends StatefulWidget {
  final AnakSearchModel anak;
  const GrafikPertumbuhanScreen({super.key, required this.anak});

  @override
  State<GrafikPertumbuhanScreen> createState() =>
      _GrafikPertumbuhanScreenState();
}

class _GrafikPertumbuhanScreenState
    extends State<GrafikPertumbuhanScreen> {
    late PertumbuhanRepository _repo;

  List<PertumbuhanModel> _riwayat = [];
  Map<String, List<MasterStandarModel>> _master = {};

  bool _isLoading = true;
  String? _error;
  String _tab = 'BB/U';
  bool _showAll = false;
  bool _isPreloading = false;

  static const _tabs = ['BB/U', 'BB/PB', 'PB/U', 'LK/U', 'IMT/U'];


  static const _klasifikasi = {
    'BB/U': [
      ['< -3 SD', 'BB sangat kurang'],
      ['-3 s/d -2 SD', 'BB kurang'],
      ['-2 s/d +1 SD', 'BB normal'],
      ['> +1 SD', 'Risiko BB lebih'],
    ],
    'PB/U': [
      ['< -3 SD', 'Sangat pendek (severely stunted)'],
      ['-3 s/d -2 SD', 'Pendek (stunted)'],
      ['-2 s/d +3 SD', 'Normal'],
      ['> +3 SD', 'Tinggi'],
    ],
    'BB/PB': [
      ['< -3 SD', 'Gizi buruk (severely wasted)'],
      ['-3 s/d -2 SD', 'Gizi kurang (wasted)'],
      ['-2 s/d +1 SD', 'Gizi baik (normal)'],
      ['+1 s/d +2 SD', 'Berisiko gizi lebih'],
      ['> +2 SD', 'Gizi lebih / obesitas'],
    ],
    'LK/U': [
      ['< -2 SD', 'Mikrosefali'],
      ['-2 s/d +2 SD', 'Normal'],
      ['> +2 SD', 'Makrosefali'],
    ],
    'IMT/U': [
      ['< -3 SD', 'Gizi buruk'],
      ['-3 s/d -2 SD', 'Gizi kurang'],
      ['-2 s/d +1 SD', 'Gizi baik'],
      ['+1 s/d +2 SD', 'Berisiko gizi lebih'],
      ['> +2 SD', 'Gizi lebih / obesitas'],
    ],
  };

  @override
  void initState() {
    super.initState();
    _repo = PertumbuhanRepository(apiService: PertumbuhanApiService());
    _loadTabData(_tab);
  }

  String _getParameterName(String tab) {
    switch (tab) {
      case 'PB/U': return 'tb_u';
      case 'BB/PB': return 'bb_tb';
      case 'LK/U': return 'lk_u';
      case 'IMT/U': return 'imt_u';
      default: return 'bb_u';
    }
  }

  Future<void> _loadTabData(String targetTab) async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final jk = widget.anak.jenisKelamin;
      
      Future<List<PertumbuhanModel>>? riwayatFuture;
      Future<List<MasterStandarModel>>? masterFuture;

      if (_riwayat.isEmpty) {
        riwayatFuture = _repo.getRiwayatPertumbuhanByAnakId(widget.anak.id);
      }

      if (_master[targetTab] == null || _master[targetTab]!.isEmpty) {
        final parameterName = _getParameterName(targetTab);
        masterFuture = _repo.getMasterStandar(parameter: parameterName, jenisKelamin: jk);
      }

      if (riwayatFuture != null && masterFuture != null) {
        final results = await Future.wait([riwayatFuture, masterFuture]);
        final riwayat = results[0] as List<PertumbuhanModel>;
        riwayat.sort((a, b) => a.tglUkur.compareTo(b.tglUkur));
        _riwayat = riwayat;
        _master[targetTab] = results[1] as List<MasterStandarModel>;
      } else {
        if (riwayatFuture != null) {
          final riwayat = await riwayatFuture;
          riwayat.sort((a, b) => a.tglUkur.compareTo(b.tglUkur));
          _riwayat = riwayat;
        }
        if (masterFuture != null) {
          _master[targetTab] = await masterFuture;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _preloadOtherTabs();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _preloadOtherTabs() async {
    if (_isPreloading) return;
    _isPreloading = true;

    final jk = widget.anak.jenisKelamin;
    for (final t in _tabs) {
      if (_master[t] == null || _master[t]!.isEmpty) {
        try {
          final param = _getParameterName(t);
          final std = await _repo.getMasterStandar(parameter: param, jenisKelamin: jk);
          if (mounted) {
            setState(() {
              _master[t] = std;
            });
          }
        } catch (_) {
          // Abaikan error di background
        }
      }
    }
    _isPreloading = false;
  }

  String _hitungUmur() {
    try {
      final birth = DateTime.parse(widget.anak.tanggalLahir);
      final now = DateTime.now();
      
      final days = now.difference(birth).inDays;
      if (days <= 28) {
        return '$days Hari';
      }

      int totalMonths = (now.year - birth.year) * 12 + (now.month - birth.month);
      if (now.day < birth.day) {
        totalMonths--;
      }
      if (totalMonths < 0) totalMonths = 0;

      if (totalMonths < 12) {
        return '$totalMonths Bulan';
      }

      final thn = totalMonths ~/ 12;
      final bln = totalMonths % 12;
      if (bln == 0) return '$thn Tahun';
      return '$thn Tahun $bln Bulan';
    } catch (_) { return '-'; }
  }

  String _fmt(double v, {bool imt = false}) {
    if (imt && v > 0 && v < 5) v *= 100;
    return v.toStringAsFixed(1);
  }

  double _getZ(PertumbuhanModel d) {
    switch (_tab) {
      case 'PB/U': return d.zScoreTBU;
      case 'BB/PB': return d.zScoreBBTB;
      case 'IMT/U': return d.zScoreIMTU;
      case 'LK/U': return d.zScoreLKU;
      default: return d.zScoreBBU;
    }
  }

  String _getStatus(PertumbuhanModel d) {
    switch (_tab) {
      case 'PB/U': return d.statusTBU;
      case 'BB/PB': return d.statusBBTB;
      case 'IMT/U': return d.statusIMTU;
      case 'LK/U': return d.statusLKU;
      default: return d.statusBBU;
    }
  }

  String _getYLabel() {
    switch (_tab) {
      case 'PB/U': return 'Panjang/Tinggi Badan (cm)';
      case 'IMT/U': return 'IMT (kg/m²)';
      case 'LK/U': return 'Lingkar Kepala (cm)';
      default: return 'Berat Badan (kg)';
    }
  }

  String _getXLabel() => _tab == 'BB/PB' ? 'Panjang/Tinggi (cm)' : 'Usia (bulan)';

  String _getGrafikTab() {
    switch (_tab) {
      case 'PB/U': return 'TB/U';
      case 'BB/PB': return 'BB/TB';
      case 'LK/U': return 'LK/U';
      case 'IMT/U': return 'IMT/U';
      default: return 'BB/U';
    }
  }

  Color _statusColor(String s) {
    final l = s.toLowerCase();
    if (l.contains('baik') || l.contains('normal')) return const Color(0xFF0F6E56);
    if (l.contains('buruk') || l.contains('sangat') || l.contains('obesi') || l.contains('mikro') || l.contains('makro')) return const Color(0xFFA32D2D);
    return const Color(0xFFBA7517);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Pertumbuhan',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Pemantauan pertumbuhan anak',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF185FA5)))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => _loadTabData(_tab), child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );

  Widget _buildContent() {
    final latest = _riwayat.isNotEmpty ? _riwayat.last : null;
    final master = _master[_tab] ?? [];
    final shown = _showAll ? _riwayat.reversed.toList() : _riwayat.reversed.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tab bar ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((t) {
                final active = _tab == t;
                return GestureDetector(
                  onTap: () {
                    if (_tab != t) {
                      setState(() => _tab = t);
                      if (_master[t] == null || _master[t]!.isEmpty) {
                        _loadTabData(t);
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF185FA5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active ? const Color(0xFF185FA5) : Colors.grey.shade300),
                    ),
                    child: Text(t,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.grey.shade600)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Child card ──
          ChildProfileCard(
            nama: widget.anak.namaAnak,
            usia: _hitungUmur(),
          ),
          const SizedBox(height: 14),

          // ── Chart ──
          if (master.isNotEmpty && _riwayat.isNotEmpty)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: GrowthChartWidget(
                key: ValueKey(_tab),
                riwayatPertumbuhan: _riwayat,
                masterStandar: master,
                yAxisLabel: _getYLabel(),
                selectedTab: _getGrafikTab(),
                xAxisLabel: _getXLabel(),
              ),
            )
          else
            _buildEmptyChart(),
          const SizedBox(height: 14),

          // ── Status card ──
          if (latest != null) _buildStatusCard(latest),
          const SizedBox(height: 18),

          // ── Klasifikasi ──
          _buildKlasifikasi(),
          const SizedBox(height: 18),

          // ── Riwayat pengukuran ──
          const Text('Riwayat Pengukuran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_riwayat.isEmpty)
            _buildEmpty('Belum ada data pengukuran')
          else ...[
            ...shown.map((d) => _buildRiwayatItem(d)),
            if (_riwayat.length > 4)
              TextButton(
                onPressed: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? 'Sembunyikan' : 'Lihat Semua Data',
                  style: const TextStyle(color: Color(0xFF185FA5), fontWeight: FontWeight.w600),
                ),
              ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() => Container(
    height: 180,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('Belum ada data grafik $_tab',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    ),
  );

  Widget _buildEmpty(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text(msg, style: TextStyle(color: Colors.grey.shade500))),
  );

  Widget _buildStatusCard(PertumbuhanModel d) {
    final status = _getStatus(d);
    final z = _getZ(d);
    final color = _statusColor(status);
    final zLabel = _tab == 'BB/U'
        ? 'Z-score: ${z.toStringAsFixed(2)} (-2 SD s/d +1 SD)'
        : 'Z-score: ${z.toStringAsFixed(2)}';
    final whoLabel = 'Status WHO: $status';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status,
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(zLabel,
                    style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
                Text(whoLabel,
                    style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(PertumbuhanModel d) {
    final status = _getStatus(d);
    final color = _statusColor(status);
    String valueText;
    switch (_tab) {
      case 'PB/U':
        valueText = '${_fmt(d.tinggiBadan)} cm';
        break;
      case 'LK/U':
        valueText = '${_fmt(d.lingkarKepala)} cm';
        break;
      case 'IMT/U':
        valueText = '${_fmt(d.imt, imt: true)} kg/m²';
        break;
      default:
        valueText = '${_fmt(d.beratBadan)} kg';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.tglUkur,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${d.usiaUkurBulan} bln',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(valueText,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildKlasifikasi() {
    final rows = _klasifikasi[_tab] ?? [];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF185FA5)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Klasifikasi $_tab (Permenkes No. 2/2020)',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(r[0],
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF185FA5))),
                ),
                Expanded(
                  child: Text(r[1],
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
