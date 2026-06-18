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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Profil Anak',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTujuan(context, anak, anakMap),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7ECFF)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFD7ECFF),
                child: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Color(0xFF185FA5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anak.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                    Text(
                      anak.usiaTeks.isEmpty
                          ? 'Siap untuk pemantauan anak'
                          : anak.usiaTeks,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF185FA5),
                child: Icon(Icons.arrow_forward, size: 14, color: Colors.white),
              ),
            ],
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