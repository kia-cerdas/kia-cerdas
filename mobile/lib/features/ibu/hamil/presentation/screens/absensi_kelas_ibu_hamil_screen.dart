// import 'package:flutter/material.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/absensi_kelas_ibu_hamil_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/absensi_kelas_ibu_hamil_model.dart';
// import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// class AbsensiKelasIbuHamilScreen extends StatefulWidget {
//   const AbsensiKelasIbuHamilScreen({super.key});

//   @override
//   State<AbsensiKelasIbuHamilScreen> createState() =>
//       _AbsensiKelasIbuHamilScreenState();
// }

// class _AbsensiKelasIbuHamilScreenState
//     extends State<AbsensiKelasIbuHamilScreen> {
//   static const int _maxSesi = 9;

//   final _apiService = AbsensiKelasIbuHamilApiService();

//   // Menyimpan data per sesi: tanggal yang dipilih & status dari server
//   final List<DateTime?> _selectedDates = List.filled(_maxSesi, null);
//   final List<String> _namaKaderList = List.filled(_maxSesi, '');
//   final List<String> _statusList =
//       List.filled(_maxSesi, ''); // '' = belum diisi ibu
//   final List<int?> _idList = List.filled(_maxSesi, null);

//   bool _isLoading = false;
//   // index sesi yang sedang dalam proses simpan
//   final Set<int> _savingIndices = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadAbsensi();
//   }

//   @override
//   void dispose() {
//     _apiService.dispose();
//     super.dispose();
//   }

//   Future<void> _loadAbsensi() async {
//     setState(() => _isLoading = true);
//     try {
//       final list = await _apiService.getMine();
//       for (final item in list) {
//         final idx = item.pertemuanKe - 1;
//         if (idx >= 0 && idx < _maxSesi) {
//           _idList[idx] = item.id;
//           _namaKaderList[idx] = item.namaKader;
//           _statusList[idx] = item.status;
//           if (item.tanggal.isNotEmpty) {
//             _selectedDates[idx] = DateTime.tryParse(item.tanggal);
//           }
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   /// Apakah baris ini sudah dikunci (tidak bisa diubah ibu)
//   /// — sudah disimpan ke server (ada id) — baik menunggu maupun sudah terverifikasi
//   bool _isLocked(int index) => _idList[index] != null;

//   /// Ibu tap tombol "Tandai Hadir" pada sesi [index]
//   Future<void> _handleHadir(int index) async {
//     // Minta konfirmasi dulu
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Konfirmasi Kehadiran Sesi ${index + 1}'),
//         content: const Text(
//           'Apakah Anda yakin ingin menandai kehadiran pada sesi ini?\n\n'
//           'Data yang sudah disimpan tidak dapat diubah kembali.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Ya, Tandai Hadir'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     // Pilih tanggal
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: DateTime(now.year - 2),
//       lastDate: now,
//       helpText: 'Pilih tanggal hadir sesi ${index + 1}',
//       cancelText: 'Batal',
//       confirmText: 'Pilih',
//     );

//     if (picked == null) return;

//     setState(() => _savingIndices.add(index));

//     try {
//       final saved = await _apiService.save(
//         AbsensiKelasIbuHamilModel(
//           pertemuanKe: index + 1,
//           tanggal:
//               '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
//           namaKader: '',
//           tanggalParaf: '',
//         ),
//       );

//       setState(() {
//         _idList[index] = saved.id;
//         _selectedDates[index] = picked;
//         _statusList[index] = saved.status;
//         _namaKaderList[index] = saved.namaKader;
//       });

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Kehadiran sesi ${index + 1} berhasil dicatat'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
//       );
//     } finally {
//       if (mounted) setState(() => _savingIndices.remove(index));
//     }
//   }

//   String _formatDisplay(DateTime date) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
//       'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   /// Badge status verifikasi
//   Widget _buildStatusBadge(int index) {
//     final status = _statusList[index];
//     final hasDate = _selectedDates[index] != null;

//     if (!hasDate) {
//       // Belum diisi ibu sama sekali
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF3F4F6),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: const Color(0xFFD1D5DB)),
//         ),
//         child: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.radio_button_unchecked, size: 11, color: Color(0xFF9CA3AF)),
//             SizedBox(width: 4),
//             Text(
//               'Belum Hadir',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF6B7280),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final isVerified = status == 'Terverifikasi';
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
//             size: 11,
//             color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             isVerified ? 'Terverifikasi' : 'Menunggu',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color:
//                   isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F8FC),
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//         // ── Arrow back putih ──
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Absensi Kelas Ibu Hamil',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1.0),
//           child: Container(color: Colors.white24, height: 1.0),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadAbsensi,
//               child: ListView(
//                 padding: const EdgeInsets.all(20),
//                 children: [
//                   _buildInfoCard(),
//                   const SizedBox(height: 16),
//                   _buildAttendanceTable(),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildInfoCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE5ECF6)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: const BoxDecoration(
//               color: Color(0xFFFFF5D6),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.fact_check_outlined,
//               color: Color(0xFFE0A300),
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 14),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Absensi Kehadiran Kelas Ibu Hamil',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF172033),
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   'Tap tombol "Tandai Hadir" untuk mencatat kehadiran tiap sesi. Setelah disimpan, kader akan memverifikasi kehadiran Anda.',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF7B8798),
//                     height: 1.35,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceTable() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFD7DEE9)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(18),
//         child: Column(
//           children: [
//             _buildHeaderRow(),
//             ...List.generate(_maxSesi, _buildAttendanceRow),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderRow() {
//     return Container(
//       color: const Color(0xFFFFF0B8),
//       child: Row(
//         children: const [
//           _TableHeaderCell(text: 'No.', flex: 1, alignment: TextAlign.center),
//           _VerticalDividerLine(),
//           _TableHeaderCell(text: 'Kehadiran Ibu', flex: 5),
//           _VerticalDividerLine(),
//           _TableHeaderCell(text: 'Status', flex: 4, alignment: TextAlign.center),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceRow(int index) {
//     final isLocked = _isLocked(index);
//     final isSavingThis = _savingIndices.contains(index);
//     final date = _selectedDates[index];
//     // Baris ini hanya bisa diisi kalau baris sebelumnya sudah terisi
//     final isPrevLocked = index == 0 || _isLocked(index - 1);

//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: index == 0
//                 ? const Color(0xFFD7DEE9)
//                 : const Color(0xFFE8EDF4),
//           ),
//         ),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             // ── No ──
//             Expanded(
//               flex: 1,
//               child: Center(
//                 child: Text(
//                   '${index + 1}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF172033),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//             const _VerticalDividerLine(),

//             // ── Kolom Kehadiran Ibu ──
//             Expanded(
//               flex: 5,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                 child: isLocked
//                     // Sudah disimpan: tampilkan tanggal + ikon kunci
//                     ? Row(
//                         children: [
//                           const Icon(Icons.check_circle_rounded,
//                               size: 16, color: Color(0xFF10B981)),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               date != null ? _formatDisplay(date) : '-',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF172033),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           const Icon(Icons.lock_rounded,
//                               size: 14, color: Color(0xFFD1D5DB)),
//                         ],
//                       )
//                     // Belum disimpan: tombol tandai hadir
//                     : SizedBox(
//                         height: 36,
//                         child: ElevatedButton.icon(
//                           onPressed: isSavingThis || !isPrevLocked
//                               ? null
//                               : () => _handleHadir(index),
//                           icon: isSavingThis
//                               ? const SizedBox(
//                                   width: 14,
//                                   height: 14,
//                                   child: CircularProgressIndicator(
//                                       strokeWidth: 2, color: Colors.white),
//                                 )
//                               : const Icon(Icons.how_to_reg_rounded, size: 16),
//                           label: Text(
//                             isSavingThis ? 'Menyimpan...' : 'Tandai Hadir',
//                             style: const TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                             disabledBackgroundColor: Colors.grey.shade300,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//             const _VerticalDividerLine(),

//             // ── Kolom Status ──
//             Expanded(
//               flex: 4,
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: _buildStatusBadge(index),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TableHeaderCell extends StatelessWidget {
//   final String text;
//   final int flex;
//   final TextAlign alignment;

//   const _TableHeaderCell({
//     required this.text,
//     required this.flex,
//     this.alignment = TextAlign.left,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//         child: Text(
//           text,
//           textAlign: alignment,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w800,
//             color: Color(0xFF2F2F2F),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _VerticalDividerLine extends StatelessWidget {
//   const _VerticalDividerLine();

//   @override
//   Widget build(BuildContext context) {
//     return Container(width: 1, color: const Color(0xFFD7DEE9));
//   }
// }


// =============================================================
// SCREEN: Absensi Kelas Ibu Hamil
// -------------------------------------------------------------
// VERSI BARU — pola "buku tamu" (bebas kirim), bukan lagi
// "kotak telur 9 slot". Ibu bisa menambah absensi terus selama
// absensi sebelumnya sudah diverifikasi kader.
//
// Desain mengikuti layar Absensi Kelas Ibu Balita agar konsisten,
// tetapi warna & judul tetap memakai identitas Ibu Hamil
// (AppColors.primary + aksen kuning) supaya tetap satu keluarga.
// =============================================================

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/absensi_kelas_ibu_hamil_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/absensi_kelas_ibu_hamil_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/widgets/verification_popup.dart';

class AbsensiKelasIbuHamilScreen extends StatefulWidget {
  const AbsensiKelasIbuHamilScreen({super.key});

  @override
  State<AbsensiKelasIbuHamilScreen> createState() =>
      _AbsensiKelasIbuHamilScreenState();
}

class _AbsensiKelasIbuHamilScreenState
    extends State<AbsensiKelasIbuHamilScreen> {
  final _apiService = AbsensiKelasIbuHamilApiService();

  // Daftar absensi yang dimuat dari server. Panjangnya dinamis
  // (bisa 0, 5, 12, ... tak terbatas) — inilah inti "buku tamu".
  List<AbsensiKelasIbuHamilModel> _absensiList = [];
  bool _isLoading = false;

  // ── Pagination ──
  static const int _pageSize = 10;
  int _currentPage = 0;

  int get _totalPages => (_absensiList.length / _pageSize).ceil().clamp(1, 999);
  List<AbsensiKelasIbuHamilModel> get _pagedList {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _absensiList.length);
    return _absensiList.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _loadAbsensi();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  // Ambil ulang seluruh data dari server.
  Future<void> _loadAbsensi() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getMine();
      setState(() {
        _absensiList = list;
        _currentPage = 0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Ringkasan untuk kartu LOG KEHADIRAN ──
  int get _totalHadir => _absensiList.length;
  int get _terverifikasi =>
      _absensiList.where((a) => a.status == 'Terverifikasi').length;

  // Apakah masih ada yang menunggu verifikasi kader?
  // Kalau ya, tombol "Tambah Absensi" dikunci (sama seperti Balita).
  bool get _adaYangBelumVerifikasi =>
      _absensiList.any((a) => a.status == 'Menunggu Verifikasi');




  // =============================================================
  // BOTTOM SHEET: form "Isi Absensi Baru"
  // Muncul dari bawah saat tombol "Tambah Absensi" ditekan.
  // =============================================================
  void _showTambahAbsensi() {
    DateTime? selectedDate;
    final dateController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // StatefulBuilder dipakai supaya isi bottom sheet bisa
        // berubah sendiri (misal teks tanggal) tanpa menutup sheet.
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header bottom sheet ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Isi Absensi Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Label + kotak pemilih tanggal ──
                  const Text(
                    'Pilih Tanggal Hadir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate ?? now,
                        firstDate: DateTime(now.year - 2),
                        lastDate: now,
                        helpText: 'Pilih tanggal hadir',
                        cancelText: 'Batal',
                        confirmText: 'Pilih',
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                          dateController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateController.text.isEmpty
                                  ? 'DD/MM/YYYY'
                                  : dateController.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: dateController.text.isEmpty
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined,
                              size: 20, color: Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Kotak info kuning (identitas Ibu Hamil) ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFBBF24)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline,
                            size: 18, color: Color(0xFFD97706)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Data kehadiran yang Anda kirim akan diverifikasi oleh kader. Anda dapat menambah absensi baru setelah absensi sebelumnya diverifikasi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tombol Kirim Absensi ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving || selectedDate == null
                          ? null
                          : () {
                              // Konfirmasi dulu sebelum benar-benar kirim.
                              showVerificationPopup(
                                context: context,
                                type: VerificationPopupType.save,
                                title: 'Konfirmasi Simpan',
                                content:
                                    'Apakah Anda yakin data absensi sudah benar? Data yang sudah dikirim tidak dapat diubah kembali.',
                                onConfirm: () async {
                                  Navigator.pop(context); // tutup popup
                                  setModalState(() => isSaving = true);
                                  try {
                                    final newItem = await _apiService.save(
                                      AbsensiKelasIbuHamilModel(
                                        // pertemuanKe dikirim 0 saja;
                                        // backend yang menghitung nomor asli.
                                        pertemuanKe: 0,
                                        tanggal:
                                            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                        namaKader: '',
                                        tanggalParaf: '',
                                      ),
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(ctx); // tutup bottom sheet
                                    setState(
                                        () => _absensiList.add(newItem));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Absensi berhasil dikirim'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } catch (e) {
                                    setModalState(() => isSaving = false);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                onCancel: () => Navigator.pop(context),
                              );
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        isSaving ? 'Mengirim...' : 'Kirim Absensi',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Ubah "2025-06-16" -> "16 Jun 2025" untuk ditampilkan.
  String _formatTanggal(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // Badge status: hanya 2 kemungkinan (Menunggu / Terverifikasi).
  Widget _buildStatusBadge(String status) {
    final isVerified = status == 'Terverifikasi';

    final Color bgColor =
        isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);
    final Color borderColor =
        isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final Color textColor =
        isVerified ? const Color(0xFF059669) : const Color(0xFFD97706);
    final IconData iconData = isVerified
        ? Icons.verified_rounded
        : Icons.hourglass_top_rounded;
    final String textLabel = isVerified ? 'Terverifikasi' : 'Menunggu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            textLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Absensi Kelas Ibu Hamil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white24, height: 1.0),
        ),
      ),
      body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAbsensi,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Banner info kuning di atas ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFBBF24)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline,
                              size: 18, color: Color(0xFFD97706)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tekan tombol "Tambah Absensi" untuk mencatat kehadiran. Setiap absensi akan diverifikasi oleh kader.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Kartu LOG KEHADIRAN ──
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Text(
                              'LOG KEHADIRAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          // Ringkasan: total hadir & terverifikasi
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _SummaryBox(
                                    label: 'Total hadir',
                                    value: '$_totalHadir kali',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryBox(
                                    label: 'Terverifikasi',
                                    value: '$_terverifikasi kali',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tabel hanya muncul kalau sudah ada data
                          if (_absensiList.isNotEmpty) ...[
                            const Divider(height: 1),
                            // Header tabel
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Text('No',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6B7280))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('Tanggal',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6B7280))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('Nama Kader',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6B7280))),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text('Status',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6B7280))),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Baris-baris data (paginated)
                            ...List.generate(_pagedList.length, (i) {
                              final globalIndex = _currentPage * _pageSize + i;
                              final item = _pagedList[i];
                              final isLast = i == _pagedList.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          child: Text('${globalIndex + 1}',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF374151))),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            _formatTanggal(item.tanggal),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF374151)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.namaKader.isNotEmpty
                                                ? item.namaKader
                                                : '-',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF374151)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Center(
                                            child: _buildStatusBadge(
                                                item.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) const Divider(height: 1),
                                ],
                              );
                            }),
                            // ── Pagination controls ──
                            if (_totalPages > 1) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Halaman ${_currentPage + 1} dari $_totalPages',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280)),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.chevron_left_rounded),
                                          onPressed: _currentPage > 0
                                              ? () => setState(
                                                  () => _currentPage--)
                                              : null,
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.chevron_right_rounded),
                                          onPressed:
                                              _currentPage < _totalPages - 1
                                                  ? () => setState(
                                                      () => _currentPage++)
                                                  : null,
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(),
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Center(
                                child: Text(
                                  'Belum ada data kehadiran',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9CA3AF)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Banner peringatan jika ada yang belum diverifikasi ──
                    if (_adaYangBelumVerifikasi) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: const Color(0xFFFB923C)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lock_clock_rounded,
                                size: 16, color: Color(0xFFEA580C)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Masih ada absensi yang menunggu verifikasi kader. Absensi baru dapat ditambahkan setelah diverifikasi.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEA580C),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Tombol Tambah Absensi (dikunci jika ada yg belum verif) ──
                    Tooltip(
                      message: _adaYangBelumVerifikasi
                          ? 'Tunggu verifikasi kader terlebih dahulu'
                          : '',
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _adaYangBelumVerifikasi
                              ? null
                              : _showTambahAbsensi,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text(
                            'Tambah Absensi',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// Kotak ringkasan kecil (Total hadir / Terverifikasi).
class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}