

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/screens/mpasi_menu_screen.dart';
// import 'package:ta_pa2_pa3_project/features/anak/mpasi/presentation/screens/mpasi/halaman_utama_mpasi.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/widgets/dashboard_menu_card.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/widgets/dashboard_phase_selector.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/presentation/widgets/dashboard_quick_menu.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/data/dashboard_menu_data.dart';
// MODUL IBU
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/perjalanan_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/kehamilan_aktif_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/absensi_kelas_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/rujukan_list_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/pemantauan_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/catatan_pelayanan_menu_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/log_ttd_mms_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/imunisasi_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/pilih_anak.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/persalinan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/hasil_evaluasi_kesehatan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/skrining_preeklampsia_screen.dart';
// MODUL ANAK
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/screens/anak/pilih_anak_screen.dart';
// import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/screens/anak/cari_anak_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/edukasi/presentation/screens/edukasi/edukasi_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/ibu_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/services/ibu_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/anak/tumbuh_kembang/presentation/screens/skrining/skrining_bahaya.dart';
// MODUL CATATAN
// import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/widgets/index.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/grafik_evaluasi_kehamilan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/grafik_evaluasi_kehamilan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/grafik_peningkatan_bb_screen.dart';

// import edukasi
import 'package:ta_pa2_pa3_project/features/edukasi/presentation/screens/edukasi_screen_all.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/pelayanan_ibu_nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/catatan_pelayanan_nifas_screen.dart';
import 'package:ta_pa2_pa3_project/features/profil/presentation/screens/profil_screen.dart';
import 'package:ta_pa2_pa3_project/features/absensi/presentation/screens/absensi_pilihan_screen.dart';
// MODUL IMUNISASI
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/services/imunisasi_service.dart';

// edukasi
import 'package:ta_pa2_pa3_project/features/edukasi/presentation/ibu/edukasi_asi_screen.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/presentation/ibu/edukasi_imd_screen.dart';

// Untuk notifikasi
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/log_ttd_mms_api_service.dart';
// Untuk kontrol
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPhase = 'Hamil';
  int _selectedNavIndex = 0;

  // [SCOPE: modul-ibu] Set fase yang boleh diklik di tab selector.
  // Aturan bisnis:
  //   - Status HAMIL  → {'Hamil', 'Tumbuh'}   (Nifas & Menyusui dinonaktifkan)
  //   - Status NIFAS  → {'Nifas', 'Menyusui', 'Tumbuh'}  (Hamil dinonaktifkan)
  //   - null          → loading / belum diketahui → semua tab bebas
  // Variabel ini TIDAK memengaruhi logika modul anak atau modul lainnya.
  Set<String>? _enabledIbuPhases;

  final _kehamilanService = KehamilanApiService();
  bool _loadingKehamilan = false;
  KehamilanAktifModel? _kehamilanAktif;

  final _ibuApiService = IbuApiService();
  final _imunisasiService = ImunisasiService();
  bool _loadingAnak = false;
  List<IbuAnakModel>? _anakSaya;
  List<ImunisasiModel> _imunisasiData = [];
  int _overdueCount = 0;

  // Reminder Kontrol
  bool _hasKontrolAlert = false;
  String _kontrolAlertMessage = '';
  String _kontrolDismissKey = '';

  bool _loadingImunisasi = false;
  String? _imunisasiError;

  // Untuk notif Log TTD/MMS
  bool _hasTTDAlert = false;
  String _ttdAlertMessage = '';
  final _logTTDService = LogTTDMMSApiService();

  List<dynamic> _rujukanList = [];

  @override
  void initState() {
    super.initState();
    _loadKehamilanAktif();
    _loadDataAnak();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _loadImunisasi();
    });
    _loadRujukan();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _checkKontrolAlert();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _checkTTDAlert();
    });
  }

  Future<void> _loadRujukan() async {
    try {
      final kehamilan = await _kehamilanService.getKehamilanAktif();

      final data = await _kehamilanService.getRujukanByKehamilanId(
        kehamilan.id,
      );

      if (!mounted) return;

      setState(() {
        _rujukanList = data;
      });
    } catch (_) {}
  }

  Future<void> _loadDataAnak() async {
    setState(() => _loadingAnak = true);
    try {
      final anak = await _ibuApiService.getAnakSaya();
      if (!mounted) return;
      setState(() {
        _anakSaya = anak;
        _loadingAnak = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAnak = false);
    }
  }

  Future<void> _loadImunisasi() async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loadingImunisasi = true;
      _imunisasiError = null;
    });

    try {
      final List<ImunisasiModel> result =
          await _imunisasiService.getJadwalImunisasi();

      if (!mounted) return;

      final int totalTerlewat = result.fold<int>(
        0,
        (sum, anak) => sum + anak.jumlahTerlewat,
      );

      setState(() {
        _imunisasiData = result;
        _overdueCount = totalTerlewat;
        _loadingImunisasi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _imunisasiError = e.toString();
        _loadingImunisasi = false;
      });
    }
  }

  // Future<void> _checkKontrolAlert() async {
  //   final hpht = _kehamilanAktif?.hpht;
  //   if (hpht == null) return;

  //   final now = DateTime.now();
  //   final hariIni = DateTime(now.year, now.month, now.day);

  //   // Hitung usia kehamilan dalam minggu
  //   final offsetHari = hariIni
  //       .difference(
  //         DateTime(hpht.year, hpht.month, hpht.day),
  //       )
  //       .inDays;

  //   if (offsetHari < 0 || offsetHari > 294) {
  //     // Di luar rentang kehamilan normal (294 hari = 42 minggu)
  //     if (mounted) setState(() => _hasKontrolAlert = false);
  //     return;
  //   }

  //   final mingguKehamilan = offsetHari ~/ 7;

  //   // Hitung semua jadwal kontrol dari HPHT
  //   final jadwals = _hitungJadwalKontrol(hpht, mingguKehamilan);

  //   // Cek apakah besok ada jadwal kontrol
  //   final besok = hariIni.add(const Duration(days: 1));

  //   String? pesanAlert;
  //   for (final jadwal in jadwals) {
  //     final jadwalOnly = DateTime(jadwal.year, jadwal.month, jadwal.day);
  //     if (jadwalOnly == besok) {
  //       final tglStr = '${besok.day}/${besok.month}/${besok.year}';
  //       pesanAlert = 'Besok ($tglStr) jadwal kontrol pemeriksaan kehamilan.';
  //       break;
  //     }
  //     // Juga alert hari-H itu sendiri jika terlewat kemarin (belum ada notif H-1)
  //     if (jadwalOnly == hariIni) {
  //       pesanAlert = 'Hari ini jadwal kontrol pemeriksaan kehamilanmu!';
  //       break;
  //     }
  //   }

  //   if (!mounted) return;
  //   setState(() {
  //     _hasKontrolAlert = pesanAlert != null;
  //     _kontrolAlertMessage = pesanAlert ?? '';
  //   });
  // }

  Future<void> _checkKontrolAlert() async {
    final hpht = _kehamilanAktif?.hpht;
    if (hpht == null) {
      if (mounted) setState(() => _hasKontrolAlert = false);
      return;
    }

    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final hphtOnly = DateTime(hpht.year, hpht.month, hpht.day);

    final offsetHari = hariIni.difference(hphtOnly).inDays;

    // Di luar rentang kehamilan normal (0–294 hari = 42 minggu)
    if (offsetHari < 0 || offsetHari > 294) {
      if (mounted) setState(() => _hasKontrolAlert = false);
      return;
    }

    // Bulan kehamilan saat ini (1 bulan = 28 hari)
    final bulanKe = (offsetHari ~/ 28) + 1;
    if (bulanKe < 1 || bulanKe > 10) {
      if (mounted) setState(() => _hasKontrolAlert = false);
      return;
    }

    // Frekuensi kontrol per bulan sesuai trimester
    int frekuensi;
    String labelTrimester;
    if (bulanKe <= 3) {
      frekuensi = 1;
      labelTrimester = 'Trimester 1';
    } else if (bulanKe <= 6) {
      frekuensi = 2;
      labelTrimester = 'Trimester 2';
    } else {
      frekuensi = 3;
      labelTrimester = 'Trimester 3';
    }

    // Key unik per periode — sekali dismiss, tidak muncul lagi di bulan itu
    final dismissKey = 'kontrol_dismissed_b${bulanKe}_f$frekuensi';

    final prefs = await SharedPreferences.getInstance();
    final sudahDismiss = prefs.getBool(dismissKey) ?? false;

    if (!mounted) return;
    setState(() {
      _hasKontrolAlert = !sudahDismiss;
      _kontrolAlertMessage = sudahDismiss
          ? ''
          : 'Bulan ini ($labelTrimester) kamu perlu kontrol $frekuensi kali. '
              'Sudah periksa bulan ini?';
      _kontrolDismissKey = dismissKey;
    });
  }

  List<DateTime> _hitungJadwalKontrol(DateTime hpht, int mingguSaatIni) {
    final hphtOnly = DateTime(hpht.year, hpht.month, hpht.day);
    final hariIni = DateTime.now();
    final hariIniOnly = DateTime(hariIni.year, hariIni.month, hariIni.day);

    final List<DateTime> jadwals = [];

    for (int bulan = 1; bulan <= 10; bulan++) {
      final awalBulan = hphtOnly.add(Duration(days: (bulan - 1) * 28));

      List<DateTime> tanggalDalamBulan;

      if (bulan <= 3) {
        // Trimester 1: 1x per bulan
        tanggalDalamBulan = [awalBulan];
      } else if (bulan <= 6) {
        // Trimester 2: 2x per bulan
        tanggalDalamBulan = [
          awalBulan,
          awalBulan.add(const Duration(days: 14)),
        ];
      } else {
        // Trimester 3: 3x per bulan
        tanggalDalamBulan = [
          awalBulan,
          awalBulan.add(const Duration(days: 9)),
          awalBulan.add(const Duration(days: 19)),
        ];
      }

      for (final tgl in tanggalDalamBulan) {
        final tglOnly = DateTime(tgl.year, tgl.month, tgl.day);
        // Hanya yang belum lewat (termasuk hari ini dan besok)
        if (!tglOnly.isBefore(hariIniOnly)) {
          jadwals.add(tgl);
        }
      }
    }

    return jadwals;
  }

  // Untuk notifikasi Log TTD/MMS
  Future<void> _checkTTDAlert() async {
    final hpht = _kehamilanAktif?.hpht;
    if (hpht == null) return;

    try {
      final logs = await _logTTDService.getMine();

      final now = DateTime.now();
      final hariIni = DateTime(now.year, now.month, now.day);
      final kemarin = hariIni.subtract(const Duration(days: 1));

      final belumHariIni = !_sudahDiminum(logs, hpht, hariIni);
      final belumKemarin = !_sudahDiminum(logs, hpht, kemarin);

      if (!mounted) return;

      if (belumHariIni) {
        setState(() {
          _hasTTDAlert = true;
          _ttdAlertMessage = 'Belum minum TTD/MMS hari ini. Yuk catat!';
        });
      } else if (belumKemarin) {
        setState(() {
          _hasTTDAlert = true;
          _ttdAlertMessage = 'Catatan TTD/MMS kemarin belum terisi.';
        });
      } else {
        setState(() {
          _hasTTDAlert = false;
          _ttdAlertMessage = '';
        });
      }
    } catch (_) {
    }
  }

  /// Cek apakah pada [tgl] sudah ada log TTD yang diminum.
  bool _sudahDiminum(
    List<LogTTDMMSModel> logs,
    DateTime hpht,
    DateTime tgl,
  ) {
    const hariPerBulan = 30;
    final hphtOnly = DateTime(hpht.year, hpht.month, hpht.day);
    final tglOnly = DateTime(tgl.year, tgl.month, tgl.day);
    final offsetHari = tglOnly.difference(hphtOnly).inDays;

    if (offsetHari < 0) return true; // sebelum HPHT, skip
    final bulanKe = (offsetHari ~/ hariPerBulan) + 1;
    final hariKe = (offsetHari % hariPerBulan) + 1;

    if (bulanKe < 1 || bulanKe > 10 || hariKe < 1 || hariKe > 31) {
      return true; // di luar masa kehamilan
    }

    return logs.any(
      (log) =>
          log.bulanKe == bulanKe && log.hariKe == hariKe && log.sudahDiminum,
    );
  }

  @override
  void dispose() {
    _ibuApiService.dispose();
    _imunisasiService.dispose();
    _logTTDService.dispose();
    super.dispose();
  }

  Future<void> _loadKehamilanAktif() async {
    try {
      final kehamilan = await _kehamilanService.getKehamilanAktif();
      if (!mounted) return;
      // [SCOPE: modul-ibu] Kehamilan aktif ditemukan → ibu masih HAMIL.
      // Hanya tab Hamil & Tumbuh yang bisa diakses; Nifas & Menyusui dinonaktifkan.
      setState(() {
        _kehamilanAktif = kehamilan;
        _enabledIbuPhases = {'Hamil', 'Tumbuh'};
        _selectedPhase = 'Hamil';
      });
      _checkKontrolAlert();
      _checkTTDAlert();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      // [SCOPE: modul-ibu] 404 / "tidak ditemukan" → tidak ada kehamilan aktif
      // → ibu sudah melahirkan / masa NIFAS.
      // Tab Hamil dinonaktifkan; Nifas, Menyusui, dan Tumbuh bisa diakses.
      if (msg.contains('tidak ditemukan') || msg.contains('404')) {
        setState(() {
          _enabledIbuPhases = {'Nifas', 'Menyusui', 'Tumbuh'};
          _selectedPhase = 'Nifas';
        });
      }
      // Error lain (jaringan, dll) → biarkan _enabledIbuPhases null
      // agar tidak salah mengunci fase
    }
  }

  // Future<void> _openHamilJourney() async {
  //   if (_loadingKehamilan) return;
  //   setState(() => _loadingKehamilan = true);
  //   try {
  //     final kehamilan = await _kehamilanService.getKehamilanAktif();
  //     if (!mounted) return;
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => JourneyScreen(
  //           currentWeek: kehamilan.ukKehamilanSaatIni,
  //           gravida: kehamilan.gravida,
  //           paritas: kehamilan.paritas,
  //           abortus: kehamilan.abortus,
  //           hplText: kehamilan.taksiranPersalinan != null
  //               ? '${kehamilan.taksiranPersalinan!.day} / ${kehamilan.taksiranPersalinan!.month} / ${kehamilan.taksiranPersalinan!.year}'
  //               : '-',
  //           hphtText: kehamilan.hpht != null
  //               ? '${kehamilan.hpht!.day} / ${kehamilan.hpht!.month} / ${kehamilan.hpht!.year}'
  //               : '-',
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  //   } finally {
  //     if (mounted) setState(() => _loadingKehamilan = false);
  //   }
  // }

  Future<void> _openHamilJourney() async {
    if (_loadingKehamilan) return;
    setState(() => _loadingKehamilan = true);
    try {
      final kehamilan = await _kehamilanService.getKehamilanAktif();
      if (!mounted) return;

      // Safety check: pastikan hpht tidak null
      if (kehamilan.hpht == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data HPHT belum tersedia')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JourneyScreen(
            currentWeek: kehamilan.ukKehamilanSaatIni,
            gravida: kehamilan.gravida,
            paritas: kehamilan.paritas,
            abortus: kehamilan.abortus,
            hplText: kehamilan.taksiranPersalinan != null
                ? '${kehamilan.taksiranPersalinan!.day} / ${kehamilan.taksiranPersalinan!.month} / ${kehamilan.taksiranPersalinan!.year}'
                : '-',
            hphtText:
                '${kehamilan.hpht!.day} / ${kehamilan.hpht!.month} / ${kehamilan.hpht!.year}',
            hpht: kehamilan.hpht!, // ✅ pakai kehamilan, bukan _kehamilanAktif
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loadingKehamilan = false);
    }
  }

  // void _showKontrolDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Row(
  //         children: [
  //           Icon(Icons.local_hospital_outlined, color: Color(0xFF185FA5)),
  //           SizedBox(width: 8),
  //           Text(
  //             'Jadwal Kontrol Kehamilan',
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             _kontrolAlertMessage,
  //             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  //           ),
  //           const SizedBox(height: 12),
  //           const Text(
  //             'Kontrol kehamilan rutin penting untuk memantau kesehatan Bunda '
  //             'dan perkembangan si kecil. Pastikan datang ke Posyandu atau '
  //             'Puskesmas terdekat sesuai jadwal.',
  //             style:
  //                 TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
  //           ),
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFEEF4FF),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Row(
  //               children: [
  //                 Icon(Icons.info_outline, size: 16, color: Color(0xFF185FA5)),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Ketuk "Lihat Detail" untuk membuka perjalanan kehamilan '
  //                     'dan melihat jadwal lengkap kontrol.',
  //                     style: TextStyle(fontSize: 12, color: Color(0xFF185FA5)),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF185FA5),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           onPressed: () {
  //             Navigator.pop(ctx); // tutup dialog dulu
  //             // Navigate ke JourneyScreen; setelah kembali, alert hilang otomatis
  //             _openHamilJourney().then((_) {
  //               // Re-check: hari mungkin sudah berganti atau jadwal sudah lewat
  //               _checkKontrolAlert();
  //             });
  //           },
  //           child: const Text(
  //             'Lihat Detail',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showKontrolDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // harus tekan tombol, bukan tap di luar
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_hospital_outlined, color: Color(0xFF185FA5)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pengingat Kontrol Kehamilan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _kontrolAlertMessage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kontrol rutin penting untuk memastikan kesehatan Bunda '
              'dan perkembangan si kecil. Kunjungi Posyandu atau '
              'Puskesmas terdekat ya, Bun! 💙',
              style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF185FA5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Simpan dismiss — tidak muncul lagi bulan ini
                if (_kontrolDismissKey.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(_kontrolDismissKey, true);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                // Langsung hilangkan alert dari bell
                if (mounted) {
                  setState(() {
                    _hasKontrolAlert = false;
                    _kontrolAlertMessage = '';
                  });
                }
              },
              child: const Text(
                'Oke, Mengerti',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _trimesterLabel(int week) {
    if (week <= 12) return 'Trimester 1';
    if (week <= 27) return 'Trimester 2';
    return 'Trimester 3';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
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
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getContextualGuidanceText() {
    if (_selectedPhase == 'Hamil') {
      final week = _kehamilanAktif?.ukKehamilanSaatIni ?? 0;

      if (week > 0 && week <= 12) {
        return 'Bunda sedang di Trimester 1. Yuk cek kondisi awal kehamilan dan perkembangan janinmu!';
      } else if (week > 12 && week <= 27) {
        return 'Bunda sudah di Trimester 2. Yuk pantau pertumbuhan janin dan kesehatan Bunda!';
      } else if (week > 27) {
        return 'Trimester 3 sedang berjalan, Bun. Yuk cek kondisi kehamilanmu dan kesiapan persalinan!';
      }
    } else if (_selectedPhase == 'Nifas') {
      return 'Masa nifas juga penting, Bun. Yuk cek pemulihan tubuh Bunda secara rutin!';
    } else if (_selectedPhase == 'Menyusui') {
      return 'Semangat memberi ASI ya, Bun! Yuk cek panduan dan kesehatan ibu menyusui.';
    } else if (_selectedPhase == 'Tumbuh') {
      return 'Yuk pantau pertumbuhan dan perkembangan si kecil sesuai usianya!';
    }

    return 'Yuk cek kondisi kesehatan Bunda dan si kecil hari ini!';
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedNavIndex == 0) {
      body = _buildHomeBody();
    } else if (_selectedNavIndex == 1) {
      body = const AbsensiPilihanScreen();
      // body = const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(20),
      //     child: Text(
      //       'Menu Catatan dapat diakses dari Menu Cepat di halaman Beranda',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 16),
      //     ),
      //   ),
      // );
    } else if (_selectedNavIndex == 2) {
      body = const EdukasiScreenAll();
    } else if (_selectedNavIndex == 3) {
      body = PilihAnakImunisasiScreen(tujuan: 'imunisasi');
    } else {
      body = const ProfilScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: body,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _selectedNavIndex,
        overdueCount: _overdueCount,
        onTap: (i) {
          setState(() {
            _selectedNavIndex = i;
          });
          // 🔥 PERBAIKAN: Jika user menekan tab Beranda (index 0), tarik data terbaru dari API
          if (i == 0) {
            _loadImunisasi();
            _loadDataAnak();
            _checkTTDAlert();
            _checkKontrolAlert();
          }
        },
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // DashboardHeader(
          //   data: _imunisasiData,
          //   overdueCount: _overdueCount,
          //   onOpenImunisasi: () {
          //     setState(() {
          //       _selectedNavIndex = 3;
          //     });
          //   },
          // ),
          DashboardHeader(
            data: _imunisasiData,
            overdueCount: _overdueCount,
            onOpenImunisasi: () {
              setState(() {
                _selectedNavIndex = 3;
              });
            },
            // ── Kontrol pemeriksaan ──
            hasKontrolAlert: _hasKontrolAlert,
            kontrolAlertMessage: _kontrolAlertMessage,
            onOpenKontrol: () {
              // Arahkan ke screen pemeriksaan kehamilan / perjalanan hamil
              // _openHamilJourney();
              _showKontrolDialog();
            },
            // ── TAMBAHAN TTD ──
            hasTTDAlert: _hasTTDAlert,
            ttdAlertMessage: _ttdAlertMessage,
            onOpenTTD: () {
              if (_kehamilanAktif?.hpht == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Data kehamilan belum tersedia')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LogTTDMMSScreen(hpht: _kehamilanAktif!.hpht!),
                ),
              ).then((_) {
                // Refresh status TTD setelah kembali dari screen log
                _checkTTDAlert();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // [SCOPE: modul-ibu] enabledPhases dikontrol oleh _loadKehamilanAktif.
                // Hamil → {'Hamil','Tumbuh'} | Nifas → {'Nifas','Menyusui','Tumbuh'}
                DashboardPhaseSelector(
                  selectedPhase: _selectedPhase,
                  onPhaseSelected: (phase) =>
                      setState(() => _selectedPhase = phase),
                  enabledPhases: _enabledIbuPhases,
                ),
                const SizedBox(height: 32),
                if (_selectedPhase == 'Hamil') _buildHamilContent(),
                if (_selectedPhase == 'Nifas') _buildNifasShortcut(),
                if (_selectedPhase == 'Menyusui') _buildMenyusuiShortcut(),
                if (_selectedPhase == 'Tumbuh') _buildTumbuhContent(),
                if (_selectedPhase != 'Hamil' &&
                    _selectedPhase != 'Nifas' &&
                    _selectedPhase != 'Menyusui' &&
                    _selectedPhase != 'Tumbuh')
                  _buildPlaceholderContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNifasShortcut() {
    return Column(
      children: [
        const SizedBox(height: 16),
        DashboardMenuCard(
          title: 'Pemantauan Ibu Nifas',
          subtitle: 'Pantau masa nifas pasca persalinan',
          icon: Icons.person_outline,
          iconColor: AppColors.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NifasScreen(),
            ),
          ),
        ),
        DashboardMenuCard(
          title: 'Ringkasan Pelayanan Ibu Nifas',
          subtitle: 'Lihat catatan pelayanan ibu nifas',
          icon: Icons.medical_services_outlined,
          iconColor: AppColors.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PelayananIbuNifasScreen(),
            ),
          ),
        ),
        DashboardMenuCard(
          title: 'Catatan Pelayanan Nifas',
          subtitle: 'Lihat catatan pemeriksaan dan saran nifas',
          icon: Icons.note_alt_outlined,
          iconColor: AppColors.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CatatanPelayananNifasScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenyusuiShortcut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pelajari ASI eksklusif, IMD, dan tips menyusui untuk kesehatan ibu dan bayi.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildMenyusuiMenu(
                title: 'IMD',
                subtitle: 'Inisiasi Menyusu Dini',
                icon: Icons.child_friendly,
                color: const Color(
                  0xFF3B82F6,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EdukasiIMDScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenyusuiMenu(
                title: 'ASI Eksklusif',
                subtitle: 'Panduan menyusui',
                icon: Icons.favorite,
                color: const Color(
                  0xFFEC4899,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EdukasiASIScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHamilContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ADD: BANNER TEKS PANDUAN UNTUK PERSONA ABI (IBU DESA) ---
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getContextualGuidanceText(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress kehamilan — klik navigasi ke JourneyScreen
        const Text('MENU CEPAT',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openHamilJourney,
          child: DashboardInfoCard(
            child: Builder(builder: (_) {
              final week = _kehamilanAktif?.ukKehamilanSaatIni ?? 0;
              final progress = week > 0 ? (week / 40).clamp(0.0, 1.0) : 0.0;
              final trimester = week > 0 ? _trimesterLabel(week) : '-';
              final hpl = _formatDate(_kehamilanAktif?.taksiranPersalinan);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        week > 0 ? 'Kehamilan $week Minggu' : 'Kehamilan Aktif',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  Text('$trimester • HPL: $hpl',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.blue.shade50,
                    color: TrimesterTheme.t1Primary,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minggu 1',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('Minggu 40',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Info insight janin — DINONAKTIFKAN SEMENTARA
        // DashboardInfoCard(
        //   child: Row(
        //     children: [
        //       const Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text('Sebesar Buah Jagung',
        //                 style: TextStyle(fontWeight: FontWeight.bold)),
        //             Text(
        //               'Panjang janin sekitar 30 cm dengan berat sekitar 600 gram.',
        //               style: TextStyle(fontSize: 12, color: Colors.black54),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Image.network(
        //         'https://cdn-icons-png.flaticon.com/512/1141/1141771.png',
        //         width: 40,
        //       ),
        //     ],
        //   ),
        // ),

        const SizedBox(height: 12),

        _buildPemeriksaanIbuCard(),
        const SizedBox(height: 32),

        // Menu Kehamilan — card navigasi
        const Text('Menu Kehamilan',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),

        DashboardMenuCard(
          title: 'Kehamilan Trimester 1–3',
          subtitle: 'Pantau perkembangan kehamilan',
          icon: Icons.favorite_outline,
          iconColor: Colors.pink,
          onTap: _openHamilJourney,
        ),
        DashboardMenuCard(
          title: 'Persalinan',
          subtitle: 'Persiapan & proses persalinan',
          icon: Icons.child_care_outlined,
          iconColor: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersalinanScreen()),
          ),
        ),
        DashboardMenuCard(
          title: 'Surat Rekomendasi Rujukan',
          subtitle: _rujukanList.isNotEmpty
              ? '${_rujukanList.length} surat rujukan tersedia'
              : 'Belum ada surat rekomendasi rujukan saat ini',
          icon: Icons.description_outlined,
          iconColor: AppColors.blue500,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RujukanListScreen(),
            ),
          ),
        ),
        // DashboardMenuCard(
        //   title: 'Grafik Evaluasi Kehamilan',
        //   subtitle: 'Pantau TFU & DJJ selama kehamilan',
        //   icon: Icons.show_chart_outlined,
        //   iconColor: Colors.purple,
        //   onTap: () => Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => const GrafikEvaluasiKehamilanScreen(),
        //     ),
        //   ),
        // ),

        const SizedBox(height: 16),
        // DashboardQuickMenu(
        //   items: DashboardMenuData.hamilQuickMenuItems.map((item) {
        //     return {
        //       ...item,
        //       'onTap': () {
        //         if (item['key'] == 'absensi') {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (_) => const AbsensiKelasIbuHamilScreen()));
        //           return;
        //         }
        //         if (item['key'] == 'catatan') {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (_) => const CatatanMenuScreen()));
        //           return;
        //         }
        //         ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(content: Text('${item['label']} belum tersedia')));
        //       },
        //     };
        //   }).toList(),
        // ),
        // const SizedBox(height: 32),

        DashboardQuickMenu(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          items: DashboardMenuData.hamilQuickMenuItems.map((item) {
            return {
              ...item,
              'onTap': () {
                switch (item['key']) {
                  case 'rujukan':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RujukanListScreen()));
                    break;
                  case 'bb_ibu':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                // const GrafikEvaluasiKehamilanScreen()));
                                const GrafikPeningkatanBBScreen()));
                    break;
                  case 'djj_tfu':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const GrafikEvaluasiKehamilanScreen()));
                    break;
                  case 'pemantauan':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PemantauanIbuHamilScreen()));
                    break;
                  case 'catatan':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const CatatanPelayananMenuScreen()));
                    break;
                  // case 'log_ttd':
                  //   Navigator.push(context,
                  //       MaterialPageRoute(builder: (_) => const LogTTDMMSScreen()));
                  //   break;
                  case 'log_ttd':
                    // Safety: cek dulu apakah data kehamilan tersedia
                    if (_kehamilanAktif?.hpht == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data kehamilan belum tersedia')),
                      );
                      break;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogTTDMMSScreen(
                          hpht: _kehamilanAktif!.hpht!,
                        ),
                      ),
                    );
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${item['label']} belum tersedia')));
                }
              },
            };
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // [MODUL: ANAK - Tumbuh Kembang] Konten tab Tumbuh
  // ─────────────────────────────────────────────
  Widget _buildTumbuhContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loadingAnak)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_anakSaya != null && _anakSaya!.isNotEmpty)
          _anakSaya!.length == 1
              // 1 anak -> full width
              ? _buildAnakCard(_anakSaya![0], fullWidth: true)
              // > 1 anak -> horizontal scroll, kartu 75%
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: _anakSaya!.length,
                    itemBuilder: (context, index) {
                      return _buildAnakCard(_anakSaya![index]);
                    },
                  ),
                )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(16),
              color: Colors.orange.shade50,
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data anak ditambahkan oleh bidan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Silakan hubungi bidan untuk menambahkan atau memperbarui profil anak.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        const Text('MENU TUMBUH',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),

        // [WIDGET: DashboardTumbuhQuickMenu] — 6 menu cepat modul anak
        DashboardTumbuhQuickMenu(
          items: DashboardMenuData.tumbuhQuickMenuItems.map((item) {
            return {
              ...item,
              'onTap': () {
                switch (item['key']) {
                  case 'pertumbuhan':
                    // [MODUL: ANAK] Pilih anak → DetailPertumbuhanScreen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PilihAnakScreen()));
                    break;
                  case 'imunisasi':
                    // [MODUL: ANAK] Pilih anak → ImunisasiScreen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PilihAnakScreen(tujuan: 'imunisasi')));
                    break;
                  case 'mpasi':
                    // [MODUL: ANAK] Pilih anak → HalamanUtamaMpasiScreen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MpasiMenuScreen()));
                    break;
                  case 'edukasi':
                    // [MODUL: ANAK] Langsung ke EdukasiScreen (tidak butuh pilih anak)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EdukasiScreen()));
                    break;
                  case 'bahaya':
                    // [MODUL: ANAK] Pilih anak → SkriningBahayaScreen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PilihAnakScreen(tujuan: 'bahaya')));
                    break;
                  case 'pemantauan':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PilihAnakScreen(tujuan: 'pemantauan')));
                    break;
                  case 'catatan':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PilihAnakScreen(tujuan: 'catatan'),
                      ),
                    );
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${item['label']} belum tersedia')));
                }
              },
            };
          }).toList(),
        ),
        const SizedBox(height: 32),

        // [MODUL: ANAK] Banner tanda bahaya — klik langsung ke SkriningBahayaScreen
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PilihAnakScreen(tujuan: 'darurat')),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kenali Tanda Bahaya — Segera ke faskes jika ada gejala ini',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.orange),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    return const Center(
      child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Konten fase ini segera hadir!')),
    );
  }

  Widget _buildAnakCard(IbuAnakModel anak, {bool fullWidth = false}) {
    return Container(
      margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      width: fullWidth
          ? double.infinity
          : MediaQuery.of(context).size.width * 0.75, // Biar card berikutnya ngintip
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Background biru sangat muda
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E52A8), // Warna biru box icon
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.person_outline, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  anak.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E3A8A), // Biru gelap untuk teks nama
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  anak.usiaTeks,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  anak.jenisKelamin,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // [MODUL: IBU - Hamil] Banner surat rujukan
  // ─────────────────────────────────────────────

  Widget _buildPemeriksaanIbuCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pemeriksaan Ibu",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pantau hasil evaluasi kesehatan dan skrining kehamilan Ibu.",
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _menuPemeriksaan(
                  title: "Evaluasi\nKesehatan",
                  icon: Icons.health_and_safety_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HasilEvaluasiKesehatanScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _menuPemeriksaan(
                  title: "Skrining\nPreeklampsia",
                  icon: Icons.favorite_border,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SkriningPreeklampsiaScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuPemeriksaan({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.blue.shade100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenyusuiMenu({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}