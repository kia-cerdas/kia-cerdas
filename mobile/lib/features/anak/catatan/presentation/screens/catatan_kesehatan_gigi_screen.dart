import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pemeriksaan_gigi_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/pemeriksaan_gigi_api_service.dart';
import 'catatan_detail_screen.dart';

class CatatanKesehataanGigiScreen extends StatefulWidget {
  final int anakId;
  final String anakName;

  const CatatanKesehataanGigiScreen({
    super.key,
    required this.anakId,
    required this.anakName,
  });

  @override
  State<CatatanKesehataanGigiScreen> createState() =>
      _CatatanKesehataanGigiScreenState();
}

class _CatatanKesehataanGigiScreenState
    extends State<CatatanKesehataanGigiScreen> {
  final PemeriksaanGigiApiService _apiService = PemeriksaanGigiApiService();
  bool isLoading = true;
  String errorMsg = '';
  List<PemeriksaanGigiModel> catatanList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });
    try {
      final data = await _apiService.getByAnakID(widget.anakId);
      if (mounted) {
        setState(() {
          catatanList = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'attention':
        return Colors.orange;
      case 'late':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'normal':
        return 'Normal';
      case 'attention':
        return 'Perlu perhatian';
      case 'late':
        return 'Terlambat';
      default:
        return '-';
    }
  }

  Widget _buildDentalStatusTag(String label, String value, String type) {
    Color bgColor;
    Color textColor;

    // Tag untuk dental parameters
    if (type == 'gigi_berlubang' && int.tryParse(value) != null && int.parse(value) == 0) {
      bgColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF155724);
    } else if (type == 'status_plak' && (value.toLowerCase().contains('tidak') || value.toLowerCase().contains('bersih'))) {
      bgColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF155724);
    } else if (type == 'risiko' && value.toLowerCase().contains('rendah')) {
      bgColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF155724);
    } else if (type == 'risiko' && value.toLowerCase().contains('sedang')) {
      bgColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFF856404);
    } else if (type == 'risiko' && value.toLowerCase().contains('tinggi')) {
      bgColor = const Color(0xFFF8D7DA);
      textColor = const Color(0xFF721C24);
    } else if (type == 'status_plak' && (value.toLowerCase().contains('ada') || value.toLowerCase().contains('kotor'))) {
      bgColor = const Color(0xFFFFF3CD);
      textColor = const Color(0xFF856404);
    } else {
      bgColor = const Color(0xFFE2E3E5);
      textColor = const Color(0xFF383D41);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kesehatan Gigi',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau kesehatan gigi ${widget.anakName}',
              style: const TextStyle(
                color: Color(0xFF7B8798),
                fontSize: 13,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF172033)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Reminder
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Color(0xFFD32F2F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catatan gigi untuk ${widget.anakName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Jaga selalu kebersihan mulut anak', style: TextStyle(color: Color(0xFF7B8798))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMsg.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMsg, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : catatanList.isEmpty
                        ? const Center(child: Text('Belum ada catatan kesehatan gigi.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: catatanList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = catatanList[index];
                              
                              final dateStr = DateFormat('dd MMM yyyy').format(item.tanggal);
                              final kondisi = item.gigiBerlubang > 0 ? 'Ada Gigi Berlubang' : 'Sehat';
                              final status = item.gigiBerlubang > 0 || item.resikoGigiBerlubang.toLowerCase() == 'tinggi' ? 'attention' : 'normal';

                              // Convert model to Map for existing CatatanDetailScreen
                              final mapItem = {
                                'date': dateStr,
                                'bulanke': item.bulan,
                                'jumlahGigi': item.jumlahGigi,
                                'gigiBerlubang': item.gigiBerlubang,
                                'statusPlak': item.statusPlak,
                                'kondisi': kondisi,
                                'resikoGigiBerlubang': item.resikoGigiBerlubang,
                                'status': status
                              };

                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Usia: ${item.bulan} bulan',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798)),
                                          ),
                                        ],
                                      ),
                                      Chip(
                                        label: Text(_statusLabel(status)),
                                        backgroundColor: _statusColor(status).withOpacity(0.12),
                                        labelStyle: TextStyle(color: _statusColor(status)),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        'Kondisi: $kondisi',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gigi: ${item.jumlahGigi} | Berlubang: ${item.gigiBerlubang}',
                                        style: const TextStyle(color: Color(0xFF7B8798), fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      // Dental parameters tags
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          _buildDentalStatusTag(
                                            'Plak: ${item.statusPlak}',
                                            item.statusPlak,
                                            'status_plak',
                                          ),
                                          _buildDentalStatusTag(
                                            'Risiko: ${item.resikoGigiBerlubang}',
                                            item.resikoGigiBerlubang,
                                            'risiko',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  isThreeLine: true,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CatatanDetailScreen(data: mapItem, title: 'Detail Kesehatan Gigi')),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
