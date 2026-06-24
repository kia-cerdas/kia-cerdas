import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/absensi_kelas_ibu_hamil_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/absensi_kelas_ibu_hamil_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/widgets/verification_popup.dart';
// Untuk validasi
import 'package:ta_pa2_pa3_project/core/widgets/confirm_helper.dart';

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
  bool _isBottomSheetOpen = false;

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
      setState(() => _absensiList = list);
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

  // CATATAN:
  // Fungsi popup konfirmasi keluar sengaja DIBIARKAN di sini (tidak dihapus)
  // supaya mudah diaktifkan lagi bila suatu saat dibutuhkan.
  // Saat ini TIDAK dipanggil dari mana pun, jadi ibu bisa keluar langsung.
  // ignore: unused_element
  void _showExitPopup() {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.exit,
      title: 'Yakin ingin keluar?',
      content:
          'Apakah Anda yakin ingin keluar dari halaman ini? Data yang belum dikirim tidak akan tersimpan.',
      onConfirm: () {
        Navigator.pop(context); // tutup popup
        Navigator.pop(context); // keluar dari halaman
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  // =============================================================
  // BOTTOM SHEET: form "Isi Absensi Baru"
  // Muncul dari bawah saat tombol "Tambah Absensi" ditekan.
  // =============================================================
  // void _showTambahAbsensi() {
  //   DateTime? selectedDate;
  //   final dateController = TextEditingController();
  //   bool isSaving = false;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) {
  //       // StatefulBuilder dipakai supaya isi bottom sheet bisa
  //       // berubah sendiri (misal teks tanggal) tanpa menutup sheet.
  //       return StatefulBuilder(
  //         builder: (ctx, setModalState) {
  //           return Padding(
  //             padding: EdgeInsets.only(
  //               left: 20,
  //               right: 20,
  //               top: 20,
  //               bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // ── Header bottom sheet ──
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       'Isi Absensi Baru',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w700,
  //                         color: Color(0xFF1A1A2E),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(ctx),
  //                       padding: EdgeInsets.zero,
  //                       constraints: const BoxConstraints(),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // ── Label + kotak pemilih tanggal ──
  //                 const Text(
  //                   'Pilih Tanggal Hadir',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(0xFF374151),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 GestureDetector(
  //                   onTap: () async {
  //                     final now = DateTime.now();
  //                     final picked = await showDatePicker(
  //                       context: ctx,
  //                       initialDate: selectedDate ?? now,
  //                       firstDate: DateTime(now.year - 2),
  //                       lastDate: now,
  //                       helpText: 'Pilih tanggal hadir',
  //                       cancelText: 'Batal',
  //                       confirmText: 'Pilih',
  //                     );
  //                     if (picked != null) {
  //                       setModalState(() {
  //                         selectedDate = picked;
  //                         dateController.text =
  //                             '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
  //                       });
  //                     }
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 14, vertical: 14),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: const Color(0xFFD1D5DB)),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             dateController.text.isEmpty
  //                                 ? 'DD/MM/YYYY'
  //                                 : dateController.text,
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: dateController.text.isEmpty
  //                                   ? const Color(0xFF9CA3AF)
  //                                   : const Color(0xFF1A1A2E),
  //                             ),
  //                           ),
  //                         ),
  //                         const Icon(Icons.calendar_today_outlined,
  //                             size: 20, color: Color(0xFF6B7280)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // ── Kotak info kuning (identitas Ibu Hamil) ──
  //                 Container(
  //                   padding: const EdgeInsets.all(14),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFFEF3C7),
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(color: const Color(0xFFFBBF24)),
  //                   ),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: const [
  //                       Icon(Icons.info_outline,
  //                           size: 18, color: Color(0xFFD97706)),
  //                       SizedBox(width: 10),
  //                       Expanded(
  //                         child: Text(
  //                           'Data kehadiran yang Anda kirim akan diverifikasi oleh kader. Anda dapat menambah absensi baru setelah absensi sebelumnya diverifikasi.',
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Color(0xFF92400E),
  //                             height: 1.4,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // ── Tombol Kirim Absensi ──
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: ElevatedButton.icon(
  //                     onPressed: isSaving || selectedDate == null
  //                         ? null
  //                         : () async {
  //                             // ──────────────────────────────────────────────
  //                             // VALIDASI KONFIRMASI SAAT MENGIRIM ABSENSI
  //                             // (ini TETAP ada — beda dengan validasi keluar)
  //                             // ──────────────────────────────────────────────
  //                             final tanggalFormatted = dateController.text;

  //                             final confirmed = await context.showConfirm(
  //                               title: 'Konfirmasi Absensi',
  //                               message:
  //                                   'Apakah ibu benar-benar hadir di kelas ibu hamil pada tanggal $tanggalFormatted? Data yang sudah dikirim tidak dapat diubah.',
  //                               confirmText: 'Ya, Hadir',
  //                               cancelText: 'Batal',
  //                             );

  //                             if (!confirmed) return;
  //                             // ──────────────────────────────────────────────

  //                             setModalState(() => isSaving = true);
  //                             try {
  //                               final newItem = await _apiService.save(
  //                                 AbsensiKelasIbuHamilModel(
  //                                   pertemuanKe: 0,
  //                                   tanggal:
  //                                       '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
  //                                   namaKader: '',
  //                                   tanggalParaf: '',
  //                                 ),
  //                               );
  //                               if (!mounted) return;
  //                               Navigator.pop(ctx); // tutup bottom sheet
  //                               setState(() => _absensiList.add(newItem));
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 const SnackBar(
  //                                   content: Text('Absensi berhasil dikirim'),
  //                                   behavior: SnackBarBehavior.floating,
  //                                 ),
  //                               );
  //                             } catch (e) {
  //                               setModalState(() => isSaving = false);
  //                               if (!mounted) return;
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content: Text(e.toString()),
  //                                   behavior: SnackBarBehavior.floating,
  //                                 ),
  //                               );
  //                             }
  //                           },
  //                     icon: isSaving
  //                         ? const SizedBox(
  //                             width: 18,
  //                             height: 18,
  //                             child: CircularProgressIndicator(
  //                                 strokeWidth: 2, color: Colors.white),
  //                           )
  //                         : const Icon(Icons.send_rounded, size: 18),
  //                     label: Text(
  //                       isSaving ? 'Mengirim...' : 'Kirim Absensi',
  //                       style: const TextStyle(
  //                           fontWeight: FontWeight.w700, fontSize: 15),
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.primary,
  //                       foregroundColor: Colors.white,
  //                       disabledBackgroundColor: Colors.grey.shade300,
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12)),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

    // =============================================================
  // BOTTOM SHEET: form "Isi Absensi Baru"
  // Muncul dari bawah saat tombol "Tambah Absensi" ditekan.
  // =============================================================
  // void _showTambahAbsensi() {
  //   DateTime? selectedDate;
  //   final dateController = TextEditingController();
  //   bool isSaving = false;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) {
  //       // StatefulBuilder dipakai supaya isi bottom sheet bisa
  //       // berubah sendiri (misal teks tanggal) tanpa menutup sheet.
  //       return StatefulBuilder(
  //         builder: (ctx, setModalState) {
  //           return Padding(
  //             padding: EdgeInsets.only(
  //               left: 20,
  //               right: 20,
  //               top: 20,
  //               bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // ── Header bottom sheet ──
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       'Isi Absensi Baru',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w700,
  //                         color: Color(0xFF1A1A2E),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(ctx),
  //                       padding: EdgeInsets.zero,
  //                       constraints: const BoxConstraints(),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
                  
  //                 // INFO BATASAN TANGGAL
  //                 const Text(
  //                   'Catatan: Anda hanya dapat mencatat kehadiran maksimal 2 hari yang lalu.',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Color(0xFF6B7280),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // ── Label + kotak pemilih tanggal ──
  //                 const Text(
  //                   'Pilih Tanggal Hadir',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(0xFF374151),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 GestureDetector(
  //                   onTap: () async {
  //                     final now = DateTime.now();
  //                     // Batasi tanggal: maksimal 2 hari ke belakang
  //                     final firstDate = now.subtract(const Duration(days: 2));

  //                     final picked = await showDatePicker(
  //                       context: ctx,
  //                       initialDate: selectedDate ?? now, // Default hari ini
  //                       firstDate: firstDate, // Tidak bisa pilih sebelum H-2
  //                       lastDate: now, // Tidak bisa pilih masa depan
  //                       helpText: 'Pilih tanggal hadir',
  //                       cancelText: 'Batal',
  //                       confirmText: 'Pilih',
  //                     );
  //                     if (picked != null) {
  //                       // Cek duplikat langsung setelah ibu memilih tanggal
  //                       final pickedStr =
  //                           '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  //                       final sudahAda =
  //                           _absensiList.any((a) => a.tanggal == pickedStr);

  //                       if (sudahAda) {
  //                         // Reset pilihan — kotak tanggal tetap kosong/tidak berubah
  //                         setModalState(() {
  //                           selectedDate = null;
  //                           dateController.text = '';
  //                         });
  //                         if (!ctx.mounted) return;
  //                         ScaffoldMessenger.of(ctx).showSnackBar(
  //                           SnackBar(
  //                             content: Row(
  //                               children: const [
  //                                 Icon(Icons.error_outline,
  //                                     color: Colors.white, size: 18),
  //                                 SizedBox(width: 8),
  //                                 Expanded(
  //                                   child: Text(
  //                                     'Absensi untuk tanggal ini sudah pernah dicatat',
  //                                     style: TextStyle(fontSize: 13),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             backgroundColor: const Color(0xFFEF4444),
  //                             behavior: SnackBarBehavior.floating,
  //                           ),
  //                         );
  //                       } else {
  //                         setModalState(() {
  //                           selectedDate = picked;
  //                           dateController.text =
  //                               '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
  //                         });
  //                       }
  //                     }
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 14, vertical: 14),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: const Color(0xFFD1D5DB)),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             dateController.text.isEmpty
  //                                 ? 'DD/MM/YYYY'
  //                                 : dateController.text,
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: dateController.text.isEmpty
  //                                   ? const Color(0xFF9CA3AF)
  //                                   : const Color(0xFF1A1A2E),
  //                             ),
  //                           ),
  //                         ),
  //                         const Icon(Icons.calendar_today_outlined,
  //                             size: 20, color: Color(0xFF6B7280)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // ── Kotak info kuning (identitas Ibu Hamil) ──
  //                 Container(
  //                   padding: const EdgeInsets.all(14),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFFEF3C7),
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(color: const Color(0xFFFBBF24)),
  //                   ),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: const [
  //                       Icon(Icons.info_outline,
  //                           size: 18, color: Color(0xFFD97706)),
  //                       SizedBox(width: 10),
  //                       Expanded(
  //                         child: Text(
  //                           'Data kehadiran yang Anda kirim akan diverifikasi oleh kader. Anda dapat menambah absensi baru setelah absensi sebelumnya diverifikasi.',
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Color(0xFF92400E),
  //                             height: 1.4,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // ── Tombol Kirim Absensi ──
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 50,
  //                   child: ElevatedButton.icon(
  //                     onPressed: isSaving || selectedDate == null
  //                         ? null
  //                         : () async {
  //                             // ──────────────────────────────────────────────
  //                             // VALIDASI KONFIRMASI SAAT MENGIRIM ABSENSI
  //                             // (ini TETAP ada — beda dengan validasi keluar)
  //                             // ──────────────────────────────────────────────
  //                             final tanggalFormatted = dateController.text;

  //                             final confirmed = await context.showConfirm(
  //                               title: 'Konfirmasi Absensi',
  //                               message:
  //                                   'Apakah ibu benar-benar hadir di kelas ibu hamil pada tanggal $tanggalFormatted? Data yang sudah dikirim tidak dapat diubah.',
  //                               confirmText: 'Ya, Hadir',
  //                               cancelText: 'Batal',
  //                             );

  //                             if (!confirmed) return;
  //                             // ──────────────────────────────────────────────

  //                             setModalState(() => isSaving = true);
  //                             try {
  //                               final newItem = await _apiService.save(
  //                                 AbsensiKelasIbuHamilModel(
  //                                   pertemuanKe: 0,
  //                                   tanggal:
  //                                       '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
  //                                   namaKader: '',
  //                                   tanggalParaf: '',
  //                                 ),
  //                               );
  //                               if (!mounted) return;
  //                               Navigator.pop(ctx); // tutup bottom sheet
  //                               setState(() => _absensiList.add(newItem));
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 const SnackBar(
  //                                   content: Text('Absensi berhasil dikirim'),
  //                                   behavior: SnackBarBehavior.floating,
  //                                 ),
  //                               );
  //                             } catch (e) {
  //                               setModalState(() => isSaving = false);
  //                               if (!mounted) return;
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content: Text(e.toString()),
  //                                   behavior: SnackBarBehavior.floating,
  //                                 ),
  //                               );
  //                             }
  //                           },
  //                     icon: isSaving
  //                         ? const SizedBox(
  //                             width: 18,
  //                             height: 18,
  //                             child: CircularProgressIndicator(
  //                                 strokeWidth: 2, color: Colors.white),
  //                           )
  //                         : const Icon(Icons.send_rounded, size: 18),
  //                     label: Text(
  //                       isSaving ? 'Mengirim...' : 'Kirim Absensi',
  //                       style: const TextStyle(
  //                           fontWeight: FontWeight.w700, fontSize: 15),
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.primary,
  //                       foregroundColor: Colors.white,
  //                       disabledBackgroundColor: Colors.grey.shade300,
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12)),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

    // =============================================================
  // BOTTOM SHEET: form "Isi Absensi Baru"
  // Muncul dari bawah saat tombol "Tambah Absensi" ditekan.
  // =============================================================
  void _showTambahAbsensi() {
    DateTime? selectedDate;
    final dateController = TextEditingController();
    bool isSaving = false;
    String? errorMessage; // Variabel untuk menyimpan pesan error di form

    setState(() => _isBottomSheetOpen = true);

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
                  const SizedBox(height: 8),
                  
                  // INFO BATASAN TANGGAL
                  const Text(
                    'Catatan: Anda hanya dapat mencatat kehadiran maksimal 2 hari yang lalu.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
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
                      // Batasi tanggal: maksimal 2 hari ke belakang
                      final firstDate = now.subtract(const Duration(days: 2));

                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate ?? now, // Default hari ini
                        firstDate: firstDate, // Tidak bisa pilih sebelum H-2
                        lastDate: now, // Tidak bisa pilih masa depan
                        helpText: 'Pilih tanggal hadir',
                        cancelText: 'Batal',
                        confirmText: 'Pilih',
                      );
                      
                      if (picked != null) {
                        // Cek duplikat langsung setelah ibu memilih tanggal
                        final pickedStr =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        final sudahAda =
                            _absensiList.any((a) => a.tanggal == pickedStr);

                        if (sudahAda) {
                          // Tampilkan error di dalam form, bukan SnackBar
                          setModalState(() {
                            selectedDate = null;
                            dateController.text = '';
                            errorMessage = 'Absensi untuk tanggal ini sudah pernah dicatat. Pilih tanggal lain.';
                          });
                        } else {
                          setModalState(() {
                            selectedDate = picked;
                            dateController.text =
                                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                            errorMessage = null; // Hapus error jika tanggal valid
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: errorMessage != null ? Colors.red : const Color(0xFFD1D5DB)),
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
                  
                  // TAMPILKAN PESAN ERROR DI BAWAH KOTAK TANGGAL
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                          : () async {
                              // ──────────────────────────────────────────────
                              // VALIDASI KONFIRMASI SAAT MENGIRIM ABSENSI
                              // (ini TETAP ada — beda dengan validasi keluar)
                              // ──────────────────────────────────────────────
                              final tanggalFormatted = dateController.text;

                              final confirmed = await context.showConfirm(
                                title: 'Konfirmasi Absensi',
                                message:
                                    'Apakah ibu benar-benar hadir di kelas ibu hamil pada tanggal $tanggalFormatted? Data yang sudah dikirim tidak dapat diubah.',
                                confirmText: 'Ya, Hadir',
                                cancelText: 'Batal',
                              );

                              if (!confirmed) return;
                              // ──────────────────────────────────────────────

                              setModalState(() => isSaving = true);
                              try {
                                final newItem = await _apiService.save(
                                  AbsensiKelasIbuHamilModel(
                                    pertemuanKe: 0,
                                    tanggal:
                                        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                    namaKader: '',
                                    tanggalParaf: '',
                                  ),
                                );
                                if (!mounted) return;
                                Navigator.pop(ctx); // tutup bottom sheet
                                setState(() => _absensiList.add(newItem));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Absensi berhasil dikirim'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                setModalState(() => isSaving = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
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
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isBottomSheetOpen = false);
      }
    });
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
  // Widget _buildStatusBadge(String status) {
  //   final isVerified = status == 'Terverifikasi';

  //   final Color bgColor =
  //       isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);
  //   final Color borderColor =
  //       isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
  //   final Color textColor =
  //       isVerified ? const Color(0xFF059669) : const Color(0xFFD97706);
  //   final IconData iconData = isVerified
  //       ? Icons.verified_rounded
  //       : Icons.hourglass_top_rounded;
  //   final String textLabel = isVerified ? 'Terverifikasi' : 'Menunggu';

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  //     decoration: BoxDecoration(
  //       color: bgColor,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: borderColor),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(iconData, size: 11, color: textColor),
  //         const SizedBox(width: 4),
  //         Text(
  //           textLabel,
  //           style: TextStyle(
  //             fontSize: 10,
  //             fontWeight: FontWeight.w600,
  //             color: textColor,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatusBadge(String status) {
    final isVerified = status == 'Terverifikasi';
    final isRejected = status == 'Ditolak';

    Color bgColor = const Color(0xFFFEF3C7); // Kuning (Menunggu)
    Color borderColor = const Color(0xFFF59E0B);
    Color textColor = const Color(0xFFD97706);
    IconData iconData = Icons.hourglass_top_rounded;
    String textLabel = 'Menunggu';

    if (isVerified) {
      bgColor = const Color(0xFFD1FAE5); // Hijau (Verifikasi)
      borderColor = const Color(0xFF10B981);
      textColor = const Color(0xFF059669);
      iconData = Icons.verified_rounded;
      textLabel = 'Terverifikasi';
    } else if (isRejected) {
      bgColor = const Color(0xFFFEE2E2); // Merah (Ditolak)
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFFB91C1C);
      iconData = Icons.cancel_rounded;
      textLabel = 'Ditolak';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          // Keluar langsung tanpa popup konfirmasi.
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Absensi Kelas Ibu Hamil',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Catatan kehadiran kelas ibu hamil',
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
      // PopScope dihapus: tombol back HP juga langsung keluar tanpa konfirmasi.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ExcludeSemantics(
              excluding: _isBottomSheetOpen,
              child: RepaintBoundary(
                child: RefreshIndicator(
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
                          // Baris-baris data (dinamis, tak terbatas)
                          ...List.generate(_absensiList.length, (i) {
                            final item = _absensiList[i];
                            final isLast = i == _absensiList.length - 1;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: Text('${i + 1}',
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
                                          child:
                                              _buildStatusBadge(item.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast) const Divider(height: 1),
                              ],
                            );
                          }),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                            child: Center(
                              child: Text(
                                'Belum ada data kehadiran',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF9CA3AF)),
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
                        border: Border.all(color: const Color(0xFFFB923C)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.hourglass_top_rounded,
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