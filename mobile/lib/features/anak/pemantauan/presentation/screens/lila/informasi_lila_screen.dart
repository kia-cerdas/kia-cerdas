// lib/screens/pemantauan/lila/informasi_lila_screen.dart
import 'package:flutter/material.dart';

class InformasiLilaScreen extends StatelessWidget {
  const InformasiLilaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Informasi LiLA',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.straighten, size: 64, color: Color(0xFF16A34A)),
                    SizedBox(height: 12),
                    Text(
                      'Lingkar Lengan Atas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                    ),
                    Text(
                      '(LiLA)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Apa itu LiLA
            _sectionCard(
              title: 'Apa itu LiLA?',
              icon: Icons.info_outline,
              iconColor: const Color(0xFF16A34A),
              content: 'Lingkar Lengan Atas (LiLA) adalah salah satu indikator untuk menilai status gizi anak, khususnya untuk mendeteksi gizi buruk. Pengukuran dilakukan pada lengan atas kiri, di tengah antara bahu dan siku.',
            ),
            const SizedBox(height: 16),

            // Kategori LiLA
            _sectionTitle('Kategori Pengukuran LiLA'),
            const SizedBox(height: 12),
            
            _lilaCategoryCard(
              color: const Color(0xFFDCFCE7),
              borderColor: const Color(0xFF16A34A),
              title: 'Gizi Baik',
              value: '> 13,5 cm',
              desc: 'Status gizi anak dalam kondisi baik. Lanjutkan pola makan sehat.',
              iconColor: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 10),
            
            _lilaCategoryCard(
              color: const Color(0xFFFEF3C7),
              borderColor: const Color(0xFFD97706),
              title: 'Gizi Kurang',
              value: '11,5 - 13,5 cm',
              desc: 'Anak perlu perhatian lebih. Tingkatkan asupan gizi seimbang.',
              iconColor: const Color(0xFFD97706),
            ),
            const SizedBox(height: 10),
            
            _lilaCategoryCard(
              color: const Color(0xFFFEE2E2),
              borderColor: const Color(0xFFDC2626),
              title: 'Gizi Buruk',
              value: '< 11,5 cm',
              desc: 'Segera bawa anak ke puskesmas untuk penanganan lebih lanjut!',
              iconColor: const Color(0xFFDC2626),
              isDanger: true,
            ),
            const SizedBox(height: 24),

            // Cara Mengukur
            _sectionTitle('Cara Mengukur LiLA'),
            const SizedBox(height: 12),
            _stepCard(
              step: 1,
              title: 'Posisi Anak',
              desc: 'Anak berdiri tegak dengan lengan kiri lurus ke samping.',
            ),
            const SizedBox(height: 10),
            _stepCard(
              step: 2,
              title: 'Temukan Titik Ukur',
              desc: 'Ukur tengah-tengah antara ujung bahu (akromion) dan siku (olekranon).',
            ),
            const SizedBox(height: 10),
            _stepCard(
              step: 3,
              title: 'Lingkarkan Pita Ukur',
              desc: 'Lingkarkan pita ukur melingkar di titik tengah tersebut, tidak terlalu ketat atau longgar.',
            ),
            const SizedBox(height: 10),
            _stepCard(
              step: 4,
              title: 'Baca Hasil',
              desc: 'Baca ukuran pada pita ukur saat anak dalam keadaan tenang dan rileks.',
            ),
            const SizedBox(height: 24),

            // Catatan Penting
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD97706)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Text(
                        'Catatan Penting',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• LiLA hanya untuk anak usia 6-59 bulan\n'
                    '• Gunakan pita ukur LiLA yang khusus (tidak lentur)\n'
                    '• Ukur 2 kali dan ambil rata-rata\n'
                    '• Catat hasil pengukuran secara berkala',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF92400E),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
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
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _lilaCategoryCard({
    required Color color,
    required Color borderColor,
    required String title,
    required String value,
    required String desc,
    required Color iconColor,
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDanger ? Icons.warning : Icons.check_circle,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard({
    required int step,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
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