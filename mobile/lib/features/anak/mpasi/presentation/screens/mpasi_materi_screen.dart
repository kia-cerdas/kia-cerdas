import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/models/mpasi_models.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/services/mpasi_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/widgets/mpasi_age_tabs.dart';

class MpasiMateriScreen extends StatefulWidget {
  const MpasiMateriScreen({Key? key}) : super(key: key);

  @override
  _MpasiMateriScreenState createState() => _MpasiMateriScreenState();
}

class _MpasiMateriScreenState extends State<MpasiMateriScreen> {
  int _selectedBulan = 6;
  bool _isLoading = true;
  List<MateriMpasi> _materiList = [];
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
      final data = await _apiService.getMateriByBulan(_selectedBulan);
      setState(() {
        _materiList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data materi MPASI')),
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
          'Materi MPASI',
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
                : _materiList.isEmpty
                    ? const Center(child: Text('Belum ada materi untuk usia ini'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _materiList.length,
                        itemBuilder: (context, index) {
                          final materi = _materiList[index];
                          return _buildMateriCard(materi, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriCard(MateriMpasi materi, int index) {
    // Dynamic styling based on order or content
    final isFirst = index == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: isFirst ? Colors.pinkAccent : Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  materi.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFirst ? Colors.pink.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst ? Colors.pink.shade100 : Colors.grey.shade200,
              ),
            ),
            child: Text(
              materi.konten,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
