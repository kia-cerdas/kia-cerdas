import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/log_ttd_mms_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// Untuk validasi
import 'package:ta_pa2_pa3_project/core/widgets/confirm_helper.dart';

class LogTTDMMSScreen extends StatefulWidget {
  final DateTime hpht;

  const LogTTDMMSScreen({super.key, required this.hpht});

  @override
  State<LogTTDMMSScreen> createState() => _LogTTDMMSScreenState();
}

class _LogTTDMMSScreenState extends State<LogTTDMMSScreen>
    with WidgetsBindingObserver {
  static const int _totalBulan = 10;
  static const int _totalHari = 31;
  static const int _hariPerBulan = 30;

  final _apiService = LogTTDMMSApiService();

  final Set<String> _checkedDays = {};
  final Set<String> _pendingDays = {}; // centang yang belum terkirim ke server

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isFromCache = false;
  DateTime? _cacheTimestamp;
  int _pendingCount = 0;
  int _selectedBulan = 1;

  String _key(int bulan, int hari) => '$bulan-$hari';

  // ────────────────────────────────────────────────────────────────────────
  // Tanggal helpers
  // ────────────────────────────────────────────────────────────────────────
  DateTime _tanggalDari(int bulan, int hari) {
    final offset = (bulan - 1) * _hariPerBulan + (hari - 1);
    final t = widget.hpht.add(Duration(days: offset));
    return DateTime(t.year, t.month, t.day);
  }

  DateTime get _hariIni {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _kemarin => _hariIni.subtract(const Duration(days: 1));

  bool _isDayFillable(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return !tanggal.isBefore(_kemarin) && !tanggal.isAfter(_hariIni);
  }

  bool _isDayOverdue(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return tanggal.isBefore(_kemarin) && !_isDayChecked(bulan, hari);
  }

  bool _isDayFuture(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return tanggal.isAfter(_hariIni);
  }

  int _getMaxAllowedDay(int bulan) {
    final now = DateTime.now();
    final bulanStart =
        widget.hpht.add(Duration(days: (bulan - 1) * _hariPerBulan));
    final bulanEnd = bulanStart.add(const Duration(days: _hariPerBulan));

    if (!now.isBefore(bulanEnd)) return _totalHari;
    if (now.isBefore(bulanStart)) return 0;

    final hariKe = now.difference(bulanStart).inDays + 1;
    return hariKe.clamp(0, _totalHari);
  }

  bool _isDayChecked(int bulan, int hari) =>
      _checkedDays.contains(_key(bulan, hari));

  bool _isDayPending(int bulan, int hari) =>
      _pendingDays.contains(_key(bulan, hari));

  int get _currentBulanKehamilan {
    final selisihHari = DateTime.now().difference(widget.hpht).inDays;
    final bulan = (selisihHari ~/ _hariPerBulan) + 1;
    return bulan.clamp(1, _totalBulan);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedBulan = _currentBulanKehamilan;
    _loadLog();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _apiService.dispose();
    super.dispose();
  }

  /// Ketika app kembali ke foreground → coba flush pending queue
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingCount > 0) {
      _tryFlushPending();
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Data loading
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _loadLog() async {
    setState(() => _isLoading = true);
    try {
      // Flush pending dulu sebelum fetch (kalau ada & online)
      if (_pendingCount > 0) await _apiService.flushPendingQueue();

      final logs = await _apiService.getMine();
      _checkedDays.clear();
      for (final item in logs) {
        if (item.sudahDiminum) {
          _checkedDays.add(_key(item.bulanKe, item.hariKe));
        }
      }

      // Update status cache
      _isFromCache = false;
      _cacheTimestamp = null;
    } catch (_) {
      // Sudah di-handle di service (fallback ke cache)
      // Tapi kita perlu tahu apakah ini dari cache
      _isFromCache = await LogTTDMMSApiService.hasCachedData();
      _cacheTimestamp = await LogTTDMMSApiService.getCacheTimestamp();
    } finally {
      // Muat ulang pending days dari cache pending queue
      await _refreshPendingDays();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPendingDays() async {
    _pendingCount = await LogTTDMMSApiService.pendingCount();
    // Tidak perlu setState di sini karena ini dipanggil sebelum setState di _loadLog
  }

  Future<void> _tryFlushPending() async {
    try {
      final flushed = await _apiService.flushPendingQueue();
      if (flushed > 0) {
        // Ada yang berhasil terkirim → refresh data dari server
        await _loadLog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '$flushed data offline berhasil tersinkron ke server ✓'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      // Masih offline, abaikan
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Aksi centang
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _toggleDay(int hari) async {
    if (_isSaving) return;

    if (_isDayChecked(_selectedBulan, hari)) {
      _showTooltip('Sudah dicatat, tidak dapat dibatalkan');
      return;
    }

    if (!_isDayFillable(_selectedBulan, hari)) {
      if (_isDayFuture(_selectedBulan, hari)) {
        _showTooltip('Hari ini belum tersedia');
      } else {
        _showTooltip('Waktu pengisian sudah terlewat (hanya hari ini & kemarin)');
      }
      return;
    }

    final tanggal = _tanggalDari(_selectedBulan, hari);
    final confirmed = await context.showConfirm(
      title: 'Konfirmasi Minum TTD/MMS',
      message: 'Apakah ibu benar-benar sudah meminum TTD/MMS pada tanggal ${tanggal.day}/${tanggal.month}/${tanggal.year}?',
      confirmText: 'Ya, Sudah Minum',
      cancelText: 'Belum',
    );

    if (!confirmed) return;

    final key = _key(_selectedBulan, hari);
    setState(() {
      _isSaving = true;
      _checkedDays.add(key); // optimistic UI
    });

    try {
      final result = await _apiService.save(
        LogTTDMMSModel(
            bulanKe: _selectedBulan, hariKe: hari, sudahDiminum: true),
      );

      if (result.isPending) {
        // Tersimpan lokal, belum terkirim ke server
        setState(() {
          _pendingDays.add(key);
          _pendingCount++;
        });
        _showTooltip(
            'Offline: data disimpan lokal, akan terkirim saat online ⏳');
      } else {
        // Langsung tersimpan ke server
        setState(() {
          _pendingDays.remove(key);
        });
      }
    } catch (e) {
      // Rollback optimistic update
      setState(() => _checkedDays.remove(key));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showTooltip(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Stats
  // ────────────────────────────────────────────────────────────────────────
  int get _checkedThisMonth {
    int count = 0;
    for (int hari = 1; hari <= _totalHari; hari++) {
      if (_checkedDays.contains(_key(_selectedBulan, hari))) count++;
    }
    return count;
  }

  int get _checkedTotal => _checkedDays.length;

  double get _monthProgress {
    final maxDay = _getMaxAllowedDay(_selectedBulan);
    if (maxDay == 0) return 0;
    return _checkedThisMonth / maxDay;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
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
              'Log TTD / MMS',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Catatan konsumsi Tablet Tambah Darah',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Badge pending di AppBar
          if (_pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _tryFlushPending,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_upload_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$_pendingCount pending',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLog,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Banner offline / dari cache
                  if (_isFromCache) ...[
                    _buildCacheBanner(),
                    const SizedBox(height: 12),
                  ],
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildCalendarCard(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Widgets
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildCacheBanner() {
    String tsText = '';
    if (_cacheTimestamp != null) {
      final ts = _cacheTimestamp!;
      tsText =
          ' (${ts.day}/${ts.month}/${ts.year} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')})';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD966)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 16, color: Color(0xFF856404)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — menampilkan data cache$tsText. Tarik ke bawah untuk memperbarui.',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF856404),
                  height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final maxDay = _getMaxAllowedDay(_selectedBulan);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication_liquid_outlined,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('Tablet Tambah Darah / MMS',
                    style: TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontSize: 16,
                        fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          const Text('Centang setiap hari setelah ibu meminum TTD/MMS.',
              style: TextStyle(
                  color: Color(0xFF4A6FA5), fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          Row(children: [
            _buildStatPill(
                label: 'Bulan $_selectedBulan',
                value: '$_checkedThisMonth/$maxDay hari'),
            const SizedBox(width: 10),
            _buildStatPill(label: 'Total', value: '$_checkedTotal hari'),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
                value: _monthProgress,
                backgroundColor: const Color(0xFFBFDBFE),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 7),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF4A6FA5), fontSize: 11)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF1E3A5F),
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _totalBulan,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bulan = index + 1;
          final selected = bulan == _selectedBulan;
          final hasDays = _getMaxAllowedDay(bulan) > 0;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: hasDays ? () => setState(() => _selectedBulan = bulan) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : hasDays
                        ? Colors.white
                        : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : hasDays
                            ? const Color(0xFFD7DEE9)
                            : const Color(0xFFE0E0E0)),
              ),
              child: Text('Bulan $bulan',
                  style: TextStyle(
                      color: selected
                          ? Colors.white
                          : hasDays
                              ? const Color(0xFF172033)
                              : const Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

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
                offset: const Offset(0, 6))
          ]),
      child: Column(
        children: [
          Row(children: [
            const Expanded(
                child: Text('Checklist Harian',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033)))),
            if (_isSaving)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
          const SizedBox(height: 6),
          Text('Bulan ke-$_selectedBulan kehamilan',
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF7B8798))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _totalHari,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1),
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

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendItem(color: AppColors.primary, label: 'Sudah minum'),
        _legendItem(
            color: Colors.orange.shade100,
            borderColor: Colors.orange,
            label: 'Pending offline'),
        _legendItem(
            color: const Color(0xFFFFEBEB),
            borderColor: const Color(0xFFE53935),
            label: 'Terlewat'),
        _legendItem(
            color: const Color(0xFFF6F8FC),
            borderColor: const Color(0xFFD7DEE9),
            label: 'Bisa diisi'),
      ],
    );
  }

  Widget _legendItem(
      {required Color color, Color? borderColor, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF7B8798))),
      ],
    );
  }

  Widget _buildDayCell(int hari) {
    final checked = _isDayChecked(_selectedBulan, hari);
    final pending = _isDayPending(_selectedBulan, hari);
    final fillable = _isDayFillable(_selectedBulan, hari);
    final overdue = _isDayOverdue(_selectedBulan, hari);
    final future = _isDayFuture(_selectedBulan, hari);

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double textOpacity;
    Widget? child;

    if (checked && pending) {
      // Centang offline: orange
      backgroundColor = Colors.orange.shade100;
      borderColor = Colors.orange;
      textColor = Colors.orange;
      textOpacity = 1.0;
      child = const Icon(Icons.cloud_upload_outlined,
          color: Colors.orange, size: 16);
    } else if (checked) {
      // Sudah tersimpan ke server: hijau
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      textOpacity = 1.0;
      child = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (overdue) {
      // Terlewat: merah
      backgroundColor = const Color(0xFFFFEBEB);
      borderColor = const Color(0xFFE53935);
      textColor = const Color(0xFFE53935);
      textOpacity = 1.0;
    } else if (fillable) {
      // Bisa diisi: normal
      backgroundColor = const Color(0xFFF6F8FC);
      borderColor = const Color(0xFFD7DEE9);
      textColor = const Color(0xFF172033);
      textOpacity = 1.0;
    } else if (future) {
      // Masa depan: abu-abu redup
      backgroundColor = const Color(0xFFFAFAFA);
      borderColor = const Color(0xFFEEEEEE);
      textColor = const Color(0xFFBDBDBD);
      textOpacity = 0.5;
    } else {
      backgroundColor = const Color(0xFFFAFAFA);
      borderColor = const Color(0xFFEEEEEE);
      textColor = const Color(0xFFBDBDBD);
      textOpacity = 0.5;
    }

    final onTap = (!checked && fillable) ? () => _toggleDay(hari) : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: (overdue || future)
          ? () {
              if (overdue) _showTooltip('Waktu pengisian sudah terlewat');
              if (future) _showTooltip('Belum tersedia');
            }
          : (checked && pending)
              ? () => _showTooltip(
                  'Data disimpan lokal, belum terkirim ke server. Pastikan online lalu tarik ke bawah.')
              : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        child: Center(
          child: child ??
              Opacity(
                opacity: textOpacity,
                child: Text('$hari',
                    style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w700)),
              ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE1A6))),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFE0A300)),
          SizedBox(width: 12),
          Expanded(
              child: Text(
            'Hanya hari ini dan kemarin yang dapat diisi. Hari yang terlewat ditandai merah. '
            'Saat offline, centang disimpan lokal (ikon ☁️ oranye) dan otomatis terkirim saat online kembali.',
            style: TextStyle(
                fontSize: 12, color: Color(0xFF6B5A2A), height: 1.35),
          )),
        ],
      ),
    );
  }
}