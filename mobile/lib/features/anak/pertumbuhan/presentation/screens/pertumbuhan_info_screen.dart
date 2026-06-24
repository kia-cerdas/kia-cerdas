// pertumbuhan_info_screen.dart
// Halaman 1: Informasi Pertumbuhan (statis + tabel WHO ringkas)
// Navigasi: PilihAnakScreen → PertumbuhanInfoScreen → GrafikPertumbuhanScreen

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/repositories/pertumbuhan_repository.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/services/pertumbuhan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/screens/grafik_pertumbuhan_screen.dart';

class PertumbuhanInfoScreen extends StatefulWidget {
  final AnakSearchModel anak;

  const PertumbuhanInfoScreen({super.key, required this.anak});

  @override
  State<PertumbuhanInfoScreen> createState() => _PertumbuhanInfoScreenState();
}

class _PertumbuhanInfoScreenState extends State<PertumbuhanInfoScreen> {
  late PertumbuhanRepository _repo;

  // Hanya load master standar BB/U, TB/U, LK/U untuk tabel
  List<MasterStandarModel> _masterBBU = [];
  List<MasterStandarModel> _masterTBU = [];
  List<MasterStandarModel> _masterLKU = [];
  bool _loadingTable = true;

  @override
  void initState() {
    super.initState();
    _repo = PertumbuhanRepository(apiService: PertumbuhanApiService());
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    try {
      final jk = widget.anak.jenisKelamin;
      final results = await Future.wait([
        _repo.getMasterStandar(parameter: 'bb_u', jenisKelamin: jk),
        _repo.getMasterStandar(parameter: 'tb_u', jenisKelamin: jk),
        _repo.getMasterStandar(parameter: 'lk_u', jenisKelamin: jk),
      ]);
      if (mounted) {
        setState(() {
          _masterBBU = results[0];
          _masterTBU = results[1];
          _masterLKU = results[2];
          _loadingTable = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTable = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertumbuhan',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Informasi standar pertumbuhan anak',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLihatGrafikButton(),
            const SizedBox(height: 20),
            _buildSectionTitle('3 Indikator Pertumbuhan',
                color: const Color(0xFFBA7517)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIndikatorItem('Berat Badan (BB)', 'Ditimbang setiap bulan di Posyandu sampai usia 5 tahun. Kenaikan BB adalah tanda anak sehat.'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildIndikatorItem('Panjang/Tinggi Badan', 'Diukur tiap bulan untuk deteksi dini stunting. <2 tahun diukur berbaring, ≥2 tahun berdiri.'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildIndikatorItem('Lingkar Kepala (LK)', 'Diukur tiap 3 bulan sampai 1 tahun, lalu tiap 6 bulan hingga 6 tahun untuk pantau perkembangan otak.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Standar BB & TB Median (WHO)',
                color: const Color(0xFF185FA5)),
            const SizedBox(height: 10),
            _buildWhoTable(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildLihatGrafikButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: const Color(0xFF185FA5).withValues(alpha: 0.4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GrafikPertumbuhanScreen(anak: widget.anak),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
        height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF185FA5).withValues(alpha: 1.0),   
                const Color(0xFF185FA5).withValues(alpha: 0.85), 
                const Color(0xFF185FA5).withValues(alpha: 0.35),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            children: [
              // Konten utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ikon kiri
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Teks
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lihat Grafik\nPertumbuhan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ketahui status gizi anak sesuai standar WHO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol panah kanan
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF185FA5),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── AKHIR BAGIAN YANG DIUBAH ──────────────────────────────────

  Widget _buildSectionTitle(String title, {required Color color}) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildIndikatorItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFBA7517),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(desc,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildWhoTable() {
    const usiaList = [0, 3, 6, 9, 12, 18, 24, 36, 48, 60];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header row
          Container(
            color: const Color(0xFF185FA5),
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: const [
                _TCell('Usia', flex: 2, header: true),
                _TCell('BB♂', header: true),
                _TCell('BB♀', header: true),
                _TCell('TB♂', header: true),
                _TCell('TB♀', header: true),
                _TCell('LK', header: true),
              ],
            ),
          ),
          if (_loadingTable)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF185FA5), strokeWidth: 2)),
            )
          else
            ...List.generate(usiaList.length, (i) {
              final usia = usiaList[i];
              final bbRow = _masterBBU
                  .where((m) => m.nilaiSumbuX.round() == usia);
              final tbRow = _masterTBU
                  .where((m) => m.nilaiSumbuX.round() == usia);
              final lkRow = _masterLKU
                  .where((m) => m.nilaiSumbuX.round() == usia);

              final bb = bbRow.isNotEmpty ? bbRow.first.median : 0.0;
              final tb = tbRow.isNotEmpty ? tbRow.first.median : 0.0;
              final lk = lkRow.isNotEmpty ? lkRow.first.median : 0.0;

              return Container(
                color: i.isOdd ? Colors.grey.shade50 : Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 9, horizontal: 12),
                child: Row(
                  children: [
                    _TCell('$usia bln',
                        flex: 2, bold: true),
                    _TCell(bb > 0 ? bb.toStringAsFixed(1) : '-'),
                    _TCell(bb > 0 ? bb.toStringAsFixed(1) : '-'),
                    _TCell(tb > 0 ? tb.toStringAsFixed(1) : '-'),
                    _TCell(tb > 0 ? tb.toStringAsFixed(1) : '-'),
                    _TCell(lk > 0 ? lk.toStringAsFixed(1) : '-'),
                  ],
                ),
              );
            }),
          Container(
            width: double.infinity,
            color: Colors.grey.shade50,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'BB dalam kg, TB & LK dalam cm. Sumber: WHO Child Growth Standards.',
              style:
                  TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sel tabel ringkas
class _TCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool header;
  final bool bold;

  const _TCell(this.text,
      {this.flex = 1, this.header = false, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: flex == 2 ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              (header || bold) ? FontWeight.w600 : FontWeight.normal,
          color: header ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

/// Painter untuk grid lines dekoratif di background tombol grafik
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Garis horizontal
    for (double y = 0; y < size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Garis vertikal
    for (double x = 0; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}