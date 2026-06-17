import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/detail_kunjungan_imunisasi.dart';

class KunjunganScreen extends StatefulWidget {
  const KunjunganScreen({
    super.key,
  });

  @override
  State<KunjunganScreen> createState() => _KunjunganScreenState();
}

class _KunjunganScreenState extends State<KunjunganScreen> {
  final KunjunganImunisasiService _service = KunjunganImunisasiService();

  bool _isLoading = true;

  List<KunjunganImunisasiModel> _kunjungan = [];

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKunjungan();
  }

  Future<void> _loadKunjungan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _service.getAllKunjunganImunisasi();

      if (!mounted) return;

      setState(() {
        _kunjungan = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FB,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Daftar Kunjungan Imunisasi',
          style: TextStyle(
            color: Color(
              0xFF1E293B,
            ),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1,
          ),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_kunjungan.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data kunjungan',
        ),
      );
    }

    // Group berdasarkan status
    final grouped = {
      'Terjadwal': <KunjunganImunisasiModel>[],
      'Perlu Tindak Lanjut': <KunjunganImunisasiModel>[],
      'Selesai': <KunjunganImunisasiModel>[],
      'Dibatalkan': <KunjunganImunisasiModel>[],
    };

    for (final item in _kunjungan) {
      grouped.putIfAbsent(
        item.statusKunjungan,
        () => [],
      );

      grouped[item.statusKunjungan]!.add(item);
    }

    return RefreshIndicator(
      onRefresh: _loadKunjungan,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusSection(
            title: 'Terjadwal',
            items: grouped['Terjadwal']!,
          ),
          _buildStatusSection(
            title: 'Perlu Tindak Lanjut',
            items: grouped['Perlu Tindak Lanjut']!,
          ),
          _buildStatusSection(
            title: 'Selesai',
            items: grouped['Selesai']!,
          ),
          _buildStatusSection(
            title: 'Dibatalkan',
            items: grouped['Dibatalkan']!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection({
    required String title,
    required List<KunjunganImunisasiModel> items,
  }) {
    final color = _statusColor(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
            top: 8,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Kalau kosong
        if (items.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
              bottom: 14,
            ),
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Text(
              'Tidak ada jadwal ${title.toLowerCase()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          )
        else
          ...items.map(
            (item) => _kunjunganCard(
              id: item.kunjunganId,
              namaAnak: item.namaAnak,
              tanggal: item.tanggalKunjungan ?? DateTime.now(),
              status: item.statusKunjungan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnakImunisasiDetailScreen(
                      kunjunganId: item.kunjunganId,
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _kunjunganCard({
    required int id,
    required String namaAnak,
    required DateTime tanggal,
    required String status,
    required VoidCallback onTap,
  }) {
    final color = _statusColor(
      status,
    );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              16,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 8,
                offset: const Offset(
                  0,
                  2,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons.vaccines_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      namaAnak,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        tanggal,
                      ),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(
                          0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'Terjadwal':
        return Colors.blue;

      case 'Perlu Tindak Lanjut':
        return Colors.orange;

      case 'Selesai':
        return Colors.green;

      case 'Dibatalkan':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
