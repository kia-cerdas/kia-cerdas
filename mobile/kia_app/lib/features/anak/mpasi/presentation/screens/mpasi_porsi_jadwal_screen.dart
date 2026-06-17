import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/models/mpasi_models.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/services/mpasi_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/widgets/mpasi_age_tabs.dart';

class MpasiPorsiJadwalScreen extends StatefulWidget {
  const MpasiPorsiJadwalScreen({Key? key}) : super(key: key);

  @override
  _MpasiPorsiJadwalScreenState createState() => _MpasiPorsiJadwalScreenState();
}

class _MpasiPorsiJadwalScreenState extends State<MpasiPorsiJadwalScreen> {
  int _selectedBulan = 6;
  bool _isLoading = true;
  PorsiJadwalResponse? _data;
  late MpasiApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = MpasiApiService();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.getPorsiJadwalByBulan(_selectedBulan);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data porsi dan jadwal MPASI')),
        );
      }
    }
  }

  void _onTabChanged(int bulan) {
    setState(() {
      _selectedBulan = bulan;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5B9B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Porsi & Jadwal',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: MpasiAgeTabs(
              selectedBulan: _selectedBulan,
              onTabChanged: _onTabChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data == null
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_data!.aturanPorsi != null) _buildAturanPorsi(_data!.aturanPorsi!),
                          const SizedBox(height: 24),
                          if (_data!.jadwalHarian.isNotEmpty) _buildJadwalHarian(_data!.jadwalHarian),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAturanPorsi(AturanPorsiMpasi porsi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPorsiItem(Icons.water_drop_outlined, Colors.blue, 'Tekstur', porsi.tekstur),
          const Divider(height: 32),
          _buildPorsiItem(Icons.access_time, Colors.orange, 'Frekuensi', porsi.frekuensi),
          const Divider(height: 32),
          _buildPorsiItem(Icons.scale, Colors.green, 'Porsi Setiap Makan', porsi.porsi),
        ],
      ),
    );
  }

  Widget _buildPorsiItem(IconData icon, Color iconColor, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2B4C)),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalHarian(List<JadwalHarianMpasi> jadwal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contoh Jadwal Harian',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A2B4C)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: jadwal.asMap().entries.map((entry) {
              final isLast = entry.key == jadwal.length - 1;
              final item = entry.value;
              final isMakan = item.aktivitas.toLowerCase().contains('makan');
              final isAsi = item.aktivitas.toLowerCase().contains('asi');
              
              Color dotColor = Colors.orange;
              if (isMakan) dotColor = Colors.green;
              if (isAsi) dotColor = Colors.blue;

              return IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        item.waktu,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade200,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          item.aktivitas,
                          style: TextStyle(
                            color: dotColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
