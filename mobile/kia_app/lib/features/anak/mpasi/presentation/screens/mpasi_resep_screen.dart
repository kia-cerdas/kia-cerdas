import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/models/mpasi_models.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/services/mpasi_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/widgets/mpasi_age_tabs.dart';

class MpasiResepScreen extends StatefulWidget {
  const MpasiResepScreen({Key? key}) : super(key: key);

  @override
  _MpasiResepScreenState createState() => _MpasiResepScreenState();
}

class _MpasiResepScreenState extends State<MpasiResepScreen> {
  int _selectedBulan = 6;
  bool _isLoading = true;
  List<ResepMpasi> _resepList = [];
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
      final data = await _apiService.getResepByBulan(_selectedBulan);
      setState(() {
        _resepList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data resep MPASI')),
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

  void _showResepDetail(ResepMpasi resep) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResepDetailSheet(resep),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5B9B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resep Harian',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                : _resepList.isEmpty
                    ? const Center(
                        child: Text('Belum ada resep untuk usia ini'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _resepList.length,
                        itemBuilder: (context, index) {
                          return _buildResepCard(_resepList[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResepCard(ResepMpasi resep) {
    final bool isSelingan = resep.tipe.toLowerCase().contains('selingan') ||
        resep.tipe.toLowerCase().contains('snack');
    final String? imageUrl = _resolveImageUrl(resep.gambarUrl);

    return GestureDetector(
      onTap: () => _showResepDetail(resep),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelingan ? Colors.orange.shade200 : Colors.blue.shade200,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Container(
                width: 120,
                height: 120,
                color: const Color(0xFFEAF2FF),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildResepImageFallback(isSelingan),
                      )
                    : _buildResepImageFallback(isSelingan),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelingan
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        resep.tipe.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelingan ? Colors.orange : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resep.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A2B4C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${resep.waktuPersiapan} Min',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${resep.kalori} kkal',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_right, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResepDetailSheet(ResepMpasi resep) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: const Color(0xFFEAF2FF),
                        child: _resolveImageUrl(resep.gambarUrl) != null
                            ? Image.network(
                                _resolveImageUrl(resep.gambarUrl)!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildResepImageFallback(resep.tipe
                                            .toLowerCase()
                                            .contains('selingan') ||
                                        resep.tipe
                                            .toLowerCase()
                                            .contains('snack')),
                              )
                            : _buildResepImageFallback(
                                resep.tipe.toLowerCase().contains('selingan') ||
                                    resep.tipe.toLowerCase().contains('snack')),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      resep.judul,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4C)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge('${resep.waktuPersiapan} Menit'),
                        const SizedBox(width: 12),
                        _buildBadge(resep.porsi),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Bahan-bahan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...resep.bahanBahan.map((bahan) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6, right: 8),
                                child: Icon(Icons.circle,
                                    size: 8, color: Colors.blue),
                              ),
                              Expanded(
                                  child: Text(bahan,
                                      style: const TextStyle(height: 1.5))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    const Text('Cara Membuat',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...resep.caraMembuat.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(entry.value,
                                      style: const TextStyle(height: 1.5))),
                            ],
                          ),
                        )),
                    if (resep.manfaat != null && resep.manfaat!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Manfaat',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4, right: 8),
                            child: Icon(Icons.check_circle,
                                size: 16, color: Colors.green),
                          ),
                          Expanded(
                              child: Text(resep.manfaat!,
                                  style: const TextStyle(height: 1.5))),
                        ],
                      ),
                    ],
                    if (resep.tips != null && resep.tips!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Tips',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(resep.tips!,
                                    style: const TextStyle(height: 1.5))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
      ),
    );
  }

  String? _resolveImageUrl(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return '${ApiConstants.baseUrl}$trimmed';
    }

    return '${ApiConstants.baseUrl}/$trimmed';
  }

  Widget _buildResepImageFallback(bool isSelingan) {
    return Container(
      color: isSelingan ? Colors.orange.shade50 : Colors.blue.shade50,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 36,
        color: isSelingan ? Colors.orange : Colors.blue,
      ),
    );
  }
}
