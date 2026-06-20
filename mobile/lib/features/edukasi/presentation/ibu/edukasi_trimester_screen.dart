// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';
// import 'edukasi_trimester_detail_screen.dart';

// // =========================================================================
// // HELPER: Normalisasi nilai trimester dari DB ke angka '1', '2', '3'
// // Mendukung semua format: 1/2/3, TM1/TM2/TM3, Trimester 1/2/3,
// // Trimester I/II/III, trimester i/ii/iii, snake_case, dsb.
// // =========================================================================
// String normalizeTrimester(String raw) {
//   final s = raw.trim().toLowerCase();

//   // Sudah angka murni
//   if (s == '1') return '1';
//   if (s == '2') return '2';
//   if (s == '3') return '3';

//   // Roman numeral saja: i, ii, iii
//   if (s == 'i') return '1';
//   if (s == 'ii') return '2';
//   if (s == 'iii') return '3';

//   // TM1 / tm1 / tm_1 / tm-1
//   if (RegExp(r'^tm[\s_\-]?1$').hasMatch(s)) return '1';
//   if (RegExp(r'^tm[\s_\-]?2$').hasMatch(s)) return '2';
//   if (RegExp(r'^tm[\s_\-]?3$').hasMatch(s)) return '3';

//   // trimester 1 / trimester_1 / trimester-1 / trimester1
//   if (RegExp(r'^trimester[\s_\-]?1$').hasMatch(s)) return '1';
//   if (RegExp(r'^trimester[\s_\-]?2$').hasMatch(s)) return '2';
//   if (RegExp(r'^trimester[\s_\-]?3$').hasMatch(s)) return '3';

//   // trimester i / trimester_i / trimester-i
//   if (RegExp(r'^trimester[\s_\-]?i$').hasMatch(s)) return '1';
//   if (RegExp(r'^trimester[\s_\-]?ii$').hasMatch(s)) return '2';
//   if (RegExp(r'^trimester[\s_\-]?iii$').hasMatch(s)) return '3';

//   // Coba ambil digit pertama yang ada di string
//   final digit = RegExp(r'[123]').firstMatch(s)?.group(0);
//   if (digit != null) return digit;

//   return s; // fallback: kembalikan apa adanya
// }

// class EdukasiTrimesterScreen extends StatefulWidget {
//   const EdukasiTrimesterScreen({super.key});

//   @override
//   State<EdukasiTrimesterScreen> createState() =>
//       _EdukasiTrimesterScreenState();
// }

// class _EdukasiTrimesterScreenState extends State<EdukasiTrimesterScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Future<List<EdukasiTrimesterModel>> _futureData;

//   // Tab index 0 = Semua, 1 = TM1, 2 = TM2, 3 = TM3
//   final _tabLabels = const [
//     'Semua',
//     'Trimester I',
//     'Trimester II',
//     'Trimester III',
//   ];

//   String _selectedKategori = 'Semua';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _futureData =
//         EdukasiTrimesterRepository(EdukasiTrimesterService()).getAll();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Filter berdasarkan tab (pakai normalizeTrimester)
//   List<EdukasiTrimesterModel> _filterByTab(
//     List<EdukasiTrimesterModel> data,
//     int tabIndex,
//   ) {
//     var filtered = tabIndex == 0
//         ? data
//         : data
//             .where((e) => normalizeTrimester(e.trimester) == '$tabIndex')
//             .toList();

//     if (_selectedKategori != 'Semua') {
//       filtered =
//           filtered.where((e) => e.kategori == _selectedKategori).toList();
//     }

//     return filtered;
//   }

//   // Ambil daftar kategori unik dari data tab aktif
//   List<String> _getKategoriList(
//     List<EdukasiTrimesterModel> data,
//     int tabIndex,
//   ) {
//     final base = tabIndex == 0
//         ? data
//         : data
//             .where((e) => normalizeTrimester(e.trimester) == '$tabIndex')
//             .toList();

//     final kategoriSet = base
//         .map((e) => e.kategori)
//         .where((k) => k.trim().isNotEmpty)
//         .toSet()
//         .toList()
//       ..sort();

//     return ['Semua', ...kategoriSet];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: FutureBuilder<List<EdukasiTrimesterModel>>(
//         future: _futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }

//           final allData = snapshot.data ?? [];

//           return NestedScrollView(
//             headerSliverBuilder: (context, _) => [
//               // ---- HEADER BIRU ----
//               SliverToBoxAdapter(
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//                   decoration: const BoxDecoration(color: Color(0xFF1F5EA8)),
//                   child: Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(
//                             Icons.arrow_back_ios_new,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Edukasi Trimester',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Panduan kesehatan selama kehamilan',
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.85),
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // ---- TAB BAR (sticky) ----
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _StickyTabBarDelegate(
//                   TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     tabAlignment: TabAlignment.start,
//                     indicatorColor: const Color(0xFF1F5EA8),
//                     indicatorWeight: 3,
//                     labelColor: const Color(0xFF1F5EA8),
//                     unselectedLabelColor: const Color(0xFF9CA3AF),
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                     unselectedLabelStyle: const TextStyle(fontSize: 13),
//                     tabs: _tabLabels
//                         .map((label) => Tab(text: label))
//                         .toList(),
//                     onTap: (_) =>
//                         setState(() => _selectedKategori = 'Semua'),
//                   ),
//                 ),
//               ),
//             ],

//             body: AnimatedBuilder(
//               animation: _tabController,
//               builder: (context, _) {
//                 final tabIndex = _tabController.index;
//                 final kategoriList = _getKategoriList(allData, tabIndex);
//                 final filtered = _filterByTab(allData, tabIndex);

//                 return Column(
//                   children: [
//                     // ---- FILTER KATEGORI ----
//                     if (kategoriList.length > 1)
//                       Container(
//                         color: Colors.white,
//                         padding:
//                             const EdgeInsets.fromLTRB(16, 10, 16, 10),
//                         child: SizedBox(
//                           height: 36,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: kategoriList.length,
//                             itemBuilder: (context, i) {
//                               final kat = kategoriList[i];
//                               final isSelected = _selectedKategori == kat;
//                               return GestureDetector(
//                                 onTap: () => setState(
//                                     () => _selectedKategori = kat),
//                                 child: Container(
//                                   margin:
//                                       const EdgeInsets.only(right: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isSelected
//                                         ? const Color(0xFF1F5EA8)
//                                         : const Color(0xFFF3F4F6),
//                                     borderRadius:
//                                         BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     kat,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: isSelected
//                                           ? Colors.white
//                                           : const Color(0xFF6B7280),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),

//                     // ---- LIST ARTIKEL ----
//                     Expanded(
//                       child: filtered.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'Belum ada edukasi tersedia',
//                                 style:
//                                     TextStyle(color: Color(0xFF9CA3AF)),
//                               ),
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.all(16),
//                               itemCount: filtered.length,
//                               itemBuilder: (context, index) =>
//                                   _ArticleCard(item: filtered[index]),
//                             ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // =========================================================================
// // ARTIKEL CARD
// // =========================================================================
// class _ArticleCard extends StatelessWidget {
//   final EdukasiTrimesterModel item;
//   const _ArticleCard({required this.item});

//   // Label tampilan dari nilai DB apapun
//   String get _trimesterLabel {
//     final n = normalizeTrimester(item.trimester);
//     if (n == '1') return 'Trimester I';
//     if (n == '2') return 'Trimester II';
//     if (n == '3') return 'Trimester III';
//     return item.trimester; // fallback
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => EdukasiTrimesterDetailScreen(item: item),
//         ),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Gambar
//             if (item.gambarUrl.trim().isNotEmpty)
//               ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(20)),
//                 child: Image.network(
//                   item.gambarUrl,
//                   width: double.infinity,
//                   height: 180,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => _placeholderImage(),
//                 ),
//               )
//             else
//               _placeholderImage(rounded: true),

//             Padding(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Badge trimester + kategori
//                   Row(
//                     children: [
//                       if (item.trimester.trim().isNotEmpty)
//                         _Badge(
//                           text: _trimesterLabel,
//                           bgColor: const Color(0xFF1F5EA8),
//                           textColor: Colors.white,
//                         ),
//                       if (item.trimester.trim().isNotEmpty &&
//                           item.kategori.trim().isNotEmpty)
//                         const SizedBox(width: 8),
//                       if (item.kategori.trim().isNotEmpty)
//                         _Badge(
//                           text: item.kategori,
//                           bgColor: const Color(0xFFE8F1FD),
//                           textColor: const Color(0xFF1F5EA8),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // Judul
//                   Text(
//                     item.judul,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF111827),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   // Isi (preview)
//                   Text(
//                     item.isi,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       height: 1.6,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),

//                   // Tombol baca selengkapnya
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Baca selengkapnya',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFF1F5EA8),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       const Icon(
//                         Icons.arrow_forward_rounded,
//                         size: 14,
//                         color: Color(0xFF1F5EA8),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _placeholderImage({bool rounded = false}) {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F1FD),
//         borderRadius: rounded
//             ? const BorderRadius.vertical(top: Radius.circular(20))
//             : null,
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.pregnant_woman_rounded,
//           size: 36,
//           color: Color(0xFF1F5EA8),
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // BADGE
// // =========================================================================
// class _Badge extends StatelessWidget {
//   final String text;
//   final Color bgColor;
//   final Color textColor;

//   const _Badge({
//     required this.text,
//     required this.bgColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // STICKY TAB BAR DELEGATE
// // =========================================================================
// class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   const _StickyTabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(color: Colors.white, child: tabBar);
//   }

//   @override
//   bool shouldRebuild(_StickyTabBarDelegate old) => false;
// }




// import 'package:flutter/material.dart';

// import 'edukasi_trimester_kategori_screen.dart';

// class EdukasiTrimesterScreen
//     extends StatelessWidget {
//   const EdukasiTrimesterScreen({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF4F7FB),

//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF1F5EA8),

//         title: const Text(
//           'Edukasi Trimester',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           children: [
//             _buildTrimesterCard(
//               context,
//               title:
//                   'Trimester 1',
//               subtitle:
//                   'Pelajari edukasi awal kehamilan',
//               trimester: 'TM1',
//               icon:
//                   Icons.looks_one_rounded,
//             ),

//             const SizedBox(height: 20),

//             _buildTrimesterCard(
//               context,
//               title:
//                   'Trimester 2',
//               subtitle:
//                   'Pelajari perkembangan trimester kedua',
//               trimester: 'TM2',
//               icon:
//                   Icons.looks_two_rounded,
//             ),

//             const SizedBox(height: 20),

//             _buildTrimesterCard(
//               context,
//               title:
//                   'Trimester 3',
//               subtitle:
//                   'Persiapan persalinan dan akhir kehamilan',
//               trimester: 'TM3',
//               icon:
//                   Icons.looks_3_rounded,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTrimesterCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required String trimester,
//     required IconData icon,
//   }) {
//     return InkWell(
//       borderRadius:
//           BorderRadius.circular(24),

//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 EdukasiTrimesterKategoriScreen(
//               trimester: trimester,
//               title: title,
//             ),
//           ),
//         );
//       },

//       child: Container(
//         width: double.infinity,

//         padding: const EdgeInsets.all(24),

//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(24),

//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(
//                 0.05,
//               ),

//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),

//         child: Row(
//           children: [
//             Container(
//               width: 70,
//               height: 70,

//               decoration: BoxDecoration(
//                 color:
//                     const Color(0xFF1F5EA8)
//                         .withOpacity(0.1),

//                 shape: BoxShape.circle,
//               ),

//               child: Icon(
//                 icon,
//                 size: 36,
//                 color:
//                     const Color(0xFF1F5EA8),
//               ),
//             ),

//             const SizedBox(width: 20),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment
//                         .start,

//                 children: [
//                   Text(
//                     title,
//                     style:
//                         const TextStyle(
//                       fontSize: 22,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Text(
//                     subtitle,
//                     style:
//                         const TextStyle(
//                       fontSize: 15,
//                       color:
//                           Color(0xFF6B7280),
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

// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';

// class EdukasiTrimesterScreen extends StatefulWidget {
//   const EdukasiTrimesterScreen({super.key});

//   @override
//   State<EdukasiTrimesterScreen> createState() =>
//       _EdukasiTrimesterScreenState();
// }

// class _EdukasiTrimesterScreenState extends State<EdukasiTrimesterScreen> {
//   late Future<List<EdukasiTrimesterModel>> futureData;

//   @override
//   void initState() {
//     super.initState();
//     final repository = EdukasiTrimesterRepository(
//       EdukasiTrimesterService(),
//     );
//     futureData = repository.getAll();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: FutureBuilder<List<EdukasiTrimesterModel>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }

//           final data = snapshot.data ?? [];

//           if (data.isEmpty) {
//             return const Center(child: Text('Data edukasi kosong'));
//           }

//           return ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final item = data[index];

//               return Column(
//                 children: [
//                   // Header hanya tampil di item pertama
//                   if (index == 0)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF1F5EA8),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(
//                                 Icons.arrow_back_ios_new,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Edukasi Trimester',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Panduan kesehatan selama kehamilan',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.85),
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                     child: Column(
//                       children: [
//                         // Card judul artikel
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(18),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1F5EA8),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.15),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.pregnant_woman_rounded,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Text(
//                                   item.judul,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // Card gambar (jika ada)
//                         if (item.gambarUrl.isNotEmpty)
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.network(
//                               item.gambarUrl,
//                               width: double.infinity,
//                               height: 200,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const SizedBox.shrink(),
//                             ),
//                           ),

//                         if (item.gambarUrl.isNotEmpty)
//                           const SizedBox(height: 16),

//                         // Card isi artikel
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Informasi',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF111827),
//                                 ),
//                               ),
//                               const SizedBox(height: 14),
//                               Text(
//                                 item.isi,
//                                 style: const TextStyle(
//                                   height: 1.7,
//                                   fontSize: 15,
//                                   color: Color(0xFF4B5563),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 24),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';

// class EdukasiTrimesterScreen extends StatefulWidget {
//   const EdukasiTrimesterScreen({super.key});

//   @override
//   State<EdukasiTrimesterScreen> createState() =>
//       _EdukasiTrimesterScreenState();
// }

// class _EdukasiTrimesterScreenState extends State<EdukasiTrimesterScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Future<List<EdukasiTrimesterModel>> _futureData;

//   final _tabs = const ['Semua', 'TM1', 'TM2', 'TM3'];
//   final _tabLabels = const ['Semua', 'Trimester I', 'Trimester II', 'Trimester III'];

//   String _selectedKategori = 'Semua';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _futureData = EdukasiTrimesterRepository(EdukasiTrimesterService()).getAll();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   List<EdukasiTrimesterModel> _filterByTab(
//     List<EdukasiTrimesterModel> data,
//     int tabIndex,
//   ) {
//     var filtered = tabIndex == 0
//         ? data
//         : data.where((e) => e.trimester == _tabs[tabIndex]).toList();

//     if (_selectedKategori != 'Semua') {
//       filtered = filtered.where((e) => e.kategori == _selectedKategori).toList();
//     }

//     return filtered;
//   }

//   List<String> _getKategoriList(List<EdukasiTrimesterModel> data, int tabIndex) {
//     final base = tabIndex == 0
//         ? data
//         : data.where((e) => e.trimester == _tabs[tabIndex]).toList();

//     final kategoriSet = base
//         .map((e) => e.kategori)
//         .where((k) => k.trim().isNotEmpty)
//         .toSet()
//         .toList()
//       ..sort();

//     return ['Semua', ...kategoriSet];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: FutureBuilder<List<EdukasiTrimesterModel>>(
//         future: _futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }

//           final allData = snapshot.data ?? [];

//           return NestedScrollView(
//             headerSliverBuilder: (context, innerBoxIsScrolled) => [
//               // ---- HEADER BIRU ----
//               SliverToBoxAdapter(
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF1F5EA8),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(
//                             Icons.arrow_back_ios_new,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Edukasi Trimester',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Panduan kesehatan selama kehamilan',
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.85),
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // ---- TAB BAR ----
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _StickyTabBarDelegate(
//                   TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     tabAlignment: TabAlignment.start,
//                     indicatorColor: const Color(0xFF1F5EA8),
//                     indicatorWeight: 3,
//                     labelColor: const Color(0xFF1F5EA8),
//                     unselectedLabelColor: const Color(0xFF9CA3AF),
//                     labelStyle: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                     unselectedLabelStyle: const TextStyle(
//                       fontSize: 13,
//                     ),
//                     tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
//                     onTap: (_) {
//                       setState(() => _selectedKategori = 'Semua');
//                     },
//                   ),
//                 ),
//               ),
//             ],

//             // ---- BODY: ANIMATEDBUILDER UNTUK TAB ----
//             body: AnimatedBuilder(
//               animation: _tabController,
//               builder: (context, _) {
//                 final tabIndex = _tabController.index;
//                 final kategoriList = _getKategoriList(allData, tabIndex);
//                 final filtered = _filterByTab(allData, tabIndex);

//                 return Column(
//                   children: [
//                     // ---- FILTER KATEGORI (jika ada lebih dari 1) ----
//                     if (kategoriList.length > 1)
//                       Container(
//                         color: Colors.white,
//                         padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//                         child: SizedBox(
//                           height: 36,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: kategoriList.length,
//                             itemBuilder: (context, i) {
//                               final kat = kategoriList[i];
//                               final isSelected = _selectedKategori == kat;
//                               return GestureDetector(
//                                 onTap: () =>
//                                     setState(() => _selectedKategori = kat),
//                                 child: Container(
//                                   margin: const EdgeInsets.only(right: 8),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isSelected
//                                         ? const Color(0xFF1F5EA8)
//                                         : const Color(0xFFF3F4F6),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     kat,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: isSelected
//                                           ? Colors.white
//                                           : const Color(0xFF6B7280),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),

//                     // ---- LIST ARTIKEL ----
//                     Expanded(
//                       child: filtered.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'Belum ada edukasi tersedia',
//                                 style: TextStyle(color: Color(0xFF9CA3AF)),
//                               ),
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.all(16),
//                               itemCount: filtered.length,
//                               itemBuilder: (context, index) {
//                                 return _ArticleCard(item: filtered[index]);
//                               },
//                             ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // =========================================================================
// // ARTIKEL CARD
// // =========================================================================
// class _ArticleCard extends StatelessWidget {
//   final EdukasiTrimesterModel item;

//   const _ArticleCard({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Gambar
//           if (item.gambarUrl.trim().isNotEmpty)
//             ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//               child: Image.network(
//                 item.gambarUrl,
//                 width: double.infinity,
//                 height: 180,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   height: 100,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE8F1FD),
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(20)),
//                   ),
//                   child: const Center(
//                     child: Icon(
//                       Icons.pregnant_woman_rounded,
//                       size: 40,
//                       color: Color(0xFF1F5EA8),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           else
//             Container(
//               height: 80,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFE8F1FD),
//                 borderRadius:
//                     BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.pregnant_woman_rounded,
//                   size: 36,
//                   color: Color(0xFF1F5EA8),
//                 ),
//               ),
//             ),

//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Badge trimester + kategori
//                 Row(
//                   children: [
//                     if (item.trimester.trim().isNotEmpty)
//                       _Badge(
//                         text: item.trimester,
//                         bgColor: const Color(0xFFE8F1FD),
//                         textColor: const Color(0xFF1F5EA8),
//                       ),
//                     if (item.trimester.trim().isNotEmpty &&
//                         item.kategori.trim().isNotEmpty)
//                       const SizedBox(width: 8),
//                     if (item.kategori.trim().isNotEmpty)
//                       _Badge(
//                         text: item.kategori,
//                         bgColor: const Color(0xFFE8F1FD),
//                         textColor: const Color(0xFF1F5EA8),
//                       ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Judul
//                 Text(
//                   item.judul,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF111827),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Isi (preview 3 baris)
//                 Text(
//                   item.isi,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     height: 1.6,
//                     color: Color(0xFF6B7280),
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

// // =========================================================================
// // BADGE WIDGET
// // =========================================================================
// class _Badge extends StatelessWidget {
//   final String text;
//   final Color bgColor;
//   final Color textColor;

//   const _Badge({
//     required this.text,
//     required this.bgColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // STICKY TAB BAR DELEGATE
// // =========================================================================
// class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;

//   const _StickyTabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;

//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Colors.white,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
// }

import 'package:flutter/material.dart';

import '../../data/models/edukasi_trimester_model.dart';
import '../../data/repositories/edukasi_trimester_repository.dart';
import '../../data/services/edukasi_trimester_service.dart';
import 'edukasi_trimester_detail_screen.dart';

// =========================================================================
// HELPER: Normalisasi nilai trimester dari DB ke angka '1', '2', '3'
// Mendukung semua format: 1/2/3, TM1/TM2/TM3, Trimester 1/2/3,
// Trimester I/II/III, trimester i/ii/iii, snake_case, dsb.
// =========================================================================
String normalizeTrimester(String raw) {
  final s = raw.trim().toLowerCase();

  // Sudah angka murni
  if (s == '1') return '1';
  if (s == '2') return '2';
  if (s == '3') return '3';

  // Roman numeral saja: i, ii, iii
  if (s == 'i') return '1';
  if (s == 'ii') return '2';
  if (s == 'iii') return '3';

  // TM1 / tm1 / tm_1 / tm-1
  if (RegExp(r'^tm[\s_\-]?1$').hasMatch(s)) return '1';
  if (RegExp(r'^tm[\s_\-]?2$').hasMatch(s)) return '2';
  if (RegExp(r'^tm[\s_\-]?3$').hasMatch(s)) return '3';

  // trimester 1 / trimester_1 / trimester-1 / trimester1
  if (RegExp(r'^trimester[\s_\-]?1$').hasMatch(s)) return '1';
  if (RegExp(r'^trimester[\s_\-]?2$').hasMatch(s)) return '2';
  if (RegExp(r'^trimester[\s_\-]?3$').hasMatch(s)) return '3';

  // trimester i / trimester_i / trimester-i
  if (RegExp(r'^trimester[\s_\-]?i$').hasMatch(s)) return '1';
  if (RegExp(r'^trimester[\s_\-]?ii$').hasMatch(s)) return '2';
  if (RegExp(r'^trimester[\s_\-]?iii$').hasMatch(s)) return '3';

  // Coba ambil digit pertama yang ada di string
  final digit = RegExp(r'[123]').firstMatch(s)?.group(0);
  if (digit != null) return digit;

  return s; // fallback: kembalikan apa adanya
}

class EdukasiTrimesterScreen extends StatefulWidget {
  const EdukasiTrimesterScreen({super.key});

  @override
  State<EdukasiTrimesterScreen> createState() =>
      _EdukasiTrimesterScreenState();
}

class _EdukasiTrimesterScreenState extends State<EdukasiTrimesterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<EdukasiTrimesterModel>> _futureData;

  // Tab index 0 = Semua, 1 = TM1, 2 = TM2, 3 = TM3
  final _tabLabels = const [
    'Semua',
    'Trimester I',
    'Trimester II',
    'Trimester III',
  ];

  String _selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _futureData =
        EdukasiTrimesterRepository(EdukasiTrimesterService()).getAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter berdasarkan tab (pakai normalizeTrimester)
  List<EdukasiTrimesterModel> _filterByTab(
    List<EdukasiTrimesterModel> data,
    int tabIndex,
  ) {
    var filtered = tabIndex == 0
        ? data
        : data
            .where((e) => normalizeTrimester(e.trimester) == '$tabIndex')
            .toList();

    if (_selectedKategori != 'Semua') {
      filtered =
          filtered.where((e) => e.kategori == _selectedKategori).toList();
    }

    return filtered;
  }

  // Ambil daftar kategori unik dari data tab aktif
  List<String> _getKategoriList(
    List<EdukasiTrimesterModel> data,
    int tabIndex,
  ) {
    final base = tabIndex == 0
        ? data
        : data
            .where((e) => normalizeTrimester(e.trimester) == '$tabIndex')
            .toList();

    final kategoriSet = base
        .map((e) => e.kategori)
        .where((k) => k.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Semua', ...kategoriSet];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: FutureBuilder<List<EdukasiTrimesterModel>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final allData = snapshot.data ?? [];

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              // ---- HEADER BIRU ----
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  decoration: const BoxDecoration(color: Color(0xFF1F5EA8)),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edukasi Trimester',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Panduan kesehatan selama kehamilan',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- TAB BAR (sticky) ----
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: const Color(0xFF1F5EA8),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF1F5EA8),
                    unselectedLabelColor: const Color(0xFF9CA3AF),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    tabs: _tabLabels
                        .map((label) => Tab(text: label))
                        .toList(),
                    onTap: (_) =>
                        setState(() => _selectedKategori = 'Semua'),
                  ),
                ),
              ),
            ],

            body: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                final tabIndex = _tabController.index;
                final kategoriList = _getKategoriList(allData, tabIndex);
                final filtered = _filterByTab(allData, tabIndex);

                return Column(
                  children: [
                    // ---- FILTER KATEGORI ----
                    if (kategoriList.length > 1)
                      Container(
                        color: Colors.white,
                        padding:
                            const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: kategoriList.length,
                            itemBuilder: (context, i) {
                              final kat = kategoriList[i];
                              final isSelected = _selectedKategori == kat;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _selectedKategori = kat),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1F5EA8)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    kat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // ---- LIST ARTIKEL ----
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada edukasi tersedia',
                                style:
                                    TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  _ArticleCard(item: filtered[index]),
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// ARTIKEL CARD
// =========================================================================
class _ArticleCard extends StatelessWidget {
  final EdukasiTrimesterModel item;
  const _ArticleCard({required this.item});

  // Label tampilan dari nilai DB apapun
  String get _trimesterLabel {
    final n = normalizeTrimester(item.trimester);
    if (n == '1') return 'Trimester I';
    if (n == '2') return 'Trimester II';
    if (n == '3') return 'Trimester III';
    return item.trimester; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiTrimesterDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            if (item.gambarUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.gambarUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              )
            else
              _placeholderImage(rounded: true),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge trimester + kategori
                  Row(
                    children: [
                      if (item.trimester.trim().isNotEmpty)
                        _Badge(
                          text: _trimesterLabel,
                          bgColor: const Color(0xFFE8F1FD),
                          textColor: const Color(0xFF1F5EA8),
                        ),
                      if (item.trimester.trim().isNotEmpty &&
                          item.kategori.trim().isNotEmpty)
                        const SizedBox(width: 8),
                      if (item.kategori.trim().isNotEmpty)
                        _Badge(
                          text: item.kategori,
                          bgColor: const Color(0xFFE8F1FD),
                          textColor: const Color(0xFF1F5EA8),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Isi (preview)
                  Text(
                    item.isi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  // Tombol baca selengkapnya
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F5EA8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1F5EA8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage({bool rounded = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: const Center(
        child: Icon(
          Icons.pregnant_woman_rounded,
          size: 36,
          color: Color(0xFF1F5EA8),
        ),
      ),
    );
  }
}

// =========================================================================
// BADGE
// =========================================================================
class _Badge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// =========================================================================
// STICKY TAB BAR DELEGATE
// =========================================================================
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => false;
}