// import 'package:flutter/material.dart';
// import '../../data/models/edukasi_nifas_model.dart';
// import '../../data/repositories/edukasi_nifas_repository.dart';
// import '../../data/services/edukasi_nifas_service.dart';

// class EdukasiNifasScreen extends StatefulWidget {
//   const EdukasiNifasScreen({super.key});

//   @override
//   State<EdukasiNifasScreen> createState() => _EdukasiNifasScreenState();
// }

// class _EdukasiNifasScreenState extends State<EdukasiNifasScreen> {
//   late Future<List<EdukasiNifasModel>> futureData;

//   @override
//   void initState() {
//     super.initState();
//     final repository = EdukasiNifasRepository(EdukasiNifasService());
//     futureData = repository.getAllEdukasiNifas();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: FutureBuilder<List<EdukasiNifasModel>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }

//           final data = snapshot.data ?? [];

//           if (data.isEmpty) {
//             return const Center(child: Text('Data edukasi kosong'));
//           }

//           return ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final item = data[index];

//               return Column(
//                 children: [
//                   if (index == 0)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//                       decoration: BoxDecoration(color: Color(0xFF1F5EA8)),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Edukasi Nifas',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   'Pelajari perawatan ibu setelah melahirkan',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.85),
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
//                         // CARD JUDUL
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(18),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1F5EA8),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.15),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(Icons.favorite, color: Colors.white, size: 30),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Text(
//                                   item.judul,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // CARD ISI KONTEN
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Tentang Masa Nifas',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF111827),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 item.isi,
//                                 style: const TextStyle(
//                                   height: 1.6,
//                                   fontSize: 15,
//                                   color: Color(0xFF4B5563),
//                                 ),
//                               ),
//                             ],
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
// }


import 'package:flutter/material.dart';
import '../../data/models/edukasi_nifas_model.dart';
import '../../data/repositories/edukasi_nifas_repository.dart';
import '../../data/services/edukasi_nifas_service.dart';

class EdukasiNifasScreen extends StatefulWidget {
  const EdukasiNifasScreen({super.key});

  @override
  State<EdukasiNifasScreen> createState() => _EdukasiNifasScreenState();
}

class _EdukasiNifasScreenState extends State<EdukasiNifasScreen> {
  late Future<List<EdukasiNifasModel>> futureData;

  @override
  void initState() {
    super.initState();
    final repository = EdukasiNifasRepository(EdukasiNifasService());
    futureData = repository.getAllEdukasiNifas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: FutureBuilder<List<EdukasiNifasModel>>(
        future: futureData,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Data edukasi kosong'));
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length,

            itemBuilder: (context, index) {
              final item = data[index];

              final isiList = item.isi
                  .split('\n')
                  .where((e) => e.trim().isNotEmpty)
                  .toList();

              return Column(
                children: [
                  if (index == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F5EA8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edukasi Setelah Melahirkan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Panduan perawatan ibu setelah melahirkan',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // CARD JUDUL
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F5EA8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pregnant_woman,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Edukasi',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.judul,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CARD ISI - jika isi punya banyak baris, tampilkan sebagai list bernomor
                        _buildSectionCard(
                          title: 'Informasi',
                          child: isiList.length > 1
                              ? Column(
                                  children: List.generate(
                                    isiList.length,
                                    (i) => Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0EAFB),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${i + 1}',
                                                style: const TextStyle(
                                                  color: Color(0xFF1F5EA8),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              isiList[i].replaceAll(
                                                RegExp(r'^\d+\.\s*'),
                                                '',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                height: 1.5,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  item.isi,
                                  style: const TextStyle(
                                    height: 1.6,
                                    fontSize: 15,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../data/models/edukasi_nifas_model.dart';
// import '../../data/repositories/edukasi_nifas_repository.dart';
// import '../../data/services/edukasi_nifas_service.dart';

// class EdukasiNifasScreen extends StatefulWidget {
//   const EdukasiNifasScreen({super.key});

//   @override
//   State<EdukasiNifasScreen> createState() => _EdukasiNifasScreenState();
// }

// class _EdukasiNifasScreenState extends State<EdukasiNifasScreen> {
//   late Future<List<EdukasiNifasModel>> futureData;

//   @override
//   void initState() {
//     super.initState();
//     final repository = EdukasiNifasRepository(EdukasiNifasService());
//     futureData = repository.getAllEdukasiNifas();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: FutureBuilder<List<EdukasiNifasModel>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }

//           final data = snapshot.data ?? [];

//           if (data.isEmpty) {
//             return const Center(child: Text('Data edukasi kosong'));
//           }

//           return ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final item = data[index];

//               final isiList = item.isi
//                   .split('\n')
//                   .where((e) => e.trim().isNotEmpty)
//                   .toList();

//               return Column(
//                 children: [
//                   if (index == 0)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF1F5EA8),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(
//                                 Icons.arrow_back_ios_new,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Edukasi Setelah Melahirkan',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Panduan perawatan ibu setelah melahirkan',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.85),
//                                     fontSize: 13,
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
//                         // CARD JUDUL
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(18),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1F5EA8),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 56,
//                                 height: 56,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.15),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.pregnant_woman,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Edukasi',
//                                       style: TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       item.judul,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
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

//                         // ✅ GAMBAR - tampilkan jika gambarUrl tidak kosong
//                         if (item.gambarUrl.isNotEmpty)
//                           Container(
//                             width: double.infinity,
//                             margin: const EdgeInsets.only(bottom: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(20),
//                               child: Image.network(
//                                 item.gambarUrl,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Container(
//                                     height: 200,
//                                     color: const Color(0xFFE0EAFB),
//                                     child: const Center(
//                                       child: CircularProgressIndicator(
//                                         color: Color(0xFF1F5EA8),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 200,
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFE0EAFB),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: const Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.broken_image_outlined,
//                                           color: Color(0xFF1F5EA8),
//                                           size: 40,
//                                         ),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           'Gambar tidak tersedia',
//                                           style: TextStyle(
//                                             color: Color(0xFF1F5EA8),
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),

//                         // CARD ISI
//                         _buildSectionCard(
//                           title: 'Informasi',
//                           child: isiList.length > 1
//                               ? Column(
//                                   children: List.generate(
//                                     isiList.length,
//                                     (i) => Container(
//                                       padding: const EdgeInsets.symmetric(vertical: 12),
//                                       decoration: BoxDecoration(
//                                         border: Border(
//                                           bottom: BorderSide(
//                                             color: Colors.grey.shade200,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Container(
//                                             width: 32,
//                                             height: 32,
//                                             decoration: BoxDecoration(
//                                               color: const Color(0xFFE0EAFB),
//                                               borderRadius: BorderRadius.circular(10),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 '${i + 1}',
//                                                 style: const TextStyle(
//                                                   color: Color(0xFF1F5EA8),
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 14),
//                                           Expanded(
//                                             child: Text(
//                                               isiList[i].replaceAll(
//                                                 RegExp(r'^\d+\.\s*'),
//                                                 '',
//                                               ),
//                                               style: const TextStyle(
//                                                 fontSize: 15,
//                                                 height: 1.5,
//                                                 color: Color(0xFF1F2937),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Text(
//                                   item.isi,
//                                   style: const TextStyle(
//                                     height: 1.6,
//                                     fontSize: 15,
//                                     color: Color(0xFF4B5563),
//                                   ),
//                                 ),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
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