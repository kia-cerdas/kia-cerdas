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


// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t1_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t2_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t3_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/widgets/index.dart';

// class CatatanPelayananMenuScreen extends StatelessWidget {
//   const CatatanPelayananMenuScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       appBar: IbuGradientHeader(
//         title: 'Catatan Pelayanan',
//         subtitle: 'Riwayat pemeriksaan kehamilan',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const IbuSectionTitle(
//               title: 'Pilih Trimester',
//               subtitle: 'Lihat catatan pelayanan berdasarkan trimester',
//             ),
//             IbuMenuCard(
//               icon: Icons.looks_one_outlined,
//               title: 'Catatan Pelayanan Trimester 1',
//               subtitle: 'Lihat catatan pemeriksaan trimester 1',
//               iconColor: const Color(0xFF2F80ED),
//               iconBgColor: const Color(0xFFEAF4FF),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => CatatanPelayananT1Screen()),
//               ),
//             ),
//             IbuMenuCard(
//               icon: Icons.looks_two_outlined,
//               title: 'Catatan Pelayanan Trimester 2',
//               subtitle: 'Lihat catatan pemeriksaan trimester 2',
//               iconColor: const Color(0xFF3949AB),
//               iconBgColor: const Color(0xFFE8EAF6),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => CatatanPelayananT2Screen()),
//               ),
//             ),
//             IbuMenuCard(
//               icon: Icons.looks_3_outlined,
//               title: 'Catatan Pelayanan Trimester 3',
//               subtitle: 'Lihat catatan pemeriksaan trimester 3',
//               iconColor: const Color(0xFF7B1FA2),
//               iconBgColor: const Color(0xFFF3E5F5),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => CatatanPelayananT3Screen()),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEAF4FF),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Color(0xFF2F80ED)),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Catatan pelayanan berisi hasil pemeriksaan oleh tenaga kesehatan selama masa kehamilan.',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t1_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t2_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t3_screen.dart';

// class CatatanPelayananMenuScreen extends StatefulWidget {
//   const CatatanPelayananMenuScreen({super.key});

//   @override
//   State<CatatanPelayananMenuScreen> createState() =>
//       _CatatanPelayananMenuScreenState();
// }

// class _CatatanPelayananMenuScreenState
//     extends State<CatatanPelayananMenuScreen> {
//   int selectedIndex = 0;

//   final List<Widget> pages = const [
//     CatatanPelayananT1Screen(),
//     CatatanPelayananT2Screen(),
//     CatatanPelayananT3Screen(),
//   ];

//   final List<String> labels = const [
//     'Trimester 1',
//     'Trimester 2',
//     'Trimester 3',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FF),

//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,

//               padding: const EdgeInsets.fromLTRB(
//                 20,
//                 20,
//                 20,
//                 22,
//               ),

//               decoration: const BoxDecoration(
//                 color: AppColors.primary,

//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Row(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },

//                         borderRadius:
//                             BorderRadius.circular(30),

//                         child: Container(
//                           padding:
//                               const EdgeInsets.all(8),

//                           decoration: BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(0.15),

//                             shape: BoxShape.circle,
//                           ),

//                           child: const Icon(
//                             Icons.arrow_back_ios_new,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 14),

//                       const Expanded(
//                         child: Text(
//                           'Catatan Pelayanan',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   Container(
//                     height: 54,

//                     padding: const EdgeInsets.all(5),

//                     decoration: BoxDecoration(
//                       color:
//                           Colors.white.withOpacity(0.14),

//                       borderRadius:
//                           BorderRadius.circular(18),
//                     ),

//                     child: Row(
//                       children: List.generate(
//                         labels.length,
//                         (index) {
//                           final selected =
//                               selectedIndex == index;

//                           return Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedIndex = index;
//                                 });
//                               },

//                               child: AnimatedContainer(
//                                 duration:
//                                     const Duration(
//                                   milliseconds: 220,
//                                 ),

//                                 margin:
//                                     const EdgeInsets.symmetric(
//                                   horizontal: 3,
//                                 ),

//                                 decoration: BoxDecoration(
//                                   color: selected
//                                       ? Colors.white
//                                       : Colors.transparent,

//                                   borderRadius:
//                                       BorderRadius.circular(
//                                     14,
//                                   ),
//                                 ),

//                                 child: Center(
//                                   child: Text(
//                                     labels[index],
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight:
//                                           FontWeight.w700,

//                                       color: selected
//                                           ? AppColors
//                                               .primary
//                                           : Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: AnimatedSwitcher(
//                 duration: const Duration(
//                   milliseconds: 250,
//                 ),

//                 child: Container(
//                   key: ValueKey(selectedIndex),

//                   margin:
//                       const EdgeInsets.only(top: 10),

//                   child: pages[selectedIndex],
//                 ),
//               ),
//             ),
//           ],
//         ),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Catatan Pelayanan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.55),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Trimester 1'),
            Tab(text: 'Trimester 3'),
          ],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        style:
                            TextStyle(fontSize: 11, color: Colors.black54),
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