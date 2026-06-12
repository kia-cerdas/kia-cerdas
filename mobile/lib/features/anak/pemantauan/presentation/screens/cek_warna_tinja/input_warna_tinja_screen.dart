// lib/screens/pemantauan/cek_warna_tinja/input_warna_tinja_screen.dart
import 'package:flutter/material.dart';

class InputWarnaTinjaScreen extends StatefulWidget {
  const InputWarnaTinjaScreen({Key? key}) : super(key: key);

  @override
  State<InputWarnaTinjaScreen> createState() => _InputWarnaTinjaScreenState();
}

class _InputWarnaTinjaScreenState extends State<InputWarnaTinjaScreen> {
  String? _selectedUmur;
  String? _selectedWarna;
  final List<String> _umurOptions = [
    '2 Minggu',
    '1 Bulan',
    '2 Bulan',
    '3 Bulan',
    '4 Bulan',
  ];

  final List<Map<String, dynamic>> _warnaTinja = [
    {'nama': 'Kuning (Normal)', 'color': const Color(0xFFFCD34D), 'status': 'Normal', 'desc': 'Tinja kuning merupakan warna normal pada bayi yang disusui ASI eksklusif.'},
    {'nama': 'Hijau Kuning', 'color': const Color(0xFF86EFAC), 'status': 'Normal', 'desc': 'Tinja hijau-kuning masih termasuk normal, terutama pada minggu-minggu pertama.'},
    {'nama': 'Hijau', 'color': const Color(0xFF22C55E), 'status': 'Perhatian', 'desc': 'Tinja hijau bisa terjadi karena konsumsi ASI foremilk yang berlebihan.'},
    {'nama': 'Coklat', 'color': const Color(0xFF92400E), 'status': 'Normal', 'desc': 'Tinja coklat umumnya normal, terutama jika bayi sudah mendapat MPASI.'},
    {'nama': 'Merah/Pink', 'color': const Color(0xFFEF4444), 'status': 'Bahaya', 'desc': 'Tinja merah atau pink menandakan adanya darah. Segera ke puskesmas!'},
    {'nama': 'Hitam (Meconium)', 'color': const Color(0xFF1F2937), 'status': 'Normal (0-3 hari)', 'desc': 'Tinja hitam hanya normal pada 2-3 hari pertama kehidupan. Setelah itu, segera konsultasi.'},
    {'nama': 'Putih/Pucat', 'color': const Color(0xFFF5F5F4), 'status': 'Bahaya', 'desc': 'Tinja putih/pucat menandakan masalah pada hati. Segera ke rumah sakit!'},
  ];

  void _showResult() {
    if (_selectedUmur == null || _selectedWarna == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih umur dan warna tinja terlebih dahulu'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final selectedData = _warnaTinja.firstWhere((w) => w['nama'] == _selectedWarna);
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
            Text('Umur: $_selectedUmur'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Warna Tinja: '),
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
          if (isBahaya || isPerhatian)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAlertPuskesmas();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cari Puskesmas'),
            ),
        ],
      ),
    );
  }

  void _showAlertPuskesmas() {
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
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Perlu Ke Puskesmas!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Berdasarkan pemantauan, disarankan untuk segera membawa si Kecil ke puskesmas terdekat untuk pemeriksaan lebih lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mengerti',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cek Warna Tinja',
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
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFCA8A04)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pantau warna tinja bayi untuk memastikan kesehatan pencernaannya',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pilih Umur
            const Text(
              'Pilih Umur Bayi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _umurOptions.map((umur) {
                final isSelected = _selectedUmur == umur;
                return InkWell(
                  onTap: () => setState(() => _selectedUmur = umur),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFCA8A04)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFCA8A04)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      umur,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Pilih Warna
            const Text(
              'Pilih Warna Tinja',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ..._warnaTinja.map((warna) {
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
                          ? const Color(0xFFFEF9C3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFCA8A04)
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
                            color: Color(0xFFCA8A04),
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
                  backgroundColor: const Color(0xFFCA8A04),
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