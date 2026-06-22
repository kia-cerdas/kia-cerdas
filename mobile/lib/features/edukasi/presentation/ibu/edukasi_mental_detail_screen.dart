// import 'package:flutter/material.dart';

// import '../../data/models/edukasi_mental_model.dart';

// /// Halaman DETAIL satu materi edukasi kesehatan mental.
// ///
// /// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar
// /// (EdukasiKesehatanMentalScreen). Desainnya sengaja dibuat
// /// mengikuti halaman detail trimester agar konsisten.
// class EdukasiMentalDetailScreen extends StatelessWidget {
//   final EdukasiKesehatanMentalModel item;

//   const EdukasiMentalDetailScreen({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     // Pecah teks panjang "tanda gejala" & "solusi" menjadi daftar baris,
//     // sekaligus membersihkan nomor di awal (mis. "1. ") agar tidak dobel.
//     final tandaGejalaList = _splitToList(item.tandaGejala);
//     final solusiList = _splitToList(item.solusi);

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
//                         'Kesehatan Mental',
//                         bg: const Color(0xFF1F5EA8),
//                         fg: Colors.white,
//                       ),
//                       _badge(
//                         'Ibu Hamil',
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

//                   // ── Bagian 1: Tentang Edukasi ──
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

//                   // ── Bagian 2: Tanda dan Gejala (daftar bernomor) ──
//                   if (tandaGejalaList.isNotEmpty) ...[
//                     const SizedBox(height: 28),
//                     _sectionTitle('Tanda dan Gejala'),
//                     const SizedBox(height: 8),
//                     ...List.generate(tandaGejalaList.length, (i) {
//                       return _buildListItem(
//                         number: '${i + 1}',
//                         text: tandaGejalaList[i],
//                         color: const Color(0xFFF59E0B),
//                       );
//                     }),
//                   ],

//                   // ── Bagian 3: Solusi (daftar bernomor) ──
//                   if (solusiList.isNotEmpty) ...[
//                     const SizedBox(height: 28),
//                     _sectionTitle('Solusi'),
//                     const SizedBox(height: 8),
//                     ...List.generate(solusiList.length, (i) {
//                       return _buildListItem(
//                         number: '${i + 1}',
//                         text: solusiList[i],
//                         color: const Color(0xFF10B981),
//                       );
//                     }),
//                   ],

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
//           Icons.self_improvement_rounded,
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

import '../../data/models/edukasi_mental_model.dart';

/// Halaman DETAIL satu materi edukasi kesehatan mental.
///
/// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar
/// (EdukasiKesehatanMentalScreen). Desain disamakan dengan detail
/// edukasi Anak (DetailKontenEdukasiAnakScreen): AppBar putih simpel,
/// ilustrasi dalam kotak rounded, badge pil abu-abu, judul, lalu
/// setiap bagian (Tentang Edukasi, Tanda dan Gejala, Solusi)
/// dibungkus _SectionCard putih bertajuk dengan daftar bernomor.
class EdukasiMentalDetailScreen extends StatelessWidget {
  final EdukasiKesehatanMentalModel item;

  const EdukasiMentalDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Pecah teks panjang "tanda gejala" & "solusi" menjadi daftar baris,
    // sekaligus membersihkan nomor di awal (mis. "1. ") agar tidak dobel.
    final tandaGejalaList = _splitToList(item.tandaGejala);
    final solusiList = _splitToList(item.solusi);

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
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: 'Kesehatan Mental'),
              _Badge(label: 'Ibu Hamil'),
              _Badge(label: 'ARTIKEL'),
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

          // ===== Bagian 1: Tentang Edukasi =====
          if (item.isi.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Tentang Edukasi',
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

          // ===== Bagian 2: Tanda dan Gejala =====
          if (tandaGejalaList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Tanda dan Gejala',
              child: _NumberedList(items: tandaGejalaList),
            ),
          ],

          // ===== Bagian 3: Solusi =====
          if (solusiList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Solusi',
              child: _NumberedList(items: solusiList),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
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

  Widget _buildFallbackIcon() {
    return const Icon(
      Icons.self_improvement_rounded,
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

/// Daftar bernomor dengan lingkaran nomor biru, mengikuti gaya
/// "Tutorial Edukasi" pada halaman detail edukasi Anak.
class _NumberedList extends StatelessWidget {
  final List<String> items;

  const _NumberedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        items.length,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  items[i],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}