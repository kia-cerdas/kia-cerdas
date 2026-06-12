// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/kehamilan_aktif_model.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/perjalanan_hamil_screen.dart';

// class HamilScreen extends StatefulWidget {
//   const HamilScreen({super.key});

//   @override
//   State<HamilScreen> createState() => _HamilScreenState();
// }

// class _HamilScreenState extends State<HamilScreen> {
//   final _service = KehamilanApiService();
//   late Future<KehamilanAktifModel> _futureKehamilan;

//   @override
//   void initState() {
//     super.initState();
//     _futureKehamilan = _service.getKehamilanAktif();
//   }

//   @override
//   void dispose() {
//     _service.dispose();
//     super.dispose();
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';

//     final months = [
//       'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
//       'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<KehamilanAktifModel>(
//       future: _futureKehamilan,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Modul Kehamilan')),
//             body: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   snapshot.error.toString(),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           );
//         }

//         final kehamilan = snapshot.data!;

//         return JourneyScreen(
//           currentWeek: kehamilan.ukKehamilanSaatIni,
//           gravida: kehamilan.gravida,
//           paritas: kehamilan.paritas,
//           abortus: kehamilan.abortus,
//           hplText: _formatDate(kehamilan.taksiranPersalinan),
//           hphtText: _formatDate(kehamilan.hpht),
//           hpht: kehamilan.hpht!,
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/kehamilan_aktif_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/perjalanan_hamil_screen.dart';

class HamilScreen extends StatefulWidget {
  const HamilScreen({super.key});

  @override
  State<HamilScreen> createState() => _HamilScreenState();
}

class _HamilScreenState extends State<HamilScreen> {
  final _service = KehamilanApiService();
  late Future<KehamilanAktifModel> _futureKehamilan;

  @override
  void initState() {
    super.initState();
    _futureKehamilan = _service.getKehamilanAktif();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KehamilanAktifModel>(
      future: _futureKehamilan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Modul Kehamilan')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final kehamilan = snapshot.data!;

        // Gunakan getter usiaKehamilanMinggu yang selalu dihitung real-time dari HPHT.
        // Ini memastikan UI tidak pernah menampilkan minggu yang stuck/stale.
        final currentWeek = kehamilan.usiaKehamilanMinggu;

        return JourneyScreen(
          currentWeek: currentWeek,
          gravida: kehamilan.gravida,
          paritas: kehamilan.paritas,
          abortus: kehamilan.abortus,
          hplText: _formatDate(kehamilan.taksiranPersalinan),
          hphtText: _formatDate(kehamilan.hpht),
          hpht: kehamilan.hpht!,
        );
      },
    );
  }
}