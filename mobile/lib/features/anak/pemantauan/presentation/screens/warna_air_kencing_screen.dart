import 'package:flutter/material.dart';

class WarnaAirKencingScreen extends StatelessWidget {
  const WarnaAirKencingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warna Air Kencing', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pemantauan Hidrasi (12 - 24 Bulan)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sesuaikan warna air kencing anak dengan indikator di bawah ini untuk mengetahui apakah si Kecil cukup minum air.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildIndikator(
            warna: Colors.yellow.shade100,
            status: 'Baik',
            deskripsi: 'Anak terhidrasi dengan baik. Teruskan minum air putih sesuai kebutuhan.',
          ),
          _buildIndikator(
            warna: Colors.yellow.shade400,
            status: 'Kurang Baik',
            deskripsi: 'Anak kurang terhidrasi. Tambahkan minum sesuai kebutuhan.',
          ),
          _buildIndikator(
            warna: Colors.orange.shade700,
            status: 'Tidak Baik',
            deskripsi: 'Anak sangat kurang minum. Segera beri minum. Jika tidak membaik hubungi Nakes.',
          ),
        ],
      ),
    );
  }

  Widget _buildIndikator({required Color warna, required String status, required String deskripsi}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: warna, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(deskripsi, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}