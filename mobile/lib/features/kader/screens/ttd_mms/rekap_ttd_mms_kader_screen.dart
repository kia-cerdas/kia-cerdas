// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'ttd_mms_kader_api_service.dart';
// import 'rekap_ttd_mms_model.dart';
// import 'detail_ttd_mms_ibu_screen.dart';

// class RekapTTDMMSKaderScreen extends StatefulWidget {
//   const RekapTTDMMSKaderScreen({super.key});

//   @override
//   State<RekapTTDMMSKaderScreen> createState() => _RekapTTDMMSKaderScreenState();
// }

// class _RekapTTDMMSKaderScreenState extends State<RekapTTDMMSKaderScreen> {
//   final _apiService = TtdMmsKaderApiService();

//   List<RekapTTDMMSModel> _semua = [];
//   bool _isLoading = false;
//   String? _error;

//   // Filter aktif: null = semua
//   StatusKepatuhan? _filterStatus;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _apiService.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final data = await _apiService.getRekap();
//       if (!mounted) return;
//       setState(() => _semua = data);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _error = e.toString());
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   List<RekapTTDMMSModel> get _filtered {
//     if (_filterStatus == null) return _semua;
//     return _semua.where((e) => e.status == _filterStatus).toList();
//   }

//   int _jumlah(StatusKepatuhan s) => _semua.where((e) => e.status == s).length;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       appBar: AppBar(
//         title: const Text('Pemantauan TTD/MMS'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? _buildError()
//               : RefreshIndicator(
//                   onRefresh: _loadData,
//                   child: ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       _buildSummaryRow(),
//                       const SizedBox(height: 14),
//                       _buildFilterChips(),
//                       const SizedBox(height: 12),
//                       if (_filtered.isEmpty) _buildEmpty(),
//                       ..._filtered.map(_buildIbuCard),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   // ── Summary ────────────────────────────────────────────────

//   Widget _buildSummaryRow() {
//     return Row(
//       children: [
//         _summaryPill(
//           label: 'Patuh',
//           count: _jumlah(StatusKepatuhan.patuh),
//           color: Colors.green,
//         ),
//         const SizedBox(width: 8),
//         _summaryPill(
//           label: 'Perlu pantau',
//           count: _jumlah(StatusKepatuhan.perluPantau),
//           color: Colors.orange,
//         ),
//         const SizedBox(width: 8),
//         _summaryPill(
//           label: 'Tidak patuh',
//           count: _jumlah(StatusKepatuhan.tidakPatuh),
//           color: Colors.red,
//         ),
//       ],
//     );
//   }

//   Widget _summaryPill({
//     required String label,
//     required int count,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: TextStyle(fontSize: 11, color: color),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Filter chips ────────────────────────────────────────────

//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           _filterChip(label: 'Semua (${_semua.length})', value: null),
//           const SizedBox(width: 8),
//           _filterChip(
//             label: 'Patuh (${_jumlah(StatusKepatuhan.patuh)})',
//             value: StatusKepatuhan.patuh,
//             color: Colors.green,
//           ),
//           const SizedBox(width: 8),
//           _filterChip(
//             label: 'Perlu pantau (${_jumlah(StatusKepatuhan.perluPantau)})',
//             value: StatusKepatuhan.perluPantau,
//             color: Colors.orange,
//           ),
//           const SizedBox(width: 8),
//           _filterChip(
//             label: 'Tidak patuh (${_jumlah(StatusKepatuhan.tidakPatuh)})',
//             value: StatusKepatuhan.tidakPatuh,
//             color: Colors.red,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _filterChip({
//     required String label,
//     required StatusKepatuhan? value,
//     Color? color,
//   }) {
//     final isSelected = _filterStatus == value;
//     final activeColor = color ?? AppColors.primary;
//     return GestureDetector(
//       onTap: () => setState(() => _filterStatus = value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//         decoration: BoxDecoration(
//           color: isSelected ? activeColor : Colors.white,
//           borderRadius: BorderRadius.circular(999),
//           border: Border.all(
//             color: isSelected ? activeColor : Colors.grey.shade300,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: isSelected ? Colors.white : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Ibu card ────────────────────────────────────────────────

//   Widget _buildIbuCard(RekapTTDMMSModel ibu) {
//     final status = ibu.status;
//     final Color borderColor;
//     final Color badgeColor;
//     final Color badgeText;
//     final String badgeLabel;

//     switch (status) {
//       case StatusKepatuhan.patuh:
//         borderColor = Colors.green.shade200;
//         badgeColor = Colors.green.shade50;
//         badgeText = Colors.green.shade700;
//         badgeLabel = 'Patuh';
//         break;
//       case StatusKepatuhan.perluPantau:
//         borderColor = Colors.orange.shade200;
//         badgeColor = Colors.orange.shade50;
//         badgeText = Colors.orange.shade700;
//         badgeLabel = 'Perlu pantau';
//         break;
//       case StatusKepatuhan.tidakPatuh:
//         borderColor = Colors.red.shade200;
//         badgeColor = Colors.red.shade50;
//         badgeText = Colors.red.shade700;
//         badgeLabel = 'Tidak patuh';
//         break;
//     }

//     final persenText =
//         '${(ibu.persentase * 100).toStringAsFixed(0)}%';

//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => DetailTTDMMSIbuScreen(rekap: ibu),
//         ),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: borderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Baris atas: nama + badge + persentase
//             Row(
//               children: [
//                 // Inisial avatar
//                 Container(
//                   width: 38,
//                   height: 38,
//                   decoration: BoxDecoration(
//                     color: badgeColor,
//                     shape: BoxShape.circle,
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     _initials(ibu.namaIbu),
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: badgeText,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Text(
//                               ibu.namaIbu,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 7, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: badgeColor,
//                               borderRadius: BorderRadius.circular(999),
//                             ),
//                             child: Text(
//                               badgeLabel,
//                               style: TextStyle(
//                                   fontSize: 10,
//                                   color: badgeText,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Bulan ke-${ibu.bulanKe} kehamilan',
//                         style: TextStyle(
//                             fontSize: 12, color: Colors.grey.shade600),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       persenText,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: badgeText,
//                       ),
//                     ),
//                     Text(
//                       'kepatuhan',
//                       style: TextStyle(
//                           fontSize: 10, color: Colors.grey.shade500),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             // Progress bar
//             ClipRRect(
//               borderRadius: BorderRadius.circular(999),
//               child: LinearProgressIndicator(
//                 value: ibu.persentase,
//                 minHeight: 6,
//                 backgroundColor: Colors.grey.shade100,
//                 valueColor: AlwaysStoppedAnimation<Color>(badgeText),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Statistik baris bawah
//             Row(
//               children: [
//                 _statChip(
//                   label: 'Total hari',
//                   value: '${ibu.totalHari}',
//                   color: Colors.blueGrey,
//                 ),
//                 const SizedBox(width: 8),
//                 _statChip(
//                   label: 'Diminum',
//                   value: '${ibu.totalDiminum}',
//                   color: Colors.green,
//                 ),
//                 const SizedBox(width: 8),
//                 _statChip(
//                   label: 'Terlewat',
//                   value: '${ibu.totalTerlewat}',
//                   color: Colors.red,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _statChip({
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Empty / error states ────────────────────────────────────

//   Widget _buildEmpty() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.medication_liquid_outlined,
//                 size: 56, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(
//               'Tidak ada data ibu hamil\ndi wilayah ini',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildError() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 12),
//             Text(_error!, textAlign: TextAlign.center),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadData,
//               child: const Text('Coba lagi'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Helper ──────────────────────────────────────────────────

//   String _initials(String nama) {
//     final parts = nama.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'ttd_mms_kader_api_service.dart';
import 'rekap_ttd_mms_model.dart';
import 'detail_ttd_mms_ibu_screen.dart';

class RekapTTDMMSKaderScreen extends StatefulWidget {
  const RekapTTDMMSKaderScreen({super.key});

  @override
  State<RekapTTDMMSKaderScreen> createState() => _RekapTTDMMSKaderScreenState();
}

class _RekapTTDMMSKaderScreenState extends State<RekapTTDMMSKaderScreen> {
  final _apiService = TtdMmsKaderApiService();

  List<RekapTTDMMSModel> _semua = [];
  bool _isLoading = false;
  String? _error;

  // Filter aktif: null = semua
  StatusKepatuhan? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _apiService.getRekap();
      if (!mounted) return;
      setState(() => _semua = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Hanya ibu hamil aktif (bukan NIFAS) untuk filter & summary
  List<RekapTTDMMSModel> get _hanya_hamil =>
      _semua.where((e) => !e.isNifas).toList();

  List<RekapTTDMMSModel> get _hanya_nifas =>
      _semua.where((e) => e.isNifas).toList();

  List<RekapTTDMMSModel> get _filtered {
    final source = _filterStatus == null ? _semua : _semua;
    if (_filterStatus == null) return source;
    return source.where((e) => e.status == _filterStatus).toList();
  }

  int _jumlah(StatusKepatuhan s) =>
      _hanya_hamil.where((e) => e.status == s).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Pemantauan TTD/MMS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryRow(),
                      const SizedBox(height: 14),
                      _buildFilterChips(),
                      const SizedBox(height: 12),
                      // ── Ibu Hamil Aktif ──
                      ..._buildSection(
                        judul: 'Ibu Hamil Aktif',
                        items: _filterStatus == null
                            ? _hanya_hamil
                            : _hanya_hamil
                                .where((e) => e.status == _filterStatus)
                                .toList(),
                        emptyMsg: 'Tidak ada ibu hamil aktif di wilayah ini',
                        isNifasSection: false,
                      ),
                      // ── Masa Nifas ──
                      if (_hanya_nifas.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSectionHeader(
                          'Masa Nifas (Sudah Melahirkan)',
                          const Color(0xFF7E57C2),
                        ),
                        const SizedBox(height: 8),
                        ..._buildSection(
                          judul: '',
                          items: _filterStatus == null
                              ? _hanya_nifas
                              : _hanya_nifas
                                  .where((e) => e.status == _filterStatus)
                                  .toList(),
                          emptyMsg: '',
                          isNifasSection: true,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  // ── Section header ──────────────────────────────────────────

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSection({
    required String judul,
    required List<RekapTTDMMSModel> items,
    required String emptyMsg,
    required bool isNifasSection,
  }) {
    if (items.isEmpty && emptyMsg.isNotEmpty) {
      return [_buildEmpty(emptyMsg)];
    }
    return items.map((e) => _buildIbuCard(e, isNifasSection: isNifasSection)).toList();
  }

  // ── Summary ────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryPill(
          label: 'Patuh',
          count: _jumlah(StatusKepatuhan.patuh),
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _summaryPill(
          label: 'Perlu pantau',
          count: _jumlah(StatusKepatuhan.perluPantau),
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
        _summaryPill(
          label: 'Tidak patuh',
          count: _jumlah(StatusKepatuhan.tidakPatuh),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _summaryPill({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(label: 'Semua (${_semua.length})', value: null),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Patuh (${_jumlah(StatusKepatuhan.patuh)})',
            value: StatusKepatuhan.patuh,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Perlu pantau (${_jumlah(StatusKepatuhan.perluPantau)})',
            value: StatusKepatuhan.perluPantau,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Tidak patuh (${_jumlah(StatusKepatuhan.tidakPatuh)})',
            value: StatusKepatuhan.tidakPatuh,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required StatusKepatuhan? value,
    Color? color,
  }) {
    final isSelected = _filterStatus == value;
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // ── Ibu card ────────────────────────────────────────────────

  Widget _buildIbuCard(RekapTTDMMSModel ibu, {bool isNifasSection = false}) {
    final status = ibu.status;
    final Color borderColor;
    final Color badgeColor;
    final Color badgeText;
    final String badgeLabel;

    switch (status) {
      case StatusKepatuhan.patuh:
        borderColor = Colors.green.shade200;
        badgeColor = Colors.green.shade50;
        badgeText = Colors.green.shade700;
        badgeLabel = 'Patuh';
        break;
      case StatusKepatuhan.perluPantau:
        borderColor = Colors.orange.shade200;
        badgeColor = Colors.orange.shade50;
        badgeText = Colors.orange.shade700;
        badgeLabel = 'Perlu pantau';
        break;
      case StatusKepatuhan.tidakPatuh:
        borderColor = Colors.red.shade200;
        badgeColor = Colors.red.shade50;
        badgeText = Colors.red.shade700;
        badgeLabel = 'Tidak patuh';
        break;
    }

    final persenText =
        '${(ibu.persentase * 100).toStringAsFixed(0)}%';

    // Deskripsi baris sub-judul berbeda untuk nifas vs hamil
    final subLabel = isNifasSection
        ? 'Masa nifas · ${ibu.totalHari} hari kehamilan tercatat'
        : 'Bulan ke-${ibu.bulanKe} kehamilan';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailTTDMMSIbuScreen(rekap: ibu),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Inisial avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isNifasSection
                        ? const Color(0xFFEDE7F6)
                        : badgeColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isNifasSection
                      ? const Icon(Icons.child_care,
                          size: 20, color: Color(0xFF7E57C2))
                      : Text(
                          _initials(ibu.namaIbu),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: badgeText,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              ibu.namaIbu,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge kepatuhan
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: badgeText,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isNifasSection) ...[
                            const SizedBox(width: 4),
                            // Badge NIFAS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE7F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Nifas',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF7E57C2),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subLabel,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      persenText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                    Text(
                      'kepatuhan',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ibu.persentase,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(badgeText),
              ),
            ),

            const SizedBox(height: 10),

            // Statistik baris bawah
            Row(
              children: [
                _statChip(
                  label: 'Total hari',
                  value: '${ibu.totalHari}',
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                _statChip(
                  label: 'Diminum',
                  value: '${ibu.totalDiminum}',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _statChip(
                  label: 'Terlewat',
                  value: '${ibu.totalTerlewat}',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty / error states ────────────────────────────────────

  Widget _buildEmpty(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.medication_liquid_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper ──────────────────────────────────────────────────

  String _initials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}