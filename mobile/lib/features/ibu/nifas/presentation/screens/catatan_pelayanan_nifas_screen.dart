import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import '../../data/models/catatan_pelayanan_nifas_model.dart';
import '../../data/repositories/catatan_pelayanan_nifas_repository.dart';
import '../../data/services/catatan_pelayanan_nifas_service.dart';

class CatatanPelayananNifasScreen
    extends StatefulWidget {
  const CatatanPelayananNifasScreen({
    super.key,
  });

  @override
  State<CatatanPelayananNifasScreen>
      createState() =>
          _CatatanPelayananNifasScreenState();
}

class _CatatanPelayananNifasScreenState
    extends State<
        CatatanPelayananNifasScreen> {
  final repository =
      CatatanPelayananNifasRepository(
    CatatanPelayananNifasService(),
  );

  bool isLoading = true;

  List<CatatanPelayananNifasModel>
      data = [];

  @override
  void initState() {
    super.initState();

    initializeDateFormatting(
      'id_ID',
    );

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await repository.getMine();

      setState(() {
        data = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(
    DateTime? value,
  ) {
    if (value == null) {
      return '-';
    }

    return DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(value);
  }

  Widget buildItem(
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.all(
        14,
      ),

      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FBFF,
        ),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.08),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 12,

              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value.isEmpty
                ? '-'
                : value,

            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text(
          'Catatan Pelayanan Nifas',

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: loadData,

        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : data.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                                      context,
                                    )
                                    .size
                                    .height *
                                0.25,
                      ),

                      Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Container(
                              width: 90,
                              height: 90,

                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.08,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  24,
                                ),
                              ),

                              child: const Icon(
                                Icons
                                    .description_outlined,

                                color:
                                    AppColors
                                        .primary,

                                size: 42,
                              ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            const Text(
                              'Belum Ada Catatan Pelayanan',

                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            const Text(
                              'Catatan pelayanan nifas akan muncul di sini',

                              style:
                                  TextStyle(
                                color: Colors
                                    .black54,

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    itemCount:
                        data.length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final item =
                          data[index];

                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 18,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            26,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: AppColors
                                  .primary
                                  .withOpacity(
                                0.08,
                              ),

                              blurRadius:
                                  12,

                              offset:
                                  const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            Container(
                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets.all(
                                18,
                              ),

                              decoration:
                                  BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  colors: [
                                    AppColors
                                        .primary,

                                    AppColors
                                        .primary
                                        .withOpacity(
                                      0.82,
                                    ),
                                  ],

                                  begin:
                                      Alignment
                                          .topLeft,

                                  end: Alignment
                                      .bottomRight,
                                ),

                                borderRadius:
                                    const BorderRadius.only(
                                  topLeft:
                                      Radius.circular(
                                    26,
                                  ),

                                  topRight:
                                      Radius.circular(
                                    26,
                                  ),
                                ),
                              ),

                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor:
                                        Colors
                                            .white,

                                    child: Icon(
                                      Icons
                                          .note_alt_outlined,

                                      color:
                                          AppColors
                                              .primary,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        const Text(
                                          'Catatan Pemeriksaan',

                                          style:
                                              TextStyle(
                                            color:
                                                Colors.white,

                                            fontWeight:
                                                FontWeight.bold,

                                            fontSize:
                                                16,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              4,
                                        ),

                                        Text(
                                          formatDate(
                                            item
                                                .tanggalPeriksa,
                                          ),

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white70,

                                            fontSize:
                                                12,
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
                                  const EdgeInsets.all(
                                18,
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  buildItem(
                                    'Keluhan / Pemeriksaan / Tindakan / Saran',

                                    item.keluhan,
                                  ),

                                  buildItem(
                                    'Tanggal Kembali',

                                    formatDate(
                                      item
                                          .tanggalKembali,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}