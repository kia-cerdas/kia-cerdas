import 'package:flutter/material.dart';

import '../../data/models/edukasi_nifas_model.dart';

/// Halaman DETAIL satu materi edukasi nifas (setelah melahirkan).
///
/// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar
/// (EdukasiNifasScreen). Desainnya mengikuti halaman detail trimester
/// agar konsisten. Model nifas hanya punya judul + isi (tanpa
/// "tanda gejala"/"solusi"), jadi detailnya cukup teks panjang.
class EdukasiNifasDetailScreen extends StatelessWidget {
  final EdukasiNifasModel item;

  const EdukasiNifasDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: CustomScrollView(
        slivers: [
          // ── HEADER bergambar (mengecil saat di-scroll) ──
          SliverAppBar(
            expandedHeight: item.gambarUrl.trim().isNotEmpty ? 240 : 120,
            pinned: true,
            backgroundColor: const Color(0xFF1F5EA8),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: item.gambarUrl.trim().isNotEmpty
                  ? Image.network(
                      item.gambarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _headerPlaceholder(),
                    )
                  : _headerPlaceholder(),
            ),
          ),

          // ── ISI HALAMAN ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge pil
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _badge(
                        'Masa Nifas',
                        bg: const Color(0xFF1F5EA8),
                        fg: Colors.white,
                      ),
                      _badge(
                        'Setelah Melahirkan',
                        bg: const Color(0xFFE8F1FD),
                        fg: const Color(0xFF1F5EA8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul besar
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Garis pemisah
                  Container(height: 1, color: const Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),

                  // Isi materi (teks panjang, jarak baris longgar)
                  Text(
                    item.isi,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerPlaceholder() {
    return Container(
      color: const Color(0xFF1F5EA8),
      child: const Center(
        child: Icon(
          Icons.pregnant_woman_rounded,
          size: 64,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _badge(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}