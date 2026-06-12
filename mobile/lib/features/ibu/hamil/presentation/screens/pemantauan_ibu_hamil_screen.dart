// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/pemantauan_ibu_hamil_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemantauan_ibu_hamil_model.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// class PemantauanIbuHamilScreen extends StatefulWidget {
//   const PemantauanIbuHamilScreen({super.key});

//   @override
//   State<PemantauanIbuHamilScreen> createState() => _PemantauanIbuHamilScreenState();
// }

// class _PemantauanIbuHamilScreenState extends State<PemantauanIbuHamilScreen> {
//   final _api = PemantauanIbuHamilApiService();

//   int mingguKehamilan = 12;

//   bool demamLebih2Hari = false;
//   bool sakitKepala = false;
//   bool cemasBerlebih = false;
//   bool resikoTB = false;
//   bool gerakanBayiKurang = false;
//   bool nyeriPerut = false;
//   bool cairanJalanLahir = false;
//   bool masalahKemaluan = false;
//   bool diareBerulang = false;

//   bool _loading = false;
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _api.dispose();
//     super.dispose();
//   }

//   void _showTopMessage(String text, {bool success = true}) {
//     final overlay = Overlay.of(context);

//     final entry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: 70,
//         left: 20,
//         right: 20,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: BoxDecoration(
//               color: success ? AppColors.primary : Colors.red,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   success ? Icons.check_circle_outline : Icons.error_outline,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     text,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     overlay.insert(entry);

//     Future.delayed(const Duration(seconds: 2), () {
//       entry.remove();
//     });
//   }

//   Future<void> _loadData() async {
//     setState(() => _loading = true);

//     try {
//       final list = await _api.getMine();

//       PemantauanIbuHamilModel? data;

//       for (final item in list) {
//         if (item.mingguKehamilan == mingguKehamilan) {
//           data = item;
//           break;
//         }
//       }

//       if (data != null) {
//         setState(() {
//           demamLebih2Hari = data!.demamLebih2Hari;
//           sakitKepala = data.sakitKepala;
//           cemasBerlebih = data.cemasBerlebih;
//           resikoTB = data.resikoTB;
//           gerakanBayiKurang = data.gerakanBayiKurang;
//           nyeriPerut = data.nyeriPerut;
//           cairanJalanLahir = data.cairanJalanLahir;
//           masalahKemaluan = data.masalahKemaluan;
//           diareBerulang = data.diareBerulang;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showTopMessage(e.toString(), success: false);
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _save() async {
//     setState(() => _saving = true);

//     try {
//       await _api.save(
//         PemantauanIbuHamilModel(
//           mingguKehamilan: mingguKehamilan,
//           demamLebih2Hari: demamLebih2Hari,
//           sakitKepala: sakitKepala,
//           cemasBerlebih: cemasBerlebih,
//           resikoTB: resikoTB,
//           gerakanBayiKurang: gerakanBayiKurang,
//           nyeriPerut: nyeriPerut,
//           cairanJalanLahir: cairanJalanLahir,
//           masalahKemaluan: masalahKemaluan,
//           diareBerulang: diareBerulang,
//         ),
//       );

//       if (!mounted) return;

//       _showTopMessage('Pemantauan berhasil disimpan');

//       Future.delayed(const Duration(milliseconds: 700), () {
//         if (mounted) Navigator.pop(context);
//       });
//     } catch (e) {
//       if (!mounted) return;
//       _showTopMessage(e.toString(), success: false);
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   int get _jumlahKeluhan => [
//         demamLebih2Hari,
//         sakitKepala,
//         cemasBerlebih,
//         resikoTB,
//         gerakanBayiKurang,
//         nyeriPerut,
//         cairanJalanLahir,
//         masalahKemaluan,
//         diareBerulang,
//       ].where((e) => e).length;

//   bool get _adaKeluhan => _jumlahKeluhan > 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F8FF),
//       appBar: AppBar(
//         title: const Text('Pemantauan Ibu Hamil'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 _buildHeaderCard(),
//                 const SizedBox(height: 16),
//                 _buildWeekCard(),
//                 const SizedBox(height: 16),
//                 _buildChecklistCard(),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   height: 52,
//                   child: ElevatedButton.icon(
//                     onPressed: _saving ? null : _save,
//                     icon: _saving
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.save_outlined),
//                     label: Text(
//                       _saving ? 'Menyimpan...' : 'Simpan Pemantauan',
//                       style: const TextStyle(fontWeight: FontWeight.w800),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

// Widget _buildHeaderCard() {
//   return Container(
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       color: const Color(0xFFEFF6FF),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: const Color(0xFFBFDBFE)),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.035),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 54,
//           height: 54,
//           decoration: BoxDecoration(
//             color: const Color(0xFFDBEAFE),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Icon(
//             Icons.health_and_safety_outlined,
//             color: AppColors.primary,
//             size: 30,
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Pemantauan Mingguan',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 _adaKeluhan
//                     ? 'Ada $_jumlahKeluhan keluhan yang perlu diperhatikan'
//                     : 'Tidak ada keluhan yang dicatat',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: _adaKeluhan ? AppColors.primary : const Color(0xFF7B8798),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildWeekCard() {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: const Color(0xFFE5ECF6)),
//     ),
//     child: Row(
//       children: [
//         const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
//         const SizedBox(width: 12),
//         const Expanded(
//           child: Text(
//             'Minggu Kehamilan',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
//           ),
//         ),
//         DropdownButton<int>(
//           value: mingguKehamilan,
//           underline: const SizedBox(),
//           items: List.generate(39, (index) {
//             final week = index + 4;
//             return DropdownMenuItem<int>(
//               value: week,
//               child: Text('Minggu $week'),
//             );
//           }),
//           onChanged: _saving
//               ? null
//               : (value) {
//                   if (value == null) return;
//                   setState(() {
//                     mingguKehamilan = value;
//                     demamLebih2Hari = false;
//                     sakitKepala = false;
//                     cemasBerlebih = false;
//                     resikoTB = false;
//                     gerakanBayiKurang = false;
//                     nyeriPerut = false;
//                     cairanJalanLahir = false;
//                     masalahKemaluan = false;
//                     diareBerulang = false;
//                   });
//                   _loadData();
//                 },
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildChecklistCard() {
//   return Container(
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: const Color(0xFFE5ECF6)),
//     ),
//     child: Column(
//       children: [
//         const Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'Tanda Bahaya / Keluhan',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildSwitch('Demam lebih dari 2 hari', 'Suhu tubuh tinggi atau tidak membaik', demamLebih2Hari, (v) => setState(() => demamLebih2Hari = v)),
//         _buildSwitch('Sakit kepala', 'Sakit kepala berat atau menetap', sakitKepala, (v) => setState(() => sakitKepala = v)),
//         _buildSwitch('Cemas berlebih', 'Merasa sangat gelisah atau khawatir', cemasBerlebih, (v) => setState(() => cemasBerlebih = v)),
//         _buildSwitch('Risiko TB', 'Batuk lama atau gejala TB', resikoTB, (v) => setState(() => resikoTB = v)),
//         _buildSwitch('Gerakan bayi berkurang', 'Gerakan janin lebih sedikit', gerakanBayiKurang, (v) => setState(() => gerakanBayiKurang = v)),
//         _buildSwitch('Nyeri perut', 'Nyeri hebat atau tidak biasa', nyeriPerut, (v) => setState(() => nyeriPerut = v)),
//         _buildSwitch('Keluar cairan dari jalan lahir', 'Air/lendir/cairan tidak biasa', cairanJalanLahir, (v) => setState(() => cairanJalanLahir = v)),
//         _buildSwitch('Masalah pada kemaluan', 'Nyeri, gatal, luka, dll', masalahKemaluan, (v) => setState(() => masalahKemaluan = v)),
//         _buildSwitch('Diare berulang', 'Diare sering atau tidak membaik', diareBerulang, (v) => setState(() => diareBerulang = v)),
//       ],
//     ),
//   );
// }

// Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
//   return InkWell(
//     borderRadius: BorderRadius.circular(16),
//     onTap: _saving ? null : () => onChanged(!value),
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: value ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: value ? AppColors.primary : const Color(0xFFE5ECF6),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 26,
//             height: 26,
//             decoration: BoxDecoration(
//               color: value ? AppColors.primary : Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: value ? AppColors.primary : const Color(0xFFCBD5E1),
//               ),
//             ),
//             child: value ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 4),
//                 Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7B8798))),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/pemantauan_ibu_hamil_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemantauan_ibu_hamil_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/kehamilan_aktif_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class PemantauanIbuHamilScreen extends StatefulWidget {
  const PemantauanIbuHamilScreen({super.key});

  @override
  State<PemantauanIbuHamilScreen> createState() =>
      _PemantauanIbuHamilScreenState();
}

class _PemantauanIbuHamilScreenState extends State<PemantauanIbuHamilScreen> {
  final _api = PemantauanIbuHamilApiService();
  final _kehamilanApi = KehamilanApiService();

  // ── Data ─────────────────────────────────────────────────────────────────
  KehamilanAktifModel? _kehamilan;
  List<PemantauanIbuHamilModel> _allData = [];
  PemantauanIbuHamilModel? _existingData;

  /// Usia kehamilan ibu saat ini (dari HPHT), sudah di-clamp 4–42.
  int _mingguSekarang = 0;

  // ── Checklist state (hanya untuk minggu ini) ──────────────────────────────
  bool demamLebih2Hari = false;
  bool sakitKepala = false;
  bool cemasBerlebih = false;
  bool resikoTB = false;
  bool gerakanBayiKurang = false;
  bool nyeriPerut = false;
  bool cairanJalanLahir = false;
  bool masalahKemaluan = false;
  bool diareBerulang = false;

  bool _loading = false;
  bool _saving = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get _sudahDiisi => _existingData != null;

  int get _jumlahKeluhan => [
        demamLebih2Hari,
        sakitKepala,
        cemasBerlebih,
        resikoTB,
        gerakanBayiKurang,
        nyeriPerut,
        cairanJalanLahir,
        masalahKemaluan,
        diareBerulang,
      ].where((e) => e).length;

  String get _trimesterLabel {
    if (_mingguSekarang <= 12) return 'Trimester I';
    if (_mingguSekarang <= 27) return 'Trimester II';
    return 'Trimester III';
  }

  /// Semua minggu dari 4 s/d _mingguSekarang yang BELUM ada datanya.
  List<int> get _mingguTerlewat {
    if (_mingguSekarang < 5) return [];
    final filled = {for (final d in _allData) d.mingguKehamilan};
    return List.generate(
      _mingguSekarang - 4, // minggu 4..(mingguSekarang-1)
      (i) => i + 4,
    ).where((m) => !filled.contains(m)).toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  // ── Notifikasi top ────────────────────────────────────────────────────────
  void _showTopMessage(String text, {bool success = true}) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 70,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: success ? AppColors.primary : Colors.red.shade600,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  success ? Icons.check_circle_outline : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  // ── Load data ─────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _kehamilanApi.getKehamilanAktif(),
        _api.getMine(),
      ]);

      final kehamilan = results[0] as KehamilanAktifModel;
      final allData = results[1] as List<PemantauanIbuHamilModel>;
      final mingguSaatIni = kehamilan.usiaKehamilanMinggu.clamp(4, 42);

      PemantauanIbuHamilModel? found;
      for (final item in allData) {
        if (item.mingguKehamilan == mingguSaatIni) {
          found = item;
          break;
        }
      }

      setState(() {
        _kehamilan = kehamilan;
        _allData = allData;
        _mingguSekarang = mingguSaatIni;
        _existingData = found;

        // Isi checklist dengan data yang sudah ada (jika ada)
        if (found != null) {
          demamLebih2Hari = found.demamLebih2Hari;
          sakitKepala = found.sakitKepala;
          cemasBerlebih = found.cemasBerlebih;
          resikoTB = found.resikoTB;
          gerakanBayiKurang = found.gerakanBayiKurang;
          nyeriPerut = found.nyeriPerut;
          cairanJalanLahir = found.cairanJalanLahir;
          masalahKemaluan = found.masalahKemaluan;
          diareBerulang = found.diareBerulang;
        } else {
          // Reset checklist untuk minggu baru
          demamLebih2Hari = false;
          sakitKepala = false;
          cemasBerlebih = false;
          resikoTB = false;
          gerakanBayiKurang = false;
          nyeriPerut = false;
          cairanJalanLahir = false;
          masalahKemaluan = false;
          diareBerulang = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      _showTopMessage(e.toString(), success: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Simpan ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _api.save(
        PemantauanIbuHamilModel(
          mingguKehamilan: _mingguSekarang,
          demamLebih2Hari: demamLebih2Hari,
          sakitKepala: sakitKepala,
          cemasBerlebih: cemasBerlebih,
          resikoTB: resikoTB,
          gerakanBayiKurang: gerakanBayiKurang,
          nyeriPerut: nyeriPerut,
          cairanJalanLahir: cairanJalanLahir,
          masalahKemaluan: masalahKemaluan,
          diareBerulang: diareBerulang,
        ),
      );

      if (!mounted) return;
      _showTopMessage('Pemantauan minggu $_mingguSekarang berhasil disimpan');
      await _loadAll();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      _showTopMessage(e.toString(), success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        title: const Text('Pemantauan Ibu Hamil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _buildMingguCard(),
                const SizedBox(height: 16),
                // ── Riwayat minggu yang sudah diisi ──────────────────────────
                if (_allData.isNotEmpty) ...[
                  _buildRiwayatSection(),
                  const SizedBox(height: 16),
                ],
                // ── Minggu terlewat ───────────────────────────────────────────
                if (_mingguTerlewat.isNotEmpty) ...[
                  _buildMingguTerlewatSection(),
                  const SizedBox(height: 16),
                ],
                // ── Form isian minggu ini ─────────────────────────────────────
                _buildChecklistCard(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
    );
  }

  // ── Widget: kartu minggu saat ini ─────────────────────────────────────────
  Widget _buildMingguCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lingkaran minggu
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_mingguSekarang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'minggu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minggu Pemantauan Saat Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _trimesterLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _sudahDiisi
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _sudahDiisi
                          ? Colors.greenAccent.shade200
                          : Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sudahDiisi
                          ? 'Sudah diisi minggu ini'
                          : 'Belum diisi minggu ini',
                      style: TextStyle(
                        color: _sudahDiisi
                            ? Colors.greenAccent.shade200
                            : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: riwayat pengisian (minggu yang sudah diisi) ───────────────────
  Widget _buildRiwayatSection() {
    final sorted = [..._allData]
      ..sort((a, b) => a.mingguKehamilan.compareTo(b.mingguKehamilan));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.history_rounded,
          label: 'Riwayat Pengisian',
          color: AppColors.primary,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final d = sorted[index];
              final isCurrentWeek = d.mingguKehamilan == _mingguSekarang;
              final adaKeluhan = _hasKeluhan(d);
              final isVerified = d.sudahDiverifikasi;

              return GestureDetector(
                onTap: () => _showRiwayatDetail(d),
                child: Container(
                  width: 68,
                  decoration: BoxDecoration(
                    color: isCurrentWeek
                        ? AppColors.primary
                        : (isVerified
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrentWeek
                          ? AppColors.primary
                          : (isVerified
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B)),
                      width: 1.5,
                    ),
                    boxShadow: isCurrentWeek
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mg ${d.mingguKehamilan}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isCurrentWeek
                              ? Colors.white
                              : (isVerified
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        isVerified
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_top_rounded,
                        size: 20,
                        color: isCurrentWeek
                            ? Colors.white
                            : (isVerified
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Widget: minggu terlewat (merah) ───────────────────────────────────────
  Widget _buildMingguTerlewatSection() {
    final terlewat = _mingguTerlewat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.warning_amber_rounded,
          label: 'Minggu Terlewat (${terlewat.length})',
          color: Colors.red.shade600,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Text(
            'Minggu-minggu berikut belum pernah diisi dan sudah terlewat. '
            'Data tidak dapat diisi lagi karena hanya minggu saat ini yang dapat diisi.',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.red.shade700,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: terlewat.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _buildMingguTerlewatChip(terlewat[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildMingguTerlewatChip(int minggu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close_rounded, size: 14, color: Colors.red.shade400),
          const SizedBox(width: 5),
          Text(
            'Minggu $minggu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: checklist keluhan (form isian minggu ini) ─────────────────────
  Widget _buildChecklistCard() {
    final locked = _sudahDiisi;
    final isVerified = _existingData?.sudahDiverifikasi ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: locked
              ? (isVerified
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B))
              : const Color(0xFFE2E8F0),
          width: locked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner status (hanya tampil kalau sudah diisi) ──────────────
          if (locked) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isVerified
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified
                        ? Icons.verified_rounded
                        : Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified
                              ? 'Sudah Diverifikasi Kader ✓'
                              : 'Menunggu Verifikasi Kader',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isVerified
                              ? 'Diverifikasi oleh ${_existingData!.namaKader} · ${_existingData!.tanggalVerifikasi}'
                              : 'Data sudah dikirim. Kader akan memverifikasi kehadiranmu.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Header judul ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: locked
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: locked
                        ? const Color(0xFF94A3B8)
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanda Bahaya / Keluhan — Minggu $_mingguSekarang',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        locked
                            ? (_jumlahKeluhan > 0
                                ? '$_jumlahKeluhan keluhan tercatat · tidak dapat diubah'
                                : 'Tidak ada keluhan · tidak dapat diubah')
                            : (_jumlahKeluhan > 0
                                ? '$_jumlahKeluhan keluhan ditandai'
                                : 'Tandai keluhan yang dirasakan'),
                        style: TextStyle(
                          fontSize: 12,
                          color: locked
                              ? const Color(0xFF94A3B8)
                              : (_jumlahKeluhan > 0
                                  ? Colors.orange.shade600
                                  : const Color(0xFF94A3B8)),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // ── Item checklist ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _buildItem('Demam lebih dari 2 hari',
                    Icons.thermostat_outlined, demamLebih2Hari,
                    (v) => setState(() => demamLebih2Hari = v),
                    locked: locked),
                _buildItem('Sakit kepala berat / menetap',
                    Icons.sick_outlined, sakitKepala,
                    (v) => setState(() => sakitKepala = v),
                    locked: locked),
                _buildItem('Cemas berlebihan',
                    Icons.sentiment_very_dissatisfied_outlined, cemasBerlebih,
                    (v) => setState(() => cemasBerlebih = v),
                    locked: locked),
                _buildItem('Risiko TB / batuk lama',
                    Icons.air_outlined, resikoTB,
                    (v) => setState(() => resikoTB = v),
                    locked: locked),
                _buildItem('Gerakan bayi berkurang',
                    Icons.child_friendly_outlined, gerakanBayiKurang,
                    (v) => setState(() => gerakanBayiKurang = v),
                    locked: locked),
                _buildItem('Nyeri perut hebat / tidak biasa',
                    Icons.warning_amber_outlined, nyeriPerut,
                    (v) => setState(() => nyeriPerut = v),
                    locked: locked),
                _buildItem('Keluar cairan dari jalan lahir',
                    Icons.water_drop_outlined, cairanJalanLahir,
                    (v) => setState(() => cairanJalanLahir = v),
                    locked: locked),
                _buildItem('Masalah pada kemaluan',
                    Icons.medical_services_outlined, masalahKemaluan,
                    (v) => setState(() => masalahKemaluan = v),
                    locked: locked),
                _buildItem('Diare berulang / tidak membaik',
                    Icons.sick, diareBerulang,
                    (v) => setState(() => diareBerulang = v),
                    locked: locked, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
    bool locked = false,
  }) {
    // Warna saat terkunci: item yang dicentang = abu gelap, tidak dicentang = sangat pudar
    final Color activeColor = locked ? const Color(0xFF64748B) : AppColors.primary;
    final Color activeBg = locked
        ? const Color(0xFFF1F5F9)
        : AppColors.primary.withOpacity(0.07);
    final Color activeBorder = locked
        ? const Color(0xFFCBD5E1)
        : AppColors.primary;
    final Color inactiveBg = locked
        ? const Color(0xFFFAFAFA)
        : const Color(0xFFF8FAFC);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: InkWell(
        onTap: locked || _saving ? null : () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: value ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? activeBorder : const Color(0xFFE2E8F0),
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: value
                      ? (locked
                          ? const Color(0xFFE2E8F0)
                          : AppColors.primary.withOpacity(0.12))
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: value ? activeColor : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                    color: value ? activeColor : const Color(0xFF475569),
                  ),
                ),
              ),
              if (locked)
                Icon(
                  value ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  size: 22,
                  color: value ? activeColor : const Color(0xFFCBD5E1),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: value ? AppColors.primary : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: value
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget: tombol simpan ─────────────────────────────────────────────────
  Widget _buildSaveButton() {
    // Kalau sudah diisi → sembunyikan tombol, tampilkan info saja
    if (_sudahDiisi) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(
              _saving
                  ? 'Menyimpan...'
                  : 'Simpan Pemantauan Minggu $_mingguSekarang',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Hanya dapat mengisi pemantauan untuk minggu saat ini (Minggu $_mingguSekarang)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // ── Helper: section header ────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Helper: apakah ada keluhan pada data ini ──────────────────────────────
  bool _hasKeluhan(PemantauanIbuHamilModel d) {
    return d.demamLebih2Hari ||
        d.sakitKepala ||
        d.cemasBerlebih ||
        d.resikoTB ||
        d.gerakanBayiKurang ||
        d.nyeriPerut ||
        d.cairanJalanLahir ||
        d.masalahKemaluan ||
        d.diareBerulang;
  }

  // ── Bottom sheet: detail riwayat satu minggu ──────────────────────────────
  void _showRiwayatDetail(PemantauanIbuHamilModel d) {
    final adaKeluhan = _hasKeluhan(d);
    final isCurrentWeek = d.mingguKehamilan == _mingguSekarang;

    final List<_KeluhanItem> allItems = [
      _KeluhanItem('Demam lebih dari 2 hari', Icons.thermostat_outlined, d.demamLebih2Hari),
      _KeluhanItem('Sakit kepala berat / menetap', Icons.sick_outlined, d.sakitKepala),
      _KeluhanItem('Cemas berlebihan', Icons.sentiment_very_dissatisfied_outlined, d.cemasBerlebih),
      _KeluhanItem('Risiko TB / batuk lama', Icons.air_outlined, d.resikoTB),
      _KeluhanItem('Gerakan bayi berkurang', Icons.child_friendly_outlined, d.gerakanBayiKurang),
      _KeluhanItem('Nyeri perut hebat / tidak biasa', Icons.warning_amber_outlined, d.nyeriPerut),
      _KeluhanItem('Keluar cairan dari jalan lahir', Icons.water_drop_outlined, d.cairanJalanLahir),
      _KeluhanItem('Masalah pada kemaluan', Icons.medical_services_outlined, d.masalahKemaluan),
      _KeluhanItem('Diare berulang / tidak membaik', Icons.sick, d.diareBerulang),
    ];

    // Format tanggal diisi
    String tanggalDiisi = '-';
    if (d.createdAt != null) {
      final dt = d.createdAt!.toLocal();
      const bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      tanggalDiisi = '${dt.day} ${bulan[dt.month]} ${dt.year}';
    }

    final isVerified = d.sudahDiverifikasi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isCurrentWeek
                            ? AppColors.primary.withOpacity(0.1)
                            : (adaKeluhan
                                ? Colors.orange.shade50
                                : Colors.green.shade50),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${d.mingguKehamilan}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isCurrentWeek
                                ? AppColors.primary
                                : (adaKeluhan
                                    ? Colors.orange.shade600
                                    : Colors.green.shade600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Minggu ${d.mingguKehamilan}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (isCurrentWeek) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Minggu ini',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Diisi: $tanggalDiisi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Badge status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: adaKeluhan
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: adaKeluhan
                              ? Colors.orange.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            adaKeluhan
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                            color: adaKeluhan
                                ? Colors.orange.shade600
                                : Colors.green.shade600,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            adaKeluhan ? 'Ada\nKeluhan' : 'Aman',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: adaKeluhan
                                  ? Colors.orange.shade600
                                  : Colors.green.shade600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const SizedBox(height: 10),
              // ── Badge status verifikasi kader ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isVerified
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified_rounded
                            : Icons.hourglass_top_rounded,
                        size: 18,
                        color: isVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isVerified
                                  ? 'Sudah Diverifikasi Kader'
                                  : 'Menunggu Verifikasi Kader',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isVerified
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Oleh ${d.namaKader} · ${d.tanggalVerifikasi}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF059669)
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade100),
              // Daftar keluhan
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  itemCount: allItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = allItems[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: item.value
                            ? Colors.orange.shade50
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: item.value
                              ? Colors.orange.shade200
                              : const Color(0xFFE2E8F0),
                          width: item.value ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: item.value
                                  ? Colors.orange.shade100
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              size: 17,
                              color: item.value
                                  ? Colors.orange.shade700
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item.value
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: item.value
                                    ? Colors.orange.shade800
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Icon(
                            item.value
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: item.value
                                ? Colors.orange.shade500
                                : const Color(0xFFCBD5E1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class sederhana untuk item keluhan di bottom sheet.
class _KeluhanItem {
  final String label;
  final IconData icon;
  final bool value;

  const _KeluhanItem(this.label, this.icon, this.value);
}