// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/pemeriksaan_kehamilan_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/skrining_preeklampsia_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/pemeriksaan_dokter_screen.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/widgets/index.dart';

// class TrimesterMenuScreen extends StatelessWidget {
//   final int trimester;

//   const TrimesterMenuScreen({
//     super.key,
//     required this.trimester,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: IbuGradientHeader(
//         title: 'Trimester $trimester',
//         subtitle: _subtitleForTrimester(),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           IbuMenuCard(
//             icon: Icons.pregnant_woman_outlined,
//             title: 'Pemeriksaan Kehamilan',
//             subtitle: 'Lihat hasil pemeriksaan ANC trimester $trimester',
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => PemeriksaanKehamilanScreen(trimester: trimester),
//               ),
//             ),
//           ),

//           if (trimester == 1)
//             IbuMenuCard(
//               icon: Icons.medical_information_outlined,
//               title: 'Pemeriksaan Dokter Trimester I',
//               subtitle: 'Lihat hasil pemeriksaan dokter trimester I',
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const PemeriksaanDokterScreen(trimester: 1),
//                 ),
//               ),
//             ),

//           if (trimester == 2)
//             IbuMenuCard(
//               icon: Icons.health_and_safety_outlined,
//               title: 'Skrining Preeklampsia',
//               subtitle: 'Lihat hasil skrining preeklampsia',
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const SkriningPreeklampsiaScreen(),
//                 ),
//               ),
//             ),

//           if (trimester == 3)
//             IbuMenuCard(
//               icon: Icons.medical_services_outlined,
//               title: 'Pemeriksaan Dokter Trimester III',
//               subtitle: 'Lihat hasil pemeriksaan dokter trimester III',
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const PemeriksaanDokterScreen(trimester: 3),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   String _subtitleForTrimester() {
//     if (trimester == 1) return 'Minggu 1 – 12';
//     if (trimester == 2) return 'Minggu 13 – 27';
//     return 'Minggu 28 – 40';
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/pemeriksaan_kehamilan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/skrining_preeklampsia_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/pemeriksaan_dokter_screen.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class TrimesterMenuScreen extends StatelessWidget {
  final int trimester;

  const TrimesterMenuScreen({
    super.key,
    required this.trimester,
  });

  @override
  Widget build(BuildContext context) {
    final title = "Trimester $trimester";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MenuCard(
            icon: Icons.pregnant_woman_outlined,
            title: "Pemeriksaan Kehamilan",
            subtitle: "Lihat hasil pemeriksaan ANC trimester $trimester",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PemeriksaanKehamilanScreen(trimester: trimester),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          if (trimester == 1)
            _MenuCard(
              icon: Icons.medical_information_outlined,
              title: "Pemeriksaan Dokter Trimester I",
              subtitle: "Lihat hasil pemeriksaan dokter trimester I",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PemeriksaanDokterScreen(trimester: 1),
                  ),
                );
              },
            ),

          if (trimester == 2)
            _MenuCard(
              icon: Icons.health_and_safety_outlined,
              title: "Skrining Preeklampsia",
              subtitle: "Lihat hasil skrining preeklampsia",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SkriningPreeklampsiaScreen(),
                  ),
                );
              },
            ),

          if (trimester == 3)
            _MenuCard(
              icon: Icons.medical_services_outlined,
              title: "Pemeriksaan Dokter Trimester III",
              subtitle: "Lihat hasil pemeriksaan dokter trimester III",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PemeriksaanDokterScreen(trimester: 3),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5ECF6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B8798),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}