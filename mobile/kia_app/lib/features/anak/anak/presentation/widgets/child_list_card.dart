import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';

class ChildListCard extends StatelessWidget {
  final AnakSearchModel anak;
  final String? namaIbu;
  final VoidCallback onTap;

  const ChildListCard({
    Key? key,
    required this.anak,
    this.namaIbu,
    required this.onTap,
  }) : super(key: key);

  /// Hitung usia anak dari tanggal lahir
  String _calculateAge() {
    try {
      final birthDate = DateTime.parse(anak.tanggalLahir);
      final today = DateTime.now();
      int months = (today.year - birthDate.year) * 12;
      months += today.month - birthDate.month;
      months += today.day < birthDate.day ? -1 : 0;

      if (months < 0) months = 0;

      final years = months ~/ 12;
      final remainingMonths = months % 12;

      if (years > 0) {
        return '$years tahun ${remainingMonths} bulan';
      } else {
        return '$remainingMonths bulan';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMale = anak.jenisKelamin.toLowerCase().contains('laki');
    final avatarColor = isMale ? const Color(0xFF2563EB) : const Color(0xFFEC4899);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      anak.namaAnak.isNotEmpty
                          ? anak.namaAnak[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Anak
                      Text(
                        anak.namaAnak,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nama Ibu
                      if (namaIbu != null && namaIbu!.isNotEmpty)
                        Text(
                          'Ibu: $namaIbu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      // No. KK & Usia
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'KK: ${anak.noKartuKeluarga}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _calculateAge(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
