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

//         // Gunakan getter usiaKehamilanMinggu yang selalu dihitung real-time dari HPHT.
//         // Ini memastikan UI tidak pernah menampilkan minggu yang stuck/stale.
//         final currentWeek = kehamilan.usiaKehamilanMinggu;

//         return JourneyScreen(
//           currentWeek: currentWeek,
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



// ============================================================================
// hamil_screen.dart
// SCOPE PERUBAHAN:
//   - Hanya menyentuh logika _loadRingkasanPersalinan() agar parsing response
//     dari backend benar (data adalah array, bukan object tunggal).
//   - Memperbaiki URL ringkasanPersalinan yang sudah full URL (tidak di-concat
//     lagi dengan baseUrl).
//   - Tidak ada perubahan pada backend, route, atau modul lain.
// ============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/kehamilan_aktif_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/perjalanan_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/pelayanan_ibu_nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/catatan_pelayanan_nifas_screen.dart';

// ---------------------------------------------------------------------------
// State yang mungkin ditampilkan oleh HamilScreen
// ---------------------------------------------------------------------------
enum _HamilPageState {
  loading,
  masihHamil, // Trimester 1 / 2 / 3 → tampilkan JourneyScreen
  sudahNifas, // Kehamilan selesai → tampilkan halaman nifas-placeholder
  error,
}

// ---------------------------------------------------------------------------
// HamilScreen — entry point modul kehamilan untuk ibu
//
// Alur:
//  1. Fetch GET /modul-ibu/kehamilan-aktif
//     • 200 OK  → status TRIMESTER 1/2/3 → tampilkan JourneyScreen
//     • 404     → tidak ada kehamilan aktif → ibu sudah melahirkan
//                 Fetch /modul-ibu/ringkasan-persalinan/me untuk tanggal_melahirkan
//                 → tampilkan halaman "Kehamilan selesai" + info hari nifas
//  2. Error jaringan → tampilkan pesan error + tombol coba lagi
//
// CATATAN BACKEND:
//   Tidak ada perubahan backend yang diperlukan untuk tahap ini.
//   - /modul-ibu/kehamilan-aktif  → sudah ada, return 404 jika tidak ada kehamilan aktif
//   - /modul-ibu/ringkasan-persalinan/me → sudah ada, return array data persalinan
// ---------------------------------------------------------------------------
class HamilScreen extends StatefulWidget {
  const HamilScreen({super.key});

  @override
  State<HamilScreen> createState() => _HamilScreenState();
}

class _HamilScreenState extends State<HamilScreen> {
  final _kehamilanService = KehamilanApiService();

  _HamilPageState _pageState = _HamilPageState.loading;
  KehamilanAktifModel? _kehamilan;

  // Data nifas — diisi setelah berhasil fetch ringkasan persalinan
  DateTime? _tanggalMelahirkan;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _kehamilanService.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => _pageState = _HamilPageState.loading);

    try {
      final kehamilan = await _kehamilanService.getKehamilanAktif();
      if (!mounted) return;
      setState(() {
        _kehamilan = kehamilan;
        _pageState = _HamilPageState.masihHamil;
      });
    } on Exception catch (e) {
      // 404 → tidak ada kehamilan TRIMESTER aktif → kemungkinan sudah nifas
      final msg = e.toString().toLowerCase();
      if (msg.contains('tidak ditemukan') || msg.contains('404')) {
        await _loadRingkasanPersalinan();
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
          _pageState = _HamilPageState.error;
        });
      }
    }
  }

  // ── [SCOPE PERUBAHAN] Fetch ringkasan persalinan ──────────────────────────
  // Perbaikan:
  //   1. Menggunakan ApiConstants.ringkasanPersalinan yang SUDAH full URL
  //      (termasuk baseUrl). Tidak perlu concat lagi.
  //   2. Parsing response: backend GetMine mengembalikan data sebagai ARRAY.
  //      Ambil elemen pertama (persalinan terbaru) dan parse tanggal_melahirkan.
  //   3. Jika array kosong atau tidak ada data → tetap masuk state sudahNifas
  //      tapi tanpa tanggal (UI tetap informatif).
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadRingkasanPersalinan() async {
    final token = AuthSession.token;

    // Jika tidak ada token, langsung tampilkan halaman nifas tanpa tanggal
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _tanggalMelahirkan = null;
        _pageState = _HamilPageState.sudahNifas;
      });
      return;
    }

    try {
      // ApiConstants.ringkasanPersalinan sudah full URL (include baseUrl)
      // Endpoint: GET /modul-ibu/ringkasan-persalinan/me
      final response = await http.get(
        Uri.parse(ApiConstants.ringkasanPersalinan),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      DateTime? tanggal;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        // Backend GetMine mengembalikan data sebagai List (array)
        // Ambil elemen pertama = persalinan paling baru (ORDER BY created_at DESC)
        final rawData = body['data'];
        if (rawData is List && rawData.isNotEmpty) {
          final item = rawData.first as Map<String, dynamic>;
          final rawTanggal = item['tanggal_melahirkan'] as String?;
          if (rawTanggal != null && rawTanggal.isNotEmpty) {
            tanggal = DateTime.tryParse(rawTanggal);
          }
        } else if (rawData is Map<String, dynamic>) {
          // Fallback: kalau backend berubah return object tunggal
          final rawTanggal = rawData['tanggal_melahirkan'] as String?;
          if (rawTanggal != null && rawTanggal.isNotEmpty) {
            tanggal = DateTime.tryParse(rawTanggal);
          }
        }
      }
      // Jika statusCode != 2xx, tanggal tetap null → UI tetap tampil tanpa tanggal

      setState(() {
        _tanggalMelahirkan = tanggal;
        _pageState = _HamilPageState.sudahNifas;
      });
    } catch (_) {
      // Error jaringan saat fetch ringkasan → tetap masuk sudahNifas tanpa tanggal
      if (!mounted) return;
      setState(() {
        _tanggalMelahirkan = null;
        _pageState = _HamilPageState.sudahNifas;
      });
    }
  }
  // ── [END SCOPE PERUBAHAN] ─────────────────────────────────────────────────

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Hitung hari nifas dari tanggal melahirkan hingga hari ini.
  /// Masa nifas = 0–42 hari setelah melahirkan.
  int get _hariNifas {
    if (_tanggalMelahirkan == null) return 0;
    final selisih = DateTime.now().difference(_tanggalMelahirkan!).inDays;
    return selisih.clamp(0, 42);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (_pageState) {
      case _HamilPageState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case _HamilPageState.error:
        return _buildErrorPage();

      case _HamilPageState.masihHamil:
        final k = _kehamilan!;
        return JourneyScreen(
          currentWeek: k.usiaKehamilanMinggu,
          gravida: k.gravida,
          paritas: k.paritas,
          abortus: k.abortus,
          hplText: _formatDate(k.taksiranPersalinan),
          hphtText: _formatDate(k.hpht),
          hpht: k.hpht!,
        );

      case _HamilPageState.sudahNifas:
        return _buildNifasPlaceholder();
    }
  }

  // ── Error page ────────────────────────────────────────────────────────────

  Widget _buildErrorPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Kehamilan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Nifas placeholder ─────────────────────────────────────────────────────
  //
  // Ditampilkan ketika kehamilan aktif tidak ditemukan (sudah melahirkan).
  // Progress bar kehamilan TIDAK ditampilkan di sini — digantikan info nifas.
  // Berisi: status selesai, progress nifas (0–42 hari), dan shortcut menu nifas.

  Widget _buildNifasPlaceholder() {
    final hariNifas = _hariNifas;
    final tanggalMelahirkanText = _formatDate(_tanggalMelahirkan);
    final sisaHari = (42 - hariNifas).clamp(0, 42);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Pemeriksaan Kehamilan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Header selesai ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.80),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Masa Kehamilan Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tanggalMelahirkan != null
                        ? 'Melahirkan pada $tanggalMelahirkanText'
                        : 'Selamat atas kelahiran buah hati Anda!',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Info masa nifas (hanya tampil jika ada tanggal melahirkan) ─
            if (_tanggalMelahirkan != null)
              _infoNifasCard(hariNifas: hariNifas, sisaHari: sisaHari),

            const SizedBox(height: 24),

            // ── Label seksi ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Menu Masa Nifas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // ── Menu 1: Pemantauan Ibu Nifas ─────────────────────────────
            _nifasMenuCard(
              icon: Icons.health_and_safety_outlined,
              iconColor: AppColors.primary,
              iconBackground: const Color(0xFFEAF4FF),
              borderColor: const Color(0xFFB7DBFF),
              title: 'Pemantauan Ibu Nifas',
              subtitle:
                  'Isi checklist pemantauan harian selama 42 hari masa nifas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NifasScreen()),
              ),
            ),

            const SizedBox(height: 12),

            // ── Menu 2: Ringkasan Pelayanan Ibu Nifas ────────────────────
            _nifasMenuCard(
              icon: Icons.medical_services_outlined,
              iconColor: const Color(0xFF7B5EA7),
              iconBackground: const Color(0xFFF3EEFF),
              borderColor: const Color(0xFFD9C8F5),
              title: 'Ringkasan Pelayanan Nifas',
              subtitle:
                  'Lihat ringkasan pelayanan yang diberikan pasca persalinan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PelayananIbuNifasScreen()),
              ),
            ),

            const SizedBox(height: 12),

            // ── Menu 3: Catatan Pelayanan Nifas ──────────────────────────
            _nifasMenuCard(
              icon: Icons.note_alt_outlined,
              iconColor: const Color(0xFFD97706),
              iconBackground: const Color(0xFFFFF5E0),
              borderColor: const Color(0xFFFFDFA3),
              title: 'Catatan Pelayanan Nifas',
              subtitle:
                  'Lihat catatan pemeriksaan dan saran dari tenaga kesehatan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CatatanPelayananNifasScreen()),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoNifasCard({required int hariNifas, required int sisaHari}) {
    final progress = (hariNifas / 42).clamp(0.0, 1.0);
    final sudahSelesai = hariNifas >= 42;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB7DBFF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MASA NIFAS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sudahSelesai
                      ? Colors.green.shade50
                      : const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sudahSelesai
                        ? Colors.green.shade200
                        : const Color(0xFFB7DBFF),
                  ),
                ),
                child: Text(
                  sudahSelesai ? 'Selesai' : 'Berlangsung',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: sudahSelesai
                        ? Colors.green.shade700
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hariNifas',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ 42 hari',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          if (!sudahSelesai)
            Text(
              'Sisa $sisaHari hari lagi',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            )
          else
            Text(
              'Masa nifas telah selesai',
              style: TextStyle(fontSize: 12, color: Colors.green.shade600),
            ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEAF4FF),
              valueColor: AlwaysStoppedAnimation(
                sudahSelesai ? Colors.green : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nifas Menu Card ───────────────────────────────────────────────────────

  Widget _nifasMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required Color borderColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}