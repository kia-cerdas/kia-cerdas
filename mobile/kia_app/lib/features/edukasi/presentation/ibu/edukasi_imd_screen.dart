import 'package:flutter/material.dart';

import '../../data/models/edukasi_imd_model.dart';
import '../../data/repositories/edukasi_imd_repository.dart';
import '../../data/services/edukasi_imd_service.dart';

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

    final repository = EdukasiIMDRepository(
      EdukasiIMDService(),
    );

    futureData = repository.getAllEdukasiIMD();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: FutureBuilder<List<EdukasiIMDModel>>(
        future: futureData,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Data edukasi kosong'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length,

            itemBuilder: (context, index) {
              final item = data[index];

              final manfaatList = item.manfaat
                  .split('\n')
                  .where((e) => e.trim().isNotEmpty)
                  .toList();

              return Column(
                children: [
                  if (index == 0)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(
                        20,
                        60,
                        20,
                        30,
                      ),

                      decoration: const BoxDecoration(
                        color: Color(0xFF1F5EA8),
                      ),

                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'Edukasi IMD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Kenali pentingnya IMD untuk ibu dan bayi',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.85),
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
                        // CARD UTAMA
                        Container(
                          width: double.infinity,

                          padding:
                              const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1F5EA8),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,

                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.checklist_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    const Text(
                                      'Edukasi',
                                      style: TextStyle(
                                        color:
                                            Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 4),

                                    Text(
                                      item.judul,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontWeight:
                                            FontWeight
                                                .bold,
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

                        // APA ITU IMD
                        _buildSectionCard(
                          title: 'Apa itu IMD?',
                          child: Text(
                            item.isi,
                            style: const TextStyle(
                              height: 1.6,
                              fontSize: 15,
                              color:
                                  Color(0xFF4B5563),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // MANFAAT
                        _buildSectionCard(
                          title: 'Manfaat IMD',

                          child: Column(
                            children: List.generate(
                              manfaatList.length,
                              (manfaatIndex) {
                                return Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 14,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors
                                            .grey
                                            .shade200,
                                      ),
                                    ),
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFFE7F8EF,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            10,
                                          ),
                                        ),

                                        child: Center(
                                          child: Text(
                                            '${manfaatIndex + 1}',
                                            style:
                                                const TextStyle(
                                              color:
                                                  Color(
                                                0xFF10B981,
                                              ),

                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 14),

                                      Expanded(
                                        child: Text(
                                          manfaatList[
                                                  manfaatIndex]
                                              .replaceAll(
                                            RegExp(
                                              r'^\d+\.\s*',
                                            ),
                                            '',
                                          ),

                                          style:
                                              const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: Color(
                                              0xFF1F2937,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // LANGKAH
                        _buildSectionCard(
                          title: 'Langkah IMD',

                          child: Text(
                            item.langkah,
                            style: const TextStyle(
                              height: 1.7,
                              fontSize: 15,
                              color:
                                  Color(0xFF4B5563),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,

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