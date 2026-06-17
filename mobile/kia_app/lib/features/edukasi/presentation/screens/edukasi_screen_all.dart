// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// import '../ibu/konten_edukasi_ibu_screen.dart';
// import '../anak/konten_edukasi_anak_screen.dart';

// class EdukasiScreenAll extends StatelessWidget {
//   const EdukasiScreenAll({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,

//         title: const Text(
//           'Edukasi',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         centerTitle: true,

//         iconTheme: const IconThemeData(
//           color: Colors.black87,
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           children: [

//             _buildCategoryCard(
//               context: context,
//               title: 'Ibu',
//               subtitle:
//                   'Edukasi kesehatan ibu selama masa kehamilan',
//               icon: Icons.pregnant_woman,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         const KontenEdukasiIbuScreen(),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 18),

//             _buildCategoryCard(
//               context: context,
//               title: 'Anak',
//               subtitle:
//                   'Edukasi tumbuh kembang anak sejak lahir hingga usia 6 tahun',
//               icon: Icons.child_care,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         const KontenEdukasiAnakScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryCard({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,

//       child: Container(
//         padding: const EdgeInsets.all(18),

//         decoration: BoxDecoration(
//           color: Colors.white,

//           borderRadius: BorderRadius.circular(20),

//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),

//         child: Row(
//           children: [

//             Container(
//               padding: const EdgeInsets.all(14),

//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),

//                 borderRadius:
//                     BorderRadius.circular(16),
//               ),

//               child: Icon(
//                 icon,
//                 size: 28,
//                 color: AppColors.primary,
//               ),
//             ),

//             const SizedBox(width: 16),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [

//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   const SizedBox(height: 6),

//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.black54,
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 18,
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import '../ibu/konten_edukasi_ibu_screen.dart';
import '../anak/konten_edukasi_anak_screen.dart';

class EdukasiScreenAll extends StatelessWidget {
  const EdukasiScreenAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
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
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Informasi kesehatan ibu & anak',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCategoryCard(
                    context: context,
                    title: 'Ibu',
                    subtitle: 'Edukasi kesehatan ibu selama masa kehamilan',
                    icon: Icons.pregnant_woman,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KontenEdukasiIbuScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context: context,
                    title: 'Anak',
                    subtitle:
                        'Edukasi tumbuh kembang anak sejak lahir hingga usia 6 tahun',
                    icon: Icons.child_care,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KontenEdukasiAnakScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}