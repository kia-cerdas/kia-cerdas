import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/keluhan_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/keluhan_anak_api_service.dart';

// Catatan: Pastikan import CatatanDetailScreen disesuaikan agar menerima KeluhanAnakModel
// import 'catatan_detail_screen.dart'; 

class CatatanKesehataanAnakScreen extends StatefulWidget {
  final int anakId;
  final String anakName;

  const CatatanKesehataanAnakScreen({
    super.key, 
    required this.anakId, 
    required this.anakName,
  });

  @override
  State<CatatanKesehataanAnakScreen> createState() =>
      _CatatanKesehataanAnakScreenState();
}

class _CatatanKesehataanAnakScreenState extends State<CatatanKesehataanAnakScreen> {
  final _service = KeluhanAnakApiService();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<KeluhanAnakModel> _catatanList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getByAnakId(widget.anakId);
      setState(() {
        _catatanList = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  // --- Helper Formatting ---
  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[(m - 1).clamp(0, 11)];
  }

  // --- Helper UI ---
  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'perlu_kontrol':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'perlu_kontrol':
        return 'Perlu Kontrol';
      default:
        return '-';
    }
  }

  Widget _buildStatusTag(String label, String status) {
    Color bgColor;
    Color textColor;

    if (status == 'selesai' || status == 'normal') {
      bgColor = const Color(0xFFD4EDDA);
      textColor = const Color(0xFF155724);
    } else if (status == 'perlu_kontrol' || status == 'attention') {
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

  void _showDetail(KeluhanAnakModel item) {
    // Karena Anda menggunakan CatatanDetailScreen sebelumnya dengan Map,
    // Jika CatatanDetailScreen belum diubah untuk menerima Model, gunakan dialog ini sementara.
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Detail Catatan / Keluhan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: ${_fmtDate(item.tanggal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Keluhan:\n${item.keluhan}'),
              const SizedBox(height: 8),
              if (item.tindakan != null) ...[
                Text('Tindakan:\n${item.tindakan}'),
                const SizedBox(height: 8),
              ],
              Text('Pemeriksa: ${item.pemeriksa ?? "-"}'),
              const SizedBox(height: 8),
              if (item.tanggalKembali != null)
                Text('Tanggal Kembali (Kontrol): ${_fmtDate(item.tanggalKembali)}', 
                     style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      );
    });
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
              'Catatan Kesehatan Anak',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.anakName, // Menggunakan nama anak dinamis dari parameter
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
          // Reminder banner
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Color(0xFF2F80ED)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Perbarui catatan kesehatan anak secara berkala', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Pastikan jadwal kontrol terpenuhi', style: TextStyle(color: Color(0xFF7B8798), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Gagal memuat data:\n$_errorMessage', textAlign: TextAlign.center))
                    : _catatanList.isEmpty
                        ? const Center(child: Text('Belum ada catatan kesehatan untuk anak ini.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _catatanList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _catatanList[index];
                              
                              // Logika status: Jika ada tanggal kembali, berarti perlu kontrol
                              final statusType = item.tanggalKembali != null ? 'perlu_kontrol' : 'selesai';

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    // Panggil detail bottomsheet / dialog / screen baru
                                    _showDetail(item);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _fmtDate(item.tanggal), 
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                                            ),
                                            Chip(
                                              label: Text(_statusLabel(statusType), style: const TextStyle(fontSize: 11)),
                                              backgroundColor: _statusColor(statusType).withOpacity(0.12),
                                              labelStyle: TextStyle(color: _statusColor(statusType)),
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.keluhan, 
                                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: Color(0xFF7B8798)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Pemeriksa: ${item.pemeriksa ?? "-"}', 
                                              style: const TextStyle(color: Color(0xFF7B8798), fontSize: 12)
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            if (item.tindakan != null && item.tindakan!.isNotEmpty)
                                              _buildStatusTag('Ada Tindakan', 'normal'),
                                            if (item.tanggalKembali != null)
                                              _buildStatusTag('Kontrol: ${_fmtDate(item.tanggalKembali)}', 'attention'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Fitur tambah catatan belum tersedia'))
      //     );
      //   },
      //   icon: const Icon(Icons.add),
      //   label: const Text('Tambah Catatan'),
      //   backgroundColor: const Color(0xFF2F80ED),
      // ),
    );
  }
}