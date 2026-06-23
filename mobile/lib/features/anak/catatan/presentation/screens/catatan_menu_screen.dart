import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/keluhan_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pemeriksaan_gigi_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pengukuran_lila_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/keluhan_anak_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/pemeriksaan_gigi_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/pengukuran_lila_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/presentation/utils/catatan_detail_bottom_sheet.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/neonatus_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/neonatus_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/presentation/utils/catatan_detail_neonatus_bottom_sheet.dart';

const _kBlue = Color(0xFF185FA5);
const _kBlueDark = Color(0xFF185FA5);
const _kBlueLight = Color(0xFF2178C4);

class CatatanMenuScreen extends StatefulWidget {
  final int anakId;
  final String anakName;
  final String? usiaTeks;

  const CatatanMenuScreen({
    super.key,
    required this.anakId,
    required this.anakName,
    this.usiaTeks,
  });

  @override
  State<CatatanMenuScreen> createState() => _CatatanMenuScreenState();
}

class _CatatanMenuScreenState extends State<CatatanMenuScreen> {
  int _selectedTab = 0;
  final _tabLabels = ['Neonatus', 'Keluhan Anak', 'Kesehatan Gigi', 'LILA'];
  final _tabIcons = [Icons.child_care_outlined, Icons.favorite_border, Icons.medical_services_outlined, Icons.straighten];

  // Services
  final _keluhanService = KeluhanAnakApiService();
  final _gigiService = PemeriksaanGigiApiService();
  final _lilaService = PengukuranLilaApiService();
  final _neonatusService = NeonatusApiService();

  // Data
  List<KeluhanAnakModel> _keluhanList = [];
  List<PemeriksaanGigiModel> _gigiList = [];
  List<PengukuranLilaModel> _lilaList = [];
  List<NeonatusModel> _neonatusList = [];

  bool _loadingKeluhan = true;
  bool _loadingGigi = true;
  bool _loadingLila = true;
  bool _loadingNeonatus = true;

  String? _errKeluhan, _errGigi, _errLila, _errNeonatus;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void dispose() {
    _keluhanService.dispose();
    _gigiService.dispose();
    _lilaService.dispose();
    _neonatusService.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    _fetchKeluhan();
    _fetchGigi();
    _fetchLila();
    _fetchNeonatus();
  }

  Future<void> _fetchKeluhan() async {
    setState(() { _loadingKeluhan = true; _errKeluhan = null; });
    try {
      final data = await _keluhanService.getByAnakId(widget.anakId);
      if (mounted) setState(() { _keluhanList = data; _loadingKeluhan = false; });
    } catch (e) {
      if (mounted) setState(() { _errKeluhan = e.toString(); _loadingKeluhan = false; });
    }
  }

  Future<void> _fetchGigi() async {
    setState(() { _loadingGigi = true; _errGigi = null; });
    try {
      final data = await _gigiService.getByAnakID(widget.anakId);
      if (mounted) setState(() { _gigiList = data; _loadingGigi = false; });
    } catch (e) {
      if (mounted) setState(() { _errGigi = e.toString(); _loadingGigi = false; });
    }
  }

  Future<void> _fetchLila() async {
    setState(() { _loadingLila = true; _errLila = null; });
    try {
      final data = await _lilaService.getByAnakID(widget.anakId);
      if (mounted) setState(() { _lilaList = data; _loadingLila = false; });
    } catch (e) {
      if (mounted) setState(() { _errLila = e.toString(); _loadingLila = false; });
    }
  }

  Future<void> _fetchNeonatus() async {
    setState(() { _loadingNeonatus = true; _errNeonatus = null; });
    try {
      final data = await _neonatusService.getByAnakId(widget.anakId);
      if (mounted) setState(() { _neonatusList = data; _loadingNeonatus = false; });
    } catch (e) {
      if (mounted) setState(() { _errNeonatus = e.toString(); _loadingNeonatus = false; });
    }
  }

  String _fmtDateShort(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatUsiaBulan(int totalBulan) {
    if (totalBulan < 12) return '$totalBulan Bulan';
    final tahun = totalBulan ~/ 12;
    final sisaBulan = totalBulan % 12;
    if (sisaBulan == 0) return '$tahun Tahun';
    return '$tahun Tahun $sisaBulan Bulan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFB),
      body: RepaintBoundary(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabChips(),
            _buildSectionTitle(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kBlueDark, _kBlueLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Catatan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            // Profile card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFD7ECFF),
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.anakName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF172033))),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7ECFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Usia: ${widget.usiaTeks ?? "-"}',
                          style: const TextStyle(fontSize: 12, color: _kBlue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTabChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: List.generate(_tabLabels.length, (i) {
          final selected = _selectedTab == i;
          return Padding(
            padding: EdgeInsets.only(right: i < _tabLabels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _kBlue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_tabIcons[i], size: 16, color: selected ? Colors.white : const Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Text(
                      _tabLabels[i],
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle() {
    final titles = ['Catatan Neonatus', 'Keluhan Anak', 'Catatan Kesehatan Gigi', 'Catatan LiLA'];
    final counts = [_neonatusList.length, _keluhanList.length, _gigiList.length, _lilaList.length];
    final loading = [_loadingNeonatus, _loadingKeluhan, _loadingGigi, _loadingLila];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titles[_selectedTab], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF172033))),
          if (!loading[_selectedTab])
            Text('${counts[_selectedTab]} catatan', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildNeonatusList();
      case 1: return _buildKeluhanList();
      case 2: return _buildGigiList();
      case 3: return _buildLilaList();
      default: return const SizedBox.shrink();
    }
  }

  // ─── KESEHATAN ANAK ───
  Widget _buildKeluhanList() {
    if (_loadingKeluhan) return const Center(child: CircularProgressIndicator(color: _kBlue));
    if (_errKeluhan != null) return _buildError(_errKeluhan!, _fetchKeluhan);
    if (_keluhanList.isEmpty) return _buildEmpty('Belum ada catatan kesehatan anak');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _keluhanList.length,
      itemBuilder: (ctx, i) {
        final item = _keluhanList[i];
        return _buildRecordCard(
          icon: Icons.vaccines_outlined,
          title: item.keluhan,
          subtitle: item.pemeriksa ?? '-',
          description: 'Diagnosis: ${item.tindakan ?? "-"}',
          date: _fmtDateShort(item.tanggal),
          onTap: () => showCatatanDetailKesehatanAnak(context, item),
        );
      },
    );
  }

  // ─── KESEHATAN GIGI ───
  Widget _buildGigiList() {
    if (_loadingGigi) return const Center(child: CircularProgressIndicator(color: _kBlue));
    if (_errGigi != null) return _buildError(_errGigi!, _fetchGigi);
    if (_gigiList.isEmpty) return _buildEmpty('Belum ada catatan kesehatan gigi');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _gigiList.length,
      itemBuilder: (ctx, i) {
        final item = _gigiList[i];
        return _buildRecordCard(
          icon: Icons.medical_services_outlined,
          title: 'Pemeriksaan Gigi - Usia ${_formatUsiaBulan(item.bulan)}',
          subtitle: 'Gigi: ${item.jumlahGigi} | Berlubang: ${item.gigiBerlubang}',
          description: 'Plak: ${item.statusPlak} | Risiko: ${item.resikoGigiBerlubang}',
          date: _fmtDateShort(item.tanggal),
          onTap: () => showCatatanDetailGigi(context, item),
        );
      },
    );
  }

  // ─── LILA ───
  Widget _buildLilaList() {
    if (_loadingLila) return const Center(child: CircularProgressIndicator(color: _kBlue));
    if (_errLila != null) return _buildError(_errLila!, _fetchLila);
    if (_lilaList.isEmpty) return _buildEmpty('Belum ada catatan LiLA');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _lilaList.length,
      itemBuilder: (ctx, i) {
        final item = _lilaList[i];
        return _buildRecordCard(
          icon: Icons.straighten_outlined,
          title: 'Pengukuran LiLA - Usia ${_formatUsiaBulan(item.bulan)}',
          subtitle: 'Hasil LiLA: ${item.hasilLila} cm',
          description: 'Kategori Risiko: ${item.kategoriRisiko}',
          date: _fmtDateShort(item.tanggal),
          onTap: () => showCatatanDetailLila(context, item),
        );
      },
    );
  }

  // ─── NEONATUS ───
  String _getPeriodeName(int periodeId) {
    switch (periodeId) {
      case 1: return '0 - 6 jam';
      case 2: return 'KN1 (Kunjungan Neonatus)';
      case 3: return 'KN2 (Kunjungan Neonatus)';
      case 4: return 'KN3 (Kunjungan Neonatus)';
      default: return 'Kunjungan Neonatus';
    }
  }

  Widget _buildNeonatusList() {
    if (_loadingNeonatus) return const Center(child: CircularProgressIndicator(color: _kBlue));
    if (_errNeonatus != null) return _buildError(_errNeonatus!, _fetchNeonatus);
    if (_neonatusList.isEmpty) return _buildEmpty('Belum ada catatan Neonatus');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _neonatusList.length,
      itemBuilder: (ctx, i) {
        final item = _neonatusList[i];
        return _buildRecordCard(
          icon: Icons.child_care_outlined,
          title: _getPeriodeName(item.periodeId),
          subtitle: 'Tanggal: ${_fmtDateShort(item.tanggal)}',
          description: 'Detail Pelayanan: ${item.detailPelayanan.length} item',
          date: _fmtDateShort(item.tanggal),
          onTap: () => showCatatanDetailNeonatus(context, item),
        );
      },
    );
  }

  // ─── Shared card ───
  Widget _buildRecordCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String date,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Blue left border
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: _kBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7ECFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, size: 18, color: _kBlue),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF172033)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7ECFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(date, style: const TextStyle(fontSize: 11, color: _kBlue, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(description, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Arrow
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(msg, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildError(String msg, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: retry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}