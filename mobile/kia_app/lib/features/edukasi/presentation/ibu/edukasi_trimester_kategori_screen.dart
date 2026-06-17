// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';

// import 'edukasi_trimester_detail_screen.dart';

// class EdukasiTrimesterKategoriScreen
//     extends StatefulWidget {
//   final String trimester;
//   final String title;

//   const EdukasiTrimesterKategoriScreen({
//     super.key,
//     required this.trimester,
//     required this.title,
//   });

//   @override
//   State<EdukasiTrimesterKategoriScreen>
//       createState() =>
//           _EdukasiTrimesterKategoriScreenState();
// }

// class _EdukasiTrimesterKategoriScreenState
//     extends State<
//         EdukasiTrimesterKategoriScreen> {
//   late Future<List<String>>
//       futureKategori;

//   @override
//   void initState() {
//     super.initState();

//     futureKategori =
//         getKategoriFromDatabase();
//   }

//   Future<List<String>>
//       getKategoriFromDatabase() async {
//     final repository =
//         EdukasiTrimesterRepository(
//       EdukasiTrimesterService(),
//     );

//     final data =
//         await repository.getByTrimester(
//       widget.trimester,
//     );

//     final kategoriSet = data
//         .map((e) => e.kategori)
//         .toSet()
//         .toList();

//     return kategoriSet;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF4F7FB),

//       appBar: AppBar(
//         backgroundColor:
//             const Color(0xFF1F5EA8),

//         title: Text(
//           widget.title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//       ),

//       body: FutureBuilder<List<String>>(
//         future: futureKategori,

//         builder: (context, snapshot) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child:
//                   CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 snapshot.error.toString(),
//               ),
//             );
//           }

//           final kategoriList =
//               snapshot.data ?? [];

//           if (kategoriList.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Kategori belum tersedia',
//               ),
//             );
//           }

//           return ListView.builder(
//             padding:
//                 const EdgeInsets.all(20),

//             itemCount:
//                 kategoriList.length,

//             itemBuilder:
//                 (context, index) {
//               final kategori =
//                   kategoriList[index];

//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           EdukasiTrimesterDetailScreen(
//                         trimester:
//                             widget
//                                 .trimester,
//                         kategori:
//                             kategori,
//                       ),
//                     ),
//                   );
//                 },

//                 child: Container(
//                   margin:
//                       const EdgeInsets
//                           .only(
//                     bottom: 16,
//                   ),

//                   padding:
//                       const EdgeInsets
//                           .all(20),

//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white,

//                     borderRadius:
//                         BorderRadius.circular(
//                       22,
//                     ),
//                   ),

//                   child: Row(
//                     children: [
//                       Container(
//                         width: 55,
//                         height: 55,

//                         decoration:
//                             BoxDecoration(
//                           color:
//                               const Color(
//                             0xFF1F5EA8,
//                           ).withOpacity(
//                             0.1,
//                           ),

//                           shape:
//                               BoxShape
//                                   .circle,
//                         ),

//                         child:
//                             const Icon(
//                           Icons
//                               .menu_book_rounded,

//                           color: Color(
//                             0xFF1F5EA8,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(
//                         width: 16,
//                       ),

//                       Expanded(
//                         child: Text(
//                           kategori,
//                           style:
//                               const TextStyle(
//                             fontSize:
//                                 18,
//                             fontWeight:
//                                 FontWeight
//                                     .w600,
//                           ),
//                         ),
//                       ),

//                       const Icon(
//                         Icons
//                             .arrow_forward_ios,
//                         size: 18,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }