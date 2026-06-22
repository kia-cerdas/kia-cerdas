import 'package:flutter/material.dart';

import '../../data/models/edukasi_nifas_model.dart';
import '../../data/repositories/edukasi_nifas_repository.dart';
import '../../data/services/edukasi_nifas_service.dart';
import 'edukasi_nifas_detail_screen.dart';

/// Halaman DAFTAR edukasi nifas (setelah melahirkan).
///
/// Menampilkan SEMUA materi sebagai kartu. Saat satu kartu diketuk,
/// ibu dibawa ke halaman detail (EdukasiNifasDetailScreen).
/// Pola ini sama persis dengan halaman daftar trimester & mental.
class EdukasiNifasScreen extends StatefulWidget {
  const EdukasiNifasScreen({super.key});

  @override
  State<EdukasiNifasScreen> createState() => _EdukasiNifasScreenState();
}

class _EdukasiNifasScreenState extends State<EdukasiNifasScreen> {
  late Future<List<EdukasiNifasModel>> futureData;

  @override
  void initState() {
    super.initState();

    final repository = EdukasiNifasRepository(EdukasiNifasService());
    futureData = repository.getAllEdukasiNifas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edukasi Masa Nifas',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Tips merawat diri dan pemulihan setelah melahirkan',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<EdukasiNifasModel>>(
        future: futureData,
        builder: (context, snapshot) {
          // 1) Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Error
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data ?? [];

          // 3) Kosong
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Data edukasi belum tersedia',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          // 4) Tampilkan SEMUA materi sebagai daftar kartu.
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _NifasCard(item: item);
            },
          );
        },
      ),
    );
  }
}

/// Kartu satu materi di halaman daftar.
/// Gaya kartu meniru kartu trimester: gambar, badge, judul,
/// cuplikan isi, lalu "Baca selengkapnya".
class _NifasCard extends StatelessWidget {
  final EdukasiNifasModel item;

  const _NifasCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Saat kartu diketuk -> buka halaman detail materi ini.
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiNifasDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar atas (atau placeholder kalau kosong)
            if (item.gambarUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.gambarUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              )
            else
              _placeholderImage(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Masa Nifas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F5EA8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cuplikan isi (maksimal 3 baris)
                  Text(
                    item.isi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "Baca selengkapnya ->"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F5EA8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1F5EA8),
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

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF1F5EA8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Icon(
          Icons.pregnant_woman_rounded,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }
}