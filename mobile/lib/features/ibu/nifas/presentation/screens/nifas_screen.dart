// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/checklist_pemantauan_ibu_nifas_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/detail_checklist_nifas_screen.dart';

// /// Model untuk satu hari nifas beserta status verifikasinya.
// class FilledDayStatus {
//   final int hariNifas;
//   final bool terverifikasi;
//   final String namaKader;
//   final String? tanggalVerifikasi;

//   const FilledDayStatus({
//     required this.hariNifas,
//     required this.terverifikasi,
//     this.namaKader = '',
//     this.tanggalVerifikasi,
//   });

//   factory FilledDayStatus.fromJson(Map<String, dynamic> json) {
//     return FilledDayStatus(
//       hariNifas: (json['hari_nifas'] as num).toInt(),
//       terverifikasi: json['terverifikasi'] as bool? ?? false,
//       namaKader: json['nama_kader'] as String? ?? '',
//       tanggalVerifikasi: json['tanggal_verifikasi'] as String?,
//     );
//   }
// }

// // [SCOPE: modul-ibu / nifas]
// // Model ringkas untuk data persalinan yang dibutuhkan layar nifas.
// // Hanya field yang relevan: kehamilan_id dan tanggal_melahirkan.
// class _PersalinanInfo {
//   final int kehamilanId;
//   final DateTime tanggalMelahirkan;

//   const _PersalinanInfo({
//     required this.kehamilanId,
//     required this.tanggalMelahirkan,
//   });
// }

// class NifasScreen extends StatefulWidget {
//   const NifasScreen({super.key});

//   @override
//   State<NifasScreen> createState() => _NifasScreenState();
// }

// class _NifasScreenState extends State<NifasScreen> {
//   bool isLoading = true;

//   List<FilledDayStatus> filledDaysStatus = [];

//   // [SCOPE: modul-ibu / nifas]
//   // Info persalinan: diambil dari ringkasan_pelayanan_persalinan.
//   // Digunakan untuk menghitung hari nifas hari ini dan meneruskan
//   // kehamilan_id ke ChecklistPemantauanIbuNifasScreen.
//   _PersalinanInfo? _persalinanInfo;
//   String? _persalinanError;

//   List<int> get filledDays =>
//       filledDaysStatus.map((e) => e.hariNifas).toList();

//   @override
//   void initState() {
//     super.initState();
//     _loadAll();
//   }

//   // [SCOPE: modul-ibu / nifas]
//   // Load data persalinan dan filled days secara paralel.
//   Future<void> _loadAll() async {
//     setState(() {
//       isLoading = true;
//       _persalinanError = null;
//     });
//     await Future.wait([
//       _loadPersalinanInfo(),
//       _loadFilledDays(),
//     ]);
//     if (mounted) setState(() => isLoading = false);
//   }

//   // [SCOPE: modul-ibu / nifas]
//   // Ambil tanggal_melahirkan dan kehamilan_id dari endpoint
//   // GET /modul-ibu/ringkasan-persalinan/me
//   // Endpoint sudah ada, tidak ada perubahan backend.
//   Future<void> _loadPersalinanInfo() async {
//     try {
//       final token = AuthSession.token;
//       if (token == null || token.isEmpty) return;

//       final response = await http.get(
//         Uri.parse(ApiConstants.ringkasanPersalinan),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final body = jsonDecode(response.body);
//         // Response bisa berupa array (GetMine mengembalikan list)
//         final rawData = body['data'];
//         List<dynamic> list = [];
//         if (rawData is List) {
//           list = rawData;
//         } else if (rawData is Map) {
//           list = [rawData];
//         }

//         if (list.isEmpty) {
//           if (mounted) {
//             setState(() => _persalinanError =
//                 'Data persalinan belum tersedia. Hubungi tenaga kesehatan.');
//           }
//           return;
//         }

//         // Ambil entri pertama (persalinan terbaru).
//         final item = list.first as Map<String, dynamic>;
//         final tanggalRaw = item['tanggal_melahirkan'] as String?;
//         final kehamilanId = (item['kehamilan_id'] as num?)?.toInt();

//         if (tanggalRaw == null || kehamilanId == null) {
//           if (mounted) {
//             setState(() => _persalinanError =
//                 'Tanggal melahirkan belum diisi oleh tenaga kesehatan.');
//           }
//           return;
//         }

//         final tanggal = DateTime.tryParse(tanggalRaw);
//         if (tanggal == null) {
//           if (mounted) {
//             setState(() => _persalinanError =
//                 'Format tanggal melahirkan tidak valid.');
//           }
//           return;
//         }

//         if (mounted) {
//           setState(() {
//             _persalinanInfo = _PersalinanInfo(
//               kehamilanId: kehamilanId,
//               tanggalMelahirkan: tanggal,
//             );
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() =>
//             _persalinanError = 'Gagal memuat data persalinan: $e');
//       }
//     }
//   }

//   Future<void> _loadFilledDays() async {
//     try {
//       final token = AuthSession.token;
//       if (token == null || token.isEmpty) return;

//       final response = await http.get(
//         Uri.parse(
//             '${ApiConstants.baseUrl}${ApiConstants.checklistNifasFilledDays}'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       final body = jsonDecode(response.body);
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = body['data'] as List<dynamic>? ?? [];
//         if (mounted) {
//           setState(() {
//             filledDaysStatus = data.map((e) {
//               if (e is Map<String, dynamic>) {
//                 return FilledDayStatus.fromJson(e);
//               }
//               return FilledDayStatus(
//                 hariNifas: int.parse(e.toString()),
//                 terverifikasi: false,
//               );
//             }).toList();
//           });
//         }
//       }
//     } catch (_) {}
//   }

//   // [SCOPE: modul-ibu / nifas]
//   // Hitung hari nifas hari ini dari tanggal_melahirkan.
//   // Rumus: selisih hari antara tanggal_melahirkan dan hari ini + 1.
//   // Contoh: melahirkan hari ini → hari nifas ke-1.
//   // Batas: 1–42. Di luar rentang = null (tidak aktif / sudah selesai).
//   int? get _hariNifasHariIni {
//     if (_persalinanInfo == null) return null;
//     final today = DateTime.now();
//     final lahir = _persalinanInfo!.tanggalMelahirkan;
//     // Normalisasi ke tanggal saja (tanpa jam) agar selisih tepat hari.
//     final todayDate = DateTime(today.year, today.month, today.day);
//     final lahirDate = DateTime(lahir.year, lahir.month, lahir.day);
//     final selisih = todayDate.difference(lahirDate).inDays;
//     final hari = selisih + 1; // hari ke-1 = hari melahirkan itu sendiri
//     if (hari < 1 || hari > 42) return null;
//     return hari;
//   }

//   Future<void> _openChecklist() async {
//     // [SCOPE: modul-ibu / nifas]
//     // Checklist hanya bisa dibuka jika data persalinan sudah tersedia.
//     if (_persalinanInfo == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             _persalinanError ??
//                 'Data persalinan belum tersedia.',
//           ),
//           backgroundColor: Colors.red.shade600,
//         ),
//       );
//       return;
//     }

//     final hariHariIni = _hariNifasHariIni;
//     if (hariHariIni == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Masa nifas sudah selesai (lebih dari 42 hari sejak melahirkan).',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChecklistPemantauanIbuNifasScreen(
//           filledDays: filledDays,
//           // [SCOPE: modul-ibu / nifas]
//           // Pass kehamilan_id dan hari nifas otomatis dari data persalinan.
//           kehamilanId: _persalinanInfo!.kehamilanId,
//           hariNifasHariIni: hariHariIni,
//         ),
//       ),
//     );
//     if (result == true) _loadAll();
//   }

//   void _openDetail(FilledDayStatus item) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DetailChecklistNifasScreen(
//           hariNifas: item.hariNifas,
//           terverifikasi: item.terverifikasi,
//           namaKader: item.namaKader,
//           tanggalVerifikasi: item.tanggalVerifikasi,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final verifiedCount =
//         filledDaysStatus.where((e) => e.terverifikasi).length;
//     final pendingCount = filledDaysStatus.length - verifiedCount;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       appBar: AppBar(
//         title: const Text(
//           'Pemantauan Nifas',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: AppColors.primary,
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadAll,
//         color: AppColors.primary,
//         child: CustomScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Info strip ──────────────────────────────
//                     _infoStrip(verifiedCount, pendingCount),
//                     const SizedBox(height: 8),

//                     // [SCOPE: modul-ibu / nifas]
//                     // Tampilkan info hari nifas sekarang jika data tersedia.
//                     if (_persalinanInfo != null)
//                       _hariNifasInfo(),
//                     if (_persalinanError != null)
//                       _persalinanErrorBanner(),
//                     const SizedBox(height: 12),

//                     // ── Tombol isi checklist ────────────────────
//                     _addButton(),
//                     const SizedBox(height: 20),

//                     // ── Label riwayat ───────────────────────────
//                     const Text(
//                       'Riwayat Pemantauan',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Daftar hari ──────────────────────────────────
//             if (isLoading)
//               const SliverFillRemaining(
//                 child: Center(child: CircularProgressIndicator()),
//               )
//             else if (filledDaysStatus.isEmpty)
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: _emptyState(),
//                 ),
//               )
//             else
//               SliverPadding(
//                 padding:
//                     const EdgeInsets.fromLTRB(16, 0, 16, 32),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) =>
//                         _logItem(filledDaysStatus[index]),
//                     childCount: filledDaysStatus.length,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // [SCOPE: modul-ibu / nifas]
//   // Banner info hari nifas hari ini berdasarkan tanggal_melahirkan.
//   Widget _hariNifasInfo() {
//     final hari = _hariNifasHariIni;
//     final tanggalFormatted = DateFormat('d MMM yyyy', 'id')
//         .format(_persalinanInfo!.tanggalMelahirkan);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF6FF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFBFDBFE)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.calendar_today_outlined,
//               size: 16, color: Color(0xFF3B82F6)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: hari != null
//                 ? Text(
//                     'Melahirkan $tanggalFormatted • Hari nifas ke-$hari dari 42',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF1D4ED8),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   )
//                 : Text(
//                     'Melahirkan $tanggalFormatted • Masa nifas telah selesai',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   // [SCOPE: modul-ibu / nifas]
//   // Banner error jika data persalinan belum tersedia.
//   Widget _persalinanErrorBanner() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF7ED),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFFDBA74)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.warning_amber_rounded,
//               size: 16, color: Color(0xFFD97706)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               _persalinanError!,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF92400E),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── Info strip (ringkasan) ────────────────────────────────────────

//   Widget _infoStrip(int verified, int pending) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Checklist Harian Masa Nifas',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${filledDaysStatus.length} dari 42 hari telah diisi',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           _miniStat(
//             Icons.check_circle_outline,
//             '$verified',
//             'Terverifikasi',
//             Colors.green.shade300,
//           ),
//           const SizedBox(width: 10),
//           _miniStat(
//             Icons.schedule_outlined,
//             '$pending',
//             'Menunggu',
//             Colors.orange.shade300,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _miniStat(
//       IconData icon, String value, String label, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 20),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         Text(
//           label,
//           style:
//               const TextStyle(color: Colors.white60, fontSize: 10),
//         ),
//       ],
//     );
//   }

//   // ─── Tombol tambah ────────────────────────────────────────────────

//   Widget _addButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: _openChecklist,
//         icon: const Icon(Icons.add_circle_outline, size: 20),
//         label: const Text(
//           'Isi Checklist Hari Ini',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           foregroundColor: AppColors.primary,
//           elevation: 0,
//           side: BorderSide(
//               color: AppColors.primary.withOpacity(0.4), width: 1.5),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── Item log ──────────────────────────────────────────────────────

//   Widget _logItem(FilledDayStatus item) {
//     final isVerified = item.terverifikasi;
//     final statusColor =
//         isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706);
//     final statusBg = isVerified
//         ? const Color(0xFFDCFCE7)
//         : const Color(0xFFFEF3C7);
//     final statusLabel = isVerified ? 'Terverifikasi' : 'Menunggu';
//     final statusIcon =
//         isVerified ? Icons.check_circle : Icons.schedule_rounded;

//     // [SCOPE: modul-ibu / nifas]
//     // Hitung tanggal aktual checklist hari tersebut berdasarkan tanggal_melahirkan.
//     String? tanggalAktual;
//     if (_persalinanInfo != null) {
//       final t = _persalinanInfo!.tanggalMelahirkan
//           .add(Duration(days: item.hariNifas - 1));
//       tanggalAktual = DateFormat('d MMM yyyy', 'id').format(t);
//     }

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Material(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: () => _openDetail(item),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 14, vertical: 12),
//             child: Row(
//               children: [
//                 // Nomor hari
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '${item.hariNifas}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                           height: 1,
//                         ),
//                       ),
//                       Text(
//                         'Hari',
//                         style: TextStyle(
//                           fontSize: 9,
//                           color: AppColors.primary.withOpacity(0.7),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Hari ke-${item.hariNifas}${tanggalAktual != null ? ' · $tanggalAktual' : ''}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                           color: Color(0xFF111827),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         isVerified
//                             ? 'Diverifikasi oleh ${item.namaKader.isNotEmpty ? item.namaKader : "Kader"}${item.tanggalVerifikasi != null ? " · ${_formatTanggal(item.tanggalVerifikasi!)}" : ""}'
//                             : 'Menunggu verifikasi kader',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: statusColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),

//                 // Badge status
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusBg,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(statusIcon,
//                           size: 12, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         statusLabel,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           color: statusColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 4),
//                 Icon(Icons.chevron_right,
//                     color: Colors.grey.shade400, size: 18),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── Empty state ──────────────────────────────────────────────────

//   Widget _emptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.assignment_outlined,
//               size: 48, color: Colors.grey.shade300),
//           const SizedBox(height: 12),
//           const Text(
//             'Belum ada checklist yang diisi',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Tekan tombol di atas untuk memulai',
//             style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── Helper ───────────────────────────────────────────────────────

//   String _formatTanggal(String iso) {
//     try {
//       return DateFormat('d MMM yyyy', 'id').format(DateTime.parse(iso));
//     } catch (_) {
//       return iso;
//     }
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/checklist_pemantauan_ibu_nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/detail_checklist_nifas_screen.dart';

/// Model untuk satu hari nifas beserta status verifikasinya.
class FilledDayStatus {
  final int hariNifas;
  final bool terverifikasi;
  final String namaKader;
  final String? tanggalVerifikasi;

  const FilledDayStatus({
    required this.hariNifas,
    required this.terverifikasi,
    this.namaKader = '',
    this.tanggalVerifikasi,
  });

  factory FilledDayStatus.fromJson(Map<String, dynamic> json) {
    return FilledDayStatus(
      hariNifas: (json['hari_nifas'] as num).toInt(),
      terverifikasi: json['terverifikasi'] as bool? ?? false,
      namaKader: json['nama_kader'] as String? ?? '',
      tanggalVerifikasi: json['tanggal_verifikasi'] as String?,
    );
  }
}

// [SCOPE: modul-ibu / nifas]
// Model ringkas untuk data persalinan yang dibutuhkan layar nifas.
// Hanya field yang relevan: kehamilan_id dan tanggal_melahirkan.
class _PersalinanInfo {
  final int kehamilanId;
  final DateTime tanggalMelahirkan;

  const _PersalinanInfo({
    required this.kehamilanId,
    required this.tanggalMelahirkan,
  });
}

class NifasScreen extends StatefulWidget {
  const NifasScreen({super.key});

  @override
  State<NifasScreen> createState() => _NifasScreenState();
}

class _NifasScreenState extends State<NifasScreen> {
  bool isLoading = true;

  List<FilledDayStatus> filledDaysStatus = [];

  // [SCOPE: modul-ibu / nifas]
  // Info persalinan: diambil dari ringkasan_pelayanan_persalinan.
  // Digunakan untuk menghitung hari nifas hari ini dan meneruskan
  // kehamilan_id ke ChecklistPemantauanIbuNifasScreen.
  _PersalinanInfo? _persalinanInfo;
  String? _persalinanError;

  List<int> get filledDays =>
      filledDaysStatus.map((e) => e.hariNifas).toList();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // [SCOPE: modul-ibu / nifas]
  // Load data persalinan dan filled days secara paralel.
  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      _persalinanError = null;
    });
    await Future.wait([
      _loadPersalinanInfo(),
      _loadFilledDays(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  // [SCOPE: modul-ibu / nifas]
  // Ambil tanggal_melahirkan dan kehamilan_id dari endpoint
  // GET /modul-ibu/ringkasan-persalinan/me
  // Endpoint sudah ada, tidak ada perubahan backend.
  Future<void> _loadPersalinanInfo() async {
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(ApiConstants.ringkasanPersalinan),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        // Response bisa berupa array (GetMine mengembalikan list)
        final rawData = body['data'];
        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map) {
          list = [rawData];
        }

        if (list.isEmpty) {
          if (mounted) {
            setState(() => _persalinanError =
                'Data persalinan belum tersedia. Hubungi tenaga kesehatan.');
          }
          return;
        }

        // Ambil entri pertama (persalinan terbaru).
        final item = list.first as Map<String, dynamic>;
        final tanggalRaw = item['tanggal_melahirkan'] as String?;
        final kehamilanId = (item['kehamilan_id'] as num?)?.toInt();

        if (tanggalRaw == null || kehamilanId == null) {
          if (mounted) {
            setState(() => _persalinanError =
                'Tanggal melahirkan belum diisi oleh tenaga kesehatan.');
          }
          return;
        }

        final tanggal = DateTime.tryParse(tanggalRaw);
        if (tanggal == null) {
          if (mounted) {
            setState(() => _persalinanError =
                'Format tanggal melahirkan tidak valid.');
          }
          return;
        }

        if (mounted) {
          setState(() {
            _persalinanInfo = _PersalinanInfo(
              kehamilanId: kehamilanId,
              tanggalMelahirkan: tanggal,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _persalinanError = 'Gagal memuat data persalinan: $e');
      }
    }
  }

  Future<void> _loadFilledDays() async {
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.checklistNifasFilledDays}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            filledDaysStatus = data.map((e) {
              if (e is Map<String, dynamic>) {
                return FilledDayStatus.fromJson(e);
              }
              return FilledDayStatus(
                hariNifas: int.parse(e.toString()),
                terverifikasi: false,
              );
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  // [SCOPE: modul-ibu / nifas]
  // Hitung hari nifas hari ini dari tanggal_melahirkan.
  // Rumus: selisih hari antara tanggal_melahirkan dan hari ini + 1.
  // Contoh: melahirkan hari ini → hari nifas ke-1.
  // Batas: 1–42. Di luar rentang = null (tidak aktif / sudah selesai).
  int? get _hariNifasHariIni {
    if (_persalinanInfo == null) return null;
    final today = DateTime.now();
    final lahir = _persalinanInfo!.tanggalMelahirkan;
    // Normalisasi ke tanggal saja (tanpa jam) agar selisih tepat hari.
    final todayDate = DateTime(today.year, today.month, today.day);
    final lahirDate = DateTime(lahir.year, lahir.month, lahir.day);
    final selisih = todayDate.difference(lahirDate).inDays;
    final hari = selisih + 1; // hari ke-1 = hari melahirkan itu sendiri
    if (hari < 1 || hari > 42) return null;
    return hari;
  }

  Future<void> _openChecklist() async {
    // [SCOPE: modul-ibu / nifas]
    // Checklist hanya bisa dibuka jika data persalinan sudah tersedia.
    if (_persalinanInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _persalinanError ??
                'Data persalinan belum tersedia.',
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    final hariHariIni = _hariNifasHariIni;
    if (hariHariIni == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masa nifas sudah selesai (lebih dari 42 hari sejak melahirkan).',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChecklistPemantauanIbuNifasScreen(
          filledDays: filledDays,
          // [SCOPE: modul-ibu / nifas]
          // Pass kehamilan_id dan hari nifas otomatis dari data persalinan.
          kehamilanId: _persalinanInfo!.kehamilanId,
          hariNifasHariIni: hariHariIni,
        ),
      ),
    );
    if (result == true) _loadAll();
  }

  void _openDetail(FilledDayStatus item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailChecklistNifasScreen(
          hariNifas: item.hariNifas,
          terverifikasi: item.terverifikasi,
          namaKader: item.namaKader,
          tanggalVerifikasi: item.tanggalVerifikasi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount =
        filledDaysStatus.where((e) => e.terverifikasi).length;
    final pendingCount = filledDaysStatus.length - verifiedCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Pemantauan Nifas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info strip ──────────────────────────────
                    _infoStrip(verifiedCount, pendingCount),
                    const SizedBox(height: 8),

                    // [SCOPE: modul-ibu / nifas]
                    // Tampilkan info hari nifas sekarang jika data tersedia.
                    if (_persalinanInfo != null)
                      _hariNifasInfo(),
                    if (_persalinanError != null)
                      _persalinanErrorBanner(),
                    const SizedBox(height: 12),

                    // ── Tombol isi checklist ────────────────────
                    _addButton(),
                    const SizedBox(height: 20),

                    // ── Label riwayat ───────────────────────────
                    const Text(
                      'Riwayat Pemantauan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Daftar hari ──────────────────────────────────
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filledDaysStatus.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _emptyState(),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _logItem(filledDaysStatus[index]),
                    childCount: filledDaysStatus.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // [SCOPE: modul-ibu / nifas]
  // Banner info hari nifas hari ini berdasarkan tanggal_melahirkan.
  Widget _hariNifasInfo() {
    final hari = _hariNifasHariIni;
    final tanggalFormatted = DateFormat('d MMM yyyy', 'id')
        .format(_persalinanInfo!.tanggalMelahirkan);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(
            child: hari != null
                ? Text(
                    'Melahirkan $tanggalFormatted • Hari nifas ke-$hari dari 42',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    'Melahirkan $tanggalFormatted • Masa nifas telah selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // [SCOPE: modul-ibu / nifas]
  // Banner error jika data persalinan belum tersedia.
  Widget _persalinanErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _persalinanError!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info strip (ringkasan) ────────────────────────────────────────

  Widget _infoStrip(int verified, int pending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Checklist Harian Masa Nifas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filledDaysStatus.length} dari 42 hari telah diisi',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _miniStat(
            Icons.check_circle_outline,
            '$verified',
            'Terverifikasi',
            Colors.green.shade300,
          ),
          const SizedBox(width: 10),
          _miniStat(
            Icons.schedule_outlined,
            '$pending',
            'Menunggu',
            Colors.orange.shade300,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style:
              const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  // ─── Tombol tambah ────────────────────────────────────────────────

  Widget _addButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openChecklist,
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: const Text(
          'Isi Checklist Hari Ini',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          side: BorderSide(
              color: AppColors.primary.withOpacity(0.4), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Item log ──────────────────────────────────────────────────────

  Widget _logItem(FilledDayStatus item) {
    final isVerified = item.terverifikasi;
    final statusColor =
        isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final statusBg = isVerified
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);
    final statusLabel = isVerified ? 'Terverifikasi' : 'Menunggu';
    final statusIcon =
        isVerified ? Icons.check_circle : Icons.schedule_rounded;

    // [SCOPE: modul-ibu / nifas]
    // Hitung tanggal aktual checklist hari tersebut berdasarkan tanggal_melahirkan.
    String? tanggalAktual;
    if (_persalinanInfo != null) {
      final t = _persalinanInfo!.tanggalMelahirkan
          .add(Duration(days: item.hariNifas - 1));
      tanggalAktual = DateFormat('d MMM yyyy', 'id').format(t);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Nomor hari
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.hariNifas}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      Text(
                        'Hari',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.primary.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hari ke-${item.hariNifas}${tanggalAktual != null ? ' · $tanggalAktual' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isVerified
                            ? 'Diverifikasi oleh ${item.namaKader.isNotEmpty ? item.namaKader : "Kader"}${item.tanggalVerifikasi != null ? " · ${_formatTanggal(item.tanggalVerifikasi!)}" : ""}'
                            : 'Menunggu verifikasi kader',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'Belum ada checklist yang diisi',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tekan tombol di atas untuk memulai',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────

  String _formatTanggal(String iso) {
    try {
      return DateFormat('d MMM yyyy', 'id').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}