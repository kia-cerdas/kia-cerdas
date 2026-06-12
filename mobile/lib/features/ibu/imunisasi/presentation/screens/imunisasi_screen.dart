import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/services/imunisasi_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/imunisasi_detail.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/ubah_jadwal.dart';

class ImunisasiScreen extends StatefulWidget {
  final int anakId;

  const ImunisasiScreen({
    super.key,
    required this.anakId,
    required String namaAnak,
  });

  @override
  State<ImunisasiScreen> createState() => _ImunisasiScreenState();
}

class _ImunisasiScreenState extends State<ImunisasiScreen> {
  final ImunisasiService _service = ImunisasiService();
  Future<List<ImunisasiModel>>? _futureJadwal;

  bool _isUpdating = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureJadwal = _service.getJadwalImunisasiByAnakId(
        widget.anakId,
      );
    });
  }

  String formatTanggal(DateTime? date) {
    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(date);
  }

  // Future<void> _setSelesai(int jadwalId) async {
  //   try {
  //     setState(() {
  //       _isUpdating = true;
  //     });

  //     await _service.setJadwalSelesai(jadwalId);

  //     _loadData();
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.toString())),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isUpdating = false;
  //       });
  //     }
  //   }
  // }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mendekati':
        return Colors.orange;

      case 'jatuh tempo':
        return Colors.blue;

      case 'terlewat':
        return Colors.red;

      case 'terlambat':
        return Colors.deepOrange;

      case 'krisis':
        return Colors.red.shade900;

      default:
        return Colors.greenAccent;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({
    required String title,
    required Color color,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImunisasiItem(
    BuildContext context,
    dynamic item, {
    required bool isEditable,
  }) {
    final date = item.tanggalEstimasi;

    final day = date != null ? DateFormat('dd').format(date) : '--';

    final monthYear =
        date != null ? DateFormat('MMM yyyy', 'id_ID').format(date) : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        /// OUTLINE ABU-ABU
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),

        /// SHADOW HALUS (tetap dipertahankan biar tidak flat)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TANGGAL (TETAP NETRAL)
                Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monthYear,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                /// INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// STATUS (ONLY THIS CHANGES COLOR)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(item.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: getStatusColor(item.status),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        item.namaDosis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Jadwal imunisasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 12),

            /// BUTTONS (TETAP)
            Column(
              children: [
                /// ROW 1: ACTION UTAMA + SEKUNDER
                Row(
                  children: [
                    /// UBAH JADWAL
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: item.statusId == 6
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UbahJadwalScreen(
                                      jadwalId: item.jadwalId,
                                    ),
                                  ),
                                );
                              },
                        icon: Icon(
                          Icons.event_repeat_rounded,
                          size: 18,
                          color:
                              item.statusId == 6 ? Colors.grey : Colors.black,
                        ),
                        label: Text(
                          'Ubah Jadwal',
                          style: TextStyle(
                            color:
                                item.statusId == 6 ? Colors.grey : Colors.black,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// LIHAT RINCIAN
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showImunisasiDetailModal(context, item);
                        },
                        icon: const Icon(
                          Icons.article_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Rincian Imunisasi',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// ROW 2: SELESAI (FULL WIDTH)
                // if (item.statusId != 6) ...[
                //   const SizedBox(height: 10),
                //   SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton(
                //       onPressed:
                //           _isUpdating ? null : () => _setSelesai(item.jadwalId),
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.green,
                //         disabledBackgroundColor: Colors.grey,
                //         elevation: 0,
                //         padding: const EdgeInsets.symmetric(vertical: 14),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(14),
                //         ),
                //       ),
                //       child: _isUpdating
                //           ? const SizedBox(
                //               width: 18,
                //               height: 18,
                //               child: CircularProgressIndicator(
                //                 strokeWidth: 2,
                //                 color: Colors.white,
                //               ),
                //             )
                //           : Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: const [
                //                 Icon(
                //                   Icons.task_alt,
                //                   color: Colors.white,
                //                   size: 18,
                //                 ),
                //                 SizedBox(width: 8),
                //                 Text(
                //                   'Selesai',
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //     ),
                //   ),
                // ],
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Imunisasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      body: _futureJadwal == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder<List<ImunisasiModel>>(
              future: _futureJadwal,
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada jadwal imunisasi',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadData();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      /// HEADER INFO (INDEX 0)
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(),
                        );
                      }

                      final anak = data[index - 1];

                      final perhatian = anak.jadwal.where((j) {
                        final status = j.status.toLowerCase();
                        return status == 'terlewat' ||
                            status == 'krisis' ||
                            status == 'terlambat';
                      }).toList();

                      final mendekati = anak.jadwal.where((j) {
                        final status = j.status.toLowerCase();
                        return status == 'mendekati' || status == 'jatuh tempo';
                      }).toList();

                      final selesai = anak.jadwal.where((j) {
                        final status = j.status.toLowerCase();
                        return status == 'selesai' ||
                            status == 'sudah dilakukan';
                      }).toList();

                      final lainnya = anak.jadwal.where((j) {
                        return !perhatian.contains(j) &&
                            !mendekati.contains(j) &&
                            !selesai.contains(j);
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER ANAK
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2196F3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.child_care_rounded,
                                    color: Colors.white,
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
                                        anak.namaAnak,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Lahir ${formatTanggal(anak.tanggalLahir)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pantau jadwal vaksin di sini',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// SECTION
                          if (perhatian.isNotEmpty) ...[
                            _buildSectionHeader(
                              title: 'Butuh Perhatian',
                              color: Colors.red,
                              subtitle:
                                  '${perhatian.length} imunisasi perlu diperhatikan',
                            ),
                            ...perhatian.map((item) => _buildImunisasiItem(
                                context, item,
                                isEditable: true)),
                          ],

                          if (mendekati.isNotEmpty) ...[
                            _buildSectionHeader(
                              title: 'Akan Datang',
                              color: Colors.orange,
                              subtitle:
                                  '${mendekati.length} imunisasi mendekati jadwal',
                            ),
                            ...mendekati.map((item) => _buildImunisasiItem(
                                context, item,
                                isEditable: true)),
                          ],

                          if (selesai.isNotEmpty) ...[
                            _buildSectionHeader(
                              title: 'Selesai',
                              color: Colors.green,
                              subtitle:
                                  '${selesai.length} imunisasi sudah dilakukan',
                            ),
                            ...selesai.map(
                              (item) => _buildImunisasiItem(
                                context,
                                item,
                                isEditable: false,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

void showImunisasiDetailModal(BuildContext context, dynamic item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _ImunisasiDetailModalContent(item: item),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ImunisasiDetailModalContent extends StatelessWidget {
  final dynamic item;

  const _ImunisasiDetailModalContent({required this.item});

  bool get isNeedAttention {
    final status = item.status.toLowerCase();
    return status == 'terlewat' || status == 'terlambat' || status == 'krisis';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mendekati':
        return Colors.orange;
      case 'jatuh tempo':
        return Colors.blue;
      case 'terlewat':
        return Colors.red;
      case 'terlambat':
        return Colors.deepOrange;
      case 'krisis':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _getStatusMessage() {
    switch (item.status.toLowerCase()) {
      case 'terlewat':
        return 'Imunisasi ini belum dilakukan. Segera lakukan penjadwalan ulang.';
      case 'krisis':
        return 'Imunisasi ini sudah lama terlewat dan perlu segera ditindaklanjuti.';
      case 'terlambat':
        return 'Imunisasi terlambat dilakukan, segera konsultasikan.';
      case 'mendekati':
        return 'Jadwal imunisasi akan segera tiba.';
      default:
        return 'Pantau jadwal imunisasi secara berkala.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HANDLE BAR
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              /// HERO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.vaccines_rounded, size: 40, color: statusColor),
                    const SizedBox(height: 12),
                    Text(
                      item.namaDosis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ✅ INI YANG KAMU MAU (WARNING BOX)
              if (isNeedAttention) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jadwal imunisasi ini ${item.status.toLowerCase()}. '
                          'Segera atur jadwal susulan agar perlindungan si kecil tetap optimal.',
                          style: TextStyle(
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              /// DESKRIPSI
              _buildBox("Tentang Vaksin", item.deskripsi),

              const SizedBox(height: 12),

              /// EFEK SAMPING
              _buildBox("Efek Samping", item.efekSamping),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBox(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? '-' : content,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
