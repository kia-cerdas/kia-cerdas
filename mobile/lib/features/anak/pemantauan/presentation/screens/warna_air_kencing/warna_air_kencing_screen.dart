// lib/screens/pemantauan/warna_air_kencing/warna_air_kencing_screen.dart
import 'package:flutter/material.dart';

class WarnaAirKencingScreen extends StatefulWidget {
  const WarnaAirKencingScreen({Key? key}) : super(key: key);

  @override
  State<WarnaAirKencingScreen> createState() => _WarnaAirKencingScreenState();
}

class _WarnaAirKencingScreenState extends State<WarnaAirKencingScreen> {
  String? _selectedWarna;

  final List<Map<String, dynamic>> _warnaAirKencing = [
    {'nama': 'Kuning Pucat/Bening', 'color': const Color(0xFFFEF9C3), 'status': 'Normal', 'desc': 'Menandakan bayi cukup mendapat cairan. Bayi terhidrasi dengan baik.'},
    {'nama': 'Kuning Muda', 'color': const Color(0xFFFDE047), 'status': 'Normal', 'desc': 'Warna kuning muda merupakan warna air kencing yang sehat.'},
    {'nama': 'Kuning', 'color': const Color(0xFFEAB308), 'status': 'Normal', 'desc': 'Warna kuning masih normal, pastikan bayi mendapat ASI cukup.'},
    {'nama': 'Kuning Tua/Jingga', 'color': const Color(0xFFCA8A04), 'status': 'Perhatian', 'desc': 'Bisa jadi tanda dehidrasi ringan. Perbanyak pemberian ASI.'},
    {'nama': 'Oranye/Kuning Gelap', 'color': const Color(0xFF92400E), 'status': 'Bahaya', 'desc': 'Tanda dehidrasi berat. Segera berikan ASI lebih sering atau ke puskesmas!'},
    {'nama': 'Merah/Merah Muda', 'color': const Color(0xFFF87171), 'status': 'Bahaya', 'desc': 'Bisa jadi tanda adanya darah. Segera ke puskesmas!'},
    {'nama': 'Putih/Susu', 'color': const Color(0xFFF5F5F4), 'status': 'Bahaya', 'desc': 'Bisa jadi tanda infeksi saluran kemih. Segera ke puskesmas!'},
  ];

  void _showResult() {
    if (_selectedWarna == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih warna air kencing terlebih dahulu'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final selectedData = _warnaAirKencing.firstWhere((w) => w['nama'] == _selectedWarna);
    final isBahaya = selectedData['status'] == 'Bahaya';
    final isPerhatian = selectedData['status'] == 'Perhatian';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBahaya
                    ? const Color(0xFFFEE2E2)
                    : isPerhatian
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBahaya
                    ? Icons.warning_amber
                    : isPerhatian
                        ? Icons.info
                        : Icons.check_circle,
                color: isBahaya
                    ? const Color(0xFFDC2626)
                    : isPerhatian
                        ? const Color(0xFFD97706)
                        : const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              selectedData['status'],
              style: TextStyle(
                color: isBahaya
                    ? const Color(0xFFDC2626)
                    : isPerhatian
                        ? const Color(0xFFD97706)
                        : const Color(0xFF16A34A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usia Anak: 12 - 24 Bulan'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Warna Air Kencing: '),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selectedData['color'],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_selectedWarna!),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Keterangan:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(selectedData['desc']),
            if (isBahaya) ...[
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
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
          'Warna Air Kencing',
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
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.water_drop, color: Color(0xFF0284C7)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pemantauan warna air kencing untuk anak usia 12 - 24 bulan',
                      style: TextStyle(
                        color: Color(0xFF075985),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Untuk Usia: 12 - 24 Bulan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 24),

            // Pilih Warna
            const Text(
              'Pilih Warna Air Kencing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ..._warnaAirKencing.map((warna) {
              final isSelected = _selectedWarna == warna['nama'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedWarna = warna['nama']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE0F2FE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: warna['color'],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                warna['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                warna['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: warna['status'] == 'Bahaya'
                                      ? const Color(0xFFDC2626)
                                      : warna['status'] == 'Perhatian'
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF16A34A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF0284C7),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),

            // Button Cek
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cek Hasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}