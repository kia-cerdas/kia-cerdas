// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_imd_model.dart';
// import '../../data/repositories/edukasi_imd_repository.dart';
// import '../../data/services/edukasi_imd_service.dart';

// class EdukasiIMDScreen extends StatefulWidget {
//   const EdukasiIMDScreen({super.key});

//   @override
//   State<EdukasiIMDScreen> createState() => _EdukasiIMDScreenState();
// }

// class _EdukasiIMDScreenState extends State<EdukasiIMDScreen> {
//   late Future<List<EdukasiIMDModel>> futureData;

//   @override
//   void initState() {
//     super.initState();

//     final repository = EdukasiIMDRepository(
//       EdukasiIMDService(),
//     );

//     futureData = repository.getAllEdukasiIMD();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),

//       body: FutureBuilder<List<EdukasiIMDModel>>(
//         future: futureData,

//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(snapshot.error.toString()),
//             );
//           }

//           final data = snapshot.data ?? [];

//           if (data.isEmpty) {
//             return const Center(
//               child: Text('Data edukasi kosong'),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: data.length,

//             itemBuilder: (context, index) {
//               final item = data[index];

//               final manfaatList = item.manfaat
//                   .split('\n')
//                   .where((e) => e.trim().isNotEmpty)
//                   .toList();

//               return Column(
//                 children: [
//                   if (index == 0)
//                     Container(
//                       width: double.infinity,

//                       padding: const EdgeInsets.fromLTRB(
//                         20,
//                         60,
//                         20,
//                         30,
//                       ),

//                       decoration: const BoxDecoration(
//                         color: Color(0xFF1F5EA8),
//                       ),

//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color:
//                                   Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),

//                             child: IconButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },

//                               icon: const Icon(
//                                 Icons.arrow_back_ios_new,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(width: 12),

//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,

//                               children: [
//                                 const Text(
//                                   'Edukasi IMD',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                 ),

//                                 const SizedBox(height: 4),

//                                 Text(
//                                   'Kenali pentingnya IMD untuk ibu dan bayi',
//                                   style: TextStyle(
//                                     color: Colors.white
//                                         .withOpacity(0.85),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   Padding(
//                     padding: const EdgeInsets.all(16),

//                     child: Column(
//                       children: [
//                         // CARD UTAMA
//                         Container(
//                           width: double.infinity,

//                           padding:
//                               const EdgeInsets.all(18),

//                           decoration: BoxDecoration(
//                             color:
//                                 const Color(0xFF1F5EA8),
//                             borderRadius:
//                                 BorderRadius.circular(20),
//                           ),

//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,

//                                 decoration: BoxDecoration(
//                                   color: Colors.white
//                                       .withOpacity(0.15),
//                                   shape: BoxShape.circle,
//                                 ),

//                                 child: const Icon(
//                                   Icons.checklist_rounded,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ),

//                               const SizedBox(width: 16),

//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment
//                                           .start,

//                                   children: [
//                                     const Text(
//                                       'Edukasi',
//                                       style: TextStyle(
//                                         color:
//                                             Colors.white70,
//                                         fontSize: 12,
//                                       ),
//                                     ),

//                                     const SizedBox(
//                                         height: 4),

//                                     Text(
//                                       item.judul,
//                                       style:
//                                           const TextStyle(
//                                         color:
//                                             Colors.white,
//                                         fontWeight:
//                                             FontWeight
//                                                 .bold,
//                                         fontSize: 20,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // APA ITU IMD
//                         _buildSectionCard(
//                           title: 'Apa itu IMD?',
//                           child: Text(
//                             item.isi,
//                             style: const TextStyle(
//                               height: 1.6,
//                               fontSize: 15,
//                               color:
//                                   Color(0xFF4B5563),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // MANFAAT
//                         _buildSectionCard(
//                           title: 'Manfaat IMD',

//                           child: Column(
//                             children: List.generate(
//                               manfaatList.length,
//                               (manfaatIndex) {
//                                 return Container(
//                                   padding:
//                                       const EdgeInsets
//                                           .symmetric(
//                                     vertical: 14,
//                                   ),

//                                   decoration:
//                                       BoxDecoration(
//                                     border: Border(
//                                       bottom: BorderSide(
//                                         color: Colors
//                                             .grey
//                                             .shade200,
//                                       ),
//                                     ),
//                                   ),

//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment
//                                             .start,

//                                     children: [
//                                       Container(
//                                         width: 32,
//                                         height: 32,

//                                         decoration:
//                                             BoxDecoration(
//                                           color:
//                                               const Color(
//                                             0xFFE7F8EF,
//                                           ),

//                                           borderRadius:
//                                               BorderRadius
//                                                   .circular(
//                                             10,
//                                           ),
//                                         ),

//                                         child: Center(
//                                           child: Text(
//                                             '${manfaatIndex + 1}',
//                                             style:
//                                                 const TextStyle(
//                                               color:
//                                                   Color(
//                                                 0xFF10B981,
//                                               ),

//                                               fontWeight:
//                                                   FontWeight
//                                                       .bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),

//                                       const SizedBox(
//                                           width: 14),

//                                       Expanded(
//                                         child: Text(
//                                           manfaatList[
//                                                   manfaatIndex]
//                                               .replaceAll(
//                                             RegExp(
//                                               r'^\d+\.\s*',
//                                             ),
//                                             '',
//                                           ),

//                                           style:
//                                               const TextStyle(
//                                             fontSize: 15,
//                                             height: 1.5,
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w600,
//                                             color: Color(
//                                               0xFF1F2937,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // LANGKAH
//                         _buildSectionCard(
//                           title: 'Langkah IMD',

//                           child: Text(
//                             item.langkah,
//                             style: const TextStyle(
//                               height: 1.7,
//                               fontSize: 15,
//                               color:
//                                   Color(0xFF4B5563),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 30),
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

//       padding: const EdgeInsets.all(20),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF111827),
//             ),
//           ),

//           const SizedBox(height: 16),

//           child,
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../data/models/edukasi_imd_model.dart';
import '../../data/repositories/edukasi_imd_repository.dart';
import '../../data/services/edukasi_imd_service.dart';
import 'edukasi_imd_detail_screen.dart';

/// Halaman DAFTAR edukasi IMD (Inisiasi Menyusu Dini).
///
/// Menampilkan SEMUA materi sebagai kartu. Saat satu kartu diketuk,
/// ibu dibawa ke halaman detail. Pola sama dengan edukasi lainnya.
class EdukasiIMDScreen extends StatefulWidget {
  const EdukasiIMDScreen({super.key});

  @override
  State<EdukasiIMDScreen> createState() => _EdukasiIMDScreenState();
}

class _EdukasiIMDScreenState extends State<EdukasiIMDScreen> {
  late Future<List<EdukasiIMDModel>> futureData;

  @override
  void initState() {
    super.initState();

    final repository = EdukasiIMDRepository(EdukasiIMDService());
    futureData = repository.getAllEdukasiIMD();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inisiasi Menyusu Dini',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Cara memulai menyusui sesaat setelah bayi lahir',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<EdukasiIMDModel>>(
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
              return _ImdCard(item: item);
            },
          );
        },
      ),
    );
  }
}

/// Kartu satu materi di halaman daftar.
class _ImdCard extends StatelessWidget {
  final EdukasiIMDModel item;

  const _ImdCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiImdDetailScreen(item: item),
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
                      'IMD',
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
          Icons.child_friendly_rounded,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }
}