import 'package:flutter/material.dart';

class LilaScreen extends StatefulWidget {
  const LilaScreen({Key? key}) : super(key: key);

  @override
  State<LilaScreen> createState() => _LilaScreenState();
}

class _LilaScreenState extends State<LilaScreen> {
  final TextEditingController _lilaController = TextEditingController();
  String _hasil = '';
  Color _hasilColor = Colors.grey;

  void _hitungLila() {
    double? ukuran = double.tryParse(_lilaController.text);
    if (ukuran == null) return;

    setState(() {
      // Standar dari Pita LiLA Buku KIA
      if (ukuran < 11.5) {
        _hasil = 'Gizi Buruk (Merah)\nSegera konsultasi ke Nakes!';
        _hasilColor = Colors.red;
      } else if (ukuran >= 11.5 && ukuran <= 12.4) {
        _hasil = 'Gizi Kurang (Kuning)\nPerlu perbaikan asupan gizi.';
        _hasilColor = Colors.orange;
      } else {
        _hasil = 'Gizi Baik (Hijau)\nPertahankan gizi anak.';
        _hasilColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lingkar Lengan Atas', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pengukuran LiLA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pengukuran dilakukan di lengan yang tidak aktif digunakan (biasanya lengan kiri). Alat yang digunakan adalah pita LiLA dengan indikator warna (Hijau, Kuning, Merah).', // Diambil dari Buku KIA hal. 48
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _lilaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Hasil Pengukuran (cm)',
                hintText: 'Contoh: 12.5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'cm',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hitungLila,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cek Status Gizi', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            if (_hasil.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasilColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _hasilColor),
                ),
                child: Column(
                  children: [
                    const Text('Status Anak:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _hasil,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _hasilColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}