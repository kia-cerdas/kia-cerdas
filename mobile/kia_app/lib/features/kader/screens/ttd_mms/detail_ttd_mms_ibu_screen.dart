import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
import 'rekap_ttd_mms_model.dart';
import 'ttd_mms_kader_api_service.dart';

/// Screen detail TTD/MMS per ibu hamil, dilihat oleh kader (read-only).
/// Menampilkan kalender berwarna persis seperti tampilan ibu:
///   - Biru (centang) = sudah diminum
///   - Merah          = terlewat (belum diisi, sudah lewat)
///   - Abu-abu redup  = hari depan (belum tersedia)
class DetailTTDMMSIbuScreen extends StatefulWidget {
  final RekapTTDMMSModel rekap;

  const DetailTTDMMSIbuScreen({super.key, required this.rekap});

  @override
  State<DetailTTDMMSIbuScreen> createState() => _DetailTTDMMSIbuScreenState();
}

class _DetailTTDMMSIbuScreenState extends State<DetailTTDMMSIbuScreen> {
  static const int _totalHariPerBulan = 31;
  static const int _hariPerBulan = 30;

  final _apiService = TtdMmsKaderApiService();

  /// Set key "bulan-hari" untuk hari yang sudah diminum
  final Set<String> _checkedDays = {};

  bool _isLoading = false;
  String? _error;
  int _selectedBulan = 1;

  // HPHT diambil dari rekap jika tersedia, jika tidak dikosongkan
  // (kalender tetap bisa menampilkan status sudah/belum tanpa HPHT)
  DateTime? get _hpht => widget.rekap.hpht;

  String _key(int bulan, int hari) => '$bulan-$hari';

  @override
  void initState() {
    super.initState();
    _selectedBulan = widget.rekap.bulanKe;
    _loadDetail();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final logs = await _apiService.getDetailLog(widget.rekap.kehamilanId);
      _checkedDays.clear();
      for (final item in logs) {
        if (item.sudahDiminum) {
          _checkedDays.add(_key(item.bulanKe, item.hariKe));
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Logika status hari ──────────────────────────────────────

  bool _isDayChecked(int bulan, int hari) =>
      _checkedDays.contains(_key(bulan, hari));

  /// Tanggal kalender dari bulan_ke + hari_ke relatif terhadap HPHT
  DateTime? _tanggalDari(int bulan, int hari) {
    if (_hpht == null) return null;
    final offset = (bulan - 1) * _hariPerBulan + (hari - 1);
    final t = _hpht!.add(Duration(days: offset));
    return DateTime(t.year, t.month, t.day);
  }

  DateTime get _hariIni {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Apakah hari ini sudah lewat kemarin (terlewat, tidak diisi)
  bool _isDayOverdue(int bulan, int hari) {
    if (_isDayChecked(bulan, hari)) return false;
    final tanggal = _tanggalDari(bulan, hari);
    if (tanggal == null) {
      // Tanpa HPHT: anggap terlewat jika bulan sudah lewat atau hari sudah lewat di bulan saat ini
      if (bulan < widget.rekap.bulanKe) return true;
      if (bulan == widget.rekap.bulanKe) return false; // tidak bisa tahu
      return false;
    }
    final kemarin = _hariIni.subtract(const Duration(days: 1));
    return tanggal.isBefore(kemarin);
  }

  bool _isDayFuture(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    if (tanggal == null) return bulan > widget.rekap.bulanKe;
    return tanggal.isAfter(_hariIni);
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rekap = widget.rekap;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(rekap.namaIbu),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetail,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(rekap),
                  const SizedBox(height: 16),
                  _buildTotalStatsCard(rekap),
                  const SizedBox(height: 16),
                  _buildMonthSelector(rekap.bulanKe),
                  const SizedBox(height: 12),
                  if (_error != null) _buildErrorBanner(),
                  _buildCalendarCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeaderCard(RekapTTDMMSModel rekap) {
    final status = rekap.status;
    final String statusLabel;
    switch (status) {
      case StatusKepatuhan.patuh:
        statusLabel = 'Patuh';
        break;
      case StatusKepatuhan.perluPantau:
        statusLabel = 'Perlu Pantau';
        break;
      case StatusKepatuhan.tidakPatuh:
        statusLabel = 'Tidak Patuh';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rekap.namaIbu,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Saat ini bulan ke-${rekap.bulanKe} kehamilan',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Kepatuhan total',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${(rekap.persentase * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rekap.persentase,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Total stats ─────────────────────────────────────────────

  Widget _buildTotalStatsCard(RekapTTDMMSModel rekap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Keseluruhan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _bigStatTile(
                label: 'Total hari\nseharusnya',
                value: '${rekap.totalHari}',
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 10),
              _bigStatTile(
                label: 'Sudah\ndiminum',
                value: '${rekap.totalDiminum}',
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              _bigStatTile(
                label: 'Terlewat /\nbelum diisi',
                value: '${rekap.totalTerlewat}',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStatTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Month selector ──────────────────────────────────────────

  Widget _buildMonthSelector(int maxBulan) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: maxBulan,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bulan = index + 1;
          final selected = bulan == _selectedBulan;
          return GestureDetector(
            onTap: () => setState(() => _selectedBulan = bulan),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFD7DEE9),
                ),
              ),
              child: Text(
                'Bln $bulan',
                style: TextStyle(
                  color:
                      selected ? Colors.white : const Color(0xFF172033),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Calendar card ───────────────────────────────────────────

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5ECF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Checklist Harian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              // Badge read-only
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Read-only',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bulan ke-$_selectedBulan kehamilan',
            style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _totalHariPerBulan,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final hari = index + 1;
              return _buildDayCell(hari);
            },
          ),
          const SizedBox(height: 14),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDayCell(int hari) {
    final checked = _isDayChecked(_selectedBulan, hari);
    final overdue = _isDayOverdue(_selectedBulan, hari);
    final future = _isDayFuture(_selectedBulan, hari);

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double textOpacity;
    Widget? child;

    if (checked) {
      // Sudah diminum → biru/primary dengan centang
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      textOpacity = 1.0;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (overdue) {
      // Terlewat → merah
      backgroundColor = const Color(0xFFFFEBEB);
      borderColor = const Color(0xFFE53935);
      textColor = const Color(0xFFE53935);
      textOpacity = 1.0;
    } else if (future) {
      // Hari depan → abu-abu redup
      backgroundColor = const Color(0xFFFAFAFA);
      borderColor = const Color(0xFFEEEEEE);
      textColor = const Color(0xFFBDBDBD);
      textOpacity = 0.5;
    } else {
      // Hari ini / kemarin belum diisi (kader tidak bisa isi, tampil netral)
      backgroundColor = const Color(0xFFF6F8FC);
      borderColor = const Color(0xFFD7DEE9);
      textColor = const Color(0xFF172033);
      textOpacity = 1.0;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: child ??
            Opacity(
              opacity: textOpacity,
              child: Text(
                '$hari',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: AppColors.primary, label: 'Sudah minum'),
        const SizedBox(width: 14),
        _legendItem(
          color: const Color(0xFFFFEBEB),
          borderColor: const Color(0xFFE53935),
          label: 'Terlewat',
        ),
        const SizedBox(width: 14),
        _legendItem(
          color: const Color(0xFFFAFAFA),
          borderColor: const Color(0xFFEEEEEE),
          label: 'Belum',
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    Color? borderColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor ?? color),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF7B8798)),
        ),
      ],
    );
  }

  // ── Error banner ────────────────────────────────────────────

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFE53935), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat detail log: $_error',
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
            ),
          ),
          GestureDetector(
            onTap: _loadDetail,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card ───────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE1A6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFE0A300), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data ini diisi sendiri oleh ibu melalui aplikasinya. '
              'Kader hanya dapat memantau, tidak dapat mengubah data.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B5A2A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}