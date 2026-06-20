// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/pilih_status_kunjungan.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/imunisasi_terlewat.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/profil_screen.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_model.dart';
// import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_bottom_nav.dart';
// import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_header.dart';

// import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_balita_screen.dart';
// // Bagian Ibu
// import 'package:ta_pa2_pa3_project/features/kader/screens/ttd_mms/rekap_ttd_mms_kader_screen.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_hamil_screen.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_hamil_screen.dart';
// import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_nifas_screen.dart';

// class DashboardKaderScreen extends StatefulWidget {
//   const DashboardKaderScreen({super.key});

//   @override
//   State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
// }

// class _MenuLayananItem {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final WidgetBuilder screenBuilder;

//   /// Jika diisi, baris kedua kartu menu akan menampilkan status verifikasi
//   /// dinamis dari data ringkasan desa berdasarkan key ini.
//   final String? verifikasiKey;

//   const _MenuLayananItem({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.screenBuilder,
//     this.verifikasiKey,
//   });
// }

// class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
//   int _selectedNavIndex = 0;

//   final List<String> allowedRoles = ['kader'];

//   final RingkasanDesaApiService _ringkasanService = RingkasanDesaApiService();
//   late Future<RingkasanDesaModel> _ringkasanFuture;

//   final List<_MenuLayananItem> _menuLayanan = [
//     _MenuLayananItem(
//       title: 'Kelas Ibu Balita',
//       subtitle: 'Verifikasi kehadiran',
//       icon: Icons.groups_2_outlined,
//       color: Colors.teal,
//       screenBuilder: (_) => const VerifikasiAbsensiKelasIbuBalitaScreen(),
//       verifikasiKey: 'kelas_ibu_balita',
//     ),
//     _MenuLayananItem(
//       title: 'TTD/MMS Ibu Hamil',
//       subtitle: 'Rekap kepatuhan suplemen',
//       icon: Icons.medication_outlined,
//       color: Colors.pink,
//       screenBuilder: (_) => const RekapTTDMMSKaderScreen(),
//     ),
//     _MenuLayananItem(
//       title: 'Kelas Ibu Hamil',
//       subtitle: 'Verifikasi kehadiran',
//       icon: Icons.pregnant_woman_outlined,
//       color: Colors.purple,
//       screenBuilder: (_) => const VerifikasiAbsensiKelasIbuHamilScreen(),
//       verifikasiKey: 'kelas_ibu_hamil',
//     ),
//     _MenuLayananItem(
//       title: 'Pemantauan Ibu Hamil',
//       subtitle: 'Tinjau keluhan mingguan',
//       icon: Icons.monitor_heart_outlined,
//       color: Colors.red,
//       screenBuilder: (_) => const VerifikasiPemantauanIbuHamilScreen(),
//       verifikasiKey: 'pemantauan_ibu_hamil',
//     ),
//     _MenuLayananItem(
//       title: 'Pemantauan Ibu Nifas',
//       subtitle: 'Tinjau keluhan harian',
//       icon: Icons.health_and_safety_outlined,
//       color: const Color(0xFF7B52AB),
//       screenBuilder: (_) => const VerifikasiPemantauanIbuNifasScreen(),
//       verifikasiKey: 'pemantauan_ibu_nifas',
//     ),
//     _MenuLayananItem(
//       title: 'Imunisasi Terlewat',
//       subtitle: 'Daftar anak terlewat',
//       icon: Icons.vaccines_outlined,
//       color: Colors.orange,
//       screenBuilder: (_) => const DaftarImunisasiTerlewatScreen(),
//     ),
//   ];

//   bool get isAllowed {
//     final role = AuthSession.role?.trim().toLowerCase();
//     return allowedRoles.contains(role);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _ringkasanFuture = _ringkasanService.getRingkasanDesa();
//   }

//   @override
//   void dispose() {
//     _ringkasanService.dispose();
//     super.dispose();
//   }

//   void _reloadRingkasan() {
//     setState(() {
//       _ringkasanFuture = _ringkasanService.getRingkasanDesa();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isAllowed) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF8FAFC),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.lock_outline, size: 72, color: Colors.red.shade300),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Akses Ditolak',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Halaman ini hanya dapat diakses oleh kader.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Kembali'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     Widget body;

//     switch (_selectedNavIndex) {
//       case 0:
//         body = _buildHomeBody();
//         break;
//       case 1:
//         body = const DaftarImunisasiTerlewatScreen();
//         break;
//       case 2:
//         body = const ProfilScreen();
//         break;
//       default:
//         body = _buildHomeBody();
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       body: body,
//       bottomNavigationBar: DashboardBottomNav(
//         currentIndex: _selectedNavIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedNavIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildHomeBody() {
//     return RefreshIndicator(
//       onRefresh: () async {
//         _reloadRingkasan();
//         await _ringkasanFuture;
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             const DashboardHeader(),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoHariIniSection(),
//                   const SizedBox(height: 24),
//                   _buildSectionTitle('Menu Layanan'),
//                   const SizedBox(height: 12),
//                   _buildMenuLayananGrid(),
//                   const SizedBox(height: 24),
//                   _buildRingkasanDesaHeader(),
//                   const SizedBox(height: 12),
//                   _buildRingkasanDesaCard(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w800,
//         color: Color(0xFF0F172A),
//       ),
//     );
//   }

//   /// =========================
//   /// INFO HARI INI
//   /// =========================
//   Widget _buildInfoHariIniSection() {
//     final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionTitle('Info Hari Ini'),
//         const SizedBox(height: 2),
//         Text(
//           today,
//           style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//         ),
//         const SizedBox(height: 12),
//         FutureBuilder<RingkasanDesaModel>(
//           future: _ringkasanFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return _buildInfoCardSkeleton();
//             }

//             if (snapshot.hasError) {
//               return _buildInfoCardError();
//             }

//             final jumlahPerluTindak = snapshot.data?.perluTindakLanjut ?? 0;
//             final hasWarning = jumlahPerluTindak > 0;

//             return _buildEscalationCard(
//               title: hasWarning
//                   ? '$jumlahPerluTindak kunjungan imunisasi perlu ditindak lanjut.'
//                   : 'Tidak ada kunjungan yang perlu ditindak lanjut saat ini.',
//               isWarning: hasWarning,
//               icon: hasWarning
//                   ? Icons.warning_amber_rounded
//                   : Icons.check_circle_outline_rounded,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const PilihStatusKunjunganScreen(),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoCardSkeleton() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: const [
//           SizedBox(
//             width: 18,
//             height: 18,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'Memuat ringkasan desa...',
//             style: TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCardError() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.red.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
//           const SizedBox(width: 10),
//           const Expanded(
//             child: Text(
//               'Gagal memuat ringkasan desa.',
//               style: TextStyle(fontSize: 12.5, color: Colors.black87),
//             ),
//           ),
//           TextButton(
//             onPressed: _reloadRingkasan,
//             child: const Text('Coba Lagi'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// =========================
//   /// MENU LAYANAN
//   /// Tampilan dibuat menjadi grid 2 kolom seperti menu cepat pada dashboard.
//   /// Total 6 menu akan tersusun menjadi 3 baris: 3 item kiri dan 3 item kanan.
//   /// Setiap menu berbentuk box/kotak, bukan kartu persegi panjang.
//   /// =========================
//   Widget _buildMenuLayananGrid() {
//     return FutureBuilder<RingkasanDesaModel>(
//       future: _ringkasanFuture,
//       builder: (context, snapshot) {
//         final ringkasan = snapshot.data;

//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _menuLayanan.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 0.98,
//           ),
//           itemBuilder: (context, index) {
//             return _buildMenuBoxItem(_menuLayanan[index], ringkasan);
//           },
//         );
//       },
//     );
//   }

//   // Widget _buildMenuStatusLine(
//   //   _MenuLayananItem item,
//   //   RingkasanDesaModel? ringkasan,
//   // ) {
//   //   if (item.verifikasiKey == null) {
//   //     return Text(
//   //       item.subtitle,
//   //       textAlign: TextAlign.center,
//   //       maxLines: 2,
//   //       overflow: TextOverflow.ellipsis,
//   //       style: TextStyle(
//   //         fontSize: 11.5,
//   //         height: 1.25,
//   //         color: Colors.grey.shade600,
//   //         fontWeight: FontWeight.w500,
//   //       ),
//   //     );
//   //   }

//   //   if (ringkasan == null) {
//   //     return _buildSmallStatusChip(
//   //       label: 'Memuat',
//   //       icon: Icons.hourglass_empty_rounded,
//   //       textColor: Colors.grey.shade600,
//   //       backgroundColor: Colors.grey.shade100,
//   //       borderColor: Colors.grey.shade200,
//   //     );
//   //   }

//   //   final status = ringkasan.verifikasiByKey(item.verifikasiKey!);

//   //   if (status == null || status.total == 0) {
//   //     return _buildSmallStatusChip(
//   //       label: 'Belum ada data',
//   //       icon: Icons.info_outline_rounded,
//   //       textColor: Colors.grey.shade600,
//   //       backgroundColor: Colors.grey.shade100,
//   //       borderColor: Colors.grey.shade200,
//   //     );
//   //   }

//   //   final allVerified = status.belumVerifikasi == 0;

//   //   if (allVerified) {
//   //     return _buildSmallStatusChip(
//   //       label: 'Terverifikasi',
//   //       icon: Icons.check_circle_rounded,
//   //       textColor: Colors.green.shade700,
//   //       backgroundColor: Colors.green.shade50,
//   //       borderColor: Colors.green.shade100,
//   //     );
//   //   }

//   //   return _buildSmallStatusChip(
//   //     label: '${status.belumVerifikasi} belum • ${status.sudahVerifikasi}/${status.total}',
//   //     icon: Icons.pending_actions_rounded,
//   //     textColor: Colors.orange.shade800,
//   //     backgroundColor: Colors.orange.shade50,
//   //     borderColor: Colors.orange.shade100,
//   //   );
//   // }

//     Widget _buildMenuStatusLine(
//     _MenuLayananItem item,
//     RingkasanDesaModel? ringkasan,
//   ) {
//     // Jika menu tidak punya key verifikasi (seperti TTD/MMS atau Imunisasi Terlewat)
//     if (item.verifikasiKey == null) {
//       return Text(
//         item.subtitle,
//         textAlign: TextAlign.center,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontSize: 11.5,
//           height: 1.25,
//           color: Colors.grey.shade600,
//           fontWeight: FontWeight.w500,
//         ),
//       );
//     }

//     // Jika data ringkasan masih loading
//     if (ringkasan == null) {
//       return _buildSmallStatusChip(
//         label: 'Memuat...',
//         icon: Icons.hourglass_empty_rounded,
//         textColor: Colors.grey.shade600,
//         backgroundColor: Colors.grey.shade100,
//         borderColor: Colors.grey.shade200,
//       );
//     }

//     final status = ringkasan.verifikasiByKey(item.verifikasiKey!);

//     // Jika datanya kosong (total 0)
//     if (status == null || status.total == 0) {
//       return _buildSmallStatusChip(
//         label: 'Belum ada data',
//         icon: Icons.info_outline_rounded,
//         textColor: Colors.grey.shade600,
//         backgroundColor: Colors.grey.shade100,
//         borderColor: Colors.grey.shade200,
//       );
//     }

//     final allVerified = status.belumVerifikasi == 0;

//     // Jika semua sudah diverifikasi
//     if (allVerified) {
//       return _buildSmallStatusChip(
//         label: 'Semua Terverifikasi', // Ubah teksnya biar lebih jelas
//         icon: Icons.check_circle_rounded,
//         textColor: Colors.green.shade700,
//         backgroundColor: Colors.green.shade50,
//         borderColor: Colors.green.shade100,
//       );
//     }

//     // Jika masih ada yang belum diverifikasi (INI BAGIAN YANG DIUBAH)
//     return _buildSmallStatusChip(
//       label: '${status.belumVerifikasi} belum dari ${status.total}', // Format teks disesuaikan
//       icon: Icons.pending_actions_rounded,
//       textColor: Colors.orange.shade800,
//       backgroundColor: Colors.orange.shade50,
//       borderColor: Colors.orange.shade100,
//     );
//   }

//     Widget _buildSmallStatusChip({
//     required String label,
//     required IconData icon,
//     required Color textColor,
//     required Color backgroundColor,
//     required Color borderColor,
//   }) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(8), // Ubah dari 999 ke 8 biar gak terlalu lonjong kalau 2 baris
//         border: Border.all(color: borderColor),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: textColor),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Text(
//               label,
//               textAlign: TextAlign.center,
//               maxLines: 2, // Ubah jadi 2 baris
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 10.2, // Kecilin sedikit fontnya
//                 height: 1.2,
//                 fontWeight: FontWeight.w800,
//                 color: textColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildSmallStatusChip({
//   //   required String label,
//   //   required IconData icon,
//   //   required Color textColor,
//   //   required Color backgroundColor,
//   //   required Color borderColor,
//   // }) {
//   //   return Container(
//   //     width: double.infinity,
//   //     margin: const EdgeInsets.only(top: 6),
//   //     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
//   //     decoration: BoxDecoration(
//   //       color: backgroundColor,
//   //       borderRadius: BorderRadius.circular(999),
//   //       border: Border.all(color: borderColor),
//   //     ),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Icon(icon, size: 12.5, color: textColor),
//   //         const SizedBox(width: 4),
//   //         Flexible(
//   //           child: Text(
//   //             label,
//   //             textAlign: TextAlign.center,
//   //             maxLines: 1,
//   //             overflow: TextOverflow.ellipsis,
//   //             style: TextStyle(
//   //               fontSize: 10.8,
//   //               fontWeight: FontWeight.w800,
//   //               color: textColor,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildMenuBoxItem(
//     _MenuLayananItem item,
//     RingkasanDesaModel? ringkasan,
//   ) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: item.screenBuilder),
//           );
//         },
//         borderRadius: BorderRadius.circular(20),
//         child: Ink(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: item.color.withOpacity(0.16)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: item.color,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Container(
//                   width: 24,
//                   height: 24,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.chevron_right_rounded,
//                     color: Colors.grey.shade500,
//                     size: 18,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 48,
//                       height: 48,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Icon(
//                         item.icon,
//                         color: item.color,
//                         size: 25,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       item.title,
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 13.2,
//                         height: 1.2,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF0F172A),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     _buildMenuStatusLine(item, ringkasan),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// =========================
//   /// RINGKASAN DESA
//   /// =========================
//   Widget _buildRingkasanDesaHeader() {
//     return FutureBuilder<RingkasanDesaModel>(
//       future: _ringkasanFuture,
//       builder: (context, snapshot) {
//         final namaDesa = snapshot.data?.namaDesa;
//         final title = (namaDesa != null && namaDesa.isNotEmpty)
//             ? 'Ringkasan Desa $namaDesa'
//             : 'Ringkasan Desa';

//         return _buildSectionTitle(title);
//       },
//     );
//   }

//   Widget _buildRingkasanDesaCard() {
//     return FutureBuilder<RingkasanDesaModel>(
//       future: _ringkasanFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   'Gagal memuat ringkasan desa.',
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: _reloadRingkasan,
//                   child: const Text('Coba Lagi'),
//                 ),
//               ],
//             ),
//           );
//         }

//         final data = snapshot.data ?? RingkasanDesaModel.empty();

//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildSummaryItem(
//                     'Ibu Hamil',
//                     '${data.ibuHamil.total}',
//                     Colors.pink,
//                   ),
//                   _buildSummaryItem(
//                     'Anak',
//                     '${data.jumlahAnak}',
//                     Colors.blue,
//                   ),
//                   _buildSummaryItem(
//                     'Perlu Tindak',
//                     '${data.perluTindakLanjut}',
//                     Colors.red,
//                   ),
//                 ],
//               ),
//               if (data.ibuHamil.total > 0) ...[
//                 const SizedBox(height: 16),
//                 Divider(height: 1, color: Colors.grey.shade200),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Ibu hamil per trimester',
//                   style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildTrimesterChip('Trimester 1', data.ibuHamil.trimester1),
//                     _buildTrimesterChip('Trimester 2', data.ibuHamil.trimester2),
//                     _buildTrimesterChip('Trimester 3', data.ibuHamil.trimester3),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTrimesterChip(String label, int value) {
//     return Column(
//       children: [
//         Text(
//           '$value',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   /// =========================
//   /// ESCALATION CARD
//   /// =========================
//   Widget _buildEscalationCard({
//     required String title,
//     required bool isWarning,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     final statusColor = isWarning ? Colors.red : Colors.green;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: BoxDecoration(
//           color: statusColor.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: statusColor.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: statusColor, size: 26),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.5,
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       Icon(Icons.touch_app, size: 14, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Tap untuk lihat detail',
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           color: statusColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 13,
//             color: Colors.black54,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/pilih_status_kunjungan.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/imunisasi_terlewat.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/profil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_api_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_bottom_nav.dart';
import 'package:ta_pa2_pa3_project/features/kader/widgets/dashboard_header.dart';

import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_balita_screen.dart';
// Bagian Ibu
import 'package:ta_pa2_pa3_project/features/kader/screens/ttd_mms/rekap_ttd_mms_kader_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_absensi_kelas_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/verifikasi_pemantauan_ibu_nifas_screen.dart';

class DashboardKaderScreen extends StatefulWidget {
  const DashboardKaderScreen({super.key});

  @override
  State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
}

class _MenuLayananItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder screenBuilder;

  const _MenuLayananItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screenBuilder,
  });
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _selectedNavIndex = 0;

  final List<String> allowedRoles = ['kader'];

  final RingkasanDesaApiService _ringkasanService = RingkasanDesaApiService();
  late Future<RingkasanDesaModel> _ringkasanFuture;

  final List<_MenuLayananItem> _menuLayanan = [
    _MenuLayananItem(
      title: 'Kelas Ibu Balita',
      subtitle: 'Verifikasi kehadiran',
      icon: Icons.groups_2_outlined,
      color: Colors.teal,
      screenBuilder: (_) => const VerifikasiAbsensiKelasIbuBalitaScreen(),
    ),
    _MenuLayananItem(
      title: 'TTD/MMS Ibu Hamil',
      subtitle: 'Rekap kepatuhan suplemen',
      icon: Icons.medication_outlined,
      color: Colors.pink,
      screenBuilder: (_) => const RekapTTDMMSKaderScreen(),
    ),
    _MenuLayananItem(
      title: 'Kelas Ibu Hamil',
      subtitle: 'Verifikasi kehadiran',
      icon: Icons.pregnant_woman_outlined,
      color: Colors.purple,
      screenBuilder: (_) => const VerifikasiAbsensiKelasIbuHamilScreen(),
    ),
    _MenuLayananItem(
      title: 'Pemantauan Ibu Hamil',
      subtitle: 'Tinjau keluhan mingguan',
      icon: Icons.monitor_heart_outlined,
      color: Colors.red,
      screenBuilder: (_) => const VerifikasiPemantauanIbuHamilScreen(),
    ),
    _MenuLayananItem(
      title: 'Pemantauan Ibu Nifas',
      subtitle: 'Tinjau keluhan harian',
      icon: Icons.health_and_safety_outlined,
      color: const Color(0xFF7B52AB),
      screenBuilder: (_) => const VerifikasiPemantauanIbuNifasScreen(),
    ),
    _MenuLayananItem(
      title: 'Imunisasi Terlewat',
      subtitle: 'Daftar anak terlewat',
      icon: Icons.vaccines_outlined,
      color: Colors.orange,
      screenBuilder: (_) => const DaftarImunisasiTerlewatScreen(),
    ),
  ];

  bool get isAllowed {
    final role = AuthSession.role?.trim().toLowerCase();
    return allowedRoles.contains(role);
  }

  @override
  void initState() {
    super.initState();
    _ringkasanFuture = _ringkasanService.getRingkasanDesa();
  }

  @override
  void dispose() {
    _ringkasanService.dispose();
    super.dispose();
  }

  void _reloadRingkasan() {
    setState(() {
      _ringkasanFuture = _ringkasanService.getRingkasanDesa();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isAllowed) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 72, color: Colors.red.shade300),
                const SizedBox(height: 20),
                const Text(
                  'Akses Ditolak',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Halaman ini hanya dapat diakses oleh kader.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget body;

    switch (_selectedNavIndex) {
      case 0:
        body = _buildHomeBody();
        break;
      case 1:
        body = const DaftarImunisasiTerlewatScreen();
        break;
      case 2:
        body = const ProfilScreen();
        break;
      default:
        body = _buildHomeBody();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: body,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _reloadRingkasan();
        await _ringkasanFuture;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const DashboardHeader(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoHariIniSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Menu Layanan'),
                  const SizedBox(height: 12),
                  _buildMenuLayananGrid(),
                  const SizedBox(height: 24),
                  _buildRingkasanDesaHeader(),
                  const SizedBox(height: 12),
                  _buildRingkasanDesaCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }

  /// =========================
  /// INFO HARI INI
  /// =========================
  Widget _buildInfoHariIniSection() {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Info Hari Ini'),
        const SizedBox(height: 2),
        Text(
          today,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        FutureBuilder<RingkasanDesaModel>(
          future: _ringkasanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildInfoCardSkeleton();
            }

            if (snapshot.hasError) {
              return _buildInfoCardError();
            }

            final jumlahPerluTindak = snapshot.data?.perluTindakLanjut ?? 0;
            final hasWarning = jumlahPerluTindak > 0;

            return _buildEscalationCard(
              title: hasWarning
                  ? '$jumlahPerluTindak kunjungan imunisasi perlu ditindak lanjut.'
                  : 'Tidak ada kunjungan yang perlu ditindak lanjut saat ini.',
              isWarning: hasWarning,
              icon: hasWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PilihStatusKunjunganScreen(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Memuat ringkasan desa...',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Gagal memuat ringkasan desa.',
              style: TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: _reloadRingkasan,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// MENU LAYANAN
  /// =========================
  Widget _buildMenuLayananGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _menuLayanan.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        return _buildMenuBoxItem(_menuLayanan[index]);
      },
    );
  }

  // Widget _buildMenuBoxItem(_MenuLayananItem item) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: item.screenBuilder),
  //         );
  //       },
  //       borderRadius: BorderRadius.circular(20),
  //       child: Ink(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(color: item.color.withOpacity(0.16)),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.04),
  //               blurRadius: 12,
  //               offset: const Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         child: Stack(
  //           children: [
  //             Positioned(
  //               top: 0,
  //               left: 0,
  //               right: 0,
  //               child: Container(
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: item.color,
  //                   borderRadius: const BorderRadius.only(
  //                     topLeft: Radius.circular(20),
  //                     topRight: Radius.circular(20),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 10,
  //               right: 10,
  //               child: Container(
  //                 width: 24,
  //                 height: 24,
  //                 alignment: Alignment.center,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade100,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Icon(
  //                   Icons.chevron_right_rounded,
  //                   color: Colors.grey.shade500,
  //                   size: 18,
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     width: 48,
  //                     height: 48,
  //                     alignment: Alignment.center,
  //                     decoration: BoxDecoration(
  //                       color: item.color.withOpacity(0.12),
  //                       borderRadius: BorderRadius.circular(16),
  //                     ),
  //                     child: Icon(
  //                       item.icon,
  //                       color: item.color,
  //                       size: 25,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   Text(
  //                     item.title,
  //                     textAlign: TextAlign.center,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontSize: 13.2,
  //                       height: 1.2,
  //                       fontWeight: FontWeight.w800,
  //                       color: Color(0xFF0F172A),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     item.subtitle, // Langsung tampilkan subtitle sebagai info singkat
  //                     textAlign: TextAlign.center,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       fontSize: 11.5,
  //                       height: 1.25,
  //                       color: Colors.grey.shade600,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


    Widget _buildMenuBoxItem(_MenuLayananItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: item.screenBuilder),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: item.color.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Garis warna di atas kotak
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              // Bungkus Padding dengan Positioned.fill agar memenuhi area Ink
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.2,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.25,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// RINGKASAN DESA
  /// =========================
  Widget _buildRingkasanDesaHeader() {
    return FutureBuilder<RingkasanDesaModel>(
      future: _ringkasanFuture,
      builder: (context, snapshot) {
        final namaDesa = snapshot.data?.namaDesa;
        final title = (namaDesa != null && namaDesa.isNotEmpty)
            ? 'Ringkasan Desa $namaDesa'
            : 'Ringkasan Desa';

        return _buildSectionTitle(title);
      },
    );
  }

  Widget _buildRingkasanDesaCard() {
    return FutureBuilder<RingkasanDesaModel>(
      future: _ringkasanFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Gagal memuat ringkasan desa.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _reloadRingkasan,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data ?? RingkasanDesaModel.empty();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Ibu Hamil',
                    '${data.ibuHamil.total}',
                    Colors.pink,
                  ),
                  _buildSummaryItem(
                    'Anak',
                    '${data.jumlahAnak}',
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Perlu Tindak',
                    '${data.perluTindakLanjut}',
                    Colors.red,
                  ),
                ],
              ),
              if (data.ibuHamil.total > 0) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Text(
                  'Ibu hamil per trimester',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrimesterChip('Trimester 1', data.ibuHamil.trimester1),
                    _buildTrimesterChip('Trimester 2', data.ibuHamil.trimester2),
                    _buildTrimesterChip('Trimester 3', data.ibuHamil.trimester3),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrimesterChip(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// =========================
  /// ESCALATION CARD
  /// =========================
  Widget _buildEscalationCard({
    required String title,
    required bool isWarning,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final statusColor = isWarning ? Colors.red : Colors.green;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: statusColor, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk lihat detail',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}