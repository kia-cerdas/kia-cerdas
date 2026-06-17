// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/pemeriksaan_kehamilan_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemeriksaan_kehamilan_model.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// class PemeriksaanKehamilanScreen extends StatefulWidget {
//   final int trimester;

//   const PemeriksaanKehamilanScreen({
//     super.key,
//     required this.trimester,
//   });

//   @override
//   State<PemeriksaanKehamilanScreen> createState() =>
//       _PemeriksaanKehamilanScreenState();
// }

// class _PemeriksaanKehamilanScreenState
//     extends State<PemeriksaanKehamilanScreen> {
//   final _service = PemeriksaanKehamilanApiService();
//   late Future<List<PemeriksaanKehamilanModel>> _future;

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

//   String get trimesterTitle {
//     if (widget.trimester == 1) return "Trimester I";
//     if (widget.trimester == 2) return "Trimester II";
//     return "Trimester III";
//   }

//   bool _isSameTrimester(String value) {
//     final v = value.toLowerCase().trim();

//     if (widget.trimester == 1) {
//       return v == 't1' ||
//           v == '1' ||
//           v == 'i' ||
//           v.contains('trimester i');
//     }

//     if (widget.trimester == 2) {
//       return v == 't2' ||
//           v == '2' ||
//           v == 'ii' ||
//           v.contains('trimester ii');
//     }

//     return v == 't3' ||
//         v == '3' ||
//         v == 'iii' ||
//         v.contains('trimester iii');
//   }

//   String _formatDate(String? value) {
//     if (value == null || value.isEmpty) return '-';
//     final date = DateTime.tryParse(value);
//     if (date == null) return '-';

//     final months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
//       'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   String _valueWithUnit(num? value, String unit) {
//     if (value == null) return '-';
//     return '${value.toString()} $unit';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: AppBar(
//         title: Text("Pemeriksaan Kehamilan $trimesterTitle"),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: FutureBuilder<List<PemeriksaanKehamilanModel>>(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return _EmptyState(
//               title: "Gagal memuat data",
//               message: snapshot.error.toString().replaceFirst('Exception: ', ''),
//             );
//           }

//           final allData = snapshot.data ?? [];
//           final filtered = allData
//               .where((item) => _isSameTrimester(item.trimester))
//               .toList();

//           return ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               _HeaderCard(trimesterTitle: trimesterTitle),
//               const SizedBox(height: 16),

//               if (filtered.isEmpty)
//                 const _EmptyState(
//                   title: "Data belum tersedia",
//                   message:
//                       "Belum ada data pemeriksaan kehamilan untuk trimester ini.",
//                 )
//               else
//                 ...filtered.map(
//                   (item) => _PemeriksaanCard(
//                     item: item,
//                     tanggal: _formatDate(item.tanggalPeriksa),
//                     beratBadan: _valueWithUnit(item.beratBadan, 'kg'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               PemeriksaanKehamilanDetailScreen(item: item),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _HeaderCard extends StatelessWidget {
//   final String trimesterTitle;

//   const _HeaderCard({
//     required this.trimesterTitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.18),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.pregnant_woman_outlined,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Catatan ANC",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Pemeriksaan Kehamilan $trimesterTitle",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PemeriksaanCard extends StatelessWidget {
//   final PemeriksaanKehamilanModel item;
//   final String tanggal;
//   final String beratBadan;
//   final VoidCallback onTap;

//   const _PemeriksaanCard({
//     required this.item,
//     required this.tanggal,
//     required this.beratBadan,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final tempat = item.tempatPeriksa.trim().isEmpty ? '-' : item.tempatPeriksa;
//     final tekanan =
//         item.tekananDarah.trim().isEmpty ? '-' : item.tekananDarah;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
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
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFEAF4FF),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.assignment_outlined,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Kunjungan ke-${item.kunjunganKe}",
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w800,
//                           color: Color(0xFF172033),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         tanggal,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF7B8798),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: [
//                           _MiniBadge(label: tempat),
//                           _MiniBadge(label: "TD $tekanan"),
//                           _MiniBadge(label: beratBadan),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
                      
//                       Row(
//                         children: const [
//                           Icon(Icons.ads_click_rounded, size: 14, color: AppColors.primary),
//                           SizedBox(width: 4),
//                           Text(
//                             'Tap untuk lihat hasil evaluasimu',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(
//                   Icons.chevron_right,
//                   color: Color(0xFF9AA3AF),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PemeriksaanKehamilanDetailScreen extends StatelessWidget {
//   final PemeriksaanKehamilanModel item;

//   const PemeriksaanKehamilanDetailScreen({
//     super.key,
//     required this.item,
//   });

//   String _safe(String value) => value.trim().isEmpty ? '-' : value;

//   String _num(num? value, String unit) {
//     if (value == null) return '-';
//     return '${value.toString()} $unit';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: AppBar(
//         title: Text("Kunjungan ke-${item.kunjunganKe}"),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           _InfoCard(
//             title: "Pemeriksaan Fisik",
//             icon: Icons.monitor_heart_outlined,
//             children: [
//               _InfoRow("Berat badan", _num(item.beratBadan, "kg")),
//               _InfoRow("Tinggi badan", _num(item.tinggiBadan, "cm")),
//               _InfoRow("LILA", _num(item.lingkarLenganAtas, "cm")),
//               _InfoRow("Tekanan darah", _safe(item.tekananDarah)),
//               _InfoRow("Tinggi rahim", _num(item.tinggiRahim, "cm")),
//               _InfoRow(
//                 "Letak DJJ",
//                 _safe(item.letakDenyutJantungBayi),
//               ),
//             ],
//           ),
//           _InfoCard(
//             title: "Pelayanan",
//             icon: Icons.medical_services_outlined,
//             children: [
//               _InfoRow(
//                 "Imunisasi tetanus",
//                 _safe(item.statusImunisasiTetanus),
//               ),
//               _InfoRow("Konseling", _safe(item.konseling)),
//               _InfoRow("Skrining dokter", _safe(item.skriningDokter)),
//               _InfoRow(
//                 "Tablet tambah darah",
//                 item.tabletTambahDarah == null
//                     ? '-'
//                     : '${item.tabletTambahDarah} tablet',
//               ),
//             ],
//           ),
//           _InfoCard(
//             title: "Laboratorium",
//             icon: Icons.science_outlined,
//             children: [
//               _InfoRow("Hb", _num(item.tesLabHb, "g/dL")),
//               _InfoRow("Golongan darah", _safe(item.tesGolonganDarah)),
//               _InfoRow("Protein urine", _safe(item.tesLabProteinUrine)),
//               _InfoRow(
//                 "Gula darah",
//                 item.tesLabGulaDarah == null
//                     ? '-'
//                     : '${item.tesLabGulaDarah} mg/dL',
//               ),
//             ],
//           ),
//           _InfoCard(
//             title: "Pemeriksaan Lanjutan",
//             icon: Icons.assignment_outlined,
//             children: [
//               _InfoRow("USG", _safe(item.usg)),
//               _InfoRow("Tripel eliminasi", _safe(item.tripelEliminasi)),
//               _InfoRow("Tata laksana kasus", _safe(item.tataLaksanaKasus)),
//             ],
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

// class _MiniBadge extends StatelessWidget {
//   final String label;

//   const _MiniBadge({
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final safeLabel = label.trim().isEmpty ? '-' : label;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF1F6FD),
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         safeLabel,
//         style: const TextStyle(
//           fontSize: 11,
//           color: AppColors.primary,
//           fontWeight: FontWeight.w700,
//          ),
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
//     return Container(
//       margin: const EdgeInsets.only(top: 20),
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.assignment_outlined,
//             size: 54,
//             color: AppColors.primary,
//           ),
//           const SizedBox(height: 14),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF172033),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF7B8798),
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/pemeriksaan_kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemeriksaan_kehamilan_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class PemeriksaanKehamilanScreen extends StatefulWidget {
  final int trimester;

  const PemeriksaanKehamilanScreen({
    super.key,
    required this.trimester,
  });

  @override
  State<PemeriksaanKehamilanScreen> createState() =>
      _PemeriksaanKehamilanScreenState();
}

class _PemeriksaanKehamilanScreenState
    extends State<PemeriksaanKehamilanScreen> {
  final _service = PemeriksaanKehamilanApiService();
  late Future<List<PemeriksaanKehamilanModel>> _future;

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

  String get trimesterTitle {
    if (widget.trimester == 1) return "Trimester I";
    if (widget.trimester == 2) return "Trimester II";
    return "Trimester III";
  }

  bool _isSameTrimester(String value) {
    final v = value.toLowerCase().trim();
    if (widget.trimester == 1) {
      return v == 't1' || v == '1' || v == 'i' || v.contains('trimester i');
    }
    if (widget.trimester == 2) {
      return v == 't2' || v == '2' || v == 'ii' || v.contains('trimester ii');
    }
    return v == 't3' || v == '3' || v == 'iii' || v.contains('trimester iii');
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final date = DateTime.tryParse(value);
    if (date == null) return '-';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _valueWithUnit(num? value, String unit) {
    if (value == null) return '-';
    return '${value.toString()} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text("Pemeriksaan Kehamilan $trimesterTitle"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<PemeriksaanKehamilanModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EmptyState(
              title: "Gagal memuat data",
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          final allData = snapshot.data ?? [];
          final filtered = allData
              .where((item) => _isSameTrimester(item.trimester))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderCard(trimesterTitle: trimesterTitle),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                const _EmptyState(
                  title: "Data belum tersedia",
                  message:
                      "Belum ada data pemeriksaan kehamilan untuk trimester ini.",
                )
              else
                ...filtered.map(
                  (item) => _PemeriksaanCard(
                    item: item,
                    tanggal: _formatDate(item.tanggalPeriksa),
                    beratBadan: _valueWithUnit(item.beratBadan, 'kg'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PemeriksaanKehamilanDetailScreen(item: item),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header Card
// ─────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final String trimesterTitle;

  const _HeaderCard({required this.trimesterTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pregnant_woman_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Catatan ANC",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pemeriksaan Kehamilan $trimesterTitle",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// List Card (tiap kunjungan)
// ─────────────────────────────────────────────
class _PemeriksaanCard extends StatelessWidget {
  final PemeriksaanKehamilanModel item;
  final String tanggal;
  final String beratBadan;
  final VoidCallback onTap;

  const _PemeriksaanCard({
    required this.item,
    required this.tanggal,
    required this.beratBadan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tempat = item.tempatPeriksa.trim().isEmpty ? '-' : item.tempatPeriksa;
    final tekanan = item.tekananDarah.trim().isEmpty ? '-' : item.tekananDarah;

    // Warna badge risiko
    final risikoColor = _risikoColor(item.statusRisiko);
    final hasRisiko = item.statusRisiko.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kunjungan ke-${item.kunjunganKe}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggal,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7B8798),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniBadge(label: tempat),
                          _MiniBadge(label: "TD $tekanan"),
                          _MiniBadge(label: beratBadan),
                        ],
                      ),

                      // ✅ Badge Skor & Status Risiko AI
                      if (hasRisiko) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: risikoColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: risikoColor.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.psychology_outlined,
                                      size: 13, color: risikoColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Risiko AI: ${item.statusRisiko}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: risikoColor,
                                    ),
                                  ),
                                  if (item.skorRisiko > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: risikoColor,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        "${item.skorRisiko}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.ads_click_rounded,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Tap untuk lihat detail pemeriksaan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9AA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _risikoColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('tinggi') || s.contains('high')) return AppColors.danger;
    if (s.contains('sedang') || s.contains('medium')) return AppColors.warning;
    if (s.contains('rendah') || s.contains('low')) return AppColors.success;
    return AppColors.primary;
  }
}

// ─────────────────────────────────────────────
// Detail Screen
// ─────────────────────────────────────────────
class PemeriksaanKehamilanDetailScreen extends StatelessWidget {
  final PemeriksaanKehamilanModel item;

  const PemeriksaanKehamilanDetailScreen({
    super.key,
    required this.item,
  });

  String _safe(String value) => value.trim().isEmpty ? '-' : value;

  String _num(num? value, String unit) {
    if (value == null) return '-';
    return '${value.toString()} $unit';
  }

  Color _risikoColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('tinggi') || s.contains('high')) return AppColors.danger;
    if (s.contains('sedang') || s.contains('medium')) return AppColors.warning;
    if (s.contains('rendah') || s.contains('low')) return AppColors.success;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final hasRisiko = item.statusRisiko.trim().isNotEmpty;
    final risikoColor = _risikoColor(item.statusRisiko);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text("Kunjungan ke-${item.kunjunganKe}"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ✅ Card Skor Risiko AI — ditampilkan paling atas agar menonjol
          if (hasRisiko)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    risikoColor.withOpacity(0.12),
                    risikoColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: risikoColor.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: risikoColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.psychology_outlined,
                              color: risikoColor, size: 21),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Evaluasi Risiko (AI)",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172033),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Skor + Status in a row
                    Row(
                      children: [
                        // Skor Risiko
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Skor Risiko",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7B8798),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${item.skorRisiko}",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: risikoColor,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      "poin",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: risikoColor.withOpacity(0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Status Risiko
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: risikoColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.statusRisiko,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Detail Risiko
                    if (item.detailRisiko.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      const Text(
                        "Detail Evaluasi",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B8798),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.detailRisiko,
                        style: TextStyle(
                          fontSize: 13,
                          color: risikoColor.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Card Pemeriksaan Fisik
          _InfoCard(
            title: "Pemeriksaan Fisik",
            icon: Icons.monitor_heart_outlined,
            children: [
              _InfoRow("Berat badan", _num(item.beratBadan, "kg")),
              _InfoRow("Tinggi badan", _num(item.tinggiBadan, "cm")),
              _InfoRow("LILA", _num(item.lingkarLenganAtas, "cm")),
              _InfoRow("Tekanan darah", _safe(item.tekananDarah)),
              _InfoRow("Tinggi rahim", _num(item.tinggiRahim, "cm")),
              _InfoRow("Letak DJJ", _safe(item.letakDenyutJantungBayi)),
            ],
          ),

          // Card Pelayanan
          _InfoCard(
            title: "Pelayanan",
            icon: Icons.medical_services_outlined,
            children: [
              _InfoRow("Imunisasi tetanus", _safe(item.statusImunisasiTetanus)),
              _InfoRow("Konseling", _safe(item.konseling)),
              _InfoRow("Skrining dokter", _safe(item.skriningDokter)),
              _InfoRow(
                "Tablet tambah darah",
                item.tabletTambahDarah == null
                    ? '-'
                    : '${item.tabletTambahDarah} tablet',
              ),
            ],
          ),

          // Card Laboratorium
          _InfoCard(
            title: "Laboratorium",
            icon: Icons.science_outlined,
            children: [
              _InfoRow("Hb", _num(item.tesLabHb, "g/dL")),
              _InfoRow("Golongan darah", _safe(item.tesGolonganDarah)),
              _InfoRow("Protein urine", _safe(item.tesLabProteinUrine)),
              _InfoRow(
                "Gula darah",
                item.tesLabGulaDarah == null
                    ? '-'
                    : '${item.tesLabGulaDarah} mg/dL',
              ),
            ],
          ),

          // Card Pemeriksaan Lanjutan
          _InfoCard(
            title: "Pemeriksaan Lanjutan",
            icon: Icons.assignment_outlined,
            children: [
              _InfoRow("USG", _safe(item.usg)),
              _InfoRow("Tripel eliminasi", _safe(item.tripelEliminasi)),
              _InfoRow("Tata laksana kasus", _safe(item.tataLaksanaKasus)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────
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

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final safeLabel = label.trim().isEmpty ? '-' : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        safeLabel,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
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
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
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
    );
  }
}