import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';

class DetailImunisasiTerlewatScreen extends StatefulWidget {
  final int jadwalId;

  const DetailImunisasiTerlewatScreen({
    super.key,
    required this.jadwalId,
  });

  @override
  State<DetailImunisasiTerlewatScreen> createState() =>
      _DetailImunisasiTerlewatScreenState();
}

class _DetailImunisasiTerlewatScreenState
    extends State<DetailImunisasiTerlewatScreen> {
  final KunjunganImunisasiService _service =
      KunjunganImunisasiService();

  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  DetailJadwalImunisasiTerlewatModel? detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result =
          await _service.getJadwalImunisasiTerlewatById(
        widget.jadwalId,
      );

      if (!mounted) return;

      setState(() {
        detail = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (detail == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Data tidak ditemukan',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F5F9,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Imunisasi Terlewat',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileCard(),

              const SizedBox(height: 16),

              _priorityCard(),

              const SizedBox(height: 16),

              _sectionTitle(
                "Detail Imunisasi",
              ),

              const SizedBox(height: 8),

_infoCard([
  _infoRow(
    "Dosis Vaksin",
    detail!.namaDosis,
  ),

  _infoRow(
    "Status",
    detail!.namaStatus,
  ),

  _infoRow(
    "Prioritas",
    _priorityLabel(
      detail!.prioritas,
    ),
  ),

  const SizedBox(height: 12),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(
        0xFFFEF2F2,
      ),
      borderRadius:
          BorderRadius.circular(14),
      border: Border.all(
        color: const Color(
          0xFFFECACA,
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(
              0xFFFEE2E2,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.event_available_rounded,
            color: Color(
              0xFFDC2626,
            ),
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Jadwal Imunisasi",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                detail!.jadwalImunisasi != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        detail!
                            .jadwalImunisasi!,
                      )
                    : '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                  color: Color(
                    0xFFB91C1C,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
]),
              const SizedBox(height: 16),

              _sectionTitle(
                "Informasi Orang Tua",
              ),

              const SizedBox(height: 8),

              _infoCard([
                _infoRow(
                  "Nama Ibu",
                  detail!.namaIbu,
                ),
                _infoRow(
                  "Nama Ayah",
                  detail!.namaAyah,
                ),
                _infoRow(
                  "No HP Ibu",
                  detail!.nomorTeleponIbu,
                  onTap: () {
                    openDialer(
                      detail!.nomorTeleponIbu,
                    );
                  },
                ),
                _infoRow(
                  "No HP Ayah",
                  detail!.nomorTeleponAyah,
                  onTap: () {
                    openDialer(
                      detail!.nomorTeleponAyah,
                    );
                  },
                ),
                _infoRow(
                  "Dusun",
                  detail!.dusun,
                ),
              ]),

              const SizedBox(height: 16),

              _scheduleVisitCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF38BDF8),
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.child_care,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  detail!.namaAnak,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail!.tanggalLahir != null
                      ? "Lahir ${DateFormat('dd MMM yyyy').format(detail!.tanggalLahir!)}"
                      : "-",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _priorityCard() {
  final color = _priorityColor(
    detail!.prioritas,
  );

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withOpacity(0.15),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: color,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _priorityLabel(
                  detail!.prioritas,
                ),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${detail!.jumlahHariTerlambat} hari terlambat",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

      ],
    ),
  );
}

  Widget _scheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFEF2F2,
        ),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            detail!.jadwalImunisasi != null
                ? DateFormat(
                    'dd MMM yyyy',
                  ).format(
                    detail!.jadwalImunisasi!,
                  )
                : '-',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleVisitCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _handleScheduleVisit,
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
          label: const Text(
            "Jadwalkan Kunjungan",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF0EA5E9,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Align(
      alignment:
          Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _infoCard(
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: onTap != null
                    ? Colors.blue
                    : Colors.black,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(
    String p,
  ) {
    switch (p) {
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

  Color _priorityColor(
    String p,
  ) {
    switch (p) {
      case 'P1':
        return Colors.red;
      case 'P2':
        return Colors.orange;
      case 'P3':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Future<void> openDialer(
    String phoneNumber,
  ) async {
    if (phoneNumber.isEmpty) {
      return;
    }

    final Uri phoneUri =
        Uri.parse(
      'tel:$phoneNumber',
    );

    await launchUrl(
      phoneUri,
      mode:
          LaunchMode.externalApplication,
    );
  }

  Future<void> _handleScheduleVisit() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selectedDate == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = PostKunjunganImunisasiRequest(
        idStatusKunjungan: 1,
        tanggalKunjungan: selectedDate.toIso8601String(),
        idJadwalImunisasi: detail!.jadwalId,
      );

      await _service.postKunjunganImunisasi(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kunjungan berhasil dijadwalkan',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menjadwalkan kunjungan: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}