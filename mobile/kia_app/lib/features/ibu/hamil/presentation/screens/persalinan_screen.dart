// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/constants/app_colors.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/checklist_persiapan_melahirkan_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/checklist_proses_melahirkan_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/proses_melahirkan_screens.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/widgets/ibu_menu_card.dart';

// class PersalinanScreen extends StatelessWidget {
//   const PersalinanScreen({super.key});

//   static const Color _primary = AppColors.primary;
//   static const Color _bgColor = Color(0xFFF5F7FB);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgColor,
//       appBar: AppBar(
//         title: const Text(
//           'Persalinan',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: _primary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // ── Header ──────────────────────────────────────────────────
//           _buildHeader(),

//           // ── Konten ──────────────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Seksi: Persiapan ──
//                 _buildSectionLabel('Persiapan Sebelum Bersalin'),
//                 const SizedBox(height: 12),
//                 IbuMenuCard(
//                   icon: Icons.checklist_rtl_outlined,
//                   iconColor: const Color(0xFF7C3AED),
//                   iconBgColor: const Color(0xFFF3F0FF),
//                   title: 'Checklist Persiapan Melahirkan',
//                   subtitle:
//                       'Pastikan semua persiapan sudah lengkap sebelum hari persalinan',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           const ChecklistPersiapanMelahirkanScreen(),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // ── Seksi: Proses ──
//                 _buildSectionLabel('Saat Proses Bersalin'),
//                 const SizedBox(height: 12),
//                 IbuMenuCard(
//                   icon: Icons.pregnant_woman_outlined,
//                   iconColor: const Color(0xFF059669),
//                   iconBgColor: const Color(0xFFECFDF5),
//                   title: 'Checklist Proses Melahirkan',
//                   subtitle:
//                       'Pemahaman ibu tentang proses, hak, dan penanganan saat bersalin',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           const ChecklistProsesMelahirkanScreen(),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // ── Seksi: Catatan Pasca Bersalin ──
//                 _buildSectionLabel('Catatan Pasca Bersalin'),
//                 const SizedBox(height: 12),
//                 IbuMenuCard(
//                   icon: Icons.child_friendly_outlined,
//                   iconColor: const Color(0xFFE0A300),
//                   iconBgColor: const Color(0xFFFFF5D6),
//                   title: 'Keterangan Lahir',
//                   subtitle:
//                       'Lihat ringkasan ibu bersalin, nifas, dan kondisi bayi saat lahir',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const KeteranganLahirScreen(),
//                     ),
//                   ),
//                 ),

//                 // ── Info banner ──────────────────────────────────────
//                 const SizedBox(height: 8),
//                 _buildInfoBanner(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── Header ─────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
//       decoration: const BoxDecoration(
//         color: _primary,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha: 0.15),
//           borderRadius: BorderRadius.circular(22),
//         ),
//         child: Row(children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.22),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.child_care_outlined,
//                 color: Colors.white, size: 30),
//           ),
//           const SizedBox(width: 14),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Persalinan',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w900),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   'Persiapan & proses persalinan — dari sebelum hingga pasca bersalin',
//                   style: TextStyle(
//                       color: Colors.white70, fontSize: 11, height: 1.35),
//                 ),
//               ],
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   // ─── Section label ──────────────────────────────────────────────────────
//   Widget _buildSectionLabel(String label) {
//     return Row(children: [
//       Container(
//         width: 4,
//         height: 20,
//         decoration: BoxDecoration(
//           color: _primary,
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       const SizedBox(width: 10),
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w900,
//           color: Color(0xFF1F2937),
//         ),
//       ),
//     ]);
//   }

//   // ─── Info banner ────────────────────────────────────────────────────────
//   Widget _buildInfoBanner() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF6FF),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
//       ),
//       child: const Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Data ringkasan persalinan dan keterangan lahir diisi oleh tenaga kesehatan. Checklist persiapan dan proses diisi sendiri oleh ibu.',
//               style: TextStyle(
//                   fontSize: 11, color: Color(0xFF1E3A8A), height: 1.4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/checklist_persiapan_melahirkan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/checklist_proses_melahirkan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/proses_melahirkan_screens.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/riwayat_proses_melahirkan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/widgets/ibu_menu_card.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/ringkasan_persalinan_screen.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class PersalinanScreen extends StatelessWidget {
  const PersalinanScreen({super.key});

  static const Color _primary = AppColors.primary;
  static const Color _bgColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Persalinan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header ──────────────────────────────────────────────────
          _buildHeader(),

          // ── Konten ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Seksi: Persiapan ──
                _buildSectionLabel('Persiapan Sebelum Bersalin'),
                const SizedBox(height: 12),
                IbuMenuCard(
                  icon: Icons.checklist_rtl_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  iconBgColor: const Color(0xFFF3F0FF),
                  title: 'Checklist Persiapan Melahirkan',
                  subtitle:
                      'Pastikan semua persiapan sudah lengkap sebelum hari persalinan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChecklistPersiapanMelahirkanScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Seksi: Proses ──
                _buildSectionLabel('Saat Proses Bersalin'),
                const SizedBox(height: 12),
                IbuMenuCard(
                  icon: Icons.pregnant_woman_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBgColor: const Color(0xFFECFDF5),
                  title: 'Checklist Proses Melahirkan',
                  subtitle:
                      'Pemahaman ibu tentang proses, hak, dan penanganan saat bersalin',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChecklistProsesMelahirkanScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IbuMenuCard(
                icon: Icons.summarize_outlined,
                iconColor: AppColors.primary,
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Ringkasan Pelayanan Proses Melahirkan',
                subtitle:
                    'Lihat hasil ringkasan pelayanan dan proses persalinan ibu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RingkasanPersalinanScreen(
                      token: AuthSession.token ?? '',
                    ),
                  ),
                ),
              ),

                const SizedBox(height: 8),

                // ── Seksi: Catatan Pasca Bersalin ──
                _buildSectionLabel('Catatan Pasca Bersalin'),
                const SizedBox(height: 12),

                // CARD 1: Riwayat Proses Melahirkan (BARU)
                IbuMenuCard(
                  icon: Icons.history_edu_outlined,
                  iconColor: const Color(0xFF0284C7),
                  iconBgColor: const Color(0xFFE0F2FE),
                  title: 'Riwayat Proses Melahirkan',
                  subtitle:
                      'Lihat catatan proses persalinan: G/P/A, cara melahirkan, penolong, dan catatan tenaga kesehatan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RiwayatProsesMelahirkanScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CARD 2: Keterangan Lahir (sudah ada sebelumnya)
                IbuMenuCard(
                  icon: Icons.child_friendly_outlined,
                  iconColor: const Color(0xFFE0A300),
                  iconBgColor: const Color(0xFFFFF5D6),
                  title: 'Keterangan Lahir',
                  subtitle:
                      'Lihat ringkasan ibu bersalin, nifas, dan kondisi bayi saat lahir',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KeteranganLahirScreen(),
                    ),
                  ),
                ),

                // ── Info banner ──────────────────────────────────────
                const SizedBox(height: 8),
                _buildInfoBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Persalinan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Persiapan & proses persalinan — dari sebelum hingga pasca bersalin',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Section label ──────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1F2937),
        ),
      ),
    ]);
  }

  // ─── Info banner ────────────────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Riwayat proses melahirkan dan keterangan lahir diisi oleh tenaga kesehatan. Checklist persiapan dan proses diisi sendiri oleh ibu.',
              style: TextStyle(
                  fontSize: 11, color: Color(0xFF1E3A8A), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}