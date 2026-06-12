import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/kader/services/bbl_kader_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/bbl_model.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class VerifikasiBblScreen extends StatefulWidget {
  const VerifikasiBblScreen({super.key});

  @override
  State<VerifikasiBblScreen> createState() => _VerifikasiBblScreenState();
}

class _VerifikasiBblScreenState extends State<VerifikasiBblScreen> {
  final BblKaderApiService _apiService = BblKaderApiService();
  List<BblModel> _bblList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.getAllBbl();
      setState(() {
        _bblList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verify(int anakId, BblCheckModel item, String status) async {
    // Sebagai fallback jika Kader ID tidak bisa di ekstrak, berikan default value 1 (karena kita bypass di backend)
    int kaderId = 1; 

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.verifyBbl(anakId, kaderId, item.periodeWaktu, status);
      
      if (!mounted) return;
      Navigator.pop(context); // close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memverifikasi data BBL'),
          backgroundColor: Colors.green,
        ),
      );
      
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal verifikasi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Verifikasi Bayi Baru Lahir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _bblList.isEmpty
                  ? const Center(child: Text('Belum ada data BBL yang diajukan.'))
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bblList.length,
                        itemBuilder: (context, index) {
                          final item = _bblList[index];
                          final submittedChecklists = item.checklist.where((c) => c.statusPemeriksaan).toList();

                          if (submittedChecklists.isEmpty) {
                            return const SizedBox.shrink(); // Hide if no submitted checklist
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.namaAnak != null && item.namaAnak!.isNotEmpty 
                                      ? item.namaAnak! 
                                      : 'Anak (Data tidak lengkap)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  ...submittedChecklists.map((check) {
                                    final isVerified = check.isVerified || check.status == 'Diterima';
                                    final isRejected = check.status == 'Ditolak';
                                    final isPending = !isVerified && !isRejected;
                                    
                                    Color statusColor = Colors.orange;
                                    String statusText = 'Menunggu Verifikasi';
                                    
                                    if (isVerified) {
                                      statusColor = Colors.green;
                                      statusText = 'Diterima';
                                    } else if (isRejected) {
                                      statusColor = Colors.red;
                                      statusText = 'Ditolak';
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                check.periodeWaktu,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: statusColor.withOpacity(0.5))
                                                ),
                                                child: Text(
                                                  statusText,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (check.tanggalSubmit != null)
                                            Text('Tanggal Submit: ${DateFormat('dd MMM yyyy, HH:mm').format(check.tanggalSubmit!.toLocal())}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          if (isVerified || isRejected) ...[
                                            const SizedBox(height: 8),
                                            const Divider(height: 1),
                                            const SizedBox(height: 8),
                                            Text(
                                              isRejected ? 'Ditolak oleh: ${check.namaKaderVerifikasi ?? '-'}' : 'Diverifikasi oleh: ${check.namaKaderVerifikasi ?? '-'}', 
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)
                                            ),
                                            if (check.verifiedAt != null)
                                              Text('Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(check.verifiedAt!.toLocal())}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          ],
                                          if (isPending) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () => _showConfirmationDialog(
                                                      context: context,
                                                      title: 'Tolak Verifikasi',
                                                      content: 'Apakah Anda yakin ingin menolak data BBL ini?',
                                                      onConfirm: () => _verify(item.anakId, check, 'Ditolak'),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                      side: const BorderSide(color: Colors.red),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text('Tolak'),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _showConfirmationDialog(
                                                      context: context,
                                                      title: 'Verifikasi BBL',
                                                      content: 'Apakah Anda yakin ingin memverifikasi data BBL ini?',
                                                      onConfirm: () => _verify(item.anakId, check, 'Diterima'),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF185FA5),
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      elevation: 1,
                                                    ),
                                                    child: const Text('Verifikasi'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
