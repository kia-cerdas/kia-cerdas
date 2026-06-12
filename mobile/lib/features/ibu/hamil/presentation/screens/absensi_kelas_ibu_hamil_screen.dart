import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/absensi_kelas_ibu_hamil_api_service.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/absensi_kelas_ibu_hamil_model.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class AbsensiKelasIbuHamilScreen extends StatefulWidget {
  const AbsensiKelasIbuHamilScreen({super.key});

  @override
  State<AbsensiKelasIbuHamilScreen> createState() =>
      _AbsensiKelasIbuHamilScreenState();
}

class _AbsensiKelasIbuHamilScreenState
    extends State<AbsensiKelasIbuHamilScreen> {
  static const int _maxSesi = 9;

  final _apiService = AbsensiKelasIbuHamilApiService();

  // Menyimpan data per sesi: tanggal yang dipilih & status dari server
  final List<DateTime?> _selectedDates = List.filled(_maxSesi, null);
  final List<String> _namaKaderList = List.filled(_maxSesi, '');
  final List<String> _statusList =
      List.filled(_maxSesi, ''); // '' = belum diisi ibu
  final List<int?> _idList = List.filled(_maxSesi, null);

  bool _isLoading = false;
  // index sesi yang sedang dalam proses simpan
  final Set<int> _savingIndices = {};

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

  Future<void> _loadAbsensi() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getMine();
      for (final item in list) {
        final idx = item.pertemuanKe - 1;
        if (idx >= 0 && idx < _maxSesi) {
          _idList[idx] = item.id;
          _namaKaderList[idx] = item.namaKader;
          _statusList[idx] = item.status;
          if (item.tanggal.isNotEmpty) {
            _selectedDates[idx] = DateTime.tryParse(item.tanggal);
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Apakah baris ini sudah dikunci (tidak bisa diubah ibu)
  /// — sudah disimpan ke server (ada id) — baik menunggu maupun sudah terverifikasi
  bool _isLocked(int index) => _idList[index] != null;

  /// Ibu tap tombol "Tandai Hadir" pada sesi [index]
  Future<void> _handleHadir(int index) async {
    // Minta konfirmasi dulu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi Kehadiran Sesi ${index + 1}'),
        content: const Text(
          'Apakah Anda yakin ingin menandai kehadiran pada sesi ini?\n\n'
          'Data yang sudah disimpan tidak dapat diubah kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Tandai Hadir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Pilih tanggal
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Pilih tanggal hadir sesi ${index + 1}',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked == null) return;

    setState(() => _savingIndices.add(index));

    try {
      final saved = await _apiService.save(
        AbsensiKelasIbuHamilModel(
          pertemuanKe: index + 1,
          tanggal:
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
          namaKader: '',
          tanggalParaf: '',
        ),
      );

      setState(() {
        _idList[index] = saved.id;
        _selectedDates[index] = picked;
        _statusList[index] = saved.status;
        _namaKaderList[index] = saved.namaKader;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kehadiran sesi ${index + 1} berhasil dicatat'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _savingIndices.remove(index));
    }
  }

  String _formatDisplay(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Badge status verifikasi
  Widget _buildStatusBadge(int index) {
    final status = _statusList[index];
    final hasDate = _selectedDates[index] != null;

    if (!hasDate) {
      // Belum diisi ibu sama sekali
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radio_button_unchecked, size: 11, color: Color(0xFF9CA3AF)),
            SizedBox(width: 4),
            Text(
              'Belum Hadir',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    final isVerified = status == 'Terverifikasi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 11,
            color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Terverifikasi' : 'Menunggu',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
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
        // ── Arrow back putih ──
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
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildAttendanceTable(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5D6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Color(0xFFE0A300),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Absensi Kehadiran Kelas Ibu Hamil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tap tombol "Tandai Hadir" untuk mencatat kehadiran tiap sesi. Setelah disimpan, kader akan memverifikasi kehadiran Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7B8798),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DEE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            _buildHeaderRow(),
            ...List.generate(_maxSesi, _buildAttendanceRow),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color(0xFFFFF0B8),
      child: Row(
        children: const [
          _TableHeaderCell(text: 'No.', flex: 1, alignment: TextAlign.center),
          _VerticalDividerLine(),
          _TableHeaderCell(text: 'Kehadiran Ibu', flex: 5),
          _VerticalDividerLine(),
          _TableHeaderCell(text: 'Status', flex: 4, alignment: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(int index) {
    final isLocked = _isLocked(index);
    final isSavingThis = _savingIndices.contains(index);
    final date = _selectedDates[index];
    // Baris ini hanya bisa diisi kalau baris sebelumnya sudah terisi
    final isPrevLocked = index == 0 || _isLocked(index - 1);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: index == 0
                ? const Color(0xFFD7DEE9)
                : const Color(0xFFE8EDF4),
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── No ──
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF172033),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const _VerticalDividerLine(),

            // ── Kolom Kehadiran Ibu ──
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: isLocked
                    // Sudah disimpan: tampilkan tanggal + ikon kunci
                    ? Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              date != null ? _formatDisplay(date) : '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF172033),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.lock_rounded,
                              size: 14, color: Color(0xFFD1D5DB)),
                        ],
                      )
                    // Belum disimpan: tombol tandai hadir
                    : SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: isSavingThis || !isPrevLocked
                              ? null
                              : () => _handleHadir(index),
                          icon: isSavingThis
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.how_to_reg_rounded, size: 16),
                          label: Text(
                            isSavingThis ? 'Menyimpan...' : 'Tandai Hadir',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
              ),
            ),
            const _VerticalDividerLine(),

            // ── Kolom Status ──
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _buildStatusBadge(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign alignment;

  const _TableHeaderCell({
    required this.text,
    required this.flex,
    this.alignment = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Text(
          text,
          textAlign: alignment,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
    );
  }
}

class _VerticalDividerLine extends StatelessWidget {
  const _VerticalDividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: const Color(0xFFD7DEE9));
  }
}