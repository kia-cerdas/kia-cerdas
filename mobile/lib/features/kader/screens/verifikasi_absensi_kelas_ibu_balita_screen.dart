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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String _errorMessage = '';

  /// Filter status: null = semua, 'Menunggu' = belum diverifikasi,
  /// 'Diterima' = diverifikasi diterima, 'Ditolak' = diverifikasi ditolak.
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        SnackBar(
          content: Text(status == 'Diterima' 
            ? 'Berhasil memverifikasi kehadiran' 
            : 'Berhasil menolak kehadiran'),
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

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryPill(label: 'Semua', count: _absensiList.length, color: Colors.blueGrey),
        const SizedBox(width: 6),
        _summaryPill(label: 'Menunggu', count: _jumlahBelumVerif, color: Colors.orange),
        const SizedBox(width: 6),
        _summaryPill(label: 'Terverifikasi', count: _jumlahDiterima, color: Colors.green),
        const SizedBox(width: 6),
        _summaryPill(label: 'Tidak Valid', count: _jumlahDitolak, color: Colors.red),
      ],
    );
  }

  Widget _summaryPill({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(label: 'Semua (${_absensiList.length})', value: null),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Menunggu ($_jumlahBelumVerif)',
            value: 'Menunggu',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Terverifikasi ($_jumlahDiterima)',
            value: 'Terverifikasi',
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Tidak Valid ($_jumlahDitolak)',
            value: 'Tidak Valid',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required String? value, Color? color}) {
    final isSelected = _filterStatus == value;
    final activeColor = color ?? Colors.teal;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
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

  String _getStatusText(String? status) {
    switch(status) {
      case 'Diterima':
        return 'Terverifikasi';
      case 'Ditolak':
        return 'Tidak Valid';
      default:
        return 'Menunggu';
    }
  }

  Color _getStatusColor(String? status) {
    switch(status) {
      case 'Diterima':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  bool _isVerified(AbsensiKelasIbuBalitaModel item) {
    return item.status == 'Diterima';
  }

  bool _isRejected(AbsensiKelasIbuBalitaModel item) {
    return item.status == 'Ditolak';
  }

  bool _isPending(AbsensiKelasIbuBalitaModel item) {
    return item.status.isEmpty ||
        (item.status != 'Diterima' && item.status != 'Ditolak');
  }

  int get _jumlahBelumVerif => _absensiList.where(_isPending).length;
  int get _jumlahDiterima => _absensiList.where(_isVerified).length;
  int get _jumlahDitolak => _absensiList.where(_isRejected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Kelas Ibu Balita'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildSummaryRow(),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFilterChips(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama ibu atau anak...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final filteredList = _absensiList.where((item) {
                            final q = _searchQuery.toLowerCase();
                            final matchesSearch = item.namaIbu.toLowerCase().contains(q) ||
                                item.namaAnak.toLowerCase().contains(q);
                            bool matchesFilter = true;
                            if (_filterStatus == 'Menunggu') {
                              matchesFilter = _isPending(item);
                            } else if (_filterStatus == 'Terverifikasi') {
                              matchesFilter = _isVerified(item);
                            } else if (_filterStatus == 'Tidak Valid') {
                              matchesFilter = _isRejected(item);
                            }
                            return matchesSearch && matchesFilter;
                          }).toList();

                          if (filteredList.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Belum ada log kehadiran atau tidak ditemukan.'),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final isVerified = _isVerified(item);
                              final isRejected = _isRejected(item);
                              final isPending = _isPending(item);
                              final statusColor = _getStatusColor(item.status);
                              final statusText = _getStatusText(item.status);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.namaIbu.isNotEmpty 
                                                    ? 'Ibu ${item.namaIbu}' 
                                                    : 'Ibu (Data tidak lengkap)',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold, 
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                if (item.namaAnak.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Anak: ${item.namaAnak}',
                                                    style: const TextStyle(
                                                      fontSize: 14, 
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10, 
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: statusColor.withOpacity(0.5),
                                              ),
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
                                      Text(
                                        'Pertemuan ke: ${item.pertemuanKe}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tanggal Hadir: ${item.tanggal}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      if (isVerified || isRejected) ...[
                                        const SizedBox(height: 8),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          isRejected 
                                            ? 'Ditolak oleh: ${item.namaKader}' 
                                            : 'Diverifikasi oleh: ${item.namaKader}', 
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tanggal Verifikasi: ${item.tanggalParaf}', 
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
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
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}