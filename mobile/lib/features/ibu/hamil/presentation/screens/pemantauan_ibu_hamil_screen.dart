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

// ─────────────────────────────────────────────────────────────────────────────
// Pemantauan Ibu Hamil — Desain Baru (log per minggu, status jelas)
// ─────────────────────────────────────────────────────────────────────────────

class PemantauanIbuHamilScreen extends StatefulWidget {
  const PemantauanIbuHamilScreen({super.key});

  @override
  State<PemantauanIbuHamilScreen> createState() =>
      _PemantauanIbuHamilScreenState();
}

class _PemantauanIbuHamilScreenState extends State<PemantauanIbuHamilScreen> {
  final _api = PemantauanIbuHamilApiService();
  final _kehamilanApi = KehamilanApiService();

  KehamilanAktifModel? _kehamilan;
  List<PemantauanIbuHamilModel> _allData = [];
  int _mingguSekarang = 0;

  bool _loading = false;
  bool _saving = false;

  // ── State form isian (hanya untuk minggu saat ini) ────────────────────────
  bool demamLebih2Hari = false;
  bool sakitKepala = false;
  bool cemasBerlebih = false;
  bool resikoTB = false;
  bool gerakanBayiKurang = false;
  bool nyeriPerut = false;
  bool cairanJalanLahir = false;
  bool masalahKemaluan = false;
  bool diareBerulang = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  /// Data minggu saat ini (null = belum diisi)
  PemantauanIbuHamilModel? get _dataSekarang {
    for (final d in _allData) {
      if (d.mingguKehamilan == _mingguSekarang) return d;
    }
    return null;
  }

  bool get _sudahDiisiSekarang => _dataSekarang != null;

  /// Seluruh minggu dari 4 s/d _mingguSekarang (diurutkan terbaru di atas)
  List<int> get _semuaMinggu {
    if (_mingguSekarang < 4) return [];
    return List.generate(_mingguSekarang - 3, (i) => _mingguSekarang - i);
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

  // ── Load ──────────────────────────────────────────────────────────────────
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
          demamLebih2Hari = sakitKepala = cemasBerlebih = resikoTB =
              gerakanBayiKurang = nyeriPerut = cairanJalanLahir =
                  masalahKemaluan = diareBerulang = false;
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
      await _api.save(PemantauanIbuHamilModel(
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
      ));
      if (!mounted) return;
      _showTopMessage('Pemantauan minggu $_mingguSekarang berhasil disimpan');
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      _showTopMessage(e.toString(), success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Notifikasi ────────────────────────────────────────────────────────────
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
              borderRadius: BorderRadius.circular(16),
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

  // ── Build utama ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Pemantauan Ibu Hamil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // ── Header ringkas minggu saat ini ───────────────────────
                _buildHeaderCard(),
                const SizedBox(height: 20),

                // ── Label seksi log ──────────────────────────────────────
                _buildSeksiLabel(
                  icon: Icons.list_alt_rounded,
                  label: 'Log Pemantauan Mingguan',
                ),
                const SizedBox(height: 10),

                // ── Log per minggu (daftar) ──────────────────────────────
                ..._semuaMinggu.map((minggu) => _buildLogItem(minggu)),

                // ── Form isian (hanya muncul jika minggu ini belum diisi)─
                if (!_sudahDiisiSekarang) ...[
                  const SizedBox(height: 24),
                  _buildFormIsian(),
                ],
              ],
            ),
    );
  }

  // ── Header: info minggu & trimester ──────────────────────────────────────
  Widget _buildHeaderCard() {
    final trimester = _mingguSekarang <= 12
        ? 'Trimester I'
        : _mingguSekarang <= 27
            ? 'Trimester II'
            : 'Trimester III';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Lingkaran angka minggu
          Container(
            width: 60,
            height: 60,
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
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Text(
                  'minggu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usia Kehamilan Saat Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trimester,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _sudahDiisiSekarang
                          ? Icons.check_circle_rounded
                          : Icons.edit_note_rounded,
                      color: _sudahDiisiSekarang
                          ? Colors.greenAccent.shade200
                          : Colors.white60,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _sudahDiisiSekarang
                          ? 'Minggu ini sudah diisi'
                          : 'Minggu ini belum diisi',
                      style: TextStyle(
                        color: _sudahDiisiSekarang
                            ? Colors.greenAccent.shade200
                            : Colors.white70,
                        fontSize: 11,
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

  // ── Label seksi ───────────────────────────────────────────────────────────
  Widget _buildSeksiLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Satu baris log per minggu ─────────────────────────────────────────────
  Widget _buildLogItem(int minggu) {
    final isSekarang = minggu == _mingguSekarang;

    // Cari data untuk minggu ini
    PemantauanIbuHamilModel? data;
    for (final d in _allData) {
      if (d.mingguKehamilan == minggu) {
        data = d;
        break;
      }
    }

    final sudahDiisi = data != null;
    final sudahVerifikasi = data?.sudahDiverifikasi ?? false;

    // ── Status: warna & label ──────────────────────────────────────────────
    // 🟢 Hijau  = sudah diisi DAN sudah diverifikasi kader
    // 🟡 Kuning = sudah diisi, belum diverifikasi kader
    // 🔵 Biru   = tidak ada input = tidak ada keluhan dilaporkan = aman
    //            (merah dihapus — tidak ada input bukan berarti ada masalah)
    final Color statusColor;
    final Color statusBg;
    final Color statusBorder;
    final IconData statusIcon;
    final String statusLabel;

    if (sudahVerifikasi) {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFD1FAE5);
      statusBorder = const Color(0xFF6EE7B7);
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Terverifikasi';
    } else if (sudahDiisi) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusBorder = const Color(0xFFFCD34D);
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = 'Menunggu verifikasi';
    } else {
      // [PERUBAHAN] Tidak ada input = tidak ada keluhan = aman (biru, bukan merah)
      statusColor = AppColors.primary;
      statusBg = AppColors.primary.withOpacity(0.08);
      statusBorder = AppColors.primary.withOpacity(0.25);
      statusIcon = isSekarang ? Icons.edit_note_rounded : Icons.shield_outlined;
      statusLabel = isSekarang ? 'Belum diisi' : 'Tidak ada keluhan';
    }

    // Hitung jumlah keluhan
    final jumlahKeluhan = data != null ? _countKeluhan(data) : 0;

    return GestureDetector(
      onTap: sudahDiisi ? () => _showDetailBottomSheet(data!) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSekarang
              ? AppColors.primary.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSekarang
                ? AppColors.primary.withOpacity(0.25)
                : const Color(0xFFE5E7EB),
            width: isSekarang ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Nomor minggu ──────────────────────────────────────────────
            SizedBox(
              width: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mg $minggu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSekarang
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (isSekarang)
                    Text(
                      'Ini',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),

            // ── Garis pemisah vertikal ────────────────────────────────────
            Container(
              width: 1,
              height: 36,
              color: const Color(0xFFE5E7EB),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // ── Tengah: info keluhan ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sudahDiisi)
                    Text(
                      jumlahKeluhan > 0
                          ? '$jumlahKeluhan keluhan tercatat'
                          : 'Tidak ada keluhan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: jumlahKeluhan > 0
                            ? Colors.orange.shade700
                            : AppColors.textSecondary,
                      ),
                    )
                  else
                    // [PERUBAHAN] Tidak ada input = tidak ada keluhan = aman
                    Text(
                      isSekarang ? 'Isi di bawah ↓' : 'Tidak ada keluhan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSekarang
                            ? AppColors.textHint
                            : AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  if (sudahVerifikasi && data != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Oleh ${data.namaKader}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Status badge ──────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Panah detail (hanya jika sudah diisi) ─────────────────────
            if (sudahDiisi) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textHint),
            ],
          ],
        ),
      ),
    );
  }

  // ── Form isian checklist (muncul di bawah list, hanya jika belum diisi) ───
  Widget _buildFormIsian() {
    final jumlahKeluhan = [
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeksiLabel(
          icon: Icons.edit_rounded,
          label: 'Isi Pemantauan Minggu $_mingguSekarang',
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // Sub-header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tanda Bahaya / Keluhan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (jumlahKeluhan > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          '$jumlahKeluhan ditandai',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              // Item checklist
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    _buildCheckItem('Demam lebih dari 2 hari',
                        Icons.thermostat_outlined, demamLebih2Hari,
                        (v) => setState(() => demamLebih2Hari = v)),
                    _buildCheckItem('Sakit kepala berat / menetap',
                        Icons.sick_outlined, sakitKepala,
                        (v) => setState(() => sakitKepala = v)),
                    _buildCheckItem('Cemas berlebihan',
                        Icons.sentiment_very_dissatisfied_outlined, cemasBerlebih,
                        (v) => setState(() => cemasBerlebih = v)),
                    _buildCheckItem('Risiko TB / batuk lama',
                        Icons.air_outlined, resikoTB,
                        (v) => setState(() => resikoTB = v)),
                    _buildCheckItem('Gerakan bayi berkurang',
                        Icons.child_friendly_outlined, gerakanBayiKurang,
                        (v) => setState(() => gerakanBayiKurang = v)),
                    _buildCheckItem('Nyeri perut hebat / tidak biasa',
                        Icons.warning_amber_outlined, nyeriPerut,
                        (v) => setState(() => nyeriPerut = v)),
                    _buildCheckItem('Keluar cairan dari jalan lahir',
                        Icons.water_drop_outlined, cairanJalanLahir,
                        (v) => setState(() => cairanJalanLahir = v)),
                    _buildCheckItem('Masalah pada kemaluan',
                        Icons.medical_services_outlined, masalahKemaluan,
                        (v) => setState(() => masalahKemaluan = v)),
                    _buildCheckItem('Diare berulang / tidak membaik',
                        Icons.sick, diareBerulang,
                        (v) => setState(() => diareBerulang = v),
                        isLast: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Tombol simpan
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(
              _saving ? 'Menyimpan...' : 'Simpan Minggu $_mingguSekarang',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Satu item checklist ───────────────────────────────────────────────────
  Widget _buildCheckItem(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: InkWell(
        onTap: _saving ? null : () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withOpacity(0.06)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value
                  ? AppColors.primary.withOpacity(0.4)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: value ? AppColors.primary : AppColors.textHint,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    color: value ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: value
                        ? AppColors.primary
                        : const Color(0xFFD1D5DB),
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom sheet detail minggu ────────────────────────────────────────────
  void _showDetailBottomSheet(PemantauanIbuHamilModel d) {
    final isVerified = d.sudahDiverifikasi;
    final jumlahKeluhan = _countKeluhan(d);

    final items = _buildKeluhanItems(d);

    // Format tanggal
    String tanggalDiisi = '-';
    if (d.createdAt != null) {
      final dt = d.createdAt!.toLocal();
      const bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      tanggalDiisi = '${dt.day} ${bulan[dt.month]} ${dt.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Header bottom sheet ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  children: [
                    // Lingkaran nomor minggu
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${d.mingguKehamilan}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minggu ${d.mingguKehamilan}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Diisi: $tanggalDiisi · $jumlahKeluhan keluhan',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Badge status verifikasi ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isVerified
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFFCD34D),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified_rounded
                            : Icons.hourglass_top_rounded,
                        size: 16,
                        color: isVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isVerified
                              ? 'Sudah diverifikasi oleh ${d.namaKader} · ${d.tanggalVerifikasi}'
                              : 'Menunggu verifikasi kader',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isVerified
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              // ── Daftar keluhan ──────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: item.value
                            ? Colors.orange.shade50
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item.value
                              ? Colors.orange.shade200
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 16,
                            color: item.value
                                ? Colors.orange.shade600
                                : AppColors.textHint,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item.value
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: item.value
                                    ? Colors.orange.shade800
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Icon(
                            item.value
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: item.value
                                ? Colors.orange.shade500
                                : const Color(0xFFD1D5DB),
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  int _countKeluhan(PemantauanIbuHamilModel d) => [
        d.demamLebih2Hari,
        d.sakitKepala,
        d.cemasBerlebih,
        d.resikoTB,
        d.gerakanBayiKurang,
        d.nyeriPerut,
        d.cairanJalanLahir,
        d.masalahKemaluan,
        d.diareBerulang,
      ].where((e) => e).length;

  List<_KeluhanItem> _buildKeluhanItems(PemantauanIbuHamilModel d) => [
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
}

class _KeluhanItem {
  final String label;
  final IconData icon;
  final bool value;
  const _KeluhanItem(this.label, this.icon, this.value);
}