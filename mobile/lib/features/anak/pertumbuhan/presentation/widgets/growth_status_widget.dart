import 'package:flutter/material.dart';

/// Widget untuk menampilkan status gizi dengan visual yang lebih jelas
class GrowthStatusCard extends StatelessWidget {
  final String status;
  final String label;
  final double zScore;
  final String? description;

  const GrowthStatusCard({
    Key? key,
    required this.status,
    required this.label,
    required this.zScore,
    this.description,
  }) : super(key: key);

  Color _getStatusColor() {
    final lower = status.toLowerCase();

    // Hijau - Gizi Baik
    if (lower.contains('baik') || lower.contains('normal')) {
      return const Color(0xFF0F6E56);
    }

    // Kuning/Oranye - Gizi Kurang atau Risiko
    if (lower.contains('kurang') ||
        lower.contains('risiko') ||
        lower.contains('pendek')) {
      return const Color(0xFFBA7517);
    }

    // Merah - Gizi Buruk atau Sangat Kurang
    if (lower.contains('buruk') ||
        lower.contains('sangat') ||
        lower.contains('stunting') ||
        lower.contains('obesitas')) {
      return const Color(0xFFA32D2D);
    }

    // Biru - Default
    return const Color(0xFF185FA5);
  }

  IconData _getStatusIcon() {
    final lower = status.toLowerCase();
    if (lower.contains('baik') || lower.contains('normal')) {
      return Icons.check_circle;
    } else if (lower.contains('buruk') ||
        lower.contains('sangat') ||
        lower.contains('stunting') ||
        lower.contains('obesitas')) {
      return Icons.warning_rounded;
    } else {
      return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                statusIcon,
                color: statusColor,
                size: 28,
              ),
            ],
          ),

          // Z-Score Bar
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Z-Score',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    zScore.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildZScoreBar(statusColor),
            ],
          ),

          // Description
          if (description != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                description!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZScoreBar(Color statusColor) {
    // Hitung posisi Z-Score dalam skala -3 hingga 3
    double position = 0.5; // Default ke tengah (0)
    if (zScore < -3) {
      position = 0.05;
    } else if (zScore < -2) {
      position = 0.2;
    } else if (zScore < -1) {
      position = 0.35;
    } else if (zScore > 3) {
      position = 0.95;
    } else if (zScore > 2) {
      position = 0.8;
    } else if (zScore > 1) {
      position = 0.65;
    } else {
      position = 0.5 + (zScore * 0.15);
    }

    // Gunakan LayoutBuilder agar kita bisa menghitung offset dalam piksel
    // berdasarkan lebar aktual bar. Pastikan posisi berada pada rentang [0,1].
    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorSize = 16.0;
        final maxLeft =
            (constraints.maxWidth - indicatorSize).clamp(0.0, double.infinity);
        final clampedPos = position.clamp(0.0, 1.0);
        final left = clampedPos * maxLeft;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background bar dengan zone warna
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  // Red zone (-3 to -2)
                  Expanded(
                    flex: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFA32D2D),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Amber zone (-2 to 0)
                  Expanded(
                    flex: 30,
                    child: Container(color: const Color(0xFFBA7517)),
                  ),
                  // Green zone (0 to 2)
                  Expanded(
                    flex: 30,
                    child: Container(color: const Color(0xFF0F6E56)),
                  ),
                  // Amber zone (2 to 3)
                  Expanded(
                    flex: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFBA7517),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indicator
            Positioned(
              left: left,
              top: -((indicatorSize / 2)),
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget untuk menampilkan ringkasan status gizi secara keseluruhan
class GrowthSummaryWidget extends StatelessWidget {
  final String? statusBBU;
  final String? statusTBU;
  final String? statusBBTB;
  final String? statusIMTU;
  final String? statusLKU;
  final String childName;
  final String childAge;

  const GrowthSummaryWidget({
    Key? key,
    required this.statusBBU,
    required this.statusTBU,
    required this.statusBBTB,
    this.statusIMTU,
    this.statusLKU,
    required this.childName,
    required this.childAge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF185FA5), Color(0xFF185FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF185FA5).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Ringkasan Status Gizi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Child Info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👶', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    childName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    childAge,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),

          // Status Cards
          Column(
            children: [
              _buildStatusRow('Berat/Usia (BB/U)', statusBBU),
              const SizedBox(height: 8),
              _buildStatusRow('Tinggi/Usia (TB/U)', statusTBU),
              const SizedBox(height: 8),
              _buildStatusRow('Berat/Tinggi (BB/TB)', statusBBTB),
              if (statusIMTU != null && statusIMTU!.isNotEmpty && statusIMTU != '-') ...[
                const SizedBox(height: 8),
                _buildStatusRow('IMT/Usia (IMT/U)', statusIMTU),
              ],
              if (statusLKU != null && statusLKU!.isNotEmpty && statusLKU != '-') ...[
                const SizedBox(height: 8),
                _buildStatusRow('Lingkar Kepala (LK/U)', statusLKU),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String? status) {
    // Tentukan warna badge berdasarkan status
    Color badgeColor = Colors.white.withOpacity(0.2);
    if (status != null) {
      final lower = status.toLowerCase();
      if (lower.contains('baik') || lower.contains('normal')) {
        badgeColor = const Color(0xFF0F6E56).withOpacity(0.7);
      } else if (lower.contains('buruk') || lower.contains('sangat') ||
          lower.contains('stunting') || lower.contains('obesitas')) {
        badgeColor = const Color(0xFFA32D2D).withOpacity(0.7);
      } else if (lower.contains('kurang') || lower.contains('lebih') ||
          lower.contains('risiko') || lower.contains('pendek')) {
        badgeColor = const Color(0xFFBA7517).withOpacity(0.7);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status ?? '-',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan mini stat card
class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const MiniStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
