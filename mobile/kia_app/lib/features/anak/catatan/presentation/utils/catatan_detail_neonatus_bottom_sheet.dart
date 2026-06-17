import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/neonatus_model.dart';
import 'package:intl/intl.dart';

void showCatatanDetailNeonatus(BuildContext context, NeonatusModel item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF1F5F9),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return _NeonatusDetailContent(item: item, scrollController: scrollController);
        },
      );
    },
  );
}

class _NeonatusDetailContent extends StatelessWidget {
  final NeonatusModel item;
  final ScrollController scrollController;

  const _NeonatusDetailContent({
    required this.item,
    required this.scrollController,
  });

  String _findNilai(List<String> keywords) {
    for (var d in item.detailPelayanan) {
      String name = d.namaPelayanan.toLowerCase();
      for (var kw in keywords) {
        if (name.contains(kw.toLowerCase())) {
          return d.nilai;
        }
      }
    }
    return '';
  }

  bool _isTrue(List<String> keywords) {
    String val = _findNilai(keywords);
    return val.isNotEmpty && val != '0' && val.toLowerCase() != 'tidak' && val.toLowerCase() != 'false';
  }

  String _extractKeterangan(List<String> keywordsPelayanan, String keyToExtract, {int? fallbackId}) {
    for (var d in item.detailPelayanan) {
      String name = d.namaPelayanan.toLowerCase();
      bool match = false;
      for (var kw in keywordsPelayanan) {
        if (name.contains(kw.toLowerCase())) {
          match = true;
          break;
        }
      }
      
      if (!match && fallbackId != null && d.jenisPelayananId == fallbackId) {
        match = true;
      }

      if (match && d.keterangan.isNotEmpty) {
        final parts = d.keterangan.split(' | ');
        for (var p in parts) {
          if (p.trim().toLowerCase().startsWith(keyToExtract.toLowerCase())) {
            final split = p.split(':');
            if (split.length > 1) {
              return split.sublist(1).join(':').trim();
            }
          }
        }
      }
    }
    return '';
  }

  String _getPeriodeName(int id) {
    switch (id) {
      case 1: return '0 - 6 JAM';
      case 2: return 'KN1';
      case 3: return 'KN2';
      case 4: return 'KN3';
      default: return 'KUNJUNGAN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DETAIL KUNJUNGAN: ${_getPeriodeName(item.periodeId)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'DATA REKAM MEDIS BAYI',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Color(0xFF185FA5)),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(item.tanggal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF185FA5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        
        // Body
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildAntropometriCard(),
              const SizedBox(height: 16),
              _buildTindakanMedisCard(),
              const SizedBox(height: 16),
              _buildLogTindakanCard(),
              const SizedBox(height: 16),
              _buildTripelEliminasiCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAntropometriCard() {
    return _buildCard(
      title: 'KONDISI & ANTROPOMETRI',
      icon: Icons.monitor_weight_outlined,
      iconColor: const Color(0xFF185FA5),
      child: Column(
        children: [
          _buildInputField('BERAT BADAN (BB)', _findNilai(['bb', 'berat badan']), 'GRAM'),
          const SizedBox(height: 12),
          _buildInputField('PANJANG BADAN (PB)', _findNilai(['pb', 'panjang badan']), 'CM'),
          const SizedBox(height: 12),
          _buildInputField('LINGKAR KEPALA (LK)', _findNilai(['lk', 'lingkar kepala']), 'CM'),
        ],
      ),
    );
  }

  Widget _buildTindakanMedisCard() {
    return _buildCard(
      title: 'PELAYANAN & TINDAKAN MEDIS',
      icon: Icons.medical_services_outlined,
      iconColor: Colors.green,
      child: Column(
        children: [
          _buildCheckItem('INISIASI MENYUSU DINI (IMD)', _isTrue(['imd', 'menyusu'])),
          const SizedBox(height: 10),
          _buildCheckItem('PEMBERIAN VITAMIN K1', _isTrue(['vitamin k', 'vit k'])),
          const SizedBox(height: 10),
          _buildCheckItem('SALEP/TETES MATA ANTIBIOTIK', _isTrue(['salep', 'mata', 'antibiotik'])),
          const SizedBox(height: 10),
          _buildCheckItem('IMUNISASI HEPATITIS B (HB0)', _isTrue(['hepatitis', 'hb0'])),
        ],
      ),
    );
  }

  Widget _buildLogTindakanCard() {
    return _buildCard(
      title: 'LOG TINDAKAN / IMUNISASI',
      icon: Icons.access_time,
      iconColor: Colors.grey,
      child: Column(
        children: [
          _buildInputField('TANGGAL PEMBERIAN', DateFormat('dd/MM/yyyy').format(item.tanggal), ''),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField('JAM', _extractKeterangan(['hb', 'hepatitis b'], 'Jam:', fallbackId: 7), '')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField('NO. BATCH', _extractKeterangan(['hb', 'hepatitis b'], 'Batch:', fallbackId: 7), '')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripelEliminasiCard() {
    return _buildCard(
      title: 'TRIPEL ELIMINASI',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      child: Column(
        children: [
          _buildTripelItem('HIV (H)', _extractKeterangan(['tripel', 'eliminasi'], 'H:', fallbackId: 8)),
          const SizedBox(height: 10),
          _buildTripelItem('SIFILIS (S)', _extractKeterangan(['tripel', 'eliminasi'], 'S:', fallbackId: 8)),
          const SizedBox(height: 10),
          _buildTripelItem('HEPATITIS B (HEP B)', _extractKeterangan(['tripel', 'eliminasi'], 'Hep B:', fallbackId: 8)),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildCard({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool isChecked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isChecked ? Colors.green : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.circle_outlined,
            color: isChecked ? Colors.green : Colors.grey.shade300,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                color: isChecked ? Colors.green[800] : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripelItem(String label, String value) {
    bool isNR = value.toUpperCase() == 'NR';
    bool isR = value.toUpperCase() == 'R';
    
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isNR ? const Color(0xFF185FA5) : Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                border: Border.all(color: isNR ? const Color(0xFF185FA5) : Colors.grey.shade300),
              ),
              child: Text(
                'NR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isNR ? Colors.white : Colors.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isR ? Colors.red : Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                border: Border.all(color: isR ? Colors.red : Colors.grey.shade300),
              ),
              child: Text(
                'R',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isR ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
