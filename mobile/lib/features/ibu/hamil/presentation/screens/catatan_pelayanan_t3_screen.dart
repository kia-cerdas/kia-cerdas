// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

// class CatatanPelayananT3Screen extends StatefulWidget {
//   const CatatanPelayananT3Screen({super.key});

//   @override
//   State<CatatanPelayananT3Screen> createState() =>
//       _CatatanPelayananT3ScreenState();
// }

// class _CatatanPelayananT3ScreenState
//     extends State<CatatanPelayananT3Screen> {
//   bool isLoading = true;

//   List<dynamic> catatan = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCatatan();
//   }

//   Future<void> _loadCatatan() async {
//     try {
//       final token = AuthSession.token;

//       if (token == null || token.isEmpty) {
//         throw Exception(
//           "Token tidak ditemukan",
//         );
//       }

//       final response = await http.get(
//         Uri.parse(
//           ApiConstants.catatanPelayananT3,
//         ),

//         headers: {
//           "Authorization": "Bearer $token",
//         },
//       );

//       final body =
//           jsonDecode(response.body);

//       if (response.statusCode >= 200 &&
//           response.statusCode < 300) {
//         setState(() {
//           catatan = body["data"] ?? [];
//           isLoading = false;
//         });
//       } else {
//         throw Exception(
//           body["message"]?.toString() ??
//               "Gagal mengambil data",
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(e.toString()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   String _dateText(dynamic value) {
//     if (value == null ||
//         value.toString().isEmpty) {
//       return "-";
//     }

//     return value
//         .toString()
//         .split("T")
//         .first;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (catatan.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Container(
//               width: 90,
//               height: 90,

//               decoration: BoxDecoration(
//                 color: const Color(
//                   0xFFEFF6FF,
//                 ),

//                 borderRadius:
//                     BorderRadius.circular(24),
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: AppColors.primary,
//                 size: 42,
//               ),
//             ),

//             const SizedBox(height: 18),

//             const Text(
//               'Belum ada catatan pelayanan',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),

//             const SizedBox(height: 6),

//             const Text(
//               'Data pemeriksaan trimester 3 akan muncul di sini',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(
//         16,
//         8,
//         16,
//         24,
//       ),

//       itemCount: catatan.length,

//       itemBuilder: (context, index) {
//         final item = catatan[index];

//         return Container(
//           margin: const EdgeInsets.only(
//             bottom: 16,
//           ),

//           decoration: BoxDecoration(
//             color: Colors.white,

//             borderRadius:
//                 BorderRadius.circular(24),

//             border: Border.all(
//               color: const Color(
//                 0xFFE2E8F0,
//               ),
//             ),

//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black
//                     .withValues(alpha: 0.04),

//                 blurRadius: 10,

//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),

//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,

//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 18,
//                   vertical: 14,
//                 ),

//                 decoration:
//                     const BoxDecoration(
//                   color: Color(0xFFEFF6FF),

//                   borderRadius:
//                       BorderRadius.only(
//                     topLeft:
//                         Radius.circular(24),
//                     topRight:
//                         Radius.circular(24),
//                   ),
//                 ),

//                 child: Row(
//                   children: [
//                     Container(
//                       width: 42,
//                       height: 42,

//                       decoration: BoxDecoration(
//                         color: AppColors.primary
//                             .withValues(alpha: 0.12),

//                         borderRadius:
//                             BorderRadius.circular(
//                           14,
//                         ),
//                       ),

//                       child: const Icon(
//                         Icons.description_outlined,
//                         color: AppColors.primary,
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment
//                                 .start,

//                         children: [
//                           const Text(
//                             'Tanggal Pemeriksaan',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color:
//                                   Colors.black54,
//                             ),
//                           ),

//                           const SizedBox(
//                             height: 2,
//                           ),

//                           Text(
//                             _dateText(
//                               item[
//                                   "tanggal_periksa_stamp_paraf"],
//                             ),

//                             style:
//                                 const TextStyle(
//                               fontSize: 15,
//                               fontWeight:
//                                   FontWeight.bold,
//                               color:
//                                   AppColors.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Padding(
//                 padding:
//                     const EdgeInsets.all(18),

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [
//                     const Text(
//                       "Keluhan & Pemeriksaan",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight:
//                             FontWeight.w700,
//                         color: Colors.black54,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       item[
//                               "keluhan_pemeriksaan_tindakan_saran"] ??
//                           "-",

//                       style: const TextStyle(
//                         fontSize: 14,
//                         height: 1.6,
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),

//                       decoration: BoxDecoration(
//                         color: const Color(
//                           0xFFF8FAFC,
//                         ),

//                         borderRadius:
//                             BorderRadius.circular(
//                           14,
//                         ),
//                       ),

//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.calendar_month,
//                             size: 18,
//                             color:
//                                 AppColors.primary,
//                           ),

//                           const SizedBox(width: 8),

//                           Expanded(
//                             child: Text(
//                               "Kembali periksa: ${_dateText(item["tanggal_kembali"])}",

//                               style:
//                                   const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight:
//                                     FontWeight
//                                         .w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class CatatanPelayananT3Screen extends StatefulWidget {
  const CatatanPelayananT3Screen({super.key});

  @override
  State<CatatanPelayananT3Screen> createState() =>
      _CatatanPelayananT3ScreenState();
}

class _CatatanPelayananT3ScreenState
    extends State<CatatanPelayananT3Screen> {
  bool isLoading = true;

  List<dynamic> catatan = [];

  @override
  void initState() {
    super.initState();
    _loadCatatan();
  }

  Future<void> _loadCatatan() async {
    try {
      final token = AuthSession.token;

      if (token == null || token.isEmpty) {
        throw Exception(
          "Token tidak ditemukan",
        );
      }

      final response = await http.get(
        Uri.parse(
          ApiConstants.catatanPelayananT3,
        ),

        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final body =
          jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        setState(() {
          catatan = body["data"] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception(
          body["message"]?.toString() ??
              "Gagal mengambil data",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _dateText(dynamic value) {
    if (value == null ||
        value.toString().isEmpty) {
      return "-";
    }

    return value
        .toString()
        .split("T")
        .first;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (catatan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: const Color(
                  0xFFEFF6FF,
                ),

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 42,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Belum ada catatan pelayanan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Data pemeriksaan trimester 3 akan muncul di sini',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24,
      ),

      itemCount: catatan.length,

      itemBuilder: (context, index) {
        final item = catatan[index];

        return Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(24),

            border: Border.all(
              color: const Color(
                0xFFE2E8F0,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.04),

                blurRadius: 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),

                decoration:
                    const BoxDecoration(
                  color: Color(0xFFEFF6FF),

                  borderRadius:
                      BorderRadius.only(
                    topLeft:
                        Radius.circular(24),
                    topRight:
                        Radius.circular(24),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.12),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            'Tanggal Pemeriksaan',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.black54,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            _dateText(
                              item[
                                  "tanggal_periksa"],
                            ),

                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Rekomendasi Tempat Melahirkan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item[
                              "kesimpulan_rekomendasi_tempat_melahirkan"] ??
                          "-",

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}