// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/evaluasi_kesehatan_ibu_model.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/evaluasi_kesehatan_ibu_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/presentation/ibu/konten_edukasi_ibu_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HasilEvaluasiKesehatanScreen extends StatefulWidget {
//   const HasilEvaluasiKesehatanScreen({super.key});

//   @override
//   State<HasilEvaluasiKesehatanScreen> createState() =>
//       _HasilEvaluasiKesehatanScreenState();
// }

// class _HasilEvaluasiKesehatanScreenState
//     extends State<HasilEvaluasiKesehatanScreen> {
//   final _service = EvaluasiKesehatanIbuApiService();
//   late Future<EvaluasiKesehatanIbuModel> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = _service.getMine();
//   }

//   @override
//   void dispose() {
//     _service.dispose();
//     super.dispose();
//   }

//   String _formatDate(String? value) {
//     if (value == null || value.isEmpty) return '-';

//     final date = DateTime.tryParse(value);
//     if (date == null) return '-';

//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'Mei',
//       'Jun',
//       'Jul',
//       'Agt',
//       'Sep',
//       'Okt',
//       'Nov',
//       'Des',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   // =====================================
//   // KONFIRMASI HUBUNGI BIDAN
//   // =====================================

//   Future<void> _hubungiBidan() async {
//     const String namaBidan = "Bidan Desa";
//     const String nomorBidan = "0812-6482-593";

//     final result = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return Container(
//           padding: const EdgeInsets.all(22),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(28),
//               topRight: Radius.circular(28),
//             ),
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [

//                   // HANDLE
//                   Container(
//                     width: 46,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   // ICON
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.support_agent,
//                       color: Colors.green.shade600,
//                       size: 36,
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   const Text(
//                     "Hubungi Bidan",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     "Ibu akan dihubungkan ke $namaBidan untuk mendapatkan bantuan dan arahan lebih lanjut.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 13.5,
//                       color: Colors.grey.shade700,
//                       height: 1.5,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   Text(
//                     nomorBidan,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // WHATSAPP
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green.shade600,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context, "wa");
//                       },
//                       icon: const Icon(Icons.chat),
//                       label: const Text(
//                         "Chat via WhatsApp",
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // TELEPON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppColors.primary,
//                         side: BorderSide(color: AppColors.primary),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context, "call");
//                       },
//                       icon: const Icon(Icons.call_outlined),
//                       label: const Text(
//                         "Telepon Bidan",
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: TextButton(
//                       style: TextButton.styleFrom(
//                         backgroundColor: Colors.blueGrey.shade50,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         "Batal",
//                         style: TextStyle(
//                           color: Colors.blueGrey.shade500,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     // =====================================
//     // AKSI SETELAH PILIH
//     // =====================================

//     if (result == "wa") {
//       final Uri url = Uri.parse('https://wa.me/6281264825931');
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }

//     if (result == "call") {
//       final Uri url = Uri(scheme: 'tel', path: '081264825931');
//       await launchUrl(url);
//     }
//   }

//   void _pelajariLebihLanjut() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const KontenEdukasiIbuScreen(),
//       ),
//     );
//   }

//   _RiskResult _hitungRisiko(EvaluasiKesehatanIbuModel data) {
//     int skor = 0;
//     final List<String> alasan = [];

//     final imt = data.imtKategori.toLowerCase();
//     if (imt.contains('kurus') ||
//         imt.contains('gemuk') ||
//         imt.contains('obesitas') ||
//         imt.contains('tidak normal')) {
//       skor += 2;
//       alasan.add('Kategori IMT tidak normal');
//     }

//     final lila = data.lilaCm;
//     if (lila != null && lila < 23.5) {
//       skor += 3;
//       alasan.add('LILA kurang dari 23,5 cm');
//     }

//     final riwayatKesehatan = data.riwayatKesehatanText.toLowerCase().trim();
//     if (riwayatKesehatan.isNotEmpty &&
//         riwayatKesehatan != '-' &&
//         riwayatKesehatan != 'tidak ada' &&
//         riwayatKesehatan != 'normal') {
//       skor += 3;
//       alasan.add('Memiliki riwayat kesehatan tertentu');
//     }

//     final perilakuBerisiko = data.perilakuBerisikoText.toLowerCase().trim();
//     if (perilakuBerisiko.isNotEmpty &&
//         perilakuBerisiko != '-' &&
//         perilakuBerisiko != 'tidak ada' &&
//         perilakuBerisiko != 'normal') {
//       skor += 2;
//       alasan.add('Terdapat perilaku berisiko');
//     }

//     final riwayatKeluarga = data.riwayatKeluargaText.toLowerCase().trim();
//     if (riwayatKeluarga.isNotEmpty &&
//         riwayatKeluarga != '-' &&
//         riwayatKeluarga != 'tidak ada' &&
//         riwayatKeluarga != 'normal') {
//       skor += 2;
//       alasan.add('Memiliki riwayat penyakit keluarga');
//     }

//     final inspeksiGabungan = [
//       data.inspeksiPorsio,
//       data.inspeksiUretra,
//       data.inspeksiVagina,
//       data.inspeksiVulva,
//       data.inspeksiFluksus,
//       data.inspeksiFluor,
//     ].join(' ').toLowerCase();

//     if (inspeksiGabungan.contains('tidak normal') ||
//         inspeksiGabungan.contains('abnormal') ||
//         inspeksiGabungan.contains('infeksi') ||
//         inspeksiGabungan.contains('kelainan') ||
//         inspeksiGabungan.contains('nyeri') ||
//         inspeksiGabungan.contains('keputihan') ||
//         inspeksiGabungan.contains('berbau') ||
//         inspeksiGabungan.contains('luka')) {
//       skor += 3;
//       alasan.add('Ditemukan indikasi tidak normal pada hasil inspeksi');
//     }

//     if (skor >= 7) {
//       return _RiskResult(
//         title: 'Risiko Tinggi',
//         description:
//             'Ibu memiliki beberapa faktor risiko. Disarankan segera melakukan konsultasi lanjutan ke tenaga kesehatan.',
//         color: const Color(0xFFE53935),
//         icon: Icons.error_outline,
//         reasons: alasan,
//       );
//     } else if (skor >= 3) {
//       return _RiskResult(
//         title: 'Risiko Sedang',
//         description:
//             'Terdapat beberapa faktor yang perlu diperhatikan. Tetap lakukan pemantauan dan pemeriksaan rutin.',
//         color: const Color(0xFFFFA000),
//         icon: Icons.warning_amber_rounded,
//         reasons: alasan,
//       );
//     } else {
//       return _RiskResult(
//         title: 'Risiko Rendah',
//         description:
//             'Belum ditemukan faktor risiko utama berdasarkan data evaluasi yang tersedia.',
//         color: const Color(0xFF2E7D32),
//         icon: Icons.check_circle_outline,
//         reasons: alasan.isEmpty
//             ? ['Tidak ada faktor risiko yang menonjol']
//             : alasan,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: AppBar(
//         title: const Text("Hasil Evaluasi Kesehatan"),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: FutureBuilder<EvaluasiKesehatanIbuModel>(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return _EmptyState(
//               title: "Data evaluasi belum tersedia",
//               message: snapshot.error.toString().replaceFirst('Exception: ', ''),
//             );
//           }

//           final data = snapshot.data;

//           if (data == null) {
//             return const _EmptyState(
//               title: "Data evaluasi belum tersedia",
//               message: "Silakan lakukan pemeriksaan ke tenaga kesehatan.",
//             );
//           }

//           final risiko = _hitungRisiko(data);

//           return ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               _HeaderCard(
//                 data: data,
//                 formatDate: _formatDate,
//               ),

//               const SizedBox(height: 16),

//               _RiskCard(result: risiko),

//               const SizedBox(height: 16),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _hubungiBidan,
//                   icon: const Icon(Icons.phone),
//                   label: const Text("Hubungi Bidan Sekarang"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: _pelajariLebihLanjut,
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.primary,
//                     side: BorderSide(
//                       color: AppColors.primary,
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: const Text(
//                     "Pelajari Lebih Lanjut",
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               _InfoCard(
//                 title: "Antropometri",
//                 icon: Icons.monitor_weight_outlined,
//                 children: [
//                   _InfoRow(
//                     "Tinggi badan",
//                     "${data.tbCm ?? '-'} cm",
//                   ),
//                   _InfoRow(
//                     "Berat badan",
//                     "${data.bbKg ?? '-'} kg",
//                   ),
//                   _InfoRow(
//                     "IMT",
//                     data.imtKategori,
//                   ),
//                   _InfoRow(
//                     "LILA",
//                     "${data.lilaCm ?? '-'} cm",
//                   ),
//                 ],
//               ),

//               _InfoCard(
//                 title: "Imunisasi TT",
//                 icon: Icons.verified_user_outlined,
//                 children: [
//                   _InfoRow(
//                     "Status TT",
//                     data.statusTTText,
//                   ),
//                   if (data.imunisasiLainnyaCovid19.isNotEmpty)
//                     _InfoRow(
//                       "Imunisasi lainnya",
//                       data.imunisasiLainnyaCovid19,
//                     ),
//                 ],
//               ),

//               _InfoCard(
//                 title: "Riwayat Kesehatan",
//                 icon: Icons.medical_information_outlined,
//                 children: [
//                   _InfoRow(
//                     "Riwayat",
//                     data.riwayatKesehatanText,
//                   ),
//                 ],
//               ),

//               _InfoCard(
//                 title: "Perilaku Berisiko",
//                 icon: Icons.warning_amber_rounded,
//                 children: [
//                   _InfoRow(
//                     "Perilaku",
//                     data.perilakuBerisikoText,
//                   ),
//                 ],
//               ),

//               _InfoCard(
//                 title: "Riwayat Keluarga",
//                 icon: Icons.family_restroom_outlined,
//                 children: [
//                   _InfoRow(
//                     "Riwayat",
//                     data.riwayatKeluargaText,
//                   ),
//                 ],
//               ),

//               _InfoCard(
//                 title: "Inspeksi",
//                 icon: Icons.assignment_outlined,
//                 children: [
//                   _InfoRow("Porsio", data.inspeksiPorsio),
//                   _InfoRow("Uretra", data.inspeksiUretra),
//                   _InfoRow("Vagina", data.inspeksiVagina),
//                   _InfoRow("Vulva", data.inspeksiVulva),
//                   _InfoRow("Fluksus", data.inspeksiFluksus),
//                   _InfoRow("Fluor", data.inspeksiFluor),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _RiskResult {
//   final String title;
//   final String description;
//   final Color color;
//   final IconData icon;
//   final List<String> reasons;

//   const _RiskResult({
//     required this.title,
//     required this.description,
//     required this.color,
//     required this.icon,
//     required this.reasons,
//   });
// }

// class _RiskCard extends StatelessWidget {
//   final _RiskResult result;

//   const _RiskCard({
//     required this.result,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: result.color.withOpacity(0.25)),
//         boxShadow: [
//           BoxShadow(
//             color: result.color.withOpacity(0.08),
//             blurRadius: 14,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 46,
//                 height: 46,
//                 decoration: BoxDecoration(
//                   color: result.color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(
//                   result.icon,
//                   color: result.color,
//                   size: 26,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Hasil Risiko Kesehatan",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF7B8798),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       result.title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: result.color,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Text(
//             result.description,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF4B5563),
//               height: 1.45,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             "Dasar penilaian:",
//             style: TextStyle(
//               fontSize: 13,
//               color: Color(0xFF172033),
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ...result.reasons.map(
//             (item) => Padding(
//               padding: const EdgeInsets.only(bottom: 6),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.circle,
//                     size: 7,
//                     color: result.color,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       item,
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         color: Color(0xFF4B5563),
//                         height: 1.35,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderCard extends StatelessWidget {
//   final EvaluasiKesehatanIbuModel data;
//   final String Function(String?) formatDate;

//   const _HeaderCard({
//     required this.data,
//     required this.formatDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Evaluasi Kesehatan Ibu",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 14),
//           _HeaderRow("Tanggal Periksa", formatDate(data.tanggalPeriksa)),
//           _HeaderRow("Dokter", data.namaDokter),
//           _HeaderRow("Fasilitas", data.fasilitasKesehatan),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _HeaderRow(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 7),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isEmpty ? '-' : value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final List<Widget> children;

//   const _InfoCard({
//     required this.title,
//     required this.icon,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFE5ECF6)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEAF4FF),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: AppColors.primary, size: 21),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF172033),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InfoRow(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     final safeValue = value.trim().isEmpty ? '-' : value;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Color(0xFF7B8798),
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               safeValue,
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 color: Color(0xFF172033),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final String title;
//   final String message;

//   const _EmptyState({
//     required this.title,
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.assignment_outlined,
//                 size: 60,
//                 color: Color(0xFF2F80ED),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF172033),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Color(0xFF7B8798),
//                   height: 1.4,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/evaluasi_kesehatan_ibu_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/evaluasi_kesehatan_ibu_api_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/presentation/ibu/konten_edukasi_ibu_screen.dart';

class HasilEvaluasiKesehatanScreen extends StatefulWidget {
  const HasilEvaluasiKesehatanScreen({super.key});

  @override
  State<HasilEvaluasiKesehatanScreen> createState() =>
      _HasilEvaluasiKesehatanScreenState();
}

class _HasilEvaluasiKesehatanScreenState
    extends State<HasilEvaluasiKesehatanScreen> {
  final _service = EvaluasiKesehatanIbuApiService();
  late Future<EvaluasiKesehatanIbuModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMine();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return '-';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _pelajariLebihLanjut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KontenEdukasiIbuScreen(),
      ),
    );
  }

  _RiskResult _hitungRisiko(EvaluasiKesehatanIbuModel data) {
    int skor = 0;
    final List<String> alasan = [];

    final imt = data.imtKategori.toLowerCase();
    if (imt.contains('kurus') ||
        imt.contains('gemuk') ||
        imt.contains('obesitas') ||
        imt.contains('tidak normal')) {
      skor += 2;
      alasan.add('Kategori IMT tidak normal');
    }

    final lila = data.lilaCm;
    if (lila != null && lila < 23.5) {
      skor += 3;
      alasan.add('LILA kurang dari 23,5 cm');
    }

    final riwayatKesehatan = data.riwayatKesehatanText.toLowerCase().trim();
    if (riwayatKesehatan.isNotEmpty &&
        riwayatKesehatan != '-' &&
        riwayatKesehatan != 'tidak ada' &&
        riwayatKesehatan != 'normal') {
      skor += 3;
      alasan.add('Memiliki riwayat kesehatan tertentu');
    }

    final perilakuBerisiko = data.perilakuBerisikoText.toLowerCase().trim();
    if (perilakuBerisiko.isNotEmpty &&
        perilakuBerisiko != '-' &&
        perilakuBerisiko != 'tidak ada' &&
        perilakuBerisiko != 'normal') {
      skor += 2;
      alasan.add('Terdapat perilaku berisiko');
    }

    final riwayatKeluarga = data.riwayatKeluargaText.toLowerCase().trim();
    if (riwayatKeluarga.isNotEmpty &&
        riwayatKeluarga != '-' &&
        riwayatKeluarga != 'tidak ada' &&
        riwayatKeluarga != 'normal') {
      skor += 2;
      alasan.add('Memiliki riwayat penyakit keluarga');
    }

    final inspeksiGabungan = [
      data.inspeksiPorsio,
      data.inspeksiUretra,
      data.inspeksiVagina,
      data.inspeksiVulva,
      data.inspeksiFluksus,
      data.inspeksiFluor,
    ].join(' ').toLowerCase();

    if (inspeksiGabungan.contains('tidak normal') ||
        inspeksiGabungan.contains('abnormal') ||
        inspeksiGabungan.contains('infeksi') ||
        inspeksiGabungan.contains('kelainan') ||
        inspeksiGabungan.contains('nyeri') ||
        inspeksiGabungan.contains('keputihan') ||
        inspeksiGabungan.contains('berbau') ||
        inspeksiGabungan.contains('luka')) {
      skor += 3;
      alasan.add('Ditemukan indikasi tidak normal pada hasil inspeksi');
    }

    if (skor >= 7) {
      return _RiskResult(
        title: 'Risiko Tinggi',
        description:
            'Ibu memiliki beberapa faktor risiko. Disarankan segera melakukan konsultasi lanjutan ke tenaga kesehatan.',
        color: const Color(0xFFE53935),
        icon: Icons.error_outline,
        reasons: alasan,
      );
    } else if (skor >= 3) {
      return _RiskResult(
        title: 'Risiko Sedang',
        description:
            'Terdapat beberapa faktor yang perlu diperhatikan. Tetap lakukan pemantauan dan pemeriksaan rutin.',
        color: const Color(0xFFFFA000),
        icon: Icons.warning_amber_rounded,
        reasons: alasan,
      );
    } else {
      return _RiskResult(
        title: 'Risiko Rendah',
        description:
            'Belum ditemukan faktor risiko utama berdasarkan data evaluasi yang tersedia.',
        color: const Color(0xFF2E7D32),
        icon: Icons.check_circle_outline,
        reasons: alasan.isEmpty
            ? ['Tidak ada faktor risiko yang menonjol']
            : alasan,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Hasil Evaluasi Kesehatan"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<EvaluasiKesehatanIbuModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _EmptyState(
              title: "Data evaluasi belum tersedia",
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const _EmptyState(
              title: "Data evaluasi belum tersedia",
              message: "Silakan lakukan pemeriksaan ke tenaga kesehatan.",
            );
          }

          final risiko = _hitungRisiko(data);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderCard(
                data: data,
                formatDate: _formatDate,
              ),

              const SizedBox(height: 16),

              _RiskCard(result: risiko),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _pelajariLebihLanjut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Pelajari Lebih Lanjut",
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: "Antropometri",
                icon: Icons.monitor_weight_outlined,
                children: [
                  _InfoRow(
                    "Tinggi badan",
                    "${data.tbCm ?? '-'} cm",
                  ),
                  _InfoRow(
                    "Berat badan",
                    "${data.bbKg ?? '-'} kg",
                  ),
                  _InfoRow(
                    "IMT",
                    data.imtKategori,
                  ),
                  _InfoRow(
                    "LILA",
                    "${data.lilaCm ?? '-'} cm",
                  ),
                ],
              ),

              _InfoCard(
                title: "Imunisasi TT",
                icon: Icons.verified_user_outlined,
                children: [
                  _InfoRow(
                    "Status TT",
                    data.statusTTText,
                  ),
                  if (data.imunisasiLainnyaCovid19.isNotEmpty)
                    _InfoRow(
                      "Imunisasi lainnya",
                      data.imunisasiLainnyaCovid19,
                    ),
                ],
              ),

              _InfoCard(
                title: "Riwayat Kesehatan",
                icon: Icons.medical_information_outlined,
                children: [
                  _InfoRow(
                    "Riwayat",
                    data.riwayatKesehatanText,
                  ),
                ],
              ),

              _InfoCard(
                title: "Perilaku Berisiko",
                icon: Icons.warning_amber_rounded,
                children: [
                  _InfoRow(
                    "Perilaku",
                    data.perilakuBerisikoText,
                  ),
                ],
              ),

              _InfoCard(
                title: "Riwayat Keluarga",
                icon: Icons.family_restroom_outlined,
                children: [
                  _InfoRow(
                    "Riwayat",
                    data.riwayatKeluargaText,
                  ),
                ],
              ),

              _InfoCard(
                title: "Inspeksi",
                icon: Icons.assignment_outlined,
                children: [
                  _InfoRow("Porsio", data.inspeksiPorsio),
                  _InfoRow("Uretra", data.inspeksiUretra),
                  _InfoRow("Vagina", data.inspeksiVagina),
                  _InfoRow("Vulva", data.inspeksiVulva),
                  _InfoRow("Fluksus", data.inspeksiFluksus),
                  _InfoRow("Fluor", data.inspeksiFluor),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RiskResult {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<String> reasons;

  const _RiskResult({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.reasons,
  });
}

class _RiskCard extends StatelessWidget {
  final _RiskResult result;

  const _RiskCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: result.color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: result.color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: result.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  result.icon,
                  color: result.color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hasil Risiko Kesehatan",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B8798),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.title,
                      style: TextStyle(
                        fontSize: 18,
                        color: result.color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Dasar penilaian:",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF172033),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...result.reasons.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 7,
                    color: result.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final EvaluasiKesehatanIbuModel data;
  final String Function(String?) formatDate;

  const _HeaderCard({
    required this.data,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Evaluasi Kesehatan Ibu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _HeaderRow("Tanggal Periksa", formatDate(data.tanggalPeriksa)),
          _HeaderRow("Dokter", data.namaDokter),
          _HeaderRow("Fasilitas", data.fasilitasKesehatan),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5ECF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? '-' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7B8798),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              safeValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 60,
                color: Color(0xFF2F80ED),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B8798),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}