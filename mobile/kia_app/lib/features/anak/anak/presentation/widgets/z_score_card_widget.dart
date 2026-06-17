// z_score_card_widget.dart :
import 'package:flutter/material.dart';

class ZScoreCardWidget extends StatelessWidget {
  final double zScore;
  final String statusText;
  final String categoryLabel; // Contoh: "BB/U", "TB/U"

  const ZScoreCardWidget({
    Key? key,
    required this.zScore,
    required this.statusText,
    required this.categoryLabel,
  }) : super(key: key);

  /// Hitung posisi dan warna berdasarkan Z-Score
  /// Z-Score: -3SD, -2SD, -1SD, 0 (Median), +1SD, +2SD, +3SD
  /// Warna: Red, Red, Yellow, Green, Yellow, Red, Red
  _ZScoreInfo _getZScoreInfo() {
    if (zScore < -2) {
      return _ZScoreInfo(
        position: 0.15, // Paling kiri (Merah)
        color: const Color(0xFFEF4444),
        category: 'Sangat Kurang',
      );
    } else if (zScore < -1) {
      return _ZScoreInfo(
        position: 0.28,
        color: const Color(0xFFF59E0B),
        category: 'Kurang',
      );
    } else if (zScore <= 1) {
      return _ZScoreInfo(
        position: 0.50,
        color: const Color(0xFF22C55E),
        category: 'Normal',
      );
    } else if (zScore <= 2) {
      return _ZScoreInfo(
        position: 0.72,
        color: const Color(0xFFF59E0B),
        category: 'Lebih',
      );
    } else {
      return _ZScoreInfo(
        position: 0.85, // Paling kanan (Merah)
        color: const Color(0xFFEF4444),
        category: 'Sangat Lebih',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getZScoreInfo();

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$zScore',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: info.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Z-Score Bar Visual
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bar dengan 5 warna (Merah, Kuning, Hijau, Kuning, Merah)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444), // Merah
                        const Color(0xFFF59E0B), // Kuning
                        const Color(0xFF22C55E), // Hijau
                        const Color(0xFFF59E0B), // Kuning
                        const Color(0xFFEF4444), // Merah
                      ],
                      stops: const [0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Indikator posisi dengan marker
              Stack(
                children: [
                  // Garis untuk menunjukkan posisi
                  Container(
                    height: 24,
                    child: Align(
                      alignment: Alignment(info.position * 2 - 1, 0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.arrow_drop_up,
                            color: info.color,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Label SD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('-3 SD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('-2 SD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('0 SD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('+2 SD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('+3 SD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status Text
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(info.category),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(String category) {
    switch (category) {
      case 'Sangat Kurang':
        return 'Anak memiliki status gizi yang sangat kurang. Segera konsultasikan dengan petugas kesehatan untuk penanganan lebih lanjut.';
      case 'Kurang':
        return 'Anak memiliki status gizi kurang. Tingkatkan asupan nutrisi dan konsultasikan dengan petugas kesehatan.';
      case 'Normal':
        return 'Anak memiliki status gizi yang normal. Lanjutkan pola makan dan perawatan yang baik.';
      case 'Lebih':
        return 'Anak memiliki status gizi lebih. Perhatikan asupan kalori dan olahraga teratur.';
      case 'Sangat Lebih':
        return 'Anak memiliki status gizi yang sangat lebih. Segera konsultasikan dengan petugas kesehatan.';
      default:
        return '';
    }
  }
}

class _ZScoreInfo {
  final double position; // 0 - 1
  final Color color;
  final String category;

  _ZScoreInfo({
    required this.position,
    required this.color,
    required this.category,
  });
}
