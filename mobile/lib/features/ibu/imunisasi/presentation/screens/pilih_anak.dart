import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/features/anak/anak/data/services/ibu_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/ibu_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/imunisasi_screen.dart';

/// [tujuan] menentukan halaman tujuan setelah anak dipilih.
/// Gunakan 'pertumbuhan' (default), 'imunisasi', 'pemantauan', atau 'catatan'.
class PilihAnakImunisasiScreen extends StatefulWidget {
  final String tujuan;

  const PilihAnakImunisasiScreen({super.key, required this.tujuan});

  @override
  State<PilihAnakImunisasiScreen> createState() => _PilihAnakImunisasiScreenState();
}

class _PilihAnakImunisasiScreenState extends State<PilihAnakImunisasiScreen> {
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
          'Pilih Imunisasi Anak',
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


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anak.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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

          // ICON KANAN
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImunisasiScreen(
                    anakId: int.tryParse(
                          anak.id.toString(),
                        ) ??
                        0,
                    namaAnak: anak.nama,
                  ),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blue,
              child: Icon(Icons.arrow_forward, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
