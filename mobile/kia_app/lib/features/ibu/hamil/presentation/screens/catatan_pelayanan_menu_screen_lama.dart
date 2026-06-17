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

import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t1_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t2_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_t3_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Trimester 1'),
            Tab(text: 'Trimester 2'),
            Tab(text: 'Trimester 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CatatanPelayananT1Screen(),
          CatatanPelayananT2Screen(),
          CatatanPelayananT3Screen(),
        ],
      ),
    );
  }
}