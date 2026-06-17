import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/detail_imunisasi_terlewat.dart';


class DaftarImunisasiTerlewatScreen extends StatefulWidget {
  const DaftarImunisasiTerlewatScreen({
    super.key,
  });

  @override
  State<DaftarImunisasiTerlewatScreen> createState() =>
      _DaftarImunisasiTerlewatScreenState();
}

class _DaftarImunisasiTerlewatScreenState
    extends State<DaftarImunisasiTerlewatScreen> {
  final KunjunganImunisasiService _service =
      KunjunganImunisasiService();

  late Future<List<JadwalImunisasiTerlewatModel>>
      _imunisasiFuture;

  @override
  void initState() {
    super.initState();

    _imunisasiFuture =
        _service.getAllJadwalImunisasiTerlewat();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F5F9,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Imunisasi Terlewat',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1,
          ),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body:
          FutureBuilder<
            List<JadwalImunisasiTerlewatModel>
          >(
            future: _imunisasiFuture,
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                          24,
                        ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          'Gagal memuat data',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          snapshot.error
                              .toString(),
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _imunisasiFuture =
                                  _service
                                      .getAllJadwalImunisasiTerlewat();
                            });
                          },
                          child: const Text(
                            'Coba Lagi',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data =
                  snapshot.data ?? [];

              if (data.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada imunisasi terlewat',
                  ),
                );
              }

final darurat =
    data.where((e) => e.prioritas == 'P1').toList();

final tinggi =
    data.where((e) => e.prioritas == 'P2').toList();

final sedang =
    data.where((e) => e.prioritas == 'P3').toList();

return ListView(
  padding: const EdgeInsets.all(16),
  children: [

    if (darurat.isNotEmpty) ...[
      _buildSectionTitle(
        'Darurat',
        Colors.red,
      ),
      ...darurat.map(
        (item) => _buildItem(
          context,
          item,
        ),
      ),
      const SizedBox(height: 12),
    ],

    if (tinggi.isNotEmpty) ...[
      _buildSectionTitle(
        'Tinggi',
        Colors.orange,
      ),
      ...tinggi.map(
        (item) => _buildItem(
          context,
          item,
        ),
      ),
      const SizedBox(height: 12),
    ],

    if (sedang.isNotEmpty) ...[
      _buildSectionTitle(
        'Sedang',
        Colors.amber,
      ),
      ...sedang.map(
        (item) => _buildItem(
          context,
          item,
        ),
      ),
    ],
  ],
);
            },
          ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    JadwalImunisasiTerlewatModel item,
  ) {
    final color =
        _getPriorityColor(
          item.prioritas,
        );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
              18,
            ),
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          DetailImunisasiTerlewatScreen(
        jadwalId: item.jadwalId,
      ),
    ),
  );
},
        child: Container(
          padding:
              const EdgeInsets.all(
                16,
              ),
              
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                  18,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                      0.04,
                    ),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(
                        0.15,
                      ),
                  borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: color,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      item.namaAnak,
                      style:
                          const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w700,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      item.namaDosis,
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      '${item.jumlahHariTerlambat} hari terlambat',
                      style:
                          const TextStyle(
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
  String title,
  Color color,
) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 12,
      top: 8,
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

String _getPriorityLabel(
  String prioritas,
) {
  switch (prioritas) {
    case 'P1':
      return 'Darurat';

    case 'P2':
      return 'Tinggi';

    case 'P3':
      return 'Sedang';

    default:
      return '-';
  }
}
  Color _getPriorityColor(
    String prioritas,
  ) {
    switch (prioritas) {
      case 'P1':
        return Colors.red;

      case 'P2':
        return Colors.orange;

      case 'P3':
        return Colors.amber;

      default:
        return Colors.green;
    }
  }
}