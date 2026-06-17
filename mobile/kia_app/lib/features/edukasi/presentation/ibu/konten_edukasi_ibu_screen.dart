// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// // --- IMPOR WARNA RESMI DARI FOLDER THEMES MENGGUNAKAN RELATIVE PATH YANG BENAR ---
// import '../../../../core/themes/app_colors.dart';

// // --- IMPORT NAVIGASI SCREEN MENGGUNAKAN RELATIVE PATH ---
// import '../../../../features/dashboard/presentation/screens/dashboard_screen.dart'; 
// import '../../../../features/ibu/hamil/presentation/screens/absensi_kelas_ibu_hamil_screen.dart';

// // --- IMPORT HALAMAN DETAIL EDUKASI (Berada di folder yang sama) ---
// import 'edukasi_asi_screen.dart';
// import 'edukasi_imd_screen.dart';
// import 'edukasi_mental_screen.dart';
// import 'edukasi_nifas_screen.dart';
// import 'edukasi_trimester_detail_screen.dart';
// import 'edukasi_tanda_melahirkan_screen.dart';

// // --- IMPORT REPOSITORY DATABASE SUPABASE ASLI (100% UTUH & AMAN) ---
// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';

// // =========================================================================
// // WIDGET SEARCH FILTER LOKAL (Menyatukan Fungsi Agar Kebal Error Impor)
// // =========================================================================
// class EdukasiSearchFilterLokal extends StatelessWidget {
//   final String selectedCategory;
//   final Function(String) onCategorySelected;
//   final Function(String) onSearchChanged;
//   final List<String> categories;

//   const EdukasiSearchFilterLokal({
//     super.key,
//     required this.selectedCategory,
//     required this.onCategorySelected,
//     required this.categories,
//     required this.onSearchChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 50,
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: AppColors.border),
//           ),
//           child: TextField(
//             onChanged: onSearchChanged,
//             decoration: const InputDecoration(
//               hintText: 'Cari edukasi disini...',
//               hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
//               prefixIcon: Icon(Icons.search, color: AppColors.textHint),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               final isSelected = selectedCategory == category;
//               return GestureDetector(
//                 onTap: () => onCategorySelected(category),
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.primary : AppColors.white,
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: isSelected ? AppColors.primary : AppColors.border,
//                     ),
//                   ),
//                   child: Text(
//                     category,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? AppColors.white : AppColors.textPrimary,
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
// }

// // =========================================================================
// // WIDGET KARTU UMUM LOKAL (Bersih Tanpa Atribut Video/Artikel Sumpek)
// // =========================================================================
// class EdukasiCardLokal extends StatelessWidget {
//   final String title;
//   final IconData icon; 
//   final String category;
//   final VoidCallback onTap;

//   const EdukasiCardLokal({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.category,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.black.withOpacity(0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 120,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: AppColors.purpleLight, 
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: Center(
//                 child: Icon(
//                   icon,
//                   size: 44,
//                   color: AppColors.primary, 
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14, 
//                   fontWeight: FontWeight.w600, 
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =========================================================================
// // HALAMAN INDUK SCREEN UTAMA
// // =========================================================================
// class KontenEdukasiIbuScreen extends StatefulWidget {
//   const KontenEdukasiIbuScreen({super.key});

//   @override
//   State<KontenEdukasiIbuScreen> createState() =>
//       _KontenEdukasiIbuScreenState();
// }

// class _KontenEdukasiIbuScreenState extends State<KontenEdukasiIbuScreen> {
//   String selectedCategory = 'Semua';
//   String searchQuery = '';
//   int _currentIndex = 2; 

//   String selectedTrimesterTab = 'TM1'; 

  
//  // --- KOSONGKAN SAJA PARAMETERNYA AGAR MENGIKUTI KONFIGURASI OTOMATIS TIM KAMU ---
//   final _trimesterRepository = EdukasiTrimesterRepository(
//     EdukasiTrimesterService(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     // DATA MENU UMUM NON-TRIMESTER LOKAL
//     final List<Map<String, dynamic>> edukasiUmum = [
//       {
//         'title': 'Inisiasi Menyusu Dini (IMD)',
//         'icon': Icons.child_care_rounded,
//         'category': 'Menyusui',
//         'screen': const EdukasiIMDScreen(),
//       },
//       {
//         'title': 'Edukasi Menyusui ASI Eksklusif',
//         'icon': Icons.volunteer_activism_rounded,
//         'category': 'Menyusui',
//         'screen': const EdukasiASIScreen(),
//       },
//       {
//         'title': 'Kesehatan Mental Ibu Hamil',
//         'icon': Icons.psychology_rounded,
//         'category': 'Kesehatan Mental',
//         'screen': const EdukasiKesehatanMentalScreen(),
//       },
//       {
//         'title': 'Edukasi Perawatan Masa Nifas',
//         'icon': Icons.favorite_rounded,
//         'category': 'Nifas',
//         'screen': const EdukasiNifasScreen(),
//       },
//       {
//         'title': 'Edukasi Tanda Melahirkan',
//         'icon': Icons.pregnant_woman_rounded,
//         'category': 'Persalinan',
//         'screen': const EdukasiTandaMelahirkanScreen(),
//       },
//     ];

//     final filteredUmumData = edukasiUmum.where((item) {
//       final matchesCategory = selectedCategory == 'Semua'
//           ? true
//           : item['category'] == selectedCategory;

//       final matchesSearch = item['title']
//           .toString()
//           .toLowerCase()
//           .contains(searchQuery.toLowerCase());

//       return matchesCategory && matchesSearch;
//     }).toList();

//     return Scaffold(
//       backgroundColor: AppColors.scaffold, 
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//         elevation: 0,
//         title: Column(
//           children: const [
//             Text(
//               'Edukasi Ibu',
//               style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             Text(
//               'Sumber Buku KIA',
//               style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal, fontSize: 12),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: AppColors.textPrimary),
//       ),

//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: EdukasiSearchFilterLokal(
//               selectedCategory: selectedCategory,
//               categories: const ['Semua', 'Trimester', 'Menyusui', 'Nifas', 'Persalinan', 'Kesehatan Mental'],
//               onCategorySelected: (value) {
//                 setState(() { selectedCategory = value; });
//               },
//               onSearchChanged: (value) {
//                 setState(() { searchQuery = value; });
//               },
//             ),
//           ),

//           if (selectedCategory == 'Trimester') ...[
//             const SizedBox(height: 14),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: ['TM1', 'TM2', 'TM3'].map((tm) {
//                   final isSelected = selectedTrimesterTab == tm;
//                   String label = tm == 'TM1' ? 'Trimester I' : tm == 'TM2' ? 'Trimester II' : 'Trimester III';
//                   return Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() { selectedTrimesterTab = tm; });
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         decoration: BoxDecoration(
//                           color: isSelected ? AppColors.primary : AppColors.borderLight,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Center(
//                           child: Text(
//                             label,
//                             style: TextStyle(
//                               color: isSelected ? AppColors.white : AppColors.textSecondary,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],

//           const SizedBox(height: 16),

//           Expanded(
//             child: selectedCategory == 'Trimester'
//                 ? FutureBuilder<List<EdukasiTrimesterModel>>(
//                     future: _trimesterRepository.getByTrimester(selectedTrimesterTab),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator(color: AppColors.primary));
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text(snapshot.error.toString()));
//                       }

//                       final databaseArticles = snapshot.data ?? [];
                      
//                       final filteredDbArticles = databaseArticles.where((article) {
//                         return article.judul.toLowerCase().contains(searchQuery.toLowerCase());
//                       }).toList();

//                       if (filteredDbArticles.isEmpty) {
//                         return const Center(child: Text('Artikel tidak ditemukan'));
//                       }

//                       return ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: filteredDbArticles.length,
//                         itemBuilder: (context, index) {
//                           final item = filteredDbArticles[index];
                          
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => EdukasiTrimesterDetailScreen(
//                                     trimester: item.trimester,
//                                     kategori: item.kategori,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 16),
//                               decoration: BoxDecoration(
//                                 color: AppColors.card,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: AppColors.black.withOpacity(0.03),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                                     child: Image.network(
//                                       item.gambarUrl, 
//                                       height: 150, 
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return Container(
//                                           height: 150,
//                                           color: AppColors.borderLight,
//                                           child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textHint),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           item.judul,
//                                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
//                                         ),
//                                         const SizedBox(height: 10),
//                                         Text(
//                                           item.isi,
//                                           style: const TextStyle(
//                                             fontSize: 14, 
//                                             color: AppColors.textSecondary, 
//                                             height: 1.6,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: filteredUmumData.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredUmumData[index];
//                       return EdukasiCardLokal(
//                         title: item['title'],
//                         icon: item['icon'], 
//                         category: item['category'],
//                         onTap: () {
//                           Navigator.push(
//                             context, 
//                             MaterialPageRoute(builder: (_) => item['screen'])
//                           );
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: AppColors.white,
//         currentIndex: _currentIndex,
//         selectedItemColor: AppColors.primary, 
//         unselectedItemColor: AppColors.textHint,
//         showUnselectedLabels: true,
//         selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//         unselectedLabelStyle: const TextStyle(fontSize: 12),
//         onTap: (index) {
//           if (index == _currentIndex) return;
//           setState(() { _currentIndex = index; });

//           if (index == 0) {
//             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
//           } else if (index == 1) {
//             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AbsensiKelasIbuHamilScreen()));
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
//           BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Absensi'),
//           BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Edukasi'),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import '../../../../core/themes/app_colors.dart';

import '../../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../features/ibu/hamil/presentation/screens/absensi_kelas_ibu_hamil_screen.dart';

import 'edukasi_asi_screen.dart';
import 'edukasi_imd_screen.dart';
import 'edukasi_mental_screen.dart';
import 'edukasi_nifas_screen.dart';
import 'edukasi_tanda_melahirkan_screen.dart';
import 'edukasi_trimester_screen.dart';

// =========================================================================
// WIDGET SEARCH FILTER LOKAL
// =========================================================================
class EdukasiSearchFilterLokal extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final Function(String) onSearchChanged;
  final List<String> categories;

  const EdukasiSearchFilterLokal({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Cari edukasi disini...',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              return GestureDetector(
                onTap: () => onCategorySelected(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// WIDGET KARTU EDUKASI
// =========================================================================
class EdukasiCardLokal extends StatelessWidget {
  final String title;
  final IconData icon;
  final String category;
  final VoidCallback onTap;

  const EdukasiCardLokal({
    super.key,
    required this.title,
    required this.icon,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(icon, size: 44, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// HALAMAN UTAMA EDUKASI IBU
// =========================================================================
class KontenEdukasiIbuScreen extends StatefulWidget {
  const KontenEdukasiIbuScreen({super.key});

  @override
  State<KontenEdukasiIbuScreen> createState() =>
      _KontenEdukasiIbuScreenState();
}

class _KontenEdukasiIbuScreenState extends State<KontenEdukasiIbuScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';
  int _currentIndex = 2;

  // Semua item edukasi ibu dalam satu list
  List<Map<String, dynamic>> get _allEdukasi => [
        {
          'title': 'Edukasi Trimester',
          'icon': Icons.pregnant_woman_rounded,
          'category': 'Trimester',
          'screen': const EdukasiTrimesterScreen(),
        },
        {
          'title': 'Inisiasi Menyusu Dini (IMD)',
          'icon': Icons.child_care_rounded,
          'category': 'Menyusui',
          'screen': const EdukasiIMDScreen(),
        },
        {
          'title': 'Edukasi Menyusui ASI Eksklusif',
          'icon': Icons.volunteer_activism_rounded,
          'category': 'Menyusui',
          'screen': const EdukasiASIScreen(),
        },
        {
          'title': 'Kesehatan Mental Ibu Hamil',
          'icon': Icons.psychology_rounded,
          'category': 'Kesehatan Mental',
          'screen': const EdukasiKesehatanMentalScreen(),
        },
        {
          'title': 'Edukasi Perawatan Masa Nifas',
          'icon': Icons.favorite_rounded,
          'category': 'Nifas',
          'screen': const EdukasiNifasScreen(),
        },
        {
          'title': 'Edukasi Tanda Melahirkan',
          'icon': Icons.medical_information_rounded,
          'category': 'Persalinan',
          'screen': const EdukasiTandaMelahirkanScreen(),
        },
      ];

  List<Map<String, dynamic>> get _filtered {
    return _allEdukasi.where((item) {
      final matchCategory = selectedCategory == 'Semua'
          ? true
          : item['category'] == selectedCategory;
      final matchSearch = item['title']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Column(
          children: const [
            Text(
              'Edukasi Ibu',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Sumber Buku KIA',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: EdukasiSearchFilterLokal(
              selectedCategory: selectedCategory,
              categories: const [
                'Semua',
                'Trimester',
                'Menyusui',
                'Nifas',
                'Persalinan',
                'Kesehatan Mental',
              ],
              onCategorySelected: (value) =>
                  setState(() => selectedCategory = value),
              onSearchChanged: (value) =>
                  setState(() => searchQuery = value),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada edukasi ditemukan',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return EdukasiCardLokal(
                        title: item['title'],
                        icon: item['icon'],
                        category: item['category'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item['screen'],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const AbsensiKelasIbuHamilScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}