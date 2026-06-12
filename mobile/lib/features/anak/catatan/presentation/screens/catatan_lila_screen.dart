import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pengukuran_lila_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/pengukuran_lila_api_service.dart';
import 'catatan_detail_screen.dart';

class CatatanLilaScreen extends StatefulWidget {
  final int anakId;
  final String anakName;

  const CatatanLilaScreen({
    super.key,
    required this.anakId,
    required this.anakName,
  });

  @override
  State<CatatanLilaScreen> createState() => _CatatanLilaScreenState();
}

class _CatatanLilaScreenState extends State<CatatanLilaScreen> {
  final PengukuranLilaApiService _apiService = PengukuranLilaApiService();
  bool isLoading = true;
  String errorMsg = '';
  List<PengukuranLilaModel> catatanList = [];

  @override
  void initState() {
    super.initState();
    _loadCatatan();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadCatatan() async {
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
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'berisiko':
        return Colors.orange;
      case 'kurang gizi':
      case 'buruk':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
              'Lingkar Lengan Atas (LiLA)',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau pengukuran LiLA ${widget.anakName}',
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
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Color(0xFFF57C00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catatan LiLA untuk ${widget.anakName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Pantau status gizi anak secara berkala', style: TextStyle(color: Color(0xFF7B8798))),
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
                              onPressed: _loadCatatan,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : catatanList.isEmpty
                        ? _buildEmptyState()
                        : _buildCatatanList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur tambah catatan belum tersedia untuk Ibu'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
        backgroundColor: const Color(0xFFF57C00),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.straighten_outlined,
                size: 50,
                color: Color(0xFFF57C00),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Catatan LiLA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai catat pengukuran lingkar lengan atas anak secara berkala untuk memantau status gizi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7B8798),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFF57C00)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'LiLA (Lingkar Lengan Atas) adalah indikator penting untuk menilai status gizi anak.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatanList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: catatanList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = catatanList[index];
        final dateStr = DateFormat('dd MMM yyyy').format(item.tanggal);
        
        // Data format required for CatatanDetailScreen
        final mapItem = {
          'date': dateStr,
          'bulanke': item.bulan,
          'hasilLila': '${item.hasilLila} cm',
          'kondisi': item.kategoriRisiko,
          'status': item.kategoriRisiko.toLowerCase() == 'normal' ? 'normal' : 'attention',
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
                      'Bulan ke-${item.bulan}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798)),
                    ),
                  ],
                ),
                Chip(
                  label: Text(item.kategoriRisiko),
                  backgroundColor: _statusColor(item.kategoriRisiko).withOpacity(0.12),
                  labelStyle: TextStyle(color: _statusColor(item.kategoriRisiko)),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Hasil LiLA: ${item.hasilLila} cm',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CatatanDetailScreen(
                    data: mapItem,
                    title: 'Detail LiLA',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

