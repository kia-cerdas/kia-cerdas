// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/catatan_pelayanan_kehamilan_model.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/repositories/catatan_pelayanan_kehamilan_repository.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/catatan_pelayanan_kehamilan_service.dart';

// class CatatanPelayananMenuScreen extends StatefulWidget {
//   const CatatanPelayananMenuScreen({super.key});

//   @override
//   State<CatatanPelayananMenuScreen> createState() =>
//       _CatatanPelayananMenuScreenState();
// }

// class _CatatanPelayananMenuScreenState
//     extends State<CatatanPelayananMenuScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//   final _repo = CatatanPelayananKehamilanRepository(
//     CatatanPelayananKehamilanService(),
//   );

//   // Cache per trimester agar tidak fetch ulang saat ganti tab
//   final Map<int, List<CatatanPelayananKehamilanModel>> _cache = {};
//   final Map<int, bool> _loading = {1: true, 2: true, 3: true};
//   final Map<int, String?> _error = {};

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     for (int t = 1; t <= 3; t++) {
//       _fetchTrimester(t);
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchTrimester(int trimester) async {
//     try {
//       final data = await _repo.getMine(trimester: trimester);
//       if (!mounted) return;
//       setState(() {
//         _cache[trimester] = data;
//         _loading[trimester] = false;
//         _error[trimester] = null;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error[trimester] = e.toString();
//         _loading[trimester] = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FF),
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Catatan Pelayanan',
//           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           indicatorWeight: 3,
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white.withOpacity(0.55),
//           labelStyle:
//               const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
//           unselectedLabelStyle:
//               const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//           tabs: const [
//             Tab(text: 'Trimester 1'),
//             Tab(text: 'Trimester 2'),
//             Tab(text: 'Trimester 3'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [1, 2, 3].map(_buildTabContent).toList(),
//       ),
//     );
//   }

//   Widget _buildTabContent(int trimester) {
//     if (_loading[trimester] == true) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error[trimester] != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 40),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 _error[trimester]!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 setState(() => _loading[trimester] = true);
//                 _fetchTrimester(trimester);
//               },
//               child: const Text('Coba lagi'),
//             ),
//           ],
//         ),
//       );
//     }

//     final list = _cache[trimester] ?? [];

//     if (list.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEFF6FF),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: const Icon(
//                 Icons.description_outlined,
//                 color: AppColors.primary,
//                 size: 42,
//               ),
//             ),
//             const SizedBox(height: 18),
//             const Text(
//               'Belum ada catatan pelayanan',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Data pemeriksaan trimester $trimester akan muncul di sini',
//               style: const TextStyle(fontSize: 12, color: Colors.black54),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => _fetchTrimester(trimester),
//       child: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         itemCount: list.length,
//         itemBuilder: (context, index) => _buildCard(list[index]),
//       ),
//     );
//   }

//   Widget _buildCard(CatatanPelayananKehamilanModel item) {
//     final tglPeriksa = item.tanggalPeriksa != null
//         ? item.tanggalPeriksa!.toIso8601String().split('T').first
//         : '-';
//     final tglKembali = item.tanggalKembali != null
//         ? item.tanggalKembali!.toIso8601String().split('T').first
//         : '-';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: const BoxDecoration(
//               color: Color(0xFFEFF6FF),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24),
//                 topRight: Radius.circular(24),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.description_outlined,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Tanggal Pemeriksaan',
//                         style:
//                             TextStyle(fontSize: 11, color: Colors.black54),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         tglPeriksa,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Body
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Keluhan & Pemeriksaan',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   item.keluhan.isNotEmpty ? item.keluhan : '-',
//                   style: const TextStyle(fontSize: 14, height: 1.6),
//                 ),
//                 const SizedBox(height: 18),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.calendar_month,
//                         size: 18,
//                         color: AppColors.primary,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Kembali periksa: $tglKembali',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/catatan_pelayanan_kehamilan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/repositories/catatan_pelayanan_kehamilan_repository.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/catatan_pelayanan_kehamilan_service.dart';

class CatatanPelayananMenuScreen extends StatefulWidget {
  const CatatanPelayananMenuScreen({super.key});

  @override
  State<CatatanPelayananMenuScreen> createState() =>
      _CatatanPelayananMenuScreenState();
}

class _CatatanPelayananMenuScreenState
    extends State<CatatanPelayananMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _repo = CatatanPelayananKehamilanRepository(
    CatatanPelayananKehamilanService(),
  );

  // Trimester 2 sengaja TIDAK disertakan: tidak ada tabel pemeriksaan dokter
  // untuk trimester 2, jadi tab-nya dihilangkan (bukan sekadar dikosongkan).
  static const List<int> _trimesters = [1, 3];

  // Cache per trimester agar tidak fetch ulang saat ganti tab
  final Map<int, List<CatatanPelayananKehamilanModel>> _cache = {};
  final Map<int, bool> _loading = {1: true, 3: true};
  final Map<int, String?> _error = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _trimesters.length, vsync: this);
    for (final t in _trimesters) {
      _fetchTrimester(t);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrimester(int trimester) async {
    try {
      final data = await _repo.getMine(trimester: trimester);
      if (!mounted) return;
      setState(() {
        _cache[trimester] = data;
        _loading[trimester] = false;
        _error[trimester] = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error[trimester] = e.toString();
        _loading[trimester] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
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
              'Catatan Pelayanan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Riwayat pemeriksaan kehamilan per trimester',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(color: Colors.grey.shade200, height: 1.0),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: Color(0xFF94A3B8),
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: [
                  Tab(text: 'Trimester 1'),
                  Tab(text: 'Trimester 3'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _trimesters.map(_buildTabContent).toList(),
      ),
    );
  }

  Widget _buildTabContent(int trimester) {
    if (_loading[trimester] == true) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error[trimester] != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error[trimester]!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _loading[trimester] = true);
                _fetchTrimester(trimester);
              },
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    final list = _cache[trimester] ?? [];

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada catatan pelayanan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Data pemeriksaan trimester $trimester akan muncul di sini',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchTrimester(trimester),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildCard(list[index]),
      ),
    );
  }

//   Widget _buildCard(CatatanPelayananKehamilanModel item) {
//     final tglPeriksa = item.tanggalPeriksa != null
//         ? item.tanggalPeriksa!.toIso8601String().split('T').first
//         : '-';
//     final tglKembali = item.tanggalKembali != null
//         ? item.tanggalKembali!.toIso8601String().split('T').first
//         : '-';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: const BoxDecoration(
//               color: Color(0xFFEFF6FF),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24),
//                 topRight: Radius.circular(24),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.description_outlined,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Tanggal Pemeriksaan',
//                         style:
//                             TextStyle(fontSize: 11, color: Colors.black54),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         tglPeriksa,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Body
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Keluhan & Pemeriksaan',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   item.keluhan.isNotEmpty ? item.keluhan : '-',
//                   style: const TextStyle(fontSize: 14, height: 1.6),
//                 ),
//                 const SizedBox(height: 18),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.calendar_month,
//                         size: 18,
//                         color: AppColors.primary,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Kembali periksa: $tglKembali',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  Widget _buildCard(CatatanPelayananKehamilanModel item) {
    final tglPeriksa = item.tanggalPeriksa != null
        ? item.tanggalPeriksa!.toIso8601String().split('T').first
        : '-';
    final tglKembali = item.tanggalKembali != null
        ? item.tanggalKembali!.toIso8601String().split('T').first
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Pemeriksaan',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tglPeriksa,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KONDISI: Kalau Trimester 1, tampilkan Keluhan
                if (item.trimester == 1) ...[
                  const Text(
                    'Keluhan & Pemeriksaan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.keluhan.isNotEmpty ? item.keluhan : '-',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 18),
                ],

                // KONDISI: Kalau Trimester 3, tampilkan Penjelasan
                if (item.trimester == 3) ...[
                  const Text(
                    'Penjelasan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.penjelasan.isNotEmpty ? item.penjelasan : '-',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 18),
                ],

                // Bagian Tanggal Kembali (Selalu tampil di semua trimester)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kembali periksa: $tglKembali',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


