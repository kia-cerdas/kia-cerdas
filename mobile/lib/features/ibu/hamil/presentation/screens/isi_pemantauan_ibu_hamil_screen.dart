import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/widgets/confirm_helper.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemantauan_ibu_hamil_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/pemantauan_ibu_hamil_api_service.dart';

/// Screen khusus untuk mengisi form pemantauan ibu hamil minggu ini.
/// Dipanggil dari PemantauanIbuHamilScreen saat minggu ini belum diisi.
/// Polanya sama dengan ChecklistPemantauanIbuNifasScreen.
class IsiPemantauanIbuHamilScreen extends StatefulWidget {
  final int mingguKehamilan;
  final String trimester;

  const IsiPemantauanIbuHamilScreen({
    super.key,
    required this.mingguKehamilan,
    required this.trimester,
  });

  @override
  State<IsiPemantauanIbuHamilScreen> createState() =>
      _IsiPemantauanIbuHamilScreenState();
}

class _IsiPemantauanIbuHamilScreenState
    extends State<IsiPemantauanIbuHamilScreen> {
  final _api = PemantauanIbuHamilApiService();
  bool _saving = false;

  // State checklist
  bool demamLebih2Hari = false;
  bool sakitKepala = false;
  bool cemasBerlebih = false;
  bool resikoTB = false;
  bool gerakanBayiKurang = false;
  bool nyeriPerut = false;
  bool cairanJalanLahir = false;
  bool masalahKemaluan = false;
  bool diareBerulang = false;

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

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

  Future<void> _simpan() async {
    final pesanKeluhan = _jumlahKeluhan > 0
        ? '\n\n⚠️ Terdapat $_jumlahKeluhan keluhan yang ditandai. Pastikan data sudah sesuai.'
        : '';

    final confirmed = await context.showConfirm(
      title: 'Konfirmasi Pemantauan',
      message:
          'Apakah data pemantauan minggu ke-${widget.mingguKehamilan} sudah benar?$pesanKeluhan',
      confirmText: 'Ya, Simpan',
      cancelText: 'Periksa Lagi',
    );

    if (!confirmed) return;

    setState(() => _saving = true);
    try {
      await _api.save(PemantauanIbuHamilModel(
        mingguKehamilan: widget.mingguKehamilan,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Pemantauan minggu ${widget.mingguKehamilan} berhasil disimpan'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      // Kembalikan true agar layar sebelumnya tahu perlu refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Pemantauan Minggu ${widget.mingguKehamilan}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner info minggu ──────────────────────────────────────
            _infoBanner(),
            const SizedBox(height: 20),

            // ── Section checklist ───────────────────────────────────────
            _sectionLabel('Tanda Bahaya / Keluhan'),
            const SizedBox(height: 8),
            _checkCard(_keluhanItems()),
            const SizedBox(height: 24),

            // ── Tombol simpan ───────────────────────────────────────────
            _submitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Banner info ──────────────────────────────────────────────────────────

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
          Icon(Icons.pregnant_woman_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minggu ke-${widget.mingguKehamilan} · ${widget.trimester}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Centang keluhan yang dialami minggu ini (jika ada)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Label section ────────────────────────────────────────────────────────

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

  // ─── Kartu checklist ──────────────────────────────────────────────────────

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
      onTap: _saving ? null : () => item.onChanged(!item.value),
      borderRadius: BorderRadius.only(
        bottomLeft: isLast ? const Radius.circular(14) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom:
                      BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 16,
                color: item.value ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 10),
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
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tombol simpan ────────────────────────────────────────────────────────

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _simpan,
        icon: _saving
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
          _saving ? 'Menyimpan...' : 'Simpan Pemantauan',
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

  // ─── Data items ───────────────────────────────────────────────────────────

  List<_FormItem> _keluhanItems() => [
        _FormItem(
          'Demam lebih dari 2 hari',
          Icons.thermostat_outlined,
          demamLebih2Hari,
          (v) => setState(() => demamLebih2Hari = v),
        ),
        _FormItem(
          'Sakit kepala berat / menetap',
          Icons.sick_outlined,
          sakitKepala,
          (v) => setState(() => sakitKepala = v),
        ),
        _FormItem(
          'Cemas berlebihan',
          Icons.sentiment_very_dissatisfied_outlined,
          cemasBerlebih,
          (v) => setState(() => cemasBerlebih = v),
        ),
        _FormItem(
          'Risiko TB / batuk lama',
          Icons.air_outlined,
          resikoTB,
          (v) => setState(() => resikoTB = v),
        ),
        _FormItem(
          'Gerakan bayi berkurang',
          Icons.child_friendly_outlined,
          gerakanBayiKurang,
          (v) => setState(() => gerakanBayiKurang = v),
        ),
        _FormItem(
          'Nyeri perut hebat / tidak biasa',
          Icons.warning_amber_outlined,
          nyeriPerut,
          (v) => setState(() => nyeriPerut = v),
        ),
        _FormItem(
          'Keluar cairan dari jalan lahir',
          Icons.water_drop_outlined,
          cairanJalanLahir,
          (v) => setState(() => cairanJalanLahir = v),
        ),
        _FormItem(
          'Masalah pada kemaluan',
          Icons.medical_services_outlined,
          masalahKemaluan,
          (v) => setState(() => masalahKemaluan = v),
        ),
        _FormItem(
          'Diare berulang / tidak membaik',
          Icons.sick,
          diareBerulang,
          (v) => setState(() => diareBerulang = v),
        ),
      ];
}

class _FormItem {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FormItem(this.label, this.icon, this.value, this.onChanged);
}