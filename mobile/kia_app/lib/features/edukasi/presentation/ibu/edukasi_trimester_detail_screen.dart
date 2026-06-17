// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_trimester_model.dart';
// import '../../data/repositories/edukasi_trimester_repository.dart';
// import '../../data/services/edukasi_trimester_service.dart';

// class EdukasiTrimesterDetailScreen
//     extends StatefulWidget {
//   final String trimester;
//   final String kategori;

//   const EdukasiTrimesterDetailScreen({
//     super.key,
//     required this.trimester,
//     required this.kategori,
//   });

//   @override
//   State<EdukasiTrimesterDetailScreen>
//       createState() =>
//           _EdukasiTrimesterDetailScreenState();
// }

// class _EdukasiTrimesterDetailScreenState
//     extends State<
//         EdukasiTrimesterDetailScreen> {
//   late Future<List<EdukasiTrimesterModel>>
//       futureData;

//   @override
//   void initState() {
//     super.initState();

//     final repository =
//         EdukasiTrimesterRepository(
//       EdukasiTrimesterService(),
//     );

//     futureData =
//         repository.getByKategori(
//       widget.trimester,
//       widget.kategori,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF4F7FB),

//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.fromLTRB(
//               20,
//               60,
//               20,
//               30,
//             ),

//             decoration:
//                 const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF1F5EA8),
//                   Color(0xFF2D7BEA),
//                 ],
//               ),
//             ),

//             child: Row(
//               children: [
//                 Container(
//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(
//                       0.15,
//                     ),

//                     shape:
//                         BoxShape.circle,
//                   ),

//                   child: IconButton(
//                     onPressed: () {
//                       Navigator.pop(
//                         context,
//                       );
//                     },

//                     icon: const Icon(
//                       Icons
//                           .arrow_back_ios_new,
//                       color:
//                           Colors.white,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 16),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment
//                             .start,

//                     children: [
//                       Text(
//                         widget.kategori,
//                         style:
//                             const TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 26,
//                           fontWeight:
//                               FontWeight
//                                   .bold,
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 6,
//                       ),

//                       Text(
//                         'Edukasi ${widget.trimester}',
//                         style:
//                             TextStyle(
//                           color: Colors
//                               .white
//                               .withOpacity(
//                             0.9,
//                           ),
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: FutureBuilder<
//                 List<
//                     EdukasiTrimesterModel>>(
//               future: futureData,

//               builder:
//                   (context, snapshot) {
//                 if (snapshot
//                         .connectionState ==
//                     ConnectionState
//                         .waiting) {
//                   return const Center(
//                     child:
//                         CircularProgressIndicator(),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       snapshot.error
//                           .toString(),
//                     ),
//                   );
//                 }

//                 final data =
//                     snapshot.data ??
//                         [];

//                 if (data.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'Data belum tersedia',
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding:
//                       const EdgeInsets
//                           .all(20),

//                   itemCount:
//                       data.length,

//                   itemBuilder:
//                       (context, index) {
//                     final item =
//                         data[index];

//                     return Container(
//                       margin:
//                           const EdgeInsets
//                               .only(
//                         bottom: 24,
//                       ),

//                       decoration:
//                           BoxDecoration(
//                         color:
//                             Colors.white,

//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           28,
//                         ),

//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors
//                                 .black
//                                 .withOpacity(
//                               0.05,
//                             ),

//                             blurRadius:
//                                 14,

//                             offset:
//                                 const Offset(
//                               0,
//                               5,
//                             ),
//                           ),
//                         ],
//                       ),

//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment
//                                 .start,

//                         children: [
//                           ClipRRect(
//                             borderRadius:
//                                 const BorderRadius
//                                     .vertical(
//                               top:
//                                   Radius.circular(
//                                 28,
//                               ),
//                             ),

//                             child:
//                                 Image.network(
//                               item
//                                   .gambarUrl,

//                               height: 220,

//                               width: double
//                                   .infinity,

//                               fit: BoxFit
//                                   .cover,
//                             ),
//                           ),

//                           Padding(
//                             padding:
//                                 const EdgeInsets
//                                     .all(
//                               22,
//                             ),

//                             child:
//                                 Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment
//                                       .start,

//                               children: [
//                                 Row(
//                                   children: [
//                                     _buildBadge(
//                                       item
//                                           .trimester,
//                                     ),

//                                     const SizedBox(
//                                       width:
//                                           10,
//                                     ),

//                                     _buildKategoriBadge(
//                                       item
//                                           .kategori,
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(
//                                   height:
//                                       18,
//                                 ),

//                                 Text(
//                                   item
//                                       .judul,

//                                   style:
//                                       const TextStyle(
//                                     fontSize:
//                                         24,

//                                     fontWeight:
//                                         FontWeight
//                                             .bold,

//                                     color:
//                                         Color(
//                                       0xFF111827,
//                                     ),
//                                   ),
//                                 ),

//                                 const SizedBox(
//                                   height:
//                                       16,
//                                 ),

//                                 Text(
//                                   item
//                                       .isi,

//                                   style:
//                                       const TextStyle(
//                                     fontSize:
//                                         15,

//                                     height:
//                                         1.8,

//                                     color:
//                                         Color(
//                                       0xFF4B5563,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBadge(
//     String text,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 8,
//       ),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFF1F5EA8),

//         borderRadius:
//             BorderRadius.circular(
//           50,
//         ),
//       ),

//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight:
//               FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildKategoriBadge(
//     String text,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 8,
//       ),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFE8F1FD),

//         borderRadius:
//             BorderRadius.circular(
//           50,
//         ),
//       ),

//       child: Text(
//         text,
//         style: const TextStyle(
//           color:
//               Color(0xFF1F5EA8),
//           fontWeight:
//               FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }