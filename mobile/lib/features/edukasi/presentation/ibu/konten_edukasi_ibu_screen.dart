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
// PEWARNAAN PER KATEGORI
// Tujuannya supaya ibu bisa mengenali jenis edukasi dari warna kartu,
// tidak hanya dari teks. Warna diambil dari palet pastel yang sudah ada
// di AppColors, jadi tetap konsisten dengan desain aplikasi.
// =========================================================================
class _KategoriStyle {
  final Color background;
  final Color accent;
  const _KategoriStyle(this.background, this.accent);
}

_KategoriStyle _getKategoriStyle(String category) {
  switch (category) {
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
    default:
      return const _KategoriStyle(AppColors.purpleLight, AppColors.primary);
  }
}

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
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Cari edukasi disini...',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Material(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () => onCategorySelected(category),
                    borderRadius: BorderRadius.circular(30),
                    splashColor: AppColors.primary.withOpacity(0.15),
                    highlightColor: AppColors.primary.withOpacity(0.08),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
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
  final String desc;
  final IconData icon;
  final String category;
  final VoidCallback onTap;

  const EdukasiCardLokal({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.category,
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
            color: AppColors.black.withOpacity(0.05),
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
          splashColor: style.accent.withOpacity(0.15),
          highlightColor: style.accent.withOpacity(0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
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
          'desc': 'Panduan kesehatan ibu di setiap trimester kehamilan',
          'icon': Icons.pregnant_woman_rounded,
          'category': 'Trimester',
          'screen': const EdukasiTrimesterScreen(),
        },
        {
          'title': 'Inisiasi Menyusu Dini (IMD)',
          'desc': 'Cara memulai menyusui sesaat setelah bayi lahir',
          'icon': Icons.child_care_rounded,
          'category': 'Menyusui',
          'screen': const EdukasiIMDScreen(),
        },
        {
          'title': 'Edukasi Menyusui ASI Eksklusif',
          'desc': 'Manfaat dan tips memberikan ASI selama 6 bulan penuh',
          'icon': Icons.volunteer_activism_rounded,
          'category': 'Menyusui',
          'screen': const EdukasiASIScreen(),
        },
        {
          'title': 'Kesehatan Mental Ibu Hamil',
          'desc': 'Mengenali dan menjaga kondisi emosi selama hamil',
          'icon': Icons.psychology_rounded,
          'category': 'Kesehatan Mental',
          'screen': const EdukasiKesehatanMentalScreen(),
        },
        {
          'title': 'Edukasi Perawatan Masa Nifas',
          'desc': 'Tips merawat diri dan pemulihan setelah melahirkan',
          'icon': Icons.favorite_rounded,
          'category': 'Nifas',
          'screen': const EdukasiNifasScreen(),
        },
        {
          'title': 'Edukasi Tanda Melahirkan',
          'desc': 'Kenali tanda-tanda menjelang persalinan',
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
            // Text(
            //   'Sumber Buku KI',
            //   style: TextStyle(
            //     color: AppColors.textSecondary,
            //     fontWeight: FontWeight.normal,
            //     fontSize: 12,
            //   ),
            // ),
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
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Edukasi tidak ditemukan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Coba kata kunci atau kategori lain',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return EdukasiCardLokal(
                        title: item['title'],
                        desc: item['desc'],
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
    );
  }
}