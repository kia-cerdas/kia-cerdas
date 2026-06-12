import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
import 'rujukan_detail_screen.dart';

class RujukanListScreen extends StatefulWidget {
  const RujukanListScreen({super.key});

  @override
  State<RujukanListScreen> createState() =>
      _RujukanListScreenState();
}

class _RujukanListScreenState
    extends State<RujukanListScreen> {

  final _kehamilanService =
      KehamilanApiService();

  bool isLoading = true;

  List<dynamic> rujukanList = [];

  @override
  void initState() {
    super.initState();
    _loadRujukan();
  }

  Future<void> _loadRujukan() async {
    try {

      final kehamilan =
          await _kehamilanService
              .getKehamilanAktif();

      final data =
          await _kehamilanService
              .getRujukanByKehamilanId(
                kehamilan.id,
              );

      if (!mounted) return;

      setState(() {
        rujukanList = data;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
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

    return value.toString().split("T").first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),

      appBar: AppBar(
        title: const Text(
          "Surat Rekomendasi Rujukan",
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: isLoading

          // LOADING
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          // EMPTY STATE
          : rujukanList.isEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Container(
                          padding:
                              const EdgeInsets.all(
                                  24),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .blue.shade50,

                            shape:
                                BoxShape.circle,
                          ),

                          child: Icon(
                            Icons
                                .health_and_safety_outlined,

                            size: 56,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        const SizedBox(
                            height: 26),

                        Text(
                          "Belum Ada Rujukan Saat Ini",

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors
                                .grey.shade800,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          "Ibu belum menerima surat rekomendasi rujukan dari bidan atau tenaga kesehatan.",

                          textAlign:
                              TextAlign.center,

                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors
                                .grey.shade600,
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors.white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),

                            border: Border.all(
                              color: Colors
                                  .blue.shade100,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withValues(
                                        alpha:
                                            0.03),

                                blurRadius: 10,

                                offset:
                                    const Offset(
                                        0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              Icon(
                                Icons
                                    .favorite_outline,

                                size: 18,

                                color:
                                    AppColors.primary,
                              ),

                              const SizedBox(
                                  width: 8),

                              Flexible(
                                child: Text(
                                  "Tetap semangat menjaga kesehatan ya, Bu 💙",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey
                                        .shade700,

                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // LIST DATA
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(18),

                  itemCount:
                      rujukanList.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                        rujukanList[index];

                    return Container(
                      margin:
                          const EdgeInsets.only(
                              bottom: 16),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                                    alpha:
                                        0.05),

                            blurRadius: 12,

                            offset:
                                const Offset(
                                    0, 5),
                          ),
                        ],
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(
                                18),

                        leading: Container(
                          width: 54,
                          height: 54,

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .blue.shade50,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),
                          ),

                          child: Icon(
                            Icons
                                .description_outlined,

                            color:
                                AppColors.primary,

                            size: 28,
                          ),
                        ),

                        title: Text(
                          item["rujukan_diagnosis_akhir"]
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? item[
                                  "rujukan_diagnosis_akhir"]
                              : "Rujukan Kehamilan",

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,
                          ),
                        ),

                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(
                                  top: 10),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                "Tanggal kontrol kembali: ${_dateText(item["rujukan_balik_tanggal"])}",

                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey
                                      .shade700,

                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(
                                  height: 8),

                              Row(
                                children: [

                                  Icon(
                                    Icons
                                        .touch_app_outlined,

                                    size: 17,

                                    color:
                                        AppColors
                                            .primary,
                                  ),

                                  const SizedBox(
                                      width: 6),

                                  Expanded(
                                    child: Text(
                                      "Tap untuk melihat langkah yang perlu Ibu lakukan",

                                      style:
                                          TextStyle(
                                        fontSize:
                                            12.5,

                                        color:
                                            AppColors
                                                .primary,

                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        trailing: Icon(
                          Icons
                              .chevron_right_rounded,

                          color: Colors
                              .grey.shade500,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                                  RujukanDetailScreen(
                                data: item,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}