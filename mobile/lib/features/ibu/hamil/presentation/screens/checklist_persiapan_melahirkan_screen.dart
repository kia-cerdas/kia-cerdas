import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/persiapan_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/persiapan_melahirkan_api_service.dart';

class ChecklistPersiapanMelahirkanScreen extends StatefulWidget {
  const ChecklistPersiapanMelahirkanScreen({super.key});

  @override
  State<ChecklistPersiapanMelahirkanScreen> createState() =>
      _ChecklistPersiapanMelahirkanScreenState();
}

class _ChecklistPersiapanMelahirkanScreenState
    extends State<ChecklistPersiapanMelahirkanScreen> {
  // ─── Colors (konsisten dengan screen lain di modul ibu) ───────────────────
  static const Color _primary = AppColors.primary;
  static const Color _bgColor = Color(0xFFF5F7FB);
  static const Color _cardBorder = Color(0xFFB7DBFF);
  static const Color _checkedColor = Color(0xFF1A7A3F);
  static const Color _checkedBg = Color(0xFFECFDF5);
  static const Color _checkedBorder = Color(0xFF86EFAC);
  static const Color _uncheckedBg = Color(0xFFF9FAFB);
  static const Color _uncheckedBorder = Color(0xFFE5E7EB);

  final _service = PersiapanMelahirkanApiService();

  late PersiapanMelahirkanModel _data;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // ─── Label + field getter/setter untuk setiap item ────────────────────────
  static const List<_CheckItem> _items = [
    _CheckItem(
      label: 'Perkiraan Tanggal Persalinan',
      subtitle: 'Sudah mengetahui taksiran tanggal melahirkan',
      icon: Icons.calendar_month_outlined,
    ),
    _CheckItem(
      label: 'Pendamping Persalinan',
      subtitle: 'Sudah menentukan siapa yang mendampingi saat melahirkan',
      icon: Icons.people_outline,
    ),
    _CheckItem(
      label: 'Dana Persalinan',
      subtitle: 'Dana untuk biaya persalinan sudah disiapkan',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _CheckItem(
      label: 'Status JKN / Asuransi',
      subtitle: 'Kartu JKN / BPJS atau asuransi kesehatan sudah aktif',
      icon: Icons.health_and_safety_outlined,
    ),
    _CheckItem(
      label: 'Fasilitas Kesehatan Persalinan',
      subtitle: 'Sudah memilih faskes tempat melahirkan',
      icon: Icons.local_hospital_outlined,
    ),
    _CheckItem(
      label: 'Pendonor Darah',
      subtitle: 'Sudah menyiapkan calon pendonor darah jika dibutuhkan',
      icon: Icons.water_drop_outlined,
    ),
    _CheckItem(
      label: 'Transportasi',
      subtitle: 'Kendaraan menuju faskes sudah disiapkan',
      icon: Icons.directions_car_outlined,
    ),
    _CheckItem(
      label: 'Metode KB Pasca Persalinan',
      subtitle: 'Sudah memilih metode KB yang akan digunakan setelah melahirkan',
      icon: Icons.medical_services_outlined,
    ),
    _CheckItem(
      label: 'Program P4K',
      subtitle: 'Stiker P4K sudah ditempel di rumah',
      icon: Icons.home_outlined,
    ),
    _CheckItem(
      label: 'Dokumen Penting',
      subtitle: 'KTP, Kartu Keluarga, buku KIA, dan dokumen lain sudah disiapkan',
      icon: Icons.folder_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _data = PersiapanMelahirkanModel.empty();
    _loadData();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getMine();
      setState(() => _data = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Toggle ───────────────────────────────────────────────────────────────
  void _toggle(int index, bool value) {
    setState(() {
      _data = switch (index) {
        0 => _data.copyWith(perkiraanPersalinan: value),
        1 => _data.copyWith(pendampingPersalinan: value),
        2 => _data.copyWith(danaPersalinan: value),
        3 => _data.copyWith(statusJkn: value),
        4 => _data.copyWith(faskesPersalinan: value),
        5 => _data.copyWith(pendonorDarah: value),
        6 => _data.copyWith(transportasi: value),
        7 => _data.copyWith(metodeKb: value),
        8 => _data.copyWith(programP4k: value),
        9 => _data.copyWith(dokumenPenting: value),
        _ => _data,
      };
    });
  }

  bool _getValueAt(int index) => switch (index) {
        0 => _data.perkiraanPersalinan,
        1 => _data.pendampingPersalinan,
        2 => _data.danaPersalinan,
        3 => _data.statusJkn,
        4 => _data.faskesPersalinan,
        5 => _data.pendonorDarah,
        6 => _data.transportasi,
        7 => _data.metodeKb,
        8 => _data.programP4k,
        9 => _data.dokumenPenting,
        _ => false,
      };

  // ─── Save ─────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final saved = await _service.save(_data);
      setState(() => _data = saved);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checklist berhasil disimpan ✓'),
            backgroundColor: _checkedColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Persiapan Melahirkan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        child: Column(children: [
                          _buildProgressCard(),
                          const SizedBox(height: 16),
                          _buildSectionLabel('Checklist Persiapan'),
                          const SizedBox(height: 10),
                          ..._buildCheckItems(),
                        ]),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : _buildSaveButton(),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checklist_rtl_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checklist Persiapan Melahirkan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Centang setiap item yang sudah dipersiapkan sebelum persalinan',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11, height: 1.35),
                ),
                SizedBox(height: 10),
                _SelfFillBadge(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Progress Card ────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    final checked = _data.totalChecked;
    final total = PersiapanMelahirkanModel.totalItems;
    final percent = total > 0 ? checked / total : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bar_chart_rounded, color: _primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Progres: $checked dari $total item',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937)),
          ),
          const Spacer(),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: _primary),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              percent == 1.0 ? _checkedColor : _primary,
            ),
          ),
        ),
        if (percent == 1.0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _checkedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _checkedBorder),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, color: _checkedColor, size: 15),
              SizedBox(width: 6),
              Text(
                'Semua persiapan sudah lengkap!',
                style: TextStyle(
                    color: _checkedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(children: [
      Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: _primary, borderRadius: BorderRadius.circular(8))),
      const SizedBox(width: 10),
      Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937))),
    ]);
  }

  // ─── Check Items ──────────────────────────────────────────────────────────
  List<Widget> _buildCheckItems() {
    return List.generate(_items.length, (index) {
      final item = _items[index];
      final checked = _getValueAt(index);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ChecklistTile(
          item: item,
          checked: checked,
          onChanged: (value) => _toggle(index, value),
          checkedColor: _checkedColor,
          checkedBg: _checkedBg,
          checkedBorder: _checkedBorder,
          uncheckedBg: _uncheckedBg,
          uncheckedBorder: _uncheckedBorder,
        ),
      );
    });
  }

  // ─── Save Button ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined),
          label: Text(
            _isSaving ? 'Menyimpan...' : 'Simpan Checklist',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge "Diisi oleh Ibu" ──────────────────────────────────────────────────
class _SelfFillBadge extends StatelessWidget {
  const _SelfFillBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2FA84F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Diisi oleh Ibu Hamil',
          style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
}

// ─── Data class for checklist item ───────────────────────────────────────────
class _CheckItem {
  final String label;
  final String subtitle;
  final IconData icon;
  const _CheckItem({
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

// ─── Single checklist tile ───────────────────────────────────────────────────
class _ChecklistTile extends StatelessWidget {
  final _CheckItem item;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final Color checkedColor;
  final Color checkedBg;
  final Color checkedBorder;
  final Color uncheckedBg;
  final Color uncheckedBorder;

  const _ChecklistTile({
    required this.item,
    required this.checked,
    required this.onChanged,
    required this.checkedColor,
    required this.checkedBg,
    required this.checkedBorder,
    required this.uncheckedBg,
    required this.uncheckedBorder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: checked ? checkedBg : uncheckedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: checked ? checkedBorder : uncheckedBorder,
          width: 1.5,
        ),
        boxShadow: checked
            ? [
                BoxShadow(
                  color: checkedColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: checked
                    ? checkedColor.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: checked ? checkedColor : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: checked
                            ? checkedColor
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          height: 1.3),
                    ),
                  ]),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(checked),
                size: 26,
                color: checked ? checkedColor : const Color(0xFFD1D5DB),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
