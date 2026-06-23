import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/features/anak/anak/data/services/ibu_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/ibu_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/imunisasi/presentation/screens/imunisasi_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/menu_pemantauan_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/screens/pertumbuhan_info_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/pemantauan_menu_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/presentation/screens/catatan_menu_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/deteksi_gejala_darurat_screen.dart';

class PilihAnakScreen extends StatefulWidget {
  final String tujuan;

  const PilihAnakScreen({
    super.key,
    this.tujuan = 'pertumbuhan',
  });

  @override
  State<PilihAnakScreen> createState() => _PilihAnakScreenState();
}

class _PilihAnakScreenState extends State<PilihAnakScreen> {
  final IbuApiService _service = IbuApiService();
  late Future<List<IbuAnakModel>> _anakFuture;

  @override
  void initState() {
    super.initState();
    _anakFuture = _service.getAnakSaya();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  // ─── Helper: apakah tujuan ini memerlukan batasan usia 6 tahun ───
  bool get _tujuanBerbatasiUsia =>
      widget.tujuan == 'pertumbuhan' ||
      widget.tujuan == 'pemantauan' ||
      widget.tujuan == 'bahaya';

  // ─── Helper: cek apakah anak sudah melewati tepat 6 tahun ───
  bool _isOver6Years(String tanggalLahir) {
    if (tanggalLahir.isEmpty) return false;
    try {
      final lahir = DateTime.parse(tanggalLahir);
      // Terblokir tepat saat anak melewati hari ulang tahun ke-6
      final batas = DateTime(lahir.year + 6, lahir.month, lahir.day);
      return DateTime.now().isAfter(batas);
    } catch (_) {
      return false;
    }
  }

  // ─── Dialog info ketika anak sudah melewati batas usia ───
  void _showBatasUsiaDialog(BuildContext context, IbuAnakModel anak) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_friendly_rounded,
                  color: Color(0xFFBA7517),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masa Pemantauan Selesai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: Color(0xFF475569),
                  ),
                  children: [
                    TextSpan(
                      text: anak.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          ' sudah berusia lebih dari 6 tahun.\n\nPemantauan tumbuh kembang pada modul ini hanya berlaku hingga usia 6 tahun sesuai standar buku KIA.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF0F6E56), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fitur Imunisasi dan Catatan masih dapat diakses.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              'Pilih Profil Anak',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Pilih anak untuk melanjutkan',
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
      body: FutureBuilder<List<IbuAnakModel>>(
        future: _anakFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data anak',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _anakFuture = _service.getAnakSaya();
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final anakList = snapshot.data ?? const <IbuAnakModel>[];

          if (anakList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada data anak yang terhubung ke akun ini.'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anakList.length,
            itemBuilder: (context, index) {
              final anak = anakList[index];
              return _buildItem(context, anak);
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, IbuAnakModel anak) {
    final anakMap = anak.toChildMap();
    final isBlocked = _tujuanBerbatasiUsia && _isOver6Years(anak.tanggalLahir);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => isBlocked
            ? _showBatasUsiaDialog(context, anak)
            : _openTujuan(context, anak, anakMap),
        child: Opacity(
          opacity: isBlocked ? 0.65 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isBlocked ? const Color(0xFFF1F5F9) : const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBlocked
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFFD7ECFF),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isBlocked
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFD7ECFF),
                  child: Icon(
                    Icons.person_outline,
                    size: 26,
                    color: isBlocked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF185FA5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anak.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBlocked
                              ? const Color(0xFF64748B)
                              : const Color(0xFF185FA5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        anak.usiaTeks.isEmpty
                            ? 'Siap untuk pemantauan anak'
                            : anak.usiaTeks,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isBlocked ? const Color(0xFF94A3B8) : null,
                        ),
                      ),
                      // Badge "Pemantauan selesai" untuk anak > 6 tahun
                      if (isBlocked) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: const Color(0xFFFDBA74)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 11, color: Color(0xFFBA7517)),
                              SizedBox(width: 4),
                              Text(
                                'Pemantauan selesai (> 6 tahun)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isBlocked
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF185FA5),
                  child: Icon(
                    isBlocked ? Icons.lock_outline : Icons.arrow_forward,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTujuan(
    BuildContext context,
    IbuAnakModel anak,
    Map<String, dynamic> anakMap,
  ) {
    if (widget.tujuan == 'imunisasi') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImunisasiScreen(anak: anakMap),
        ),
      );
      return;
    }
    if (widget.tujuan == 'bahaya') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PemantauanMenuScreen(anak: anakMap),
        ),
      );
      return;
    }
    if (widget.tujuan == 'darurat') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeteksiGejalaDaruratScreen(anak: anakMap),
        ),
      );
      return;
    }
    if (widget.tujuan == 'pemantauan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPemantauanScreen(anak: anakMap),
        ),
      );
      return;
    }

    if (widget.tujuan == 'catatan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CatatanMenuScreen(
            anakId: int.tryParse(anak.id.toString()) ?? 0,
            anakName: anak.nama,
            usiaTeks: anak.usiaTeks,
          ),
        ),
      );
      return;
    }

    // Default: pertumbuhan
    final anakSearchModel = AnakSearchModel(
      id: anak.id,
      noKartuKeluarga: 0,
      namaAnak: anak.nama,
      jenisKelamin: anak.jenisKelamin,
      tanggalLahir: anak.tanggalLahir,
      beratLahir: 0,
      tinggiLahir: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PertumbuhanInfoScreen(anak: anakSearchModel),
      ),
    );
  }
}