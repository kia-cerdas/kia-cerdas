import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

import '../../data/models/ringkasan_persalinan_model.dart';
import '../../data/repositories/ringkasan_persalinan_repository.dart';
import '../../data/services/ringkasan_persalinan_service.dart';

class RingkasanPersalinanScreen extends StatefulWidget {
  final String token;

  const RingkasanPersalinanScreen({
    super.key,
    required this.token,
  });

  @override
  State<RingkasanPersalinanScreen> createState() =>
      _RingkasanPersalinanScreenState();
}

class _RingkasanPersalinanScreenState
    extends State<RingkasanPersalinanScreen> {

  late Future<List<RingkasanPersalinanModel>> futureData;

  @override
  void initState() {
    super.initState();

    final repository = RingkasanPersalinanRepository(
      RingkasanPersalinanService(),
    );

    futureData = repository.getData(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Ringkasan Persalinan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<List<RingkasanPersalinanModel>>(
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
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,

            itemBuilder: (context, index) {
              return _buildCard(data[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(
    RingkasanPersalinanModel item,
  ) {

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(
                  Icons.child_friendly_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      item.caraMelahirkan ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.penolongProsesMelahirkan ?? '-',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Informasi Persalinan",
          ),

          const SizedBox(height: 14),

          _infoTile(
            Icons.calendar_month,
            "Tanggal Melahirkan",
            item.tanggalMelahirkan ?? '-',
          ),

          _infoTile(
            Icons.access_time,
            "Pukul Melahirkan",
            item.pukulMelahirkan ?? '-',
          ),

          _infoTile(
            Icons.monitor_weight_outlined,
            "Usia Kehamilan",
            "${item.umurKehamilanMinggu ?? 0} Minggu",
          ),

          _infoTile(
            Icons.favorite_outline,
            "Keadaan Ibu",
            item.keadaanIbu ?? '-',
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Data Bayi",
          ),

          const SizedBox(height: 14),

          _infoTile(
            Icons.person_outline,
            "Jenis Kelamin",
            item.bayiJenisKelamin ?? '-',
          ),

          _infoTile(
            Icons.scale,
            "Berat Bayi",
            "${item.bayiBeratLahirGram ?? 0} gram",
          ),

          _infoTile(
            Icons.height,
            "Panjang Badan",
            "${item.bayiPanjangBadanCm ?? 0} cm",
          ),

          _infoTile(
            Icons.circle_outlined,
            "Lingkar Kepala",
            "${item.bayiLingkarKepalaCm ?? 0} cm",
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Asuhan Bayi",
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [

              if (item.asuhanImd1JamPertama == true)
                _chip("IMD 1 Jam Pertama"),

              if (item.asuhanSuntikanVitaminK1 == true)
                _chip("Vitamin K1"),

              if (item.asuhanSalepMataAntibiotika == true)
                _chip("Salep Mata"),

              if (item.asuhanImunisasiHb0 == true)
                _chip("Imunisasi HB0"),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            "Keterangan Bayi",
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Text(
              item.keteranganTambahanBayi?.isEmpty == true
                  ? "-"
                  : item.keteranganTambahanBayi ?? '-',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
  ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  label,

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}