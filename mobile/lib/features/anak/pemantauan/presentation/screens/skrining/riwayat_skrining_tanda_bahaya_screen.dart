import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/models/lembar_pemantauan_dynamic_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/services/lembar_pemantauan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/lembar_pemantauan_screen.dart';

class RiwayatSkriningTandaBahayaScreen extends StatefulWidget {
  final Map<String, dynamic>? anak;
  final bool showAllRecords;

  const RiwayatSkriningTandaBahayaScreen({
    super.key,
    this.anak,
    this.showAllRecords = false,
  });

  @override
  State<RiwayatSkriningTandaBahayaScreen> createState() =>
      _RiwayatSkriningTandaBahayaScreenState();
}

class _RiwayatSkriningTandaBahayaScreenState
    extends State<RiwayatSkriningTandaBahayaScreen> {
  final LembarPemantauanApiService _service = LembarPemantauanApiService();
  bool _loading = true;
  List<LembarPemantauanModel> _records = const [];
  final Set<int> _verifyingIds = {};

  String get _namaAnak => (widget.anak?['nama'] ?? 'Si Kecil').toString();
  String get _usiaAnak =>
      (widget.anak?['usia_teks'] ?? 'Usia tidak diketahui').toString();
  bool get _isKaderMode =>
      widget.showAllRecords ||
      (AuthSession.role?.trim().toLowerCase() == 'kader');

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _loading = true;
    });

    try {
      final anakRaw = widget.anak?['id'];
      final anakId = anakRaw is int
          ? anakRaw
          : int.tryParse((anakRaw ?? '').toString()) ?? 0;

      final records = _isKaderMode || anakId <= 0
          ? await _service.getSemuaPemantauan()
          : await _service.getRiwayatPemantauan(anakId);

      records.sort((a, b) {
        final compareDate = b.tanggalPeriksa.compareTo(a.tanggalPeriksa);
        if (compareDate != 0) return compareDate;
        return b.id.compareTo(a.id);
      });

      if (!mounted) return;
      setState(() {
        _records = records;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat riwayat skrining: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Diterima':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Diterima':
        return Icons.check_circle_rounded;
      case 'Ditolak':
        return Icons.error_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  void _openPemantauanHariIni() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LembarPemantauanScreen(anak: widget.anak),
      ),
    );
  }

  Future<void> _verifyRecord(
      LembarPemantauanModel record, String status) async {
    final pemeriksa = (AuthSession.userName ?? 'Kader').trim();
    if (pemeriksa.isEmpty) {
      _showSnack('Nama pemeriksa tidak tersedia.');
      return;
    }

    setState(() {
      _verifyingIds.add(record.id);
    });

    try {
      await _service.verifyLembarPemantauan(
        id: record.id,
        status: status,
        namaPemeriksa: pemeriksa,
      );

      if (!mounted) return;
      _showSnack('Status berhasil diperbarui.', isSuccess: true);
      await _loadRecords();
    } catch (e) {
      _showSnack('Gagal memperbarui status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _verifyingIds.remove(record.id);
        });
      }
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green.shade700 : null,
      ),
    );
  }

  void _showRecordHelp(LembarPemantauanModel record) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info Status'),
        content: Text(
          record.status == 'Menunggu verifikasi'
              ? 'Data ini masih menunggu verifikasi kader.'
              : 'Status data sudah diperbarui pada ${record.updatedAt}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _periodeLabel(LembarPemantauanModel record) {
    final satuan = record.rentangUsia?.satuanWaktu.toLowerCase().trim() ?? '';
    final periode = record.periodeWaktu;
    if (satuan == 'hari') return 'Hari ke-$periode';
    if (satuan == 'minggu') return 'Minggu ke-$periode';
    if (satuan == 'bulan') return 'Bulan ke-$periode';
    if (satuan == 'tahun') return 'Tahun ke-$periode';
    return 'Periode ke-$periode';
  }

  String _examinerLabel(String value) {
    final cleaned = value.trim();
    return cleaned.isEmpty ? '-' : cleaned;
  }

  String _childName(LembarPemantauanModel record) {
    final child = record.anak;
    final candidates = <dynamic>[
      child?['penduduk'] is Map<String, dynamic>
          ? (child!['penduduk'] as Map<String, dynamic>)['nama_lengkap']
          : null,
      child?['penduduk'] is Map<String, dynamic>
          ? (child!['penduduk'] as Map<String, dynamic>)['nama']
          : null,
      child?['nama'],
      child?['nama_anak'],
      child?['nama_lengkap'],
    ];

    for (final item in candidates) {
      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return 'Anak #${record.anakId}';
  }

  String _motherName(LembarPemantauanModel record) {
    final child = record.anak;
    final candidates = <dynamic>[
      child?['kehamilan'] is Map<String, dynamic>
          ? (child!['kehamilan'] as Map<String, dynamic>)['ibu'] is Map<String, dynamic>
              ? ((child['kehamilan'] as Map<String, dynamic>)['ibu'] as Map<String, dynamic>)['kependudukan'] is Map<String, dynamic>
                  ? (((child['kehamilan'] as Map<String, dynamic>)['ibu'] as Map<String, dynamic>)['kependudukan'] as Map<String, dynamic>)['nama_lengkap']
                  : null
              : null
          : null,
      child?['kehamilan'] is Map<String, dynamic>
          ? (child!['kehamilan'] as Map<String, dynamic>)['ibu'] is Map<String, dynamic>
              ? ((child['kehamilan'] as Map<String, dynamic>)['ibu'] as Map<String, dynamic>)['kependudukan'] is Map<String, dynamic>
                  ? (((child['kehamilan'] as Map<String, dynamic>)['ibu'] as Map<String, dynamic>)['kependudukan'] as Map<String, dynamic>)['nama']
                  : null
              : null
          : null,
      child?['nama_ibu'],
    ];

    for (final item in candidates) {
      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final totalPending = _records
        .where((record) => record.status == 'Menunggu verifikasi')
        .length;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _isKaderMode ? 'Verifikasi Skrining' : 'Riwayat Skrining',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 24),
                      if (!_isKaderMode) _buildPrimaryActionCard(),
                      if (_isKaderMode) _buildKaderSummaryCard(totalPending),
                      const SizedBox(height: 16),
                      _buildEmptyState(context),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!_isKaderMode) _buildPrimaryActionCard(),
                      if (_isKaderMode) _buildKaderSummaryCard(totalPending),
                      const SizedBox(height: 16),
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      ..._records.map((record) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRecordCard(record),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    if (_isKaderMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0F2FE),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lembar menunggu verifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap Setujui atau Tolak pada data yang sudah di cek.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD7ECFF),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 30,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaAnak,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _usiaAnak,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_records.length} catatan skrining tersimpan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ini adalah catatan pemantauan bayimu. Tap untuk lihat detail atau tambah catatan baru.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_fill_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Isi pemantauan hari ini agar kader bisa segera menilai.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _openPemantauanHariIni,
              child: const Text('Isi Pemantauan Hari Ini'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaderSummaryCard(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFDBEAFE),
            ),
            child: const Icon(Icons.pending_actions_rounded,
                color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount data menunggu verifikasi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status yang sudah diverifikasi akan langsung terlihat oleh ibu.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(LembarPemantauanModel record) {
    final statusColor = _statusColor(record.status);
    final examiner = _examinerLabel(record.namaPemeriksa);
    final detailSelesai =
        record.detailGejala.where((item) => item.isTerjadi).toList();
    final selectedGejalaList = detailSelesai
        .map((d) => d.kategoriTandaSakit?.gejala ?? 'Gejala tidak diketahui')
        .toList();
    final statusIcon = _statusIcon(record.status);
    final childLabel = _childName(record);
    final motherLabel = _motherName(record);
    final isPending = record.status == 'Menunggu verifikasi';
    final isBusy = _verifyingIds.contains(record.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isKaderMode ? childLabel : (record.rentangUsia?.namaRentang ?? '-'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_isKaderMode && motherLabel.isNotEmpty) ...[
                      Text(
                        'Ibu: $motherLabel',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (_isKaderMode) ...[
                      Text(
                        '${record.rentangUsia?.namaRentang ?? '-'} · ${_periodeLabel(record)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ] else ...[
                      Text(
                        _periodeLabel(record),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      record.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(
              Icons.calendar_today_rounded, 'Tanggal', record.tanggalPeriksa),
          const SizedBox(height: 8),
          _infoRow(Icons.badge_rounded, 'Pemeriksa', examiner),
          const SizedBox(height: 8),
          _infoRow(
            Icons.checklist_rounded,
            'Gejala terpilih',
            '${detailSelesai.length} item',
          ),
          if (selectedGejalaList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gejala yang ditemukan:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedGejalaList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final gejala = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              index < selectedGejalaList.length - 1 ? 8 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              gejala,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          _infoRow(
            Icons.verified_rounded,
            _isKaderMode ? 'Update status' : 'Tgl verifikasi',
            record.status == 'Menunggu verifikasi' ? '-' : record.updatedAt,
          ),
          if (_isKaderMode) ...[
            const SizedBox(height: 12),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _verifyRecord(record, 'Ditolak'),
                      icon: isBusy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.close_rounded),
                      label: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _verifyRecord(record, 'Diterima'),
                      icon: isBusy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Setujui'),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Sudah diverifikasi oleh $examiner',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          if (record.status != 'Diterima') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _showRecordHelp(record),
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('Lihat Detail'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFEE2E2),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFFDC2626),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isKaderMode
                ? 'Belum ada data menunggu verifikasi'
                : 'Belum ada riwayat skrining',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isKaderMode
                ? 'Data skrining anak yang masuk akan tampil di sini untuk diverifikasi.'
                : 'Hasil skrining yang sudah disimpan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          if (!_isKaderMode)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openPemantauanHariIni,
                child: const Text('Isi Pemantauan Hari Ini'),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _loadRecords,
              child: const Text('Muat ulang'),
            ),
          ),
        ],
      ),
    );
  }
}
