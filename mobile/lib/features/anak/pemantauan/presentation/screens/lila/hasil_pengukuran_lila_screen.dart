// lib/screens/pemantauan/lila/hasil_pengukuran_lila_screen.dart
import 'package:flutter/material.dart';

class HasilPengukuranLilaScreen extends StatefulWidget {
  const HasilPengukuranLilaScreen({Key? key}) : super(key: key);

  @override
  State<HasilPengukuranLilaScreen> createState() => _HasilPengukuranLilaScreenState();
}

class _HasilPengukuranLilaScreenState extends State<HasilPengukuranLilaScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  final TextEditingController _lilaController = TextEditingController();
  String? _selectedBulan;
  final List<String> _bulanOptions = [
    '6 Bulan', '7 Bulan', '8 Bulan', '9 Bulan', '10 Bulan', '11 Bulan',
    '12 Bulan', '15 Bulan', '18 Bulan', '21 Bulan', '24 Bulan',
    '27 Bulan', '30 Bulan', '33 Bulan', '36 Bulan', '42 Bulan',
    '48 Bulan', '54 Bulan', '59 Bulan',
  ];

  List<Map<String, dynamic>> _riwayatPengukuran = [];

  void _simpanPengukuran() {
    if (_namaController.text.isEmpty ||
        _selectedBulan == null ||
        _lilaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data pengukuran'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final lila = double.tryParse(_lilaController.text);
    if (lila == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan angka yang valid untuk LiLA'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    String status;
    Color statusColor;
    if (lila > 13.5) {
      status = 'Gizi Baik';
      statusColor = const Color(0xFF16A34A);
    } else if (lila >= 11.5) {
      status = 'Gizi Kurang';
      statusColor = const Color(0xFFD97706);
    } else {
      status = 'Gizi Buruk';
      statusColor = const Color(0xFFDC2626);
    }

    setState(() {
      _riwayatPengukuran.insert(0, {
        'nama': _namaController.text,
        'umur': _selectedBulan,
        'lila': lila,
        'status': status,
        'statusColor': statusColor,
        'tanggal': DateTime.now().toString().substring(0, 10),
      });
    });

    _showResultDialog(status, statusColor, lila);

    _lilaController.clear();
  }

  void _showResultDialog(String status, Color statusColor, double lila) {
    final isGiziBuruk = status == 'Gizi Buruk';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGiziBuruk ? Icons.warning_amber : Icons.check_circle,
                size: 56,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'LiLA: ${lila.toStringAsFixed(1)} cm',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isGiziBuruk
                  ? 'Anak memerlukan penanganan segera di puskesmas!'
                  : status == 'Gizi Kurang'
                      ? 'Tingkatkan asupan gizi anak dan lakukan pemantauan rutin.'
                      : 'Status gizi anak baik. Pertahankan pola makan sehat!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (isGiziBuruk) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_hospital, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ PERLU KE PUSKESMAS SEGERA!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan & Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRiwayat(int index) {
    setState(() {
      _riwayatPengukuran.removeAt(index);
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _lilaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hasil Pengukuran LiLA',
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
            // Form Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Pengukuran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nama Anak
                  const Text(
                    'Nama Anak',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama anak',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF16A34A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Umur
                  const Text(
                    'Umur Anak (6-59 bulan)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBulan,
                        hint: const Text(
                          'Pilih umur',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        isExpanded: true,
                        items: _bulanOptions.map((bulan) {
                          return DropdownMenuItem(
                            value: bulan,
                            child: Text(bulan),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBulan = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LiLA
                  const Text(
                    'Lingkar Lengan Atas (cm)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lilaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Contoh: 12.5',
                      suffixText: 'cm',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF16A34A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _simpanPengukuran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Pengukuran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Riwayat Pengukuran
            const Text(
              'Riwayat Pengukuran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            
            if (_riwayatPengukuran.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada data pengukuran',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._riwayatPengukuran.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: Key('riwayat_$index'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteRiwayat(index),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 50,
                            decoration: BoxDecoration(
                              color: data['statusColor'],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['nama'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      data['umur'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'LiLA: ${data['lila'].toStringAsFixed(1)} cm',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: data['statusColor'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: data['statusColor'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}