// import 'package:flutter/material.dart';
// import '../../data/models/edukasi_trimester_model.dart';

// class EdukasiTrimesterDetailScreen extends StatelessWidget {
//   final EdukasiTrimesterModel item;

//   const EdukasiTrimesterDetailScreen({super.key, required this.item});

//   String get _trimesterLabel {
//     final s = item.trimester.trim().toLowerCase();
//     if (s.contains('1') || s.endsWith('i')) return 'Trimester I';
//     if (s.contains('2') || s.endsWith('ii')) return 'Trimester II';
//     if (s.contains('3') || s.endsWith('iii')) return 'Trimester III';
//     return item.trimester;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: CustomScrollView(
//         slivers: [
//           // ── App bar dengan gambar ──────────────────────────────────
//           SliverAppBar(
//             expandedHeight: item.gambarUrl.trim().isNotEmpty ? 240 : 120,
//             pinned: true,
//             backgroundColor: const Color(0xFF1F5EA8),
//             foregroundColor: Colors.white,
//             flexibleSpace: FlexibleSpaceBar(
//               background: item.gambarUrl.trim().isNotEmpty
//                   ? Image.network(
//                       item.gambarUrl,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _headerPlaceholder(),
//                     )
//                   : _headerPlaceholder(),
//             ),
//           ),

//           // ── Konten artikel ────────────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Badge trimester + kategori
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: [
//                       if (item.trimester.trim().isNotEmpty)
//                         _badge(
//                           _trimesterLabel,
//                           bg: const Color(0xFF1F5EA8),
//                           fg: Colors.white,
//                         ),
//                       if (item.kategori.trim().isNotEmpty)
//                         _badge(
//                           item.kategori,
//                           bg: const Color(0xFFE8F1FD),
//                           fg: const Color(0xFF1F5EA8),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Judul
//                   Text(
//                     item.judul,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF111827),
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Divider tipis
//                   Container(
//                     height: 1,
//                     color: const Color(0xFFE5E7EB),
//                   ),
//                   const SizedBox(height: 20),

//                   // Isi lengkap
//                   Text(
//                     item.isi,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       height: 1.8,
//                       color: Color(0xFF374151),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _headerPlaceholder() {
//     return Container(
//       color: const Color(0xFF1F5EA8),
//       child: const Center(
//         child: Icon(
//           Icons.pregnant_woman_rounded,
//           size: 64,
//           color: Colors.white24,
//         ),
//       ),
//     );
//   }

//   Widget _badge(String text, {required Color bg, required Color fg}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: fg,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../data/models/edukasi_trimester_model.dart';

/// Halaman DETAIL satu materi edukasi trimester.
/// Desain disamakan dengan detail edukasi Anak (DetailKontenEdukasiAnakScreen):
/// AppBar putih simpel, ilustrasi dalam kotak rounded, badge pil abu-abu,
/// judul, lalu konten dibungkus _SectionCard putih bertajuk.
class EdukasiTrimesterDetailScreen extends StatelessWidget {
  final EdukasiTrimesterModel item;

  const EdukasiTrimesterDetailScreen({super.key, required this.item});

  String get _trimesterLabel {
    final s = item.trimester.trim().toLowerCase();
    if (s.contains('1') || s.endsWith('i')) return 'Trimester I';
    if (s.contains('2') || s.endsWith('ii')) return 'Trimester II';
    if (s.contains('3') || s.endsWith('iii')) return 'Trimester III';
    return item.trimester;
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
        title: const Text(
          'Edukasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Thumbnail / Illustration Section =====
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: item.gambarUrl.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        item.gambarUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                      ),
                    )
                  : _buildFallbackIcon(),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Badges Row =====
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.kategori.trim().isNotEmpty)
                _Badge(label: item.kategori),
              if (item.trimester.trim().isNotEmpty)
                _Badge(label: _trimesterLabel),
              const _Badge(label: 'ARTIKEL'),
            ],
          ),
          const SizedBox(height: 16),

          // ===== Title =====
          Text(
            item.judul,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),

          // ===== Isi Materi Section =====
          if (item.isi.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Isi Materi',
              child: Text(
                item.isi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.7,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return const Icon(
      Icons.menu_book_rounded,
      size: 72,
      color: Color(0xFF1F5EA8),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.textColor = const Color(0xFF334155),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}