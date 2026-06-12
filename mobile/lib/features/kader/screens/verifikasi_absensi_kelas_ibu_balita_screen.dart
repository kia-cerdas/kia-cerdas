import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/absensi/data/datasources/absensi_kelas_ibu_balita_api_service.dart';
import 'package:ta_pa2_pa3_project/features/absensi/data/models/absensi_kelas_ibu_balita_model.dart';
import 'package:intl/intl.dart';

class VerifikasiAbsensiKelasIbuBalitaScreen extends StatefulWidget {
  const VerifikasiAbsensiKelasIbuBalitaScreen({super.key});

  @override
  State<VerifikasiAbsensiKelasIbuBalitaScreen> createState() => _VerifikasiAbsensiKelasIbuBalitaScreenState();
}

class _VerifikasiAbsensiKelasIbuBalitaScreenState extends State<VerifikasiAbsensiKelasIbuBalitaScreen> {
  final AbsensiKelasIbuBalitaApiService _apiService = AbsensiKelasIbuBalitaApiService();
  List<AbsensiKelasIbuBalitaModel> _absensiList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.getAllKader();
      setState(() {
        _absensiList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verify(AbsensiKelasIbuBalitaModel item, String status) async {
    final namaKader = AuthSession.userName ?? 'Kader';
    final tanggalParaf = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.verifyKader(item.id!, namaKader, tanggalParaf, status);
      
      if (!mounted) return;
      Navigator.pop(context); // close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memverifikasi kehadiran'),
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
      appBar: AppBar(
        title: const Text('Verifikasi Kelas Ibu Balita'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _absensiList.isEmpty
                  ? const Center(child: Text('Belum ada log kehadiran.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _absensiList.length,
                      itemBuilder: (context, index) {
                        final item = _absensiList[index];
                        final isVerified = item.status == 'Diterima' || (item.namaKader.isNotEmpty && item.tanggalParaf.isNotEmpty && item.status != 'Ditolak');
                        final isRejected = item.status == 'Ditolak';
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

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.namaIbu.isNotEmpty ? 'Ibu ${item.namaIbu}' : 'Ibu (Data tidak lengkap)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
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
                                Text('Pertemuan ke: ${item.pertemuanKe}'),
                                Text('Tanggal Hadir: ${item.tanggal}'),
                                if (isVerified || isRejected) ...[
                                  const SizedBox(height: 4),
                                  Text(isRejected ? 'Ditolak oleh: ${item.namaKader}' : 'Diverifikasi oleh: ${item.namaKader}', style: const TextStyle(color: Colors.grey)),
                                  Text('Tanggal: ${item.tanggalParaf}', style: const TextStyle(color: Colors.grey)),
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
                                              content: 'Apakah Anda yakin ingin menolak data absensi ini?',
                                              onConfirm: () => _verify(item, 'Ditolak'),
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
                                              title: 'Verifikasi Kehadiran',
                                              content: 'Apakah Anda yakin ingin memverifikasi data absensi ini?',
                                              onConfirm: () => _verify(item, 'Diterima'),
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
                          ),
                        );
                      },
                    ),
    );
  }
}
