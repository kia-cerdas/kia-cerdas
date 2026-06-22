// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';
// import 'detail_konten_edukasi_anak_screen.dart';

// class ListKontenEdukasiAnakScreen extends StatelessWidget {
//   final String kategori;
//   final String deskripsi;
//   final List<EdukasiAnakItem> items;
//   final Color accentColor;
//   final IconData icon;

//   const ListKontenEdukasiAnakScreen({
//     super.key,
//     required this.kategori,
//     required this.deskripsi,
//     required this.items,
//     required this.accentColor,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffold,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               kategori,
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             Text(
//               deskripsi,
//               style: const TextStyle(
//                 color: AppColors.textSecondary,
//                 fontWeight: FontWeight.normal,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: AppColors.border),
//         ),
//       ),
//       body: items.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 return _KontenAnakListItem(
//                   item: items[index],
//                   accentColor: accentColor,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => DetailKontenEdukasiAnakScreen(item: items[index]),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: accentColor.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 40, color: accentColor.withValues(alpha: 0.5)),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Belum ada konten $kategori',
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Konten akan segera tersedia',
//             style: TextStyle(fontSize: 13, color: AppColors.textHint),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =========================================================================
// // ITEM CARD - TANPA SPACER/EXPANDED (aman di dalam ListView)
// // =========================================================================
// class _KontenAnakListItem extends StatelessWidget {
//   final EdukasiAnakItem item;
//   final Color accentColor;
//   final VoidCallback onTap;

//   const _KontenAnakListItem({
//     required this.item,
//     required this.accentColor,
//     required this.onTap,
//   });

//   String? _resolveImageUrl(String? url) {
//     if (url == null || url.trim().isEmpty) return null;
//     final trimmed = url.trim();

//     // Skip URL halaman Unsplash (bukan gambar langsung)
//     if (trimmed.contains('unsplash.com/photos') ||
//         trimmed.contains('unsplash.com/@')) {
//       return null;
//     }

//     if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
//       return trimmed;
//     }
//     if (trimmed.startsWith('/')) return '${ApiConstants.baseUrl}$trimmed';
//     return '${ApiConstants.baseUrl}/$trimmed';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = _resolveImageUrl(item.thumbnailUrl);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(14),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           splashColor: accentColor.withValues(alpha: 0.1),
//           child: IntrinsicHeight(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Thumbnail - fixed width
//                 Container(
//                   width: 100,
//                   decoration: BoxDecoration(
//                     color: accentColor.withValues(alpha: 0.08),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(14),
//                       bottomLeft: Radius.circular(14),
//                     ),
//                     child: Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         if (imageUrl != null)
//                           Image.network(
//                             imageUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => _buildFallbackIcon(),
//                           )
//                         else
//                           _buildFallbackIcon(),
//                         if (item.isVideo)
//                           Center(
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black54,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Info section
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Badge tipe
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: accentColor.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             item.displayTipe,
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                               color: accentColor,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         // Judul
//                         Text(
//                           item.judul,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textPrimary,
//                             height: 1.3,
//                           ),
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 8),
//                         // Footer - TANPA Spacer
//                         Row(
//                           children: [
//                             if (item.durasiBaca.isNotEmpty) ...[
//                               const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textHint),
//                               const SizedBox(width: 4),
//                               Text(
//                                 item.durasiBaca,
//                                 style: const TextStyle(fontSize: 11, color: AppColors.textHint),
//                               ),
//                             ],
//                             const Expanded(child: SizedBox()), // Ganti Spacer
//                             Text(
//                               'Baca →',
//                               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFallbackIcon() {
//     return Center(
//       child: Icon(
//         item.isVideo ? Icons.play_circle_outline_rounded : Icons.article_outlined,
//         size: 36,
//         color: accentColor.withValues(alpha: 0.4),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';
import 'detail_konten_edukasi_anak_screen.dart';

class ListKontenEdukasiAnakScreen extends StatelessWidget {
  final String kategori;
  final String deskripsi;
  final List<EdukasiAnakItem> items;
  final Color accentColor;
  final IconData icon;

  const ListKontenEdukasiAnakScreen({
    super.key,
    required this.kategori,
    required this.deskripsi,
    required this.items,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kategori,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              deskripsi,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _KontenAnakListItem(
                  item: items[index],
                  accentColor: accentColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailKontenEdukasiAnakScreen(item: items[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: accentColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada konten $kategori',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Konten akan segera tersedia',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// ITEM CARD - Layout vertikal (gambar atas, konten bawah) seperti card ibu
// =========================================================================
class _KontenAnakListItem extends StatelessWidget {
  final EdukasiAnakItem item;
  final Color accentColor;
  final VoidCallback onTap;

  const _KontenAnakListItem({
    required this.item,
    required this.accentColor,
    required this.onTap,
  });

  String? _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.contains('unsplash.com/photos') ||
        trimmed.contains('unsplash.com/@')) {
      return null;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) return '${ApiConstants.baseUrl}$trimmed';
    return '${ApiConstants.baseUrl}/$trimmed';
  }

  // Cuplikan isi: utamakan ringkasan, fallback ke konten kalau ringkasan kosong.
  // Memastikan semua kategori anak (Informasi Umum, Pola Asuh, Perawatan)
  // selalu menampilkan cuplikan isi seperti card ibu.
  String get _cuplikanIsi =>
      item.ringkasan.trim().isNotEmpty ? item.ringkasan.trim() : item.konten.trim();

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(item.thumbnailUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar / Placeholder ──
            if (imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholderImage(rounded: true),
                    ),
                    if (item.isVideo)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow,
                                color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              _placeholderImage(rounded: true),

            // ── Konten ──
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tipe
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      item.displayTipe,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
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

                  // Cuplikan isi (sama seperti card ibu: maksimal 3 baris)
                  if (_cuplikanIsi.isNotEmpty)
                    Text(
                      _cuplikanIsi,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                  // Tombol baca selengkapnya
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: accentColor,
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

  Widget _placeholderImage({bool rounded = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: Center(
        child: Icon(
          item.isVideo
              ? Icons.play_circle_outline_rounded
              : Icons.article_outlined,
          size: 36,
          color: accentColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}