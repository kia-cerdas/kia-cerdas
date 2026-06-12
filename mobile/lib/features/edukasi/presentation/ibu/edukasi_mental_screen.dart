import 'package:flutter/material.dart';

import '../../data/models/edukasi_mental_model.dart';
import '../../data/repositories/edukasi_mental_repository.dart';
import '../../data/services/edukasi_mental_service.dart';

class EdukasiKesehatanMentalScreen
    extends StatefulWidget {
  const EdukasiKesehatanMentalScreen({
    super.key,
  });

  @override
  State<EdukasiKesehatanMentalScreen>
      createState() =>
          _EdukasiKesehatanMentalScreenState();
}

class _EdukasiKesehatanMentalScreenState
    extends State<EdukasiKesehatanMentalScreen> {
  late Future<List<EdukasiKesehatanMentalModel>>
      futureData;

  @override
  void initState() {
    super.initState();

    final repository =
        EdukasiKesehatanMentalRepository(
      EdukasiKesehatanMentalService(),
    );

    futureData =
        repository.getAllEdukasiKesehatanMental();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: FutureBuilder<
          List<EdukasiKesehatanMentalModel>>(
        future: futureData,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Data edukasi kosong',
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length,

            itemBuilder: (context, index) {
              final item = data[index];

              final tandaGejalaList = item
                  .tandaGejala
                  .split('\n')
                  .where(
                    (e) => e.trim().isNotEmpty,
                  )
                  .toList();

              final solusiList = item.solusi
                  .split('\n')
                  .where(
                    (e) => e.trim().isNotEmpty,
                  )
                  .toList();

              return Column(
                children: [
                  if (index == 0)
                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        60,
                        20,
                        30,
                      ),

                      decoration:
                          const BoxDecoration(
                        color: Color(0xFF1F5EA8),
                      ),

                      child: Row(
                        children: [
                          Container(
                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(
                                0.2,
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },

                              icon: const Icon(
                                Icons
                                    .arrow_back_ios_new,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                const Text(
                                  'Kesehatan Mental',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,

                                    fontSize: 24,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  'Jaga kesehatan mental ibu selama kehamilan',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.85,
                                    ),
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
                        const EdgeInsets.all(16),

                    child: Column(
                      children: [
                        // CARD
                        Container(
                          width: double.infinity,

                          padding:
                              const EdgeInsets
                                  .all(18),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFF1F5EA8,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.15,
                                  ),

                                  shape: BoxShape
                                      .circle,
                                ),

                                child: const Icon(
                                  Icons
                                      .psychology,
                                  color:
                                      Colors
                                          .white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(
                                width: 16,
                              ),

                              Expanded(
                                child: Text(
                                  item.judul,
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white,

                                    fontSize: 20,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ISI
                        _buildSectionCard(
                          title:
                              'Tentang Edukasi',

                          child: Text(
                            item.isi,

                            style:
                                const TextStyle(
                              height: 1.6,
                              fontSize: 15,
                              color:
                                  Color(
                                0xFF4B5563,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // TANDA GEJALA
                        _buildSectionCard(
                          title:
                              'Tanda dan Gejala',

                          child: Column(
                            children:
                                List.generate(
                              tandaGejalaList
                                  .length,
                              (i) {
                                return _buildListItem(
                                  number:
                                      '${i + 1}',
                                  text:
                                      tandaGejalaList[
                                              i]
                                          .replaceAll(
                                    RegExp(
                                      r'^\d+\.\s*',
                                    ),
                                    '',
                                  ),
                                  color:
                                      const Color(
                                    0xFFF59E0B,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // SOLUSI
                        _buildSectionCard(
                          title: 'Solusi',

                          child: Column(
                            children:
                                List.generate(
                              solusiList.length,
                              (i) {
                                return _buildListItem(
                                  number:
                                      '${i + 1}',
                                  text:
                                      solusiList[
                                              i]
                                          .replaceAll(
                                    RegExp(
                                      r'^\d+\.\s*',
                                    ),
                                    '',
                                  ),
                                  color:
                                      const Color(
                                    0xFF10B981,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),
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
        borderRadius:
            BorderRadius.circular(20),
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

  Widget _buildListItem({
    required String number,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 32,
            height: 32,

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}