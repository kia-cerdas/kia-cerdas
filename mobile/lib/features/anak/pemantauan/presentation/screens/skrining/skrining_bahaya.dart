import 'package:flutter/material.dart';

class SkriningBahayaScreen extends StatefulWidget {
  final Map<String, dynamic>? anak;

  const SkriningBahayaScreen({Key? key, this.anak}) : super(key: key);

  @override
  State<SkriningBahayaScreen> createState() => _SkriningBahayaScreenState();
}

class _SkriningBahayaScreenState extends State<SkriningBahayaScreen> {
  // Track selected symptoms
  Map<String, bool> selectedSymptoms = {
    // Demam
    'temp_39': false,
    'temp_38_39': false,
    'demam_3hari': false,
    // Diare
    'diare_darah': false,
    'dehidrasi': false,
    'diare_5kali': false,
    // Kejang & Kesadaran
    'kejang': false,
    'tidak_sadar': false,
  };

  // Gejala darurat (yang menampilkan badge merah)
  List<String> emergencySymptoms = [
    'temp_39',
    'diare_darah',
    'dehidrasi',
    'kejang',
    'tidak_sadar',
  ];

  int get totalSymptomCount => selectedSymptoms.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skrining Tanda Bahaya',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.anak != null)
              Text(
                'Untuk: ${widget.anak!['nama']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              const Text(
                'Jawab pertanyaan berikut dengan jujur. Centang gejala yang dialami anak Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Counter Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gejala terpilih:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAED),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFCED2)),
                      ),
                      child: Text(
                        '$totalSymptomCount dari 8',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DEMAM Section
              _buildCategorySection(
                category: 'Demam',
                items: [
                  {
                    'id': 'temp_39',
                    'label': 'Suhu tubuh anak ≥ 39.5°C?',
                    'isEmergency': true,
                  },
                  {
                    'id': 'temp_38_39',
                    'label': 'Suhu tubuh anak 38.5-39.4°C?',
                    'isEmergency': false,
                  },
                  {
                    'id': 'demam_3hari',
                    'label': 'Demam sudah berlangsung ≥ 3 hari?',
                    'isEmergency': false,
                  },
                ],
              ),
              const SizedBox(height: 20),

              // DIARE Section
              _buildCategorySection(
                category: 'Diare',
                items: [
                  {
                    'id': 'diare_darah',
                    'label': 'Diare disertai darah?',
                    'isEmergency': true,
                  },
                  {
                    'id': 'dehidrasi',
                    'label': 'Ada tanda dehidrasi (mata cekung, mulut kering, lemas)?',
                    'isEmergency': true,
                  },
                  {
                    'id': 'diare_5kali',
                    'label': 'Diare ≥ 5 kali per hari?',
                    'isEmergency': false,
                  },
                ],
              ),
              const SizedBox(height: 20),

              // KEJANG & KESADARAN Section
              _buildCategorySection(
                category: 'Kejang & Kesadaran',
                items: [
                  {
                    'id': 'kejang',
                    'label': 'Anak mengalami kejang?',
                    'isEmergency': true,
                  },
                  {
                    'id': 'tidak_sadar',
                    'label': 'Anak tidak sadar atau sangat lemas?',
                    'isEmergency': true,
                  },
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Lihat Hasil Skrining',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required String category,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
            thickness: 1,
          ),

          // Items
          ...List.generate(
            items.length,
            (index) {
              final item = items[index];
              final id = item['id'] as String;
              final label = item['label'] as String;
              final isEmergency = item['isEmergency'] as bool? ?? false;
              final isChecked = selectedSymptoms[id] ?? false;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              selectedSymptoms[id] = value ?? false;
                            });
                          },
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.all(
                            isChecked ? const Color(0xFF2563EB) : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Darurat',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      color: Colors.grey.shade100,
                      height: 1,
                      thickness: 1,
                      indent: 50,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showResults() {
    final emergencyCount = selectedSymptoms.entries
        .where((e) => e.value && emergencySymptoms.contains(e.key))
        .length;

    final hasEmergency = emergencyCount > 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: hasEmergency ? const Color(0xFFFFEAED) : const Color(0xFFECFDF5),
        title: Text(
          hasEmergency ? 'SEGERA KE FASILITAS' : 'Hasil Skrining',
          style: TextStyle(
            color: hasEmergency ? const Color(0xFFDC2626) : const Color(0xFF059669),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          hasEmergency
              ? 'Anak Anda menunjukkan gejala darurat. Segera bawa ke fasilitas kesehatan terdekat!'
              : 'Anak Anda menunjukkan $totalSymptomCount gejala. Pantau kondisi anak dan konsultasikan dengan tenaga kesehatan jika diperlukan.',
          style: const TextStyle(fontSize: 14),
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
}