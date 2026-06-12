import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImunisasiDetailScreen extends StatelessWidget {
  final dynamic item;

  const ImunisasiDetailScreen({
    super.key,
    required this.item,
  });

  bool get isNeedAttention {
    final status = item.status.toLowerCase();

    return status == 'terlewat' || status == 'terlambat' || status == 'krisis';
  }

  String formatTanggal(DateTime? date) {
    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(date);
  }

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
        return Colors.grey;
    }
  }

  String getStatusMessage() {
    switch (item.status.toLowerCase()) {
      case 'terlewat':
        return 'Imunisasi ini belum dilakukan. Yuk jadwalkan ulang agar perlindungan si kecil tetap optimal.';

      case 'krisis':
        return 'Imunisasi ini sudah cukup lama terlewat dan perlu segera diperhatikan.';

      case 'terlambat':
        return 'Jadwal imunisasi terlambat dilakukan. Sebaiknya segera konsultasikan ke bidan atau posyandu.';

      case 'mendekati':
        return 'Jadwal imunisasi akan segera tiba. Jangan lupa dipersiapkan ya Bunda.';

      default:
        return 'Pantau jadwal imunisasi si kecil agar tetap sesuai anjuran.';
    }
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content.isEmpty ? '-' : content,
            style: const TextStyle(
              height: 1.7,
              color: Color(0xFF475569),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(item.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Imunisasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBar: isNeedAttention
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: jadwal susulan
                    },
                    icon: const Icon(Icons.event_repeat_rounded),
                    label: const Text(
                      'Atur Jadwal Susulan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF2196F3,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// HERO CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.12),
                    statusColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.vaccines_rounded,
                      size: 42,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    item.namaDosis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    formatTanggal(
                      item.tanggalEstimasi,
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      height: 1.6,
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// DESKRIPSI
            _buildSectionCard(
              icon: Icons.health_and_safety_outlined,
              title: 'Tentang Vaksin',
              content: item.deskripsi,
            ),

            const SizedBox(height: 18),

            /// EFEK SAMPING
            _buildSectionCard(
              icon: Icons.medical_information_outlined,
              title: 'Efek Samping yang Mungkin Terjadi',
              content: item.efekSamping,
            ),

            if (isNeedAttention) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.red.shade100,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Jadwal imunisasi ini ${item.status.toLowerCase()}. Segera konsultasikan ke bidan atau posyandu untuk menentukan jadwal susulan.',
                        style: TextStyle(
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
