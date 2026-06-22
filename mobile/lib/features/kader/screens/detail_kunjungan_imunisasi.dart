import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AnakImunisasiDetailScreen extends StatefulWidget {
  final int kunjunganId;

  const AnakImunisasiDetailScreen({
    super.key,
    required this.kunjunganId,
  });

  @override
  State<AnakImunisasiDetailScreen> createState() =>
      _AnakImunisasiDetailScreenState();
}

class _AnakImunisasiDetailScreenState extends State<AnakImunisasiDetailScreen> {
  final KunjunganImunisasiService _service = KunjunganImunisasiService();

  bool _isLoading = true;
  String? _error;

  DetailKunjunganImunisasiModel? detail;

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

      final result = await _service.getKunjunganById(
        widget.kunjunganId,
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Kunjungan Imunisasi',
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
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: _buildDetailBody(),
    );
  }

  Widget _buildDetailBody() {
    final item = detail!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              _profileCard(item),
              const SizedBox(
                height: 16,
              ),
              _sectionTitle(
                "Detail Imunisasi",
              ),
              const SizedBox(
                height: 8,
              ),
              _infoCard([
                _infoRow(
                  "Dosis Vaksin",
                  item.namaDosis,
                ),

                _infoRow(
                  "Status",
                  item.statusKunjungan,
                ),

                _infoRow(
                  "Tanggal Kunjungan Imunisasi",
                  item.tanggalKunjungan != null
                      ? DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          item.tanggalKunjungan!,
                        )
                      : '-',
                ),

                const SizedBox(height: 12),

                // Highlight Jadwal Imunisasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          color: Color(0xFFDC2626),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jadwal Imunisasi Seharusnya",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.jadwalImunisasi != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(
                                      item.jadwalImunisasi!,
                                    )
                                  : '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(
                height: 16,
              ),
              _sectionTitle(
                "Informasi Orang Tua",
              ),
              const SizedBox(
                height: 8,
              ),
              _infoCard([
                _infoRow(
                  "Nama Ibu",
                  item.namaIbu,
                ),
                _infoRow(
                  "Nama Ayah",
                  item.namaAyah,
                ),
                _infoRow(
                  "No HP Ibu",
                  item.nomorTeleponIbu,
                  onTap: () {
                    if (item.nomorTeleponIbu.isNotEmpty) {
                      openDialer(item.nomorTeleponIbu);
                    }
                  },
                ),
                _infoRow(
                  "No HP Ayah",
                  item.nomorTeleponAyah,
                  onTap: () {
                    if (item.nomorTeleponAyah.isNotEmpty) {
                      openDialer(item.nomorTeleponAyah);
                    }
                  },
                ),
                _infoRow(
                  "Dusun",
                  item.dusun,
                ),
              ]),
              if (!_isFinalStatus(item.statusKunjungan)) ...[
                const SizedBox(
                  height: 16,
                ),
                _sectionTitle(
                  "Kunjungan Imunisasi",
                ),
                const SizedBox(
                  height: 8,
                ),
                _visitActionCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard(
    DetailKunjunganImunisasiModel item,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.child_care,
              color: Colors.blue,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaAnak,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  item.tanggalLahir != null
                      ? 'Lahir ${DateFormat('dd MMM yyyy').format(item.tanggalLahir!)}'
                      : '-',
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

  Widget _deadlineCard(
    DateTime? tanggal,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event,
            color: Colors.red,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            tanggal != null
                ? DateFormat(
                    'dd MMM yyyy',
                  ).format(
                    tanggal,
                  )
                : '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCancelling = false;
  Widget _visitActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isRescheduling
                        ? null
                        : () async {
                            await _showScheduleDialog();
                          },
                    icon: _isRescheduling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                          ),
                    label: Text(
                      _isRescheduling ? "Memproses..." : "Jadwalkan Ulang",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF0F766E,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF99F6E4),
                        width: 1.5,
                      ),
                      backgroundColor: const Color(
                        0xFFF0FDFA,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating
                        ? null
                        : () async {
                            final confirm = await _showConfirmDialog();

                            if (confirm != true) {
                              return;
                            }

                            try {
                              setState(() {
                                _isUpdating = true;
                              });

                              await _service.updateStatusKunjungan(
                                widget.kunjunganId,
                                3,
                              );

                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Status berhasil diperbarui',
                                  ),
                                  backgroundColor: Color(
                                    0xFF22C55E,
                                  ),
                                ),
                              );

                              await _loadDetail();
                            } catch (e) {
                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isUpdating = false;
                                });
                              }
                            }
                          },
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      _isUpdating ? "Memproses..." : "Dikunjungi",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(
                        0xFF22C55E,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BUTTON BATALKAN
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isCancelling
                  ? null
                  : () async {
                      final confirm = await _showCancelDialog();

                      if (confirm != true) {
                        return;
                      }

                      try {
                        setState(() {
                          _isCancelling = true;
                        });

                        await _service.updateStatusKunjungan(
                          widget.kunjunganId,
                          4, // dibatalkan
                        );

                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Kunjungan berhasil dibatalkan',
                            ),
                            backgroundColor: Color(
                              0xFFDC2626,
                            ),
                          ),
                        );

                        await _loadDetail();
                      } catch (e) {
                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isCancelling = false;
                          });
                        }
                      }
                    },
              icon: _isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.close_rounded,
                      size: 20,
                    ),
              label: Text(
                _isCancelling ? "Memproses..." : "Batalkan Kunjungan",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(
                  0xFFDC2626,
                ),
                backgroundColor: const Color(
                  0xFFFEF2F2,
                ),
                side: const BorderSide(
                  color: Color(
                    0xFFFECACA,
                  ),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard(
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;

    Color statusColor(String status) {
      switch (status.toLowerCase()) {
        case 'terjadwal':
          return const Color(0xFF3B82F6); // hijau

        case 'perlu tindak lanjut':
          return const Color(0xFFF59E0B); // kuning

        case 'selesai':
          return const Color(0xFF22C55E); // biru

        case 'dibatalkan':
          return const Color(0xFFEF4444); // merah

        default:
          return Colors.grey;
      }
    }

    final isStatus = label.toLowerCase() == "status";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),

            // ========================
            // STATUS BADGE
            // ========================
            if (isStatus)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor(value).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor(value).withOpacity(0.25),
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: statusColor(value),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )

            // ========================
            // NORMAL TEXT / PHONE
            // ========================
            else
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isClickable ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (isClickable)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _isUpdating = false;
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Konfirmasi",
          ),
          content: const Text(
            "Tandai kunjungan ini sebagai sudah dikunjungi?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Batal",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF22C55E,
                ),
              ),
              child: const Text(
                "Ya",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isRescheduling = false;
  Future<void> _showScheduleDialog() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: "Pilih Tanggal Kunjungan",
      cancelText: "Batal",
      confirmText: "Pilih",
    );

    if (pickedDate == null) return;

    try {
      setState(() {
        _isRescheduling = true;
      });

      // Format YYYY-MM-DD
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(
        pickedDate,
      );

      await _service.updateTanggalKunjungan(
        widget.kunjunganId,
        formattedDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jadwal berhasil diubah ke $formattedDate',
          ),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );

      // refresh data
      await _loadDetail();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRescheduling = false;
        });
      }
    }
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Batalkan Kunjungan",
          ),
          content: const Text(
            "Apakah Anda yakin ingin membatalkan kunjungan ini?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Batal",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFDC2626,
                ),
              ),
              child: const Text(
                "Ya, Batalkan",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isFinalStatus(String status) {
    final normalized = status.toLowerCase().trim();

    return normalized == 'selesai' || normalized == 'dibatalkan';
  }

  Future<void> openDialer(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
