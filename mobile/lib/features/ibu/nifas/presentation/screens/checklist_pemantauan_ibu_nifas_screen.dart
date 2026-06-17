import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

import '../../data/models/checklist_pemantauan_ibu_nifas_model.dart';
import '../../data/repositories/checklist_pemantauan_ibu_nifas_repository.dart';
import '../../data/services/checklist_pemantauan_ibu_nifas_service.dart';
// Untuk validasi
import 'package:ta_pa2_pa3_project/core/widgets/confirm_helper.dart';

// [SCOPE: modul-ibu / nifas]
// Versi disederhanakan: tidak ada grid 42 kotak.
// Layar ini langsung menampilkan form untuk hari nifas HARI INI.
// Jika hari ini sudah diisi, tombol simpan dinonaktifkan dan muncul pesan.
class ChecklistPemantauanIbuNifasScreen extends StatefulWidget {
  final List<int> filledDays;

  // kehamilan_id dari ringkasan_pelayanan_persalinan (bukan getKehamilanAktif).
  final int kehamilanId;

  // Hari nifas hari ini, dihitung dari tanggal_melahirkan di NifasScreen.
  final int hariNifasHariIni;

  const ChecklistPemantauanIbuNifasScreen({
    super.key,
    this.filledDays = const [],
    required this.kehamilanId,
    required this.hariNifasHariIni,
  });

  @override
  State<ChecklistPemantauanIbuNifasScreen> createState() =>
      _ChecklistPemantauanIbuNifasScreenState();
}

class _ChecklistPemantauanIbuNifasScreenState
    extends State<ChecklistPemantauanIbuNifasScreen> {
  late ChecklistPemantauanIbuNifasRepository repository;
  final TextEditingController keluhanController = TextEditingController();

  bool isLoading = false;

  // [SCOPE: modul-ibu / nifas]
  // Apakah hari ini sudah diisi? Jika ya, form dikunci.
  bool get _sudahDiisiHariIni =>
      widget.filledDays.contains(widget.hariNifasHariIni);

  // Nifas A
  bool pemeriksaanNifas = false;
  bool konsumsiVitaminA = false;
  bool pemenuhanGizi = false;
  bool demamLebih38 = false;
  bool sakitKepala = false;
  bool pandanganKabur = false;
  bool nyeriUluHati = false;
  bool masalahKesehatanJiwa = false;

  // Nifas B
  bool jantungBerdebar = false;
  bool cairanJalanLahir = false;
  bool napasPendek = false;
  bool payudaraBermasalah = false;
  bool gangguanBak = false;
  bool kelaminBermasalah = false;
  bool darahNifasBerbau = false;
  bool pendarahanBerat = false;
  bool keputihan = false;

  @override
  void initState() {
    super.initState();
    repository = ChecklistPemantauanIbuNifasRepository(
      ChecklistPemantauanIbuNifasService(),
    );
  }

  @override
  void dispose() {
    keluhanController.dispose();
    super.dispose();
  }

  Future<void> submitChecklist() async {

    if (isLoading || _sudahDiisiHariIni) return;

    // ──────────────────────────────────────────────
    // VALIDASI KONFIRMASI (BARU)
    // ──────────────────────────────────────────────
    final jumlahTandaBahaya = [
      jantungBerdebar,
      cairanJalanLahir,
      napasPendek,
      payudaraBermasalah,
      gangguanBak,
      kelaminBermasalah,
      darahNifasBerbau,
      pendarahanBerat,
      keputihan,
    ].where((e) => e).length;

    final pesanTandaBahaya = jumlahTandaBahaya > 0
        ? '\n\n⚠️ Perhatian: Terdapat $jumlahTandaBahaya tanda bahaya yang ditandai. Pastikan data sudah sesuai agar segera ditindaklanjuti.'
        : '';

    final confirmed = await context.showConfirm(
      title: 'Simpan Checklist Nifas',
      message: 'Apakah checklist pemantauan hari ke-${widget.hariNifasHariIni} sudah benar?$pesanTandaBahaya',
      confirmText: 'Ya, Simpan',
      cancelText: 'Periksa Lagi',
    );

    if (!confirmed) return;

    // if (isLoading || _sudahDiisiHariIni) return;

    setState(() => isLoading = true);

    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        _showSnack('Silakan login ulang', isError: true);
        return;
      }

      // [SCOPE: modul-ibu / nifas]
      // Gunakan kehamilanId dari parameter (dari ringkasan_pelayanan_persalinan),
      // BUKAN dari getKehamilanAktif() yang akan gagal karena ibu sudah nifas.
      final model = ChecklistPemantauanIbuNifasModel(
        kehamilanId: widget.kehamilanId,
        hariNifas: widget.hariNifasHariIni,
        pemeriksaanNifas: pemeriksaanNifas,
        konsumsiVitaminA: konsumsiVitaminA,
        pemenuhanGizi: pemenuhanGizi,
        demamLebih38: demamLebih38,
        sakitKepala: sakitKepala,
        pandanganKabur: pandanganKabur,
        nyeriUluHati: nyeriUluHati,
        masalahKesehatanJiwa: masalahKesehatanJiwa,
        jantungBerdebar: jantungBerdebar,
        cairanJalanLahir: cairanJalanLahir,
        napasPendek: napasPendek,
        payudaraBermasalah: payudaraBermasalah,
        gangguanBak: gangguanBak,
        kelaminBermasalah: kelaminBermasalah,
        darahNifasBerbau: darahNifasBerbau,
        pendarahanBerat: pendarahanBerat,
        keputihan: keputihan,
        keluhan: keluhanController.text.trim(),
      );

      await repository.createChecklist(token: token, model: model);

      if (!mounted) return;
      _showSnack('Checklist berhasil disimpan');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Checklist Hari ke-${widget.hariNifasHariIni}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner hari ini ──────────────────────────────────────
            _infoBanner(),
            const SizedBox(height: 20),

            // [SCOPE: modul-ibu / nifas]
            // Jika sudah diisi hari ini, tampilkan pesan dan sembunyikan form.
            if (_sudahDiisiHariIni)
              _sudahDiisiWidget()
            else ...[
              _sectionLabel('Nifas A — Kondisi Umum'),
              const SizedBox(height: 8),
              _checkCard(_nifasAItems()),
              const SizedBox(height: 16),

              _sectionLabel('Nifas B — Tanda Bahaya'),
              const SizedBox(height: 8),
              _checkCard(_nifasBItems()),
              const SizedBox(height: 16),

              _sectionLabel('Keluhan Tambahan (opsional)'),
              const SizedBox(height: 8),
              _keluhanField(),
              const SizedBox(height: 24),

              _submitButton(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Banner info hari ini ─────────────────────────────────────────

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // [SCOPE: modul-ibu / nifas]
              // Hari nifas sudah dihitung otomatis dari tanggal_melahirkan.
              'Hari nifas ke-${widget.hariNifasHariIni} dari 42 hari',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget jika sudah diisi ──────────────────────────────────────

  Widget _sudahDiisiWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: Colors.green.shade500),
          const SizedBox(height: 12),
          const Text(
            'Checklist hari ini sudah diisi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kamu sudah mengisi checklist untuk hari nifas ke-${widget.hariNifasHariIni}.\n'
            'Silakan kembali besok untuk mengisi hari berikutnya.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Kembali ke Riwayat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Label section ────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }

  // ─── Kartu checklist ──────────────────────────────────────────────

  Widget _checkCard(List<_FormItem> items) {
    return Container(
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
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _checkRow(item, isLast: isLast);
        }),
      ),
    );
  }

  Widget _checkRow(_FormItem item, {bool isLast = false}) {
    return InkWell(
      onTap: isLoading ? null : () => item.onChanged(!item.value),
      borderRadius: BorderRadius.only(
        bottomLeft:
            isLast ? const Radius.circular(14) : Radius.zero,
        bottomRight:
            isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.value ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: item.value
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.value
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.value
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Keluhan field ────────────────────────────────────────────────

  Widget _keluhanField() {
    return Container(
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
      child: TextFormField(
        controller: keluhanController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Tuliskan keluhan jika ada...',
          hintStyle: const TextStyle(
              fontSize: 13, color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // ─── Tombol simpan ────────────────────────────────────────────────

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : submitChecklist,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: Text(
          isLoading ? 'Menyimpan...' : 'Simpan Checklist',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Data items ───────────────────────────────────────────────────

  List<_FormItem> _nifasAItems() => [
        _FormItem(
          'Sudah pemeriksaan nifas',
          pemeriksaanNifas,
          (v) => setState(() => pemeriksaanNifas = v),
        ),
        _FormItem(
          'Sudah konsumsi vitamin A',
          konsumsiVitaminA,
          (v) => setState(() => konsumsiVitaminA = v),
        ),
        _FormItem(
          'Pemenuhan gizi terpenuhi',
          pemenuhanGizi,
          (v) => setState(() => pemenuhanGizi = v),
        ),
        _FormItem(
          'Demam lebih dari 38°C',
          demamLebih38,
          (v) => setState(() => demamLebih38 = v),
        ),
        _FormItem(
          'Sakit kepala',
          sakitKepala,
          (v) => setState(() => sakitKepala = v),
        ),
        _FormItem(
          'Pandangan kabur',
          pandanganKabur,
          (v) => setState(() => pandanganKabur = v),
        ),
        _FormItem(
          'Nyeri ulu hati',
          nyeriUluHati,
          (v) => setState(() => nyeriUluHati = v),
        ),
        _FormItem(
          'Masalah kesehatan jiwa',
          masalahKesehatanJiwa,
          (v) => setState(() => masalahKesehatanJiwa = v),
        ),
      ];

  List<_FormItem> _nifasBItems() => [
        _FormItem(
          'Jantung berdebar',
          jantungBerdebar,
          (v) => setState(() => jantungBerdebar = v),
        ),
        _FormItem(
          'Cairan dari jalan lahir',
          cairanJalanLahir,
          (v) => setState(() => cairanJalanLahir = v),
        ),
        _FormItem(
          'Napas pendek',
          napasPendek,
          (v) => setState(() => napasPendek = v),
        ),
        _FormItem(
          'Payudara bermasalah',
          payudaraBermasalah,
          (v) => setState(() => payudaraBermasalah = v),
        ),
        _FormItem(
          'Gangguan BAK',
          gangguanBak,
          (v) => setState(() => gangguanBak = v),
        ),
        _FormItem(
          'Kelamin bermasalah',
          kelaminBermasalah,
          (v) => setState(() => kelaminBermasalah = v),
        ),
        _FormItem(
          'Darah nifas berbau',
          darahNifasBerbau,
          (v) => setState(() => darahNifasBerbau = v),
        ),
        _FormItem(
          'Pendarahan berat',
          pendarahanBerat,
          (v) => setState(() => pendarahanBerat = v),
        ),
        _FormItem(
          'Keputihan',
          keputihan,
          (v) => setState(() => keputihan = v),
        ),
      ];
}

class _FormItem {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FormItem(this.label, this.value, this.onChanged);
}