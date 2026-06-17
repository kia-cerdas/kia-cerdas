// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_tanda_melahirkan_model.dart';
// import '../../data/repositories/edukasi_tanda_melahirkan_repository.dart';
// import '../../data/services/edukasi_tanda_melahirkan_service.dart';

// class EdukasiTandaMelahirkanScreen
//     extends StatefulWidget {
//   const EdukasiTandaMelahirkanScreen({
//     super.key,
//   });

//   @override
//   State<EdukasiTandaMelahirkanScreen>
//       createState() =>
//           _EdukasiTandaMelahirkanScreenState();
// }

// class _EdukasiTandaMelahirkanScreenState
//     extends State<
//         EdukasiTandaMelahirkanScreen> {
//   late Future<
//           List<
//               EdukasiTandaMelahirkanModel>>
//       futureData;

//   @override
//   void initState() {
//     super.initState();

//     final repository =
//         EdukasiTandaMelahirkanRepository(
//       EdukasiTandaMelahirkanService(),
//     );

//     futureData = repository
//         .getAllEdukasiTandaMelahirkan();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF4F7FB),

//       body: FutureBuilder<
//           List<
//               EdukasiTandaMelahirkanModel>>(
//         future: futureData,

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

//           final data = snapshot.data ?? [];

//           if (data.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Data edukasi kosong',
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: data.length,

//             itemBuilder: (context, index) {
//               final item = data[index];

//               final tandaList = item.tanda
//                   .split('\n')
//                   .where(
//                     (e) => e.trim().isNotEmpty,
//                   )
//                   .toList();

//               final tindakanList = item
//                   .tindakan
//                   .split('\n')
//                   .where(
//                     (e) => e.trim().isNotEmpty,
//                   )
//                   .toList();

//               return Column(
//                 children: [
//                   if (index == 0)
//                     Container(
//                       width:
//                           double.infinity,

//                       padding:
//                           const EdgeInsets
//                               .fromLTRB(
//                         20,
//                         60,
//                         20,
//                         30,
//                       ),

//                       decoration:
//                           const BoxDecoration(
//                         color:
//                             Color(0xFF1F5EA8),
//                       ),

//                       child: Row(
//                         children: [
//                           Container(
//                             decoration:
//                                 BoxDecoration(
//                               color: Colors
//                                   .white
//                                   .withOpacity(
//                                 0.2,
//                               ),

//                               shape:
//                                   BoxShape
//                                       .circle,
//                             ),

//                             child:
//                                 IconButton(
//                               onPressed: () {
//                                 Navigator.pop(
//                                   context,
//                                 );
//                               },

//                               icon:
//                                   const Icon(
//                                 Icons
//                                     .arrow_back_ios_new,
//                                 color: Colors
//                                     .white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(
//                             width: 12,
//                           ),

//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment
//                                       .start,

//                               children: [
//                                 const Text(
//                                   'Tanda Melahirkan',
//                                   style:
//                                       TextStyle(
//                                     color: Colors
//                                         .white,

//                                     fontSize:
//                                         24,

//                                     fontWeight:
//                                         FontWeight
//                                             .bold,
//                                   ),
//                                 ),

//                                 const SizedBox(
//                                   height: 4,
//                                 ),

//                                 Text(
//                                   'Kenali tanda persalinan sejak dini',
//                                   style:
//                                       TextStyle(
//                                     color: Colors
//                                         .white
//                                         .withOpacity(
//                                       0.85,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   Padding(
//                     padding:
//                         const EdgeInsets
//                             .all(16),

//                     child: Column(
//                       children: [
//                         // CARD
//                         Container(
//                           width:
//                               double.infinity,

//                           padding:
//                               const EdgeInsets
//                                   .all(18),

//                           decoration:
//                               BoxDecoration(
//                             color:
//                                 const Color(
//                               0xFF1F5EA8,
//                             ),

//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               20,
//                             ),
//                           ),

//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,

//                                 decoration:
//                                     BoxDecoration(
//                                   color: Colors
//                                       .white
//                                       .withOpacity(
//                                     0.15,
//                                   ),

//                                   shape: BoxShape
//                                       .circle,
//                                 ),

//                                 child:
//                                     const Icon(
//                                   Icons
//                                       .medical_information,
//                                   color: Colors
//                                       .white,
//                                   size: 30,
//                                 ),
//                               ),

//                               const SizedBox(
//                                 width: 16,
//                               ),

//                               Expanded(
//                                 child: Text(
//                                   item.judul,
//                                   style:
//                                       const TextStyle(
//                                     color: Colors
//                                         .white,

//                                     fontSize:
//                                         20,

//                                     fontWeight:
//                                         FontWeight
//                                             .bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 16,
//                         ),

//                         _buildSectionCard(
//                           title:
//                               'Tentang Persalinan',

//                           child: Text(
//                             item.isi,

//                             style:
//                                 const TextStyle(
//                               height: 1.6,
//                               fontSize: 15,
//                               color:
//                                   Color(
//                                 0xFF4B5563,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 16,
//                         ),

//                         _buildListSection(
//                           title:
//                               'Tanda Persalinan',

//                           items:
//                               tandaList,

//                           color:
//                               const Color(
//                             0xFFEF4444,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 16,
//                         ),

//                         _buildListSection(
//                           title:
//                               'Tindakan yang Dilakukan',

//                           items:
//                               tindakanList,

//                           color:
//                               const Color(
//                             0xFF10B981,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 30,
//                         ),
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

//   Widget _buildSectionCard({
//     required String title,
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(20),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight:
//                   FontWeight.bold,
//               color: Color(0xFF111827),
//             ),
//           ),

//           const SizedBox(height: 16),

//           child,
//         ],
//       ),
//     );
//   }

//   Widget _buildListSection({
//     required String title,
//     required List<String> items,
//     required Color color,
//   }) {
//     return _buildSectionCard(
//       title: title,

//       child: Column(
//         children: List.generate(
//           items.length,
//           (index) {
//             return Container(
//               padding:
//                   const EdgeInsets.symmetric(
//                 vertical: 14,
//               ),

//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color:
//                         Colors.grey.shade200,
//                   ),
//                 ),
//               ),

//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Container(
//                     width: 32,
//                     height: 32,

//                     decoration:
//                         BoxDecoration(
//                       color:
//                           color.withOpacity(
//                         0.12,
//                       ),

//                       borderRadius:
//                           BorderRadius
//                               .circular(
//                         10,
//                       ),
//                     ),

//                     child: Center(
//                       child: Text(
//                         '${index + 1}',
//                         style: TextStyle(
//                           color: color,
//                           fontWeight:
//                               FontWeight
//                                   .bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(
//                     width: 14,
//                   ),

//                   Expanded(
//                     child: Text(
//                       items[index]
//                           .replaceAll(
//                         RegExp(
//                           r'^\d+\.\s*',
//                         ),
//                         '',
//                       ),

//                       style:
//                           const TextStyle(
//                         fontSize: 15,
//                         height: 1.5,
//                         fontWeight:
//                             FontWeight.w600,
//                         color: Color(
//                           0xFF1F2937,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../data/models/edukasi_tanda_melahirkan_model.dart';
import '../../data/repositories/edukasi_tanda_melahirkan_repository.dart';
import '../../data/services/edukasi_tanda_melahirkan_service.dart';
import 'edukasi_tanda_melahirkan_detail_screen.dart';

/// Halaman DAFTAR edukasi tanda melahirkan.
///
/// Menampilkan SEMUA materi sebagai kartu. Saat satu kartu diketuk,
/// ibu dibawa ke halaman detail. Pola sama dengan trimester/mental/nifas.
class EdukasiTandaMelahirkanScreen extends StatefulWidget {
  const EdukasiTandaMelahirkanScreen({super.key});

  @override
  State<EdukasiTandaMelahirkanScreen> createState() =>
      _EdukasiTandaMelahirkanScreenState();
}

class _EdukasiTandaMelahirkanScreenState
    extends State<EdukasiTandaMelahirkanScreen> {
  late Future<List<EdukasiTandaMelahirkanModel>> futureData;

  @override
  void initState() {
    super.initState();

    final repository = EdukasiTandaMelahirkanRepository(
      EdukasiTandaMelahirkanService(),
    );
    futureData = repository.getAllEdukasiTandaMelahirkan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5EA8),
        foregroundColor: Colors.white,
        title: const Text(
          'Tanda Melahirkan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<EdukasiTandaMelahirkanModel>>(
        future: futureData,
        builder: (context, snapshot) {
          // 1) Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Error
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data ?? [];

          // 3) Kosong
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Data edukasi belum tersedia',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          // 4) Tampilkan SEMUA materi sebagai daftar kartu.
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _TandaMelahirkanCard(item: item);
            },
          );
        },
      ),
    );
  }
}

/// Kartu satu materi di halaman daftar.
class _TandaMelahirkanCard extends StatelessWidget {
  final EdukasiTandaMelahirkanModel item;

  const _TandaMelahirkanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiTandaMelahirkanDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar atas (atau placeholder kalau kosong)
            if (item.gambarUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.gambarUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              )
            else
              _placeholderImage(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tanda Melahirkan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F5EA8),
                      ),
                    ),
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

                  // Cuplikan isi (maksimal 3 baris)
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
                  const SizedBox(height: 12),

                  // "Baca selengkapnya ->"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F5EA8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
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

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF1F5EA8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Icon(
          Icons.medical_services_rounded,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }
}