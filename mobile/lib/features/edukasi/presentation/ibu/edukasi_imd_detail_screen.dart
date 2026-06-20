// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_imd_model.dart';

// /// Halaman DETAIL satu materi edukasi IMD (Inisiasi Menyusu Dini).
// ///
// /// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar.
// /// Desain mengikuti detail trimester/mental agar konsisten.
// /// Model IMD punya bagian: isi, manfaat, dan langkah.
// class EdukasiImdDetailScreen extends StatelessWidget {
//   final EdukasiIMDModel item;

//   const EdukasiImdDetailScreen({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     // Pecah teks panjang "manfaat" & "langkah" menjadi daftar baris bersih.
//     final manfaatList = _splitToList(item.manfaat);
//     final langkahList = _splitToList(item.langkah);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FB),
//       body: CustomScrollView(
//         slivers: [
//           // ── HEADER bergambar (mengecil saat di-scroll) ──
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

//           // ── ISI HALAMAN ──
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Badge pil
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: [
//                       _badge(
//                         'IMD',
//                         bg: const Color(0xFF1F5EA8),
//                         fg: Colors.white,
//                       ),
//                       _badge(
//                         'Inisiasi Menyusu Dini',
//                         bg: const Color(0xFFE8F1FD),
//                         fg: const Color(0xFF1F5EA8),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Judul besar
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

//                   // Garis pemisah
//                   Container(height: 1, color: const Color(0xFFE5E7EB)),
//                   const SizedBox(height: 20),

//                   // ── Bagian 1: Tentang Edukasi (teks panjang) ──
//                   if (item.isi.trim().isNotEmpty) ...[
//                     _sectionTitle('Tentang Edukasi'),
//                     const SizedBox(height: 12),
//                     Text(
//                       item.isi,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         height: 1.8,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                   ],

//                   // ── Bagian 2: Manfaat IMD (hijau = hal positif) ──
//                   _buildSection(
//                     'Manfaat IMD',
//                     manfaatList,
//                     const Color(0xFF10B981),
//                   ),

//                   // ── Bagian 3: Langkah-langkah (biru = panduan urut) ──
//                   _buildSection(
//                     'Langkah-langkah IMD',
//                     langkahList,
//                     const Color(0xFF1F5EA8),
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

//   // =====================================================================
//   // HELPER
//   // =====================================================================

//   // Membangun satu bagian (judul + daftar bernomor).
//   // Kalau datanya kosong, bagian ini tidak ditampilkan sama sekali.
//   Widget _buildSection(String title, List<String> items, Color color) {
//     if (items.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 28),
//         _sectionTitle(title),
//         const SizedBox(height: 8),
//         ...List.generate(items.length, (i) {
//           return _buildListItem(
//             number: '${i + 1}',
//             text: items[i],
//             color: color,
//           );
//         }),
//       ],
//     );
//   }

//   List<String> _splitToList(String raw) {
//     return raw
//         .split('\n')
//         .map((e) => e.trim())
//         .where((e) => e.isNotEmpty)
//         .map((e) => e.replaceAll(RegExp(r'^\d+\.\s*'), ''))
//         .toList();
//   }

//   Widget _headerPlaceholder() {
//     return Container(
//       color: const Color(0xFF1F5EA8),
//       child: const Center(
//         child: Icon(
//           Icons.child_friendly_rounded,
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

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFF111827),
//       ),
//     );
//   }

//   Widget _buildListItem({
//     required String number,
//     required String text,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 15,
//                 height: 1.6,
//                 color: Color(0xFF374151),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../data/models/edukasi_imd_model.dart';

/// Halaman DETAIL satu materi edukasi IMD (Inisiasi Menyusu Dini).
///
/// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar.
/// Desain mengikuti detail trimester/mental agar konsisten.
/// Model IMD punya bagian: isi, manfaat, dan langkah.
class EdukasiImdDetailScreen extends StatelessWidget {
  final EdukasiIMDModel item;

  const EdukasiImdDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Pecah teks panjang "manfaat" & "langkah" menjadi daftar baris bersih.
    final manfaatList = _splitToList(item.manfaat);
    final langkahList = _splitToList(item.langkah);

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
                        'IMD',
                        bg: const Color(0xFFE8F1FD),
                        fg: const Color(0xFF1F5EA8),
                      ),
                      _badge(
                        'Inisiasi Menyusu Dini',
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

                  // ── Bagian 1: Tentang Edukasi (teks panjang) ──
                  if (item.isi.trim().isNotEmpty) ...[
                    _sectionTitle('Tentang Edukasi'),
                    const SizedBox(height: 12),
                    Text(
                      item.isi,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],

                  // ── Bagian 2: Manfaat IMD (hijau = hal positif) ──
                  _buildSection(
                    'Manfaat IMD',
                    manfaatList,
                    const Color(0xFF10B981),
                  ),

                  // ── Bagian 3: Langkah-langkah (biru = panduan urut) ──
                  _buildSection(
                    'Langkah-langkah IMD',
                    langkahList,
                    const Color(0xFF1F5EA8),
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

  // =====================================================================
  // HELPER
  // =====================================================================

  // Membangun satu bagian (judul + daftar bernomor).
  // Kalau datanya kosong, bagian ini tidak ditampilkan sama sekali.
  Widget _buildSection(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _sectionTitle(title),
        const SizedBox(height: 8),
        ...List.generate(items.length, (i) {
          return _buildListItem(
            number: '${i + 1}',
            text: items[i],
            color: color,
          );
        }),
      ],
    );
  }

  List<String> _splitToList(String raw) {
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.replaceAll(RegExp(r'^\d+\.\s*'), ''))
        .toList();
  }

  Widget _headerPlaceholder() {
    return Container(
      color: const Color(0xFF1F5EA8),
      child: const Center(
        child: Icon(
          Icons.child_friendly_rounded,
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildListItem({
    required String number,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}