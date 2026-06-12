import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';

class ChildInfoBanner extends StatelessWidget {
  final AnakSearchModel anak;
  final String? namaIbu;

  const ChildInfoBanner({
    Key? key,
    required this.anak,
    this.namaIbu,
  }) : super(key: key);

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
    final genderText = isMale ? 'Laki-laki' : 'Perempuan';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
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
                  fontSize: 28,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Gender & Usia
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: avatarColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        genderText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Usia: ${_calculateAge()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (namaIbu != null && namaIbu!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ibu: $namaIbu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
