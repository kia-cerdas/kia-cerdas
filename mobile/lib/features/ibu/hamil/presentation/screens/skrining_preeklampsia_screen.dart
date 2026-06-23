import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/skrining_preeklampsia_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/skrining_preeklampsia_api_service.dart';

class SkriningPreeklampsiaScreen extends StatefulWidget {
  const SkriningPreeklampsiaScreen({super.key});

  @override
  State<SkriningPreeklampsiaScreen> createState() =>
      _SkriningPreeklampsiaScreenState();
}

class _SkriningPreeklampsiaScreenState
    extends State<SkriningPreeklampsiaScreen> {
  final _service = SkriningPreeklampsiaApiService();
  late Future<SkriningPreeklampsiaModel> _future;

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

  List<SkriningAnswerItem> _faktorTerdeteksi(SkriningPreeklampsiaModel data) {
    return [
      ...data.risikoSedangItems,
      ...data.risikoTinggiItems,
      ...data.pemeriksaanFisikItems,
    ].where((item) => item.value).toList();
  }

  _PreeklampsiaGuidance _getGuidance(SkriningPreeklampsiaModel data) {
    final faktor = _faktorTerdeteksi(data);

    if (data.hasRisikoTinggi) {
      return _PreeklampsiaGuidance(
        title: "Risiko Tinggi",
        statusLabel: "Perlu Pemeriksaan Lanjutan",
        actionTitle: "Segera hubungi bidan",
        actionMessage:
            "Hasil skrining menunjukkan ada faktor risiko tinggi preeklampsia. Ibu disarankan segera menghubungi bidan atau datang ke fasilitas kesehatan.",
        reasonTitle: "Mengapa hasilnya berisiko tinggi?",
        reasonMessage:
            faktor.isEmpty
                ? "Terdapat tanda atau faktor yang mengarah pada risiko tinggi preeklampsia."
                : "Ada faktor risiko penting yang terdeteksi pada hasil skrining ibu.",
        dangerTitle: "Apa bahayanya?",
        dangerMessage:
            "Preeklampsia dapat membahayakan ibu dan janin jika tidak segera diperiksa, seperti tekanan darah tinggi, gangguan organ, kejang, atau gangguan pertumbuhan janin.",
        whatToDoTitle: "Apa yang harus dilakukan?",
        whatToDoMessage:
            "Segera hubungi bidan, lakukan pemeriksaan tekanan darah, dan ikuti arahan tenaga kesehatan.",
        checkTime: "Periksa hari ini atau maksimal dalam 1–3 hari.",
        color: const Color(0xFFE53935),
        backgroundColor: const Color(0xFFFFEBEE),
        icon: Icons.warning_amber_rounded,
        factors: faktor,
      );
    }

    if (data.hasRisikoSedang || data.hasPemeriksaanFisikBermasalah) {
      return _PreeklampsiaGuidance(
        title: "Risiko Sedang",
        statusLabel: "Perlu Dipantau",
        actionTitle: "Konsultasikan hasil ke bidan",
        actionMessage:
            "Hasil skrining menunjukkan ada beberapa faktor yang perlu diperhatikan. Ibu disarankan berkonsultasi dengan bidan.",
        reasonTitle: "Mengapa hasilnya berisiko sedang?",
        reasonMessage:
            faktor.isEmpty
                ? "Ada tanda yang perlu dipantau agar tidak berkembang menjadi kondisi yang lebih serius."
                : "Beberapa faktor risiko ditemukan dan perlu dipantau oleh tenaga kesehatan.",
        dangerTitle: "Apa bahayanya?",
        dangerMessage:
            "Jika tidak dipantau, kondisi ibu bisa memburuk dan berpotensi mengarah pada preeklampsia.",
        whatToDoTitle: "Apa yang harus dilakukan?",
        whatToDoMessage:
            "Konsultasikan hasil ini kepada bidan, lakukan pemeriksaan rutin, dan segera periksa jika muncul keluhan.",
        checkTime: "Periksa dalam 1 minggu atau lebih cepat jika ada keluhan.",
        color: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFFFF8E1),
        icon: Icons.info_outline,
        factors: faktor,
      );
    }

    return _PreeklampsiaGuidance(
      title: "Risiko Rendah",
      statusLabel: "Kondisi Cukup Baik",
      actionTitle: "Tetap pantau kondisi ibu",
      actionMessage:
          "Hasil skrining belum menunjukkan faktor risiko utama. Ibu tetap disarankan melakukan pemeriksaan kehamilan secara rutin.",
      reasonTitle: "Mengapa hasilnya risiko rendah?",
      reasonMessage:
          "Tidak ditemukan faktor risiko utama dari data skrining yang tersedia.",
      dangerTitle: "Apa yang tetap perlu diwaspadai?",
      dangerMessage:
          "Risiko bisa berubah jika muncul keluhan seperti sakit kepala berat, pandangan kabur, bengkak, nyeri ulu hati, atau tekanan darah tinggi.",
      whatToDoTitle: "Apa yang harus dilakukan?",
      whatToDoMessage:
          "Tetap ikuti jadwal pemeriksaan kehamilan dan segera hubungi bidan jika mengalami keluhan.",
      checkTime: "Ikuti jadwal pemeriksaan kehamilan berikutnya.",
      color: const Color(0xFF22C55E),
      backgroundColor: const Color(0xFFE8F5E9),
      icon: Icons.check_circle_outline,
      factors: faktor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SkriningPreeklampsiaModel>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final guidance = data == null ? null : _getGuidance(data);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skrining Preeklampsia',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Deteksi dini risiko preeklampsia pada kehamilan',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey.shade200, height: 1.0),
            ),
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _EmptyState(
                  title: "Data belum tersedia",
                  message:
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                );
              }

              if (data == null || guidance == null) {
                return const _EmptyState(
                  title: "Data belum tersedia",
                  message: "Belum ada data skrining preeklampsia.",
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                children: [
                  _SummaryCard(guidance: guidance),
                  const SizedBox(height: 14),

                  // _ActionGuidanceCard(guidance: guidance),
                  // const SizedBox(height: 14),

                  _ExplanationCard(guidance: guidance),
                  const SizedBox(height: 14),

                  _DetectedFactorsCard(guidance: guidance),
                  const SizedBox(height: 14),

                  _AnswerCard(
                    title: "Faktor Risiko Sedang",
                    icon: Icons.list_alt_outlined,
                    items: data.risikoSedangItems,
                  ),

                  _AnswerCard(
                    title: "Faktor Risiko Tinggi",
                    icon: Icons.warning_amber_rounded,
                    items: data.risikoTinggiItems,
                  ),

                  _AnswerCard(
                    title: "Pemeriksaan Fisik",
                    icon: Icons.monitor_heart_outlined,
                    items: data.pemeriksaanFisikItems,
                  ),

                  const _MedicalNoteCard(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PreeklampsiaGuidance {
  final String title;
  final String statusLabel;
  final String actionTitle;
  final String actionMessage;
  final String reasonTitle;
  final String reasonMessage;
  final String dangerTitle;
  final String dangerMessage;
  final String whatToDoTitle;
  final String whatToDoMessage;
  final String checkTime;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final List<SkriningAnswerItem> factors;

  const _PreeklampsiaGuidance({
    required this.title,
    required this.statusLabel,
    required this.actionTitle,
    required this.actionMessage,
    required this.reasonTitle,
    required this.reasonMessage,
    required this.dangerTitle,
    required this.dangerMessage,
    required this.whatToDoTitle,
    required this.whatToDoMessage,
    required this.checkTime,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.factors,
  });
}

// class _SummaryCard extends StatelessWidget {
//   final _PreeklampsiaGuidance guidance;

//   const _SummaryCard({
//     required this.guidance,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: guidance.color,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: guidance.color.withOpacity(0.22),
//             blurRadius: 14,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               guidance.icon,
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
//                   "Hasil Skrining Preeklampsia",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   guidance.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.18),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Text(
//                     guidance.statusLabel,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w800,
//                     ),
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

class _SummaryCard extends StatelessWidget {
  final _PreeklampsiaGuidance guidance;

  const _SummaryCard({
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hasil Skrining Preeklampsia',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: guidance.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: guidance.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  guidance.icon,
                  color: guidance.color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guidance.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: guidance.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        guidance.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: guidance.color.withOpacity(0.8),
                        ),
                      ),
                    ],
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

class _ActionGuidanceCard extends StatelessWidget {
  final _PreeklampsiaGuidance guidance;

  const _ActionGuidanceCard({
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: guidance.backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: guidance.color.withOpacity(0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: guidance.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.touch_app_outlined,
              color: guidance.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guidance.actionTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: guidance.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  guidance.actionMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _SmallInfoBadge(
                  icon: Icons.schedule_outlined,
                  label: guidance.checkTime,
                  color: guidance.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final _PreeklampsiaGuidance guidance;

  const _ExplanationCard({
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Penjelasan Hasil",
      icon: Icons.info_outline,
      children: [
        _ExplanationItem(
          icon: Icons.help_outline,
          title: guidance.reasonTitle,
          message: guidance.reasonMessage,
          color: guidance.color,
        ),
        const SizedBox(height: 12),
        _ExplanationItem(
          icon: Icons.health_and_safety_outlined,
          title: guidance.dangerTitle,
          message: guidance.dangerMessage,
          color: guidance.color,
        ),
        const SizedBox(height: 12),
        _ExplanationItem(
          icon: Icons.assignment_turned_in_outlined,
          title: guidance.whatToDoTitle,
          message: guidance.whatToDoMessage,
          color: guidance.color,
        ),
      ],
    );
  }
}

class _DetectedFactorsCard extends StatelessWidget {
  final _PreeklampsiaGuidance guidance;

  const _DetectedFactorsCard({
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    final factors = guidance.factors;

    return _SectionCard(
      title: "Faktor Risiko yang Terdeteksi",
      icon: Icons.priority_high_rounded,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5ECF6),
            ),
          ),
          child: const Text(
            "Faktor-faktor ini ditemukan pada hasil skrining ibu. Hubungi bidan untuk penanganan lebih lanjut.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF172033),
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (factors.isEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF22C55E),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Tidak ada faktor risiko utama yang terdeteksi dari data skrining saat ini.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        else
          ...factors.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: guidance.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: guidance.color.withOpacity(0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.priority_high_rounded,
                    color: guidance.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${item.label} — Perlu perhatian khusus",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: guidance.color,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<SkriningAnswerItem> items;

  const _AnswerCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      icon: icon,
      children: [
        if (items.isEmpty)
          const Text(
            "Tidak ada data pada bagian ini.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7B8798),
              fontWeight: FontWeight.w600,
            ),
          )
        else
          ...items.map((item) => _AnswerRow(item: item)),
      ],
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final SkriningAnswerItem item;

  const _AnswerRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        item.value ? const Color(0xFFE53935) : const Color(0xFF22C55E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.value ? Icons.error_outline : Icons.check_circle_outline,
            size: 19,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF172033),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.value ? "Ya" : "Tidak",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalNoteCard extends StatelessWidget {
  const _MedicalNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Hasil ini adalah skrining awal dan bukan diagnosis medis. Silakan konsultasi dengan bidan atau tenaga kesehatan untuk pemeriksaan lanjutan.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExplanationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ExplanationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF172033),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 12.8,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallInfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallInfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
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
        border: Border.all(
          color: const Color(0xFFE5ECF6),
        ),
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
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
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
                Icons.health_and_safety_outlined,
                size: 60,
                color: AppColors.primary,
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