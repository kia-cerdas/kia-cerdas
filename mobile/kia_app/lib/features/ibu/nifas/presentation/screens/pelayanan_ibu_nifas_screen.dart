import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import '../../data/models/pelayanan_ibu_nifas_model.dart';
import '../../data/repositories/pelayanan_ibu_nifas_repository.dart';
import '../../data/services/pelayanan_ibu_nifas_service.dart';

class PelayananIbuNifasScreen extends StatefulWidget {
  const PelayananIbuNifasScreen({super.key});

  @override
  State<PelayananIbuNifasScreen> createState() =>
      _PelayananIbuNifasScreenState();
}

class _PelayananIbuNifasScreenState
    extends State<PelayananIbuNifasScreen> {
  final repository = PelayananIbuNifasRepository(
    PelayananIbuNifasService(),
  );

  bool isLoading = true;

  List<PelayananIbuNifasModel> data = [];

  String selectedKunjungan = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final result = await repository.getMine();

      setState(() {
        data = result;

        if (result.isNotEmpty) {
          selectedKunjungan =
              result.first.kunjunganKe;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(date);
  }

  Widget buildItem(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKunjunganSelector() {
    final kunjunganList = data
        .map((e) => e.kunjunganKe)
        .toSet()
        .toList();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: kunjunganList.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = kunjunganList[index];

          final isSelected =
              selectedKunjungan == item;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedKunjungan = item;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.primary,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = data
        .where(
          (e) =>
              e.kunjunganKe ==
              selectedKunjungan,
        )
        .toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Pelayanan Ibu Nifas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: data.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(
                                        context,
                                      )
                                      .size
                                      .height *
                                  0.3,
                        ),
                        const Center(
                          child: Text(
                            'Belum ada data pelayanan nifas',
                            style: TextStyle(
                              color:
                                  Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [

                        const SizedBox(
                          height: 16,
                        ),

                        _buildKunjunganSelector(),

                        const SizedBox(
                          height: 16,
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding:
                                const EdgeInsets
                                    .all(16),
                            itemCount:
                                filteredData.length,
                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                              final item =
                                  filteredData[
                                      index];

                              return Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 18,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    24,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                        0.05,
                                      ),
                                      blurRadius:
                                          10,
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
                                      width: double
                                          .infinity,
                                      padding:
                                          const EdgeInsets
                                              .all(
                                        18,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            AppColors
                                                .primary,
                                        borderRadius:
                                            const BorderRadius
                                                .only(
                                          topLeft:
                                              Radius
                                                  .circular(
                                            24,
                                          ),
                                          topRight:
                                              Radius
                                                  .circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundColor:
                                                Colors
                                                    .white,
                                            child:
                                                Icon(
                                              Icons
                                                  .monitor_heart_outlined,
                                              color:
                                                  AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(
                                            width:
                                                12,
                                          ),
                                          Expanded(
                                            child:
                                                Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  item
                                                      .kunjunganKe,
                                                  style:
                                                      const TextStyle(
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
                                                    item.tanggalPeriksa,
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
                                          const EdgeInsets
                                              .all(
                                        18,
                                      ),
                                      child:
                                          Column(
                                        children: [

                                          buildItem(
                                            'Tekanan Darah',
                                            item.tandaVitalTekananDarah,
                                          ),

                                          buildItem(
                                            'Suhu Tubuh',
                                            item.tandaVitalSuhuTubuh?.toString() ??
                                                '-',
                                          ),

                                          buildItem(
                                            'Involusi Uteri',
                                            item.pelayananInvolusiUteri,
                                          ),

                                          buildItem(
                                            'Cairan Pervaginam',
                                            item.pelayananCairanPervaginam,
                                          ),

                                          buildItem(
                                            'Pemeriksaan Jalan Lahir',
                                            item.pelayananPeriksaJalanLahir,
                                          ),

                                          buildItem(
                                            'Pemeriksaan Payudara',
                                            item.pelayananPeriksaPayudara,
                                          ),

                                          buildItem(
                                            'ASI Eksklusif',
                                            item.pelayananAsiEksklusif,
                                          ),

                                          buildItem(
                                            'Vitamin A',
                                            item.pemberianKapsulVitaminA
                                                ? 'Diberikan'
                                                : 'Tidak',
                                          ),

                                          buildItem(
                                            'Tablet Tambah Darah',
                                            item.pemberianTabletTambahDarahJumlah
                                                    ?.toString() ??
                                                '-',
                                          ),

                                          buildItem(
                                            'Skrining Depresi',
                                            item.pelayananSkriningDepresiNifas,
                                          ),

                                          buildItem(
                                            'KB Pasca Persalinan',
                                            item.pelayananKontrasepsiPascaPersalinan,
                                          ),

                                          buildItem(
                                            'Risiko Malaria',
                                            item.pelayananPenangananRisikoMalaria,
                                          ),

                                          buildItem(
                                            'Komplikasi Nifas',
                                            item.komplikasiNifas,
                                          ),

                                          buildItem(
                                            'Tindakan / Saran',
                                            item.tindakanSaran,
                                          ),

                                          buildItem(
                                            'Pemeriksa',
                                            item.namaPemeriksaParaf,
                                          ),

                                          buildItem(
                                            'Tanggal Kembali',
                                            formatDate(
                                              item.tanggalKembali,
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
                      ],
                    ),
            ),
    );
  }
}