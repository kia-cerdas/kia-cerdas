// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/log_ttd_mms_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// class LogTTDMMSScreen extends StatefulWidget {
//   final DateTime hpht;

//   const LogTTDMMSScreen({super.key, required this.hpht});

//   @override
//   State<LogTTDMMSScreen> createState() => _LogTTDMMSScreenState();
// }

// class _LogTTDMMSScreenState extends State<LogTTDMMSScreen> {
//   static const int _totalBulan = 10;
//   static const int _totalHari = 31;
//   static const int _hariPerBulan = 30;

//   final _apiService = LogTTDMMSApiService();

//   final Set<String> _checkedDays = {};
//   bool _isLoading = false;
//   bool _isSaving = false;
//   int _selectedBulan = 1;

//   String _key(int bulan, int hari) => '$bulan-$hari';

//   int _getMaxAllowedDay(int bulan) {
//     final now = DateTime.now();
//     final bulanStart = widget.hpht.add(Duration(days: (bulan - 1) * _hariPerBulan));
//     final bulanEnd = bulanStart.add(const Duration(days: _hariPerBulan));

//     if (!now.isBefore(bulanEnd)) return _totalHari;
//     if (now.isBefore(bulanStart)) return 0;

//     final hariKe = now.difference(bulanStart).inDays + 1;
//     return hariKe.clamp(0, _totalHari);
//   }

//   bool _isDayEnabled(int bulan, int hari) => hari <= _getMaxAllowedDay(bulan);
//   bool _isDayChecked(int bulan, int hari) => _checkedDays.contains(_key(bulan, hari));

//   int get _currentBulanKehamilan {
//     final selisihHari = DateTime.now().difference(widget.hpht).inDays;
//     final bulan = (selisihHari ~/ _hariPerBulan) + 1;
//     return bulan.clamp(1, _totalBulan);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _selectedBulan = _currentBulanKehamilan;
//     _loadLog();
//   }

//   @override
//   void dispose() {
//     _apiService.dispose();
//     super.dispose();
//   }

//   Future<void> _loadLog() async {
//     setState(() => _isLoading = true);
//     try {
//       final logs = await _apiService.getMine();
//       _checkedDays.clear();
//       for (final item in logs) {
//         if (item.sudahDiminum) {
//           _checkedDays.add(_key(item.bulanKe, item.hariKe));
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _toggleDay(int hari) async {
//     if (_isSaving) return;

//     if (_isDayChecked(_selectedBulan, hari)) {
//       _showTooltip('Sudah dicatat, tidak dapat dibatalkan');
//       return;
//     }

//     if (!_isDayEnabled(_selectedBulan, hari)) {
//       _showTooltip('Hari ini belum tersedia');
//       return;
//     }

//     final key = _key(_selectedBulan, hari);
//     setState(() {
//       _isSaving = true;
//       _checkedDays.add(key);
//     });

//     try {
//       await _apiService.save(LogTTDMMSModel(bulanKe: _selectedBulan, hariKe: hari, sudahDiminum: true));
//     } catch (e) {
//       setState(() => _checkedDays.remove(key));
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
//       );
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   void _showTooltip(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 1500)),
//     );
//   }

//   int get _checkedThisMonth {
//     int count = 0;
//     for (int hari = 1; hari <= _totalHari; hari++) {
//       if (_checkedDays.contains(_key(_selectedBulan, hari))) count++;
//     }
//     return count;
//   }

//   int get _checkedTotal => _checkedDays.length;

//   double get _monthProgress {
//     final maxDay = _getMaxAllowedDay(_selectedBulan);
//     if (maxDay == 0) return 0;
//     return _checkedThisMonth / maxDay;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: AppBar(
//         title: const Text('Log TTD/MMS'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadLog,
//               child: ListView(
//                 padding: const EdgeInsets.all(20),
//                 children: [
//                   _buildHeaderCard(),
//                   const SizedBox(height: 16),
//                   _buildMonthSelector(),
//                   const SizedBox(height: 16),
//                   _buildCalendarCard(),
//                   const SizedBox(height: 20),
//                   _buildInfoCard(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildHeaderCard() {
//     final maxDay = _getMaxAllowedDay(_selectedBulan);
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF56CCF2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 8))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(children: [
//             Icon(Icons.medication_liquid_outlined, color: Colors.white),
//             SizedBox(width: 10),
//             Expanded(child: Text('Tablet Tambah Darah / MMS', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
//           ]),
//           const SizedBox(height: 10),
//           const Text('Centang setiap hari setelah ibu meminum TTD/MMS.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35)),
//           const SizedBox(height: 18),
//           Row(children: [
//             _buildStatPill(label: 'Bulan $_selectedBulan', value: '$_checkedThisMonth/$maxDay hari'),
//             const SizedBox(width: 10),
//             _buildStatPill(label: 'Total', value: '$_checkedTotal hari'),
//           ]),
//           const SizedBox(height: 16),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(999),
//             child: LinearProgressIndicator(value: _monthProgress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatPill({required String label, required String value}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
//             const SizedBox(height: 3),
//             Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthSelector() {
//     return SizedBox(
//       height: 46,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: _totalBulan,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, index) {
//           final bulan = index + 1;
//           final selected = bulan == _selectedBulan;
//           final hasDays = _getMaxAllowedDay(bulan) > 0;
//           return InkWell(
//             borderRadius: BorderRadius.circular(999),
//             onTap: hasDays ? () => setState(() => _selectedBulan = bulan) : null,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: selected ? AppColors.primary : hasDays ? Colors.white : const Color(0xFFF0F0F0),
//                 borderRadius: BorderRadius.circular(999),
//                 border: Border.all(color: selected ? AppColors.primary : hasDays ? const Color(0xFFD7DEE9) : const Color(0xFFE0E0E0)),
//               ),
//               child: Text('Bulan $bulan', style: TextStyle(color: selected ? Colors.white : hasDays ? const Color(0xFF172033) : const Color(0xFFBDBDBD), fontWeight: FontWeight.w700, fontSize: 13)),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCalendarCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE5ECF6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 12, offset: const Offset(0, 6))]),
//       child: Column(
//         children: [
//           Row(children: [
//             const Expanded(child: Text('Checklist Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF172033)))),
//             if (_isSaving) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
//           ]),
//           const SizedBox(height: 6),
//           Text('Bulan ke-$_selectedBulan kehamilan', style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798))),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _totalHari,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
//             itemBuilder: (context, index) {
//               final hari = index + 1;
//               return _buildDayCell(hari);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDayCell(int hari) {
//     final checked = _isDayChecked(_selectedBulan, hari);
//     final enabled = _isDayEnabled(_selectedBulan, hari);

//     Color backgroundColor;
//     Color borderColor;
//     Color textColor;
//     double textOpacity;

//     if (checked) {
//       backgroundColor = AppColors.primary;
//       borderColor = AppColors.primary;
//       textColor = Colors.white;
//       textOpacity = 1.0;
//     } else if (enabled) {
//       backgroundColor = const Color(0xFFF6F8FC);
//       borderColor = const Color(0xFFD7DEE9);
//       textColor = const Color(0xFF172033);
//       textOpacity = 1.0;
//     } else {
//       backgroundColor = const Color(0xFFFAFAFA);
//       borderColor = const Color(0xFFEEEEEE);
//       textColor = const Color(0xFFBDBDBD);
//       textOpacity = 0.5;
//     }

//     return InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: enabled ? () => _toggleDay(hari) : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
//         child: Center(
//           child: checked
//               ? const Icon(Icons.check, color: Colors.white, size: 18)
//               : Opacity(opacity: textOpacity, child: Text('$hari', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700))),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: const Color(0xFFFFF8E7), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFFE1A6))),
//       child: const Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline, color: Color(0xFFE0A300)),
//           SizedBox(width: 12),
//           Expanded(child: Text('Checklist ini membantu memantau kepatuhan minum TTD/MMS selama masa kehamilan. Centang hanya bisa dilakukan pada hari yang sudah berlalu dan tidak dapat dibatalkan.', style: TextStyle(fontSize: 12, color: Color(0xFF6B5A2A), height: 1.35))),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/log_ttd_mms_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class LogTTDMMSScreen extends StatefulWidget {
  final DateTime hpht;

  const LogTTDMMSScreen({super.key, required this.hpht});

  @override
  State<LogTTDMMSScreen> createState() => _LogTTDMMSScreenState();
}

class _LogTTDMMSScreenState extends State<LogTTDMMSScreen> {
  static const int _totalBulan = 10;
  static const int _totalHari = 31;
  static const int _hariPerBulan = 30;

  final _apiService = LogTTDMMSApiService();

  final Set<String> _checkedDays = {};
  bool _isLoading = false;
  bool _isSaving = false;
  int _selectedBulan = 1;

  String _key(int bulan, int hari) => '$bulan-$hari';

  /// Hitung tanggal kalender dari bulan_ke dan hari_ke
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

  /// Apakah hari ini boleh diisi (hanya hari ini dan kemarin)
  bool _isDayFillable(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return !tanggal.isBefore(_kemarin) && !tanggal.isAfter(_hariIni);
  }

  /// Apakah hari sudah terlewat (sebelum kemarin) dan belum dicentang
  bool _isDayOverdue(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return tanggal.isBefore(_kemarin) && !_isDayChecked(bulan, hari);
  }

  /// Apakah hari masih di masa depan (hari esok ke depan)
  bool _isDayFuture(int bulan, int hari) {
    final tanggal = _tanggalDari(bulan, hari);
    return tanggal.isAfter(_hariIni);
  }

  int _getMaxAllowedDay(int bulan) {
    final now = DateTime.now();
    final bulanStart = widget.hpht.add(Duration(days: (bulan - 1) * _hariPerBulan));
    final bulanEnd = bulanStart.add(const Duration(days: _hariPerBulan));

    if (!now.isBefore(bulanEnd)) return _totalHari;
    if (now.isBefore(bulanStart)) return 0;

    final hariKe = now.difference(bulanStart).inDays + 1;
    return hariKe.clamp(0, _totalHari);
  }

  bool _isDayChecked(int bulan, int hari) => _checkedDays.contains(_key(bulan, hari));

  int get _currentBulanKehamilan {
    final selisihHari = DateTime.now().difference(widget.hpht).inDays;
    final bulan = (selisihHari ~/ _hariPerBulan) + 1;
    return bulan.clamp(1, _totalBulan);
  }

  @override
  void initState() {
    super.initState();
    _selectedBulan = _currentBulanKehamilan;
    _loadLog();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadLog() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _apiService.getMine();
      _checkedDays.clear();
      for (final item in logs) {
        if (item.sudahDiminum) {
          _checkedDays.add(_key(item.bulanKe, item.hariKe));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

    final key = _key(_selectedBulan, hari);
    setState(() {
      _isSaving = true;
      _checkedDays.add(key);
    });

    try {
      await _apiService.save(LogTTDMMSModel(bulanKe: _selectedBulan, hariKe: hari, sudahDiminum: true));
    } catch (e) {
      setState(() => _checkedDays.remove(key));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showTooltip(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 1500)),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Log TTD/MMS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLog,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
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

  Widget _buildHeaderCard() {
    final maxDay = _getMaxAllowedDay(_selectedBulan);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF56CCF2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.medication_liquid_outlined, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text('Tablet Tambah Darah / MMS', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          const Text('Centang setiap hari setelah ibu meminum TTD/MMS.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35)),
          const SizedBox(height: 18),
          Row(children: [
            _buildStatPill(label: 'Bulan $_selectedBulan', value: '$_checkedThisMonth/$maxDay hari'),
            const SizedBox(width: 10),
            _buildStatPill(label: 'Total', value: '$_checkedTotal hari'),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: _monthProgress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
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
                color: selected ? AppColors.primary : hasDays ? Colors.white : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? AppColors.primary : hasDays ? const Color(0xFFD7DEE9) : const Color(0xFFE0E0E0)),
              ),
              child: Text('Bulan $bulan', style: TextStyle(color: selected ? Colors.white : hasDays ? const Color(0xFF172033) : const Color(0xFFBDBDBD), fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE5ECF6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Column(
        children: [
          Row(children: [
            const Expanded(child: Text('Checklist Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF172033)))),
            if (_isSaving) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
          const SizedBox(height: 6),
          Text('Bulan ke-$_selectedBulan kehamilan', style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _totalHari,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: AppColors.primary, label: 'Sudah minum'),
        const SizedBox(width: 14),
        _legendItem(color: const Color(0xFFFFEBEB), borderColor: const Color(0xFFE53935), label: 'Terlewat'),
        const SizedBox(width: 14),
        _legendItem(color: const Color(0xFFF6F8FC), borderColor: const Color(0xFFD7DEE9), label: 'Bisa diisi'),
      ],
    );
  }

  Widget _legendItem({required Color color, Color? borderColor, required String label}) {
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
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF7B8798))),
      ],
    );
  }

  Widget _buildDayCell(int hari) {
    final checked = _isDayChecked(_selectedBulan, hari);
    final fillable = _isDayFillable(_selectedBulan, hari);
    final overdue = _isDayOverdue(_selectedBulan, hari);
    final future = _isDayFuture(_selectedBulan, hari);

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double textOpacity;
    Widget? child;

    if (checked) {
      // Sudah dicentang → hijau/primary
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
      textOpacity = 1.0;
      child = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (overdue) {
      // Terlewat, tidak diisi → merah
      backgroundColor = const Color(0xFFFFEBEB);
      borderColor = const Color(0xFFE53935);
      textColor = const Color(0xFFE53935);
      textOpacity = 1.0;
    } else if (fillable) {
      // Hari ini atau kemarin, belum diisi → bisa diklik
      backgroundColor = const Color(0xFFF6F8FC);
      borderColor = const Color(0xFFD7DEE9);
      textColor = const Color(0xFF172033);
      textOpacity = 1.0;
    } else if (future) {
      // Hari depan → abu-abu redup
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

    // Hanya fillable (hari ini & kemarin) yang bisa diklik, sisanya null
    final onTap = (!checked && fillable) ? () => _toggleDay(hari) : null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      // Tap pada overdue/future tetap tampilkan pesan
      onLongPress: (overdue || future)
          ? () {
              if (overdue) _showTooltip('Waktu pengisian sudah terlewat');
              if (future) _showTooltip('Belum tersedia');
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
        child: Center(
          child: child ??
              Opacity(
                opacity: textOpacity,
                child: Text('$hari', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700)),
              ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E7), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFFE1A6))),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFE0A300)),
          SizedBox(width: 12),
          Expanded(child: Text('Hanya hari ini dan kemarin yang dapat diisi. Hari yang terlewat ditandai merah dan tidak dapat diisi kembali.', style: TextStyle(fontSize: 12, color: Color(0xFF6B5A2A), height: 1.35))),
        ],
      ),
    );
  }
}