import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/detail_kunjungan_imunisasi.dart';

class KunjunganByStatusScreen extends StatefulWidget {
  final int statusId;
  final String statusName;

  const KunjunganByStatusScreen({
    super.key,
    required this.statusId,
    required this.statusName,
  });

  @override
  State<KunjunganByStatusScreen> createState() =>
      _KunjunganByStatusScreenState();
}

class _KunjunganByStatusScreenState extends State<KunjunganByStatusScreen> {
  final KunjunganImunisasiService _service = KunjunganImunisasiService();

  late Future<List<KunjunganImunisasiModel>> _kunjunganFuture;

  @override
  void initState() {
    super.initState();

    _kunjunganFuture = _service.getKunjunganImunisasiByStatus(
      widget.statusId,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatTanggal(
    DateTime? date,
  ) {
    if (date == null) {
      return '-';
    }

    return DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(date);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.statusName,
          style: const TextStyle(
            color: Color(
              0xFF1E293B,
            ),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1,
          ),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: FutureBuilder<List<KunjunganImunisasiModel>>(
        future: _kunjunganFuture,
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
                padding: const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Gagal memuat data kunjungan',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _kunjunganFuture =
                              _service.getKunjunganImunisasiByStatus(
                            widget.statusId,
                          );
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

          final kunjunganList =
              snapshot.data ?? const <KunjunganImunisasiModel>[];

          if (kunjunganList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.vaccines_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Belum ada kunjungan ${widget.statusName.toLowerCase()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(
              16,
            ),
            itemCount: kunjunganList.length,
            itemBuilder: (
              context,
              index,
            ) {
              final kunjungan = kunjunganList[index];

              return _buildItem(
                context,
                kunjungan,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    KunjunganImunisasiModel kunjungan,
  ) {
    final statusConfig = _getStatusConfig(
      kunjungan.statusKunjungan,
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            18,
          ),

          // ==========================
          // NAVIGATE TO DETAIL
          // ==========================
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnakImunisasiDetailScreen(
                  kunjunganId: kunjungan.kunjunganId,
                ),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusConfig.color.withOpacity(
                      0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    Icons.vaccines_rounded,
                    color: statusConfig.color,
                    size: 26,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kunjungan.namaAnak,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(
                            0xFF1E293B,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            _formatTanggal(
                              kunjungan.tanggalKunjungan,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusConfig.color.withOpacity(
                            0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          kunjungan.statusKunjungan,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusConfig.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(
    String status,
  ) {
    switch (status.toLowerCase().trim()) {
      case 'terjadwal':
        return _StatusConfig(
          color: const Color(
            0xFFF59E0B,
          ),
          icon: Icons.calendar_month_rounded,
        );

      case 'perlu tindak lanjut':
        return _StatusConfig(
          color: const Color(
            0xFFEF4444,
          ),
          icon: Icons.medical_services_rounded,
        );

      case 'selesai':
        return _StatusConfig(
          color: const Color(
            0xFF10B981,
          ),
          icon: Icons.check_circle_rounded,
        );

      case 'dibatalkan':
        return _StatusConfig(
          color: const Color(
            0xFF64748B,
          ),
          icon: Icons.cancel_rounded,
        );

      default:
        return _StatusConfig(
          color: Colors.blue,
          icon: Icons.vaccines_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.icon,
  });
}
