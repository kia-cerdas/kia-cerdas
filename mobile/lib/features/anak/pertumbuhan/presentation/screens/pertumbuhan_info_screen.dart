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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pertumbuhan',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 14),
            _buildLihatGrafikButton(),
            const SizedBox(height: 20),
            _buildSectionTitle('3 Indikator Pertumbuhan',
                color: const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _buildIndikatorCard(
              Icons.monitor_weight_outlined,
              'Berat Badan (BB)',
              'Ditimbang setiap bulan di Posyandu sampai usia 5 tahun. Kenaikan BB adalah tanda anak sehat.',
              const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 8),
            _buildIndikatorCard(
              Icons.straighten,
              'Panjang/Tinggi Badan',
              'Diukur tiap bulan untuk deteksi dini stunting. <2 tahun diukur berbaring, ≥2 tahun berdiri.',
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 8),
            _buildIndikatorCard(
              Icons.circle_outlined,
              'Lingkar Kepala (LK)',
              'Diukur tiap 3 bulan sampai 1 tahun, lalu tiap 6 bulan hingga 6 tahun untuk pantau perkembangan otak.',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Interpretasi Grafik KMS',
                color: const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _buildKMSBox(
              color: const Color(0xFFDCFCE7),
              textColor: const Color(0xFF15803D),
              title: 'Naik (N) — Sehat ✓',
              desc:
                  'Garis BB naik mengikuti pita warna atau pindah ke pita di atasnya.',
            ),
            const SizedBox(height: 8),
            _buildKMSBox(
              color: const Color(0xFFFEF3C7),
              textColor: const Color(0xFFB45309),
              title: 'Tidak Naik (T) — Waspada',
              desc:
                  'Garis mendatar atau turun. Konsultasikan ke kader/Puskesmas.',
            ),
            const SizedBox(height: 8),
            _buildKMSBox(
              color: const Color(0xFFFEE2E2),
              textColor: const Color(0xFFB91C1C),
              title: 'Bawah Garis Merah (BGM)',
              desc:
                  'Tanda gizi buruk. Segera rujuk ke fasilitas kesehatan.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Standar BB & TB Median (WHO)',
                color: const Color(0xFF2563EB)),
            const SizedBox(height: 10),
            _buildWhoTable(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.trending_up, color: Colors.white, size: 30),
          ),
          SizedBox(height: 12),
          Text(
            'Tumbuh Optimal',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Sesuai Buku KIA 2024 — Standar WHO',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLihatGrafikButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GrafikPertumbuhanScreen(anak: widget.anak),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.show_chart, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lihat Grafik Pertumbuhan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'BB/U, BB/PB, PB/U, LK/U, IMT/U dengan Z-score',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white60, size: 14),
          ],
        ),
      ),
    );
  }

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

  Widget _buildIndikatorCard(
      IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKMSBox(
      {required Color color,
      required Color textColor,
      required String title,
      required String desc}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  fontSize: 12, color: textColor.withValues(alpha: 0.85))),
        ],
      ),
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
            color: const Color(0xFF1E3A5F),
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
                      color: Color(0xFF2563EB), strokeWidth: 2)),
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
