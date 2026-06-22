// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/services/informasi_umum_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_pola_asuh_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_perawatan_anak_api_service.dart';

// // Import file tujuan (diperbaiki path-nya memakai ../ karena keluar dari folder screens)
// import '../anak/detail_konten_edukasi_anak_screen.dart';
// import '../ibu/edukasi_asi_screen.dart';
// import '../ibu/edukasi_imd_screen.dart';
// import '../ibu/edukasi_mental_screen.dart';
// import '../ibu/edukasi_nifas_screen.dart';
// import '../ibu/edukasi_tanda_melahirkan_screen.dart';
// import '../ibu/edukasi_trimester_screen.dart';

// // =========================================================================
// // PEWARNAAN PER KATEGORI (DARI IBU)
// // =========================================================================
// class _KategoriStyle {
//   final Color background;
//   final Color accent;
//   const _KategoriStyle(this.background, this.accent);
// }

// _KategoriStyle _getKategoriStyle(String category) {
//   switch (category) {
//     case 'Trimester':
//       return const _KategoriStyle(AppColors.blue100, AppColors.blue500);
//     case 'Menyusui':
//       return const _KategoriStyle(AppColors.pinkLight, AppColors.pink);
//     case 'Kesehatan Mental':
//       return const _KategoriStyle(AppColors.tealLight, AppColors.teal);
//     case 'Nifas':
//       return const _KategoriStyle(AppColors.purpleLight, AppColors.purple);
//     case 'Persalinan':
//       return const _KategoriStyle(AppColors.amberLight, AppColors.amber);
//     default:
//       return const _KategoriStyle(AppColors.purpleLight, AppColors.primary);
//   }
// }

// // =========================================================================
// // HALAMAN UTAMA EDUKASI GABUNGAN
// // =========================================================================
// class EdukasiScreenAll extends StatefulWidget {
//   const EdukasiScreenAll({super.key});

//   @override
//   State<EdukasiScreenAll> createState() => _EdukasiScreenAllState();
// }

// class _EdukasiScreenAllState extends State<EdukasiScreenAll> {
//   // Services untuk Anak
//   final InformasiUmumApiService _infoUmumService = InformasiUmumApiService();
//   final EdukasiPolaAsuhApiService _polaAsuhService = EdukasiPolaAsuhApiService();
//   final EdukasiPerawatanAnakApiService _perawatanService =
//       EdukasiPerawatanAnakApiService();

//   String selectedCategory = 'Semua';
//   String searchQuery = '';

//   bool _isLoading = true;
//   String? _errorMessage;
  
//   // List gabungan Ibu & Anak
//   List<Map<String, dynamic>> _allItems = [];

//   // Data statis untuk Ibu
//   final List<Map<String, dynamic>> _ibuItems = [
//     {
//       'type': 'ibu',
//       'title': 'Edukasi Trimester',
//       'desc': 'Panduan kesehatan ibu di setiap trimester kehamilan',
//       'icon': Icons.pregnant_woman_rounded,
//       'category': 'Trimester',
//       'group': 'Ibu',
//       'screen': const EdukasiTrimesterScreen(),
//     },
//     {
//       'type': 'ibu',
//       'title': 'Inisiasi Menyusu Dini (IMD)',
//       'desc': 'Cara memulai menyusui sesaat setelah bayi lahir',
//       'icon': Icons.child_care_rounded,
//       'category': 'Menyusui',
//       'group': 'Ibu',
//       'screen': const EdukasiIMDScreen(),
//     },
//     {
//       'type': 'ibu',
//       'title': 'Edukasi Menyusui ASI Eksklusif',
//       'desc': 'Manfaat dan tips memberikan ASI selama 6 bulan penuh',
//       'icon': Icons.volunteer_activism_rounded,
//       'category': 'Menyusui',
//       'group': 'Ibu',
//       'screen': const EdukasiASIScreen(),
//     },
//     {
//       'type': 'ibu',
//       'title': 'Kesehatan Mental Ibu Hamil',
//       'desc': 'Mengenali dan menjaga kondisi emosi selama hamil',
//       'icon': Icons.psychology_rounded,
//       'category': 'Kesehatan Mental',
//       'group': 'Ibu',
//       'screen': const EdukasiKesehatanMentalScreen(),
//     },
//     {
//       'type': 'ibu',
//       'title': 'Edukasi Perawatan Masa Nifas',
//       'desc': 'Tips merawat diri dan pemulihan setelah melahirkan',
//       'icon': Icons.favorite_rounded,
//       'category': 'Nifas',
//       'group': 'Ibu',
//       'screen': const EdukasiNifasScreen(),
//     },
//     {
//       'type': 'ibu',
//       'title': 'Edukasi Tanda Melahirkan',
//       'desc': 'Kenali tanda-tanda menjelang persalinan',
//       'icon': Icons.medical_information_rounded,
//       'category': 'Persalinan',
//       'group': 'Ibu',
//       'screen': const EdukasiTandaMelahirkanScreen(),
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadAllData();
//   }

//   @override
//   void dispose() {
//     _infoUmumService.dispose();
//     _polaAsuhService.dispose();
//     _perawatanService.dispose();
//     super.dispose();
//   }

//   // Future<void> _loadAllData() async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _errorMessage = null;
//   //   });

//   //   final anakItems = <Map<String, dynamic>>[];
//   //   final errors = <String>[];

//   //   // 1. Informasi Umum (Anak)
//   //   try {
//   //     final informasiUmumList = await _infoUmumService.listInformasiUmum();
//   //     for (final item in informasiUmumList) {
//   //       anakItems.add({
//   //         'type': 'anak',
//   //         'item': EdukasiAnakItem(
//   //           id: item.id,
//   //           judul: item.judul,
//   //           kategori: 'Informasi Umum',
//   //           tipe: item.tipe.isNotEmpty ? item.tipe : 'ARTIKEL',
//   //           ringkasan: item.ringkasan,
//   //           konten: item.konten,
//   //           yangPerluDiingat: item.yangPerluDiingat,
//   //           umurTarget: item.umurTarget,
//   //           durasiBaca: item.durasiBaca,
//   //           thumbnailUrl: item.thumbnailUrl,
//   //         ),
//   //         'group': 'Anak',
//   //         'category': 'Informasi Umum',
//   //       });
//   //     }
//   //   } catch (e) {
//   //     errors.add('Informasi Umum');
//   //   }

//   //   // 2. Pola Asuh (Anak)
//   //   try {
//   //     final polaAsuhList = await _polaAsuhService.listPolaAsuh();
//   //     for (final item in polaAsuhList) {
//   //       anakItems.add({
//   //         'type': 'anak',
//   //         'item': EdukasiAnakItem(
//   //           id: item.id,
//   //           judul: item.judul,
//   //           kategori: 'Pola Asuh',
//   //           tipe: 'ARTIKEL',
//   //           konten: item.isi,
//   //           thumbnailUrl: item.gambarUrl,
//   //         ),
//   //         'group': 'Anak',
//   //         'category': 'Pola Asuh',
//   //       });
//   //     }
//   //   } catch (e) {
//   //     errors.add('Pola Asuh');
//   //   }

//   //   // 3. Perawatan Anak (Anak)
//   //   try {
//   //     final perawatanList = await _perawatanService.listPerawatanAnak();
//   //     for (final item in perawatanList) {
//   //       anakItems.add({
//   //         'type': 'anak',
//   //         'item': EdukasiAnakItem(
//   //           id: item.id,
//   //           judul: item.judul,
//   //           kategori: 'Perawatan',
//   //           tipe: 'ARTIKEL',
//   //           konten: item.isiKonten,
//   //           thumbnailUrl: item.gambarUrl,
//   //         ),
//   //         'group': 'Anak',
//   //         'category': 'Perawatan',
//   //       });
//   //     }
//   //   } catch (e) {
//   //     errors.add('Perawatan');
//   //   }

//   //   if (!mounted) return;

//   //   setState(() {
//   //     _allItems = [..._ibuItems, ...anakItems];
//   //     _isLoading = false;
//   //     if (errors.length == 3) {
//   //       _errorMessage = 'Gagal memuat data edukasi Anak. Cek koneksi internet Anda.';
//   //     }
//   //   });
//   // }

//     Future<void> _loadAllData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final anakItems = <Map<String, dynamic>>[];
//     final errors = <String>[];

//     // 1. Informasi Umum (Anak)
//     try {
//       final informasiUmumList = await _infoUmumService.listInformasiUmum();
//       for (final item in informasiUmumList) {
//         anakItems.add({
//           'type': 'anak',
//           'item': EdukasiAnakItem(
//             id: item.id,
//             judul: item.judul,
//             kategori: 'Informasi Umum',
//             tipe: item.tipe.isNotEmpty ? item.tipe : 'ARTIKEL',
//             ringkasan: item.ringkasan,
//             konten: item.konten,
//             yangPerluDiingat: item.yangPerluDiingat,
//             umurTarget: item.umurTarget,
//             durasiBaca: item.durasiBaca,
//             thumbnailUrl: item.thumbnailUrl,
//           ),
//           'group': 'Anak',
//           'category': 'Informasi Umum',
//         });
//       }
//     } catch (e) {
//       debugPrint('[EdukasiAnak] Gagal memuat Informasi Umum: $e');
//       errors.add('Informasi Umum');
//     }

//     // 2. Pola Asuh (Anak)
//     try {
//       final polaAsuhList = await _polaAsuhService.listPolaAsuh();
//       for (final item in polaAsuhList) {
//         anakItems.add({
//           'type': 'anak',
//           'item': EdukasiAnakItem(
//             id: item.id,
//             judul: item.judul,
//             kategori: 'Pola Asuh',
//             tipe: 'ARTIKEL',
//             konten: item.isi,
//             thumbnailUrl: item.gambarUrl,
//           ),
//           'group': 'Anak',
//           'category': 'Pola Asuh',
//         });
//       }
//     } catch (e) {
//       debugPrint('[EdukasiAnak] Gagal memuat Pola Asuh: $e');
//       errors.add('Pola Asuh');
//     }

//     // 3. Perawatan Anak (Anak)
//     try {
//       final perawatanList = await _perawatanService.listPerawatanAnak();
//       for (final item in perawatanList) {
//         anakItems.add({
//           'type': 'anak',
//           'item': EdukasiAnakItem(
//             id: item.id,
//             judul: item.judul,
//             kategori: 'Perawatan',
//             tipe: 'ARTIKEL',
//             konten: item.isiKonten,
//             thumbnailUrl: item.gambarUrl,
//           ),
//           'group': 'Anak',
//           'category': 'Perawatan',
//         });
//       }
//     } catch (e) {
//       debugPrint('[EdukasiAnak] Gagal memuat Perawatan: $e');
//       errors.add('Perawatan');
//     }

//     if (!mounted) return;

//     setState(() {
//       _allItems = [..._ibuItems, ...anakItems];
//       _isLoading = false;
      
//       debugPrint('=== DATA EDUKASI ===');
//       debugPrint('Total Data Ibu: ${_ibuItems.length}');
//       debugPrint('Total Data Anak (Berhasil di-fetch): ${anakItems.length}');
//       debugPrint('Total Gabungan: ${_allItems.length}');
//       debugPrint('====================');

//       if (errors.length == 3) {
//         _errorMessage = 'Gagal memuat semua data edukasi Anak. Cek koneksi internet Anda.';
//       }
//     });
//   }

//   List<Map<String, dynamic>> get _filteredItems {
//     return _allItems.where((item) {
//       final group = item['group'] as String;
//       final category = item['category'] as String;

//       final title = item['type'] == 'ibu'
//           ? item['title'] as String
//           : (item['item'] as EdukasiAnakItem).judul;
      
//       final desc = item['type'] == 'ibu'
//           ? item['desc'] as String
//           : (item['item'] as EdukasiAnakItem).ringkasan;

//       bool matchCategory = true;
//       if (selectedCategory == 'Ibu') {
//         matchCategory = group == 'Ibu';
//       } else if (selectedCategory == 'Anak') {
//         matchCategory = group == 'Anak';
//       } else if (selectedCategory != 'Semua') {
//         matchCategory = category == selectedCategory;
//       }

//       final matchSearch = searchQuery.isEmpty ||
//           title.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           desc.toLowerCase().contains(searchQuery.toLowerCase());

//       return matchCategory && matchSearch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4FA),
//       body: Column(
//         children: [
//           // Header
//           Container(
//             width: double.infinity,
//             color: AppColors.primary,
//             child: SafeArea(
//               bottom: false,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.15),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(
//                         Icons.menu_book_rounded,
//                         color: Colors.white,
//                         size: 22,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Edukasi',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         Text(
//                           'Informasi kesehatan ibu & anak',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Search & Filter
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             child: _buildSearchFilter(),
//           ),

//           const SizedBox(height: 8),

//           // Content List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
//                 : _errorMessage != null
//                     ? _buildErrorState()
//                     : RefreshIndicator(
//                         onRefresh: _loadAllData,
//                         color: AppColors.primary,
//                         child: _filteredItems.isEmpty
//                             ? _buildEmptyState()
//                             : ListView.builder(
//                                 padding: const EdgeInsets.all(16),
//                                 itemCount: _filteredItems.length,
//                                 itemBuilder: (context, index) {
//                                   final item = _filteredItems[index];
//                                   if (item['type'] == 'ibu') {
//                                     return _EdukasiIbuCard(
//                                       title: item['title'],
//                                       desc: item['desc'],
//                                       icon: item['icon'],
//                                       category: item['category'],
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => item['screen'],
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   } else {
//                                     final anakItem = item['item'] as EdukasiAnakItem;
//                                     return _EdukasiAnakCard(
//                                       item: anakItem,
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 DetailKontenEdukasiAnakScreen(item: anakItem),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   }
//                                 },
//                               ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================================================================
//   // WIDGETS UI
//   // =========================================================================
//   Widget _buildSearchFilter() {
//     final categories = [
//       'Semua', 'Ibu', 'Anak', 'Trimester', 'Menyusui', 'Kesehatan Mental', 
//       'Nifas', 'Persalinan', 'Informasi Umum', 'Pola Asuh', 'Perawatan'
//     ];

//     return Column(
//       children: [
//         Container(
//           height: 52,
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: AppColors.border),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.black.withValues(alpha: 0.03),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TextField(
//             onChanged: (val) => setState(() => searchQuery = val),
//             style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
//             decoration: const InputDecoration(
//               hintText: 'Cari edukasi disini...',
//               hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
//               prefixIcon: Icon(Icons.search, color: AppColors.textHint),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.symmetric(vertical: 14),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 44,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               final isSelected = selectedCategory == category;
//               return Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: Material(
//                   color: isSelected ? AppColors.primary : AppColors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   child: InkWell(
//                     onTap: () => setState(() => selectedCategory = category),
//                     borderRadius: BorderRadius.circular(30),
//                     splashColor: AppColors.primary.withValues(alpha: 0.15),
//                     highlightColor: AppColors.primary.withValues(alpha: 0.08),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(
//                           color: isSelected ? AppColors.primary : AppColors.border,
//                         ),
//                       ),
//                       child: Text(
//                         category,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected ? AppColors.white : AppColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFFEE2E2),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
//             ),
//             const SizedBox(height: 20),
//             const Text('Gagal memuat sebagian data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
//             const SizedBox(height: 8),
//             Text(_errorMessage ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _loadAllData,
//               icon: const Icon(Icons.refresh, size: 18),
//               label: const Text('Coba Lagi'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text('Edukasi tidak ditemukan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
//           const SizedBox(height: 8),
//           Text('Coba ubah filter atau kata kunci pencarian', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
//         ],
//       ),
//     );
//   }
// }

// // =========================================================================
// // KARTU EDUKASI IBU
// // =========================================================================
// class _EdukasiIbuCard extends StatelessWidget {
//   final String title;
//   final String desc;
//   final IconData icon;
//   final String category;
//   final VoidCallback onTap;

//   const _EdukasiIbuCard({
//     required this.title,
//     required this.desc,
//     required this.icon,
//     required this.category,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final style = _getKategoriStyle(category);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: AppColors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           splashColor: style.accent.withValues(alpha: 0.15),
//           highlightColor: style.accent.withValues(alpha: 0.08),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     height: 110,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: style.background,
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                     ),
//                     child: Center(child: Icon(icon, size: 42, color: style.accent)),
//                   ),
//                   Positioned(
//                     top: 12,
//                     left: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: AppColors.white.withValues(alpha: 0.9),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         category,
//                         style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: style.accent),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
//                     const SizedBox(height: 4),
//                     Text(desc, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // KARTU EDUKASI ANAK
// // =========================================================================
// class _EdukasiAnakCard extends StatelessWidget {
//   final EdukasiAnakItem item;
//   final VoidCallback onTap;

//   const _EdukasiAnakCard({required this.item, required this.onTap});

//   String? _resolveImageUrl(String url) {
//     final trimmed = url.trim();
//     if (trimmed.isEmpty) return null;
//     if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
//     if (trimmed.startsWith('/')) return '${ApiConstants.baseUrl}$trimmed';
//     return '${ApiConstants.baseUrl}/$trimmed';
//   }

//   Widget _buildFallbackIcon() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFDDEEFF),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
//             ],
//           ),
//           child: Icon(
//             item.isVideo ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
//             size: 32,
//             color: AppColors.primary,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = _resolveImageUrl(item.thumbnailUrl);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 120,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFDDEEFF),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//               ),
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     if (imageUrl != null)
//                       Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => _buildFallbackIcon(),
//                       )
//                     else
//                       _buildFallbackIcon(),
//                     const DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [Color(0x22000000), Color(0x00000000)],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 12,
//                       left: 12,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           item.displayTipe,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.judul,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       height: 1.4,
//                       color: Color(0xFF1E293B),
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
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


import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/informasi_umum_api_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_pola_asuh_api_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_perawatan_anak_api_service.dart';

// Import screen tujuan
import '../anak/detail_konten_edukasi_anak_screen.dart';
import '../anak/list_konten_edukasi_anak_screen.dart';
import '../ibu/edukasi_asi_screen.dart';
import '../ibu/edukasi_imd_screen.dart';
import '../ibu/edukasi_mental_screen.dart';
import '../ibu/edukasi_nifas_screen.dart';
import '../ibu/edukasi_tanda_melahirkan_screen.dart';
import '../ibu/edukasi_trimester_screen.dart';

// =========================================================================
// PEWARNAAN PER KATEGORI (IBU & ANAK)
// =========================================================================
class _KategoriStyle {
  final Color background;
  final Color accent;
  const _KategoriStyle(this.background, this.accent);
}

_KategoriStyle _getKategoriStyle(String category) {
  switch (category) {
    // --- Kategori Ibu ---
    case 'Trimester':
      return const _KategoriStyle(AppColors.blue100, AppColors.blue500);
    case 'Menyusui':
      return const _KategoriStyle(AppColors.pinkLight, AppColors.pink);
    case 'Kesehatan Mental':
      return const _KategoriStyle(AppColors.tealLight, AppColors.teal);
    case 'Nifas':
      return const _KategoriStyle(AppColors.purpleLight, AppColors.purple);
    case 'Persalinan':
      return const _KategoriStyle(AppColors.amberLight, AppColors.amber);
    // --- Kategori Anak ---
    case 'Informasi Umum':
      return const _KategoriStyle(Color(0xFFDBEAFE), Color(0xFF3B82F6));
    case 'Pola Asuh':
      return const _KategoriStyle(Color(0xFFFEF3C7), Color(0xFFD97706));
    case 'Perawatan':
      return const _KategoriStyle(Color(0xFFD1FAE5), Color(0xFF059669));
    default:
      return const _KategoriStyle(AppColors.purpleLight, AppColors.primary);
  }
}

// =========================================================================
// HALAMAN UTAMA EDUKASI GABUNGAN
// =========================================================================
class EdukasiScreenAll extends StatefulWidget {
  const EdukasiScreenAll({super.key});

  @override
  State<EdukasiScreenAll> createState() => _EdukasiScreenAllState();
}

class _EdukasiScreenAllState extends State<EdukasiScreenAll> {
  // Services untuk fetch data anak
  final InformasiUmumApiService _infoUmumService = InformasiUmumApiService();
  final EdukasiPolaAsuhApiService _polaAsuhService = EdukasiPolaAsuhApiService();
  final EdukasiPerawatanAnakApiService _perawatanService = EdukasiPerawatanAnakApiService();

  String searchQuery = '';

  bool _isLoading = true;
  String? _errorMessage;

  // List gabungan: kartu kategori Ibu + kartu kategori Anak
  List<Map<String, dynamic>> _allItems = [];

  // Data anak yang sudah difetch, dikelompokkan per kategori
  Map<String, List<EdukasiAnakItem>> _anakItemsByCategory = {};

  // =========================================================================
  // DATA STATIS: KARTU KATEGORI IBU
  // =========================================================================
  final List<Map<String, dynamic>> _ibuItems = [
    {
      'type': 'ibu',
      'title': 'Edukasi Trimester',
      'desc': 'Panduan kesehatan ibu di setiap trimester kehamilan',
      'icon': Icons.pregnant_woman_rounded,
      'category': 'Trimester',
      'group': 'Ibu',
      'screen': const EdukasiTrimesterScreen(),
    },
    {
      'type': 'ibu',
      'title': 'Inisiasi Menyusu Dini (IMD)',
      'desc': 'Cara memulai menyusui sesaat setelah bayi lahir',
      'icon': Icons.child_care_rounded,
      'category': 'Menyusui',
      'group': 'Ibu',
      'screen': const EdukasiIMDScreen(),
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Menyusui ASI Eksklusif',
      'desc': 'Manfaat dan tips memberikan ASI selama 6 bulan penuh',
      'icon': Icons.volunteer_activism_rounded,
      'category': 'Menyusui',
      'group': 'Ibu',
      'screen': const EdukasiASIScreen(),
    },
    {
      'type': 'ibu',
      'title': 'Kesehatan Mental Ibu Hamil',
      'desc': 'Mengenali dan menjaga kondisi emosi selama hamil',
      'icon': Icons.psychology_rounded,
      'category': 'Kesehatan Mental',
      'group': 'Ibu',
      'screen': const EdukasiKesehatanMentalScreen(),
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Perawatan Masa Nifas',
      'desc': 'Tips merawat diri dan pemulihan setelah melahirkan',
      'icon': Icons.favorite_rounded,
      'category': 'Nifas',
      'group': 'Ibu',
      'screen': const EdukasiNifasScreen(),
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Tanda Melahirkan',
      'desc': 'Kenali tanda-tanda menjelang persalinan',
      'icon': Icons.medical_information_rounded,
      'category': 'Persalinan',
      'group': 'Ibu',
      'screen': const EdukasiTandaMelahirkanScreen(),
    },
  ];

  // =========================================================================
  // DATA STATIS: KARTU KATEGORI ANAK
  // =========================================================================
  final List<Map<String, dynamic>> _anakCategoryCards = [
    {
      'type': 'anak_category',
      'title': 'Informasi Umum',
      'desc': 'Panduan kesehatan dan pertumbuhan anak',
      'icon': Icons.info_outline_rounded,
      'category': 'Informasi Umum',
      'group': 'Anak',
      'apiKey': 'informasi_umum',
    },
    {
      'type': 'anak_category',
      'title': 'Pola Asuh',
      'desc': 'Tips parenting dan pola asuh yang baik',
      'icon': Icons.family_restroom_rounded,
      'category': 'Pola Asuh',
      'group': 'Anak',
      'apiKey': 'pola_asuh',
    },
    {
      'type': 'anak_category',
      'title': 'Perawatan Anak',
      'desc': 'Panduan merawat kesehatan anak sehari-hari',
      'icon': Icons.healing_rounded,
      'category': 'Perawatan',
      'group': 'Anak',
      'apiKey': 'perawatan',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _infoUmumService.dispose();
    _polaAsuhService.dispose();
    _perawatanService.dispose();
    super.dispose();
  }

  // =========================================================================
  // LOAD DATA: Fetch artikel anak dari API, simpan per kategori
  // =========================================================================
  // Future<void> _loadAllData() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   final tempItemsByCategory = <String, List<EdukasiAnakItem>>{};
  //   final errors = <String>[];

  //   // 1. Informasi Umum (Anak)
  //   try {
  //     final list = await _infoUmumService.listInformasiUmum();
  //     tempItemsByCategory['informasi_umum'] = list
  //         .map((item) => EdukasiAnakItem(
  //               id: item.id,
  //               judul: item.judul,
  //               kategori: 'Informasi Umum',
  //               tipe: item.tipe.isNotEmpty ? item.tipe : 'ARTIKEL',
  //               ringkasan: item.ringkasan,
  //               konten: item.konten,
  //               yangPerluDiingat: item.yangPerluDiingat,
  //               umurTarget: item.umurTarget,
  //               durasiBaca: item.durasiBaca,
  //               thumbnailUrl: item.thumbnailUrl,
  //             ))
  //         .toList();
  //   } catch (e) {
  //     debugPrint('[EdukasiAnak] Gagal memuat Informasi Umum: $e');
  //     errors.add('Informasi Umum');
  //   }

  //   // 2. Pola Asuh (Anak)
  //   try {
  //     final list = await _polaAsuhService.listPolaAsuh();
  //     tempItemsByCategory['pola_asuh'] = list
  //         .map((item) => EdukasiAnakItem(
  //               id: item.id,
  //               judul: item.judul,
  //               kategori: 'Pola Asuh',
  //               tipe: 'ARTIKEL',
  //               konten: item.isi,
  //               thumbnailUrl: item.gambarUrl,
  //             ))
  //         .toList();
  //   } catch (e) {
  //     debugPrint('[EdukasiAnak] Gagal memuat Pola Asuh: $e');
  //     errors.add('Pola Asuh');
  //   }

  //   // 3. Perawatan Anak (Anak)
  //   try {
  //     final list = await _perawatanService.listPerawatanAnak();
  //     tempItemsByCategory['perawatan'] = list
  //         .map((item) => EdukasiAnakItem(
  //               id: item.id,
  //               judul: item.judul,
  //               kategori: 'Perawatan',
  //               tipe: 'ARTIKEL',
  //               konten: item.isiKonten,
  //               thumbnailUrl: item.gambarUrl,
  //             ))
  //         .toList();
  //   } catch (e) {
  //     debugPrint('[EdukasiAnak] Gagal memuat Perawatan: $e');
  //     errors.add('Perawatan');
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     // Simpan data artikel anak per kategori
  //     _anakItemsByCategory = tempItemsByCategory;

  //     // Gabungkan: kartu kategori ibu + kartu kategori anak
  //     _allItems = [..._ibuItems, ..._anakCategoryCards];
  //     _isLoading = false;

  //     debugPrint('=== DATA EDUKASI ===');
  //     debugPrint('Kartu Kategori Ibu: ${_ibuItems.length}');
  //     debugPrint('Kartu Kategori Anak: ${_anakCategoryCards.length}');
  //     debugPrint('Artikel Anak (Informasi Umum): ${tempItemsByCategory['informasi_umum']?.length ?? 0}');
  //     debugPrint('Artikel Anak (Pola Asuh): ${tempItemsByCategory['pola_asuh']?.length ?? 0}');
  //     debugPrint('Artikel Anak (Perawatan): ${tempItemsByCategory['perawatan']?.length ?? 0}');
  //     debugPrint('====================');

  //     if (errors.length == 3) {
  //       _errorMessage = 'Gagal memuat semua data edukasi Anak. Cek koneksi internet Anda.';
  //     }
  //   });
  // }

    Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tempItemsByCategory = <String, List<EdukasiAnakItem>>{};
    final errors = <String>[];

    // 1. Informasi Umum (Anak)
    try {
      final list = await _infoUmumService.listInformasiUmum();
      tempItemsByCategory['informasi_umum'] = list
          .map((item) => EdukasiAnakItem(
                id: item.id,
                judul: item.judul ?? 'Tanpa Judul',
                kategori: 'Informasi Umum',
                // Null-safe: cek apakah null atau kosong
                tipe: (item.tipe?.isNotEmpty ?? false) ? item.tipe! : 'ARTIKEL',
                ringkasan: item.ringkasan ?? '',
                konten: item.konten ?? '',
                yangPerluDiingat: item.yangPerluDiingat ?? '',
                umurTarget: item.umurTarget ?? '',
                durasiBaca: item.durasiBaca ?? '',
                thumbnailUrl: item.thumbnailUrl ?? '',
              ))
          .toList();
    } catch (e, stack) {
      debugPrint('[EdukasiAnak] Gagal memuat Informasi Umum: $e');
      debugPrint('Stack: $stack'); // Tambahkan ini biar kelihatan error sebenarnya
      errors.add('Informasi Umum');
    }

    // 2. Pola Asuh (Anak)
    try {
      final list = await _polaAsuhService.listPolaAsuh();
      tempItemsByCategory['pola_asuh'] = list
          .map((item) => EdukasiAnakItem(
                id: item.id,
                judul: item.judul ?? 'Tanpa Judul',
                kategori: 'Pola Asuh',
                tipe: 'ARTIKEL',
                ringkasan: item.isi ?? '', // Null-safe, dipakai utk cuplikan isi di card
                konten: item.isi ?? '', // Null-safe
                thumbnailUrl: item.gambarUrl ?? '', // Null-safe
              ))
          .toList();
    } catch (e, stack) {
      debugPrint('[EdukasiAnak] Gagal memuat Pola Asuh: $e');
      debugPrint('Stack: $stack');
      errors.add('Pola Asuh');
    }

    // 3. Perawatan Anak (Anak)
    try {
      final list = await _perawatanService.listPerawatanAnak();
      tempItemsByCategory['perawatan'] = list
          .map((item) => EdukasiAnakItem(
                id: item.id,
                judul: item.judul ?? 'Tanpa Judul',
                kategori: 'Perawatan',
                tipe: 'ARTIKEL',
                ringkasan: item.isiKonten ?? '', // Null-safe, dipakai utk cuplikan isi di card
                konten: item.isiKonten ?? '', // Null-safe
                thumbnailUrl: item.gambarUrl ?? '', // Null-safe
              ))
          .toList();
    } catch (e, stack) {
      debugPrint('[EdukasiAnak] Gagal memuat Perawatan: $e');
      debugPrint('Stack: $stack');
      errors.add('Perawatan');
    }

    if (!mounted) return;

    setState(() {
      _anakItemsByCategory = tempItemsByCategory;
      _allItems = [..._ibuItems, ..._anakCategoryCards];
      _isLoading = false;

      debugPrint('=== DATA EDUKASI ===');
      debugPrint('Artikel Anak (Informasi Umum): ${tempItemsByCategory['informasi_umum']?.length ?? 0}');
      debugPrint('Artikel Anak (Pola Asuh): ${tempItemsByCategory['pola_asuh']?.length ?? 0}');
      debugPrint('Artikel Anak (Perawatan): ${tempItemsByCategory['perawatan']?.length ?? 0}');
      debugPrint('====================');

      if (errors.length == 3) {
        _errorMessage = 'Gagal memuat data edukasi Anak.';
      }
    });
  }


  // =========================================================================
  // FILTER LOGIC
  // =========================================================================
  List<Map<String, dynamic>> get _filteredItems {
    return _allItems.where((item) {
      final title = item['title'] as String;
      final desc = item['desc'] as String;

      final matchSearch = searchQuery.isEmpty ||
          title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          desc.toLowerCase().contains(searchQuery.toLowerCase());

      return matchSearch;
    }).toList();
  }

  // =========================================================================
  // HANDLE TAP: Navigasi sesuai tipe item
  // =========================================================================
  void _handleItemTap(Map<String, dynamic> item) {
    if (item['type'] == 'ibu') {
      // Navigasi ke screen edukasi ibu
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['screen']),
      );
    } else if (item['type'] == 'anak_category') {
      // Navigasi ke list konten anak berdasarkan kategori
      final apiKey = item['apiKey'] as String;
      final items = _anakItemsByCategory[apiKey] ?? [];
      final style = _getKategoriStyle(item['category']);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListKontenEdukasiAnakScreen(
            kategori: item['title'],
            deskripsi: item['desc'],
            items: items,
            accentColor: style.accent,
            icon: item['icon'],
          ),
        ),
      );
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edukasi',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Informasi kesehatan ibu & anak',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(color: Colors.grey.shade200, height: 1.0),
                ],
              ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSearchFilter(),
          ),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadAllData,
                        color: AppColors.primary,
                        child: _filteredItems.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  // Semua item sekarang adalah kartu kategori
                                  return _EdukasiKategoriCard(
                                    title: item['title'],
                                    desc: item['desc'],
                                    icon: item['icon'],
                                    category: item['category'],
                                    group: item['group'],
                                    itemCount: item['type'] == 'anak_category'
                                        ? (_anakItemsByCategory[item['apiKey']]?.length ?? 0)
                                        : null,
                                    onTap: () => _handleItemTap(item),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // WIDGETS UI
  // =========================================================================
  Widget _buildSearchFilter() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val),
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Cari edukasi disini...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 20),
            const Text('Gagal memuat sebagian data',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(_errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Edukasi tidak ditemukan',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Coba ubah filter atau kata kunci pencarian',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// =========================================================================
// KARTU KATEGORI (DIPAKAI BAIK UNTUK IBU MAUPUN ANAK)
// =========================================================================
class _EdukasiKategoriCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final String category;
  final String group;
  final int? itemCount; // Jumlah artikel (hanya untuk anak)
  final VoidCallback onTap;

  const _EdukasiKategoriCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.category,
    required this.group,
    this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getKategoriStyle(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: style.accent.withValues(alpha: 0.15),
          highlightColor: style.accent.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header area dengan icon dan badge
              Stack(
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, size: 42, color: style.accent),
                    ),
                  ),
                  // Badge kategori
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: style.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Info text
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}