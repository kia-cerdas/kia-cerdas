import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/absensi/data/datasources/absensi_kelas_ibu_balita_api_service.dart';
import 'package:ta_pa2_pa3_project/features/absensi/data/models/absensi_kelas_ibu_balita_model.dart';
import 'package:ta_pa2_pa3_project/core/widgets/verification_popup.dart';

class AbsensiKelasIbuBalitaScreen extends StatefulWidget {
  const AbsensiKelasIbuBalitaScreen({super.key});

  @override
  State<AbsensiKelasIbuBalitaScreen> createState() =>
      _AbsensiKelasIbuBalitaScreenState();
}

class _AbsensiKelasIbuBalitaScreenState
    extends State<AbsensiKelasIbuBalitaScreen> {
  final _apiService = AbsensiKelasIbuBalitaApiService();

  List<AbsensiKelasIbuBalitaModel> _absensiList = [];
  bool _isLoading = false;

  // ── Pagination ──
  static const int _pageSize = 10;
  int _currentPage = 0;

  int get _totalPages => (_absensiList.length / _pageSize).ceil().clamp(1, 999);
  List<AbsensiKelasIbuBalitaModel> get _pagedList {
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

  Future<void> _loadAbsensi() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getMine();
      setState(() {
        _absensiList = list;
        _currentPage = 0; // reset ke halaman pertama saat data dimuat ulang
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalHadir => _absensiList.length;
  int get _tervalidasi =>
      _absensiList.where((a) => a.status == 'Diterima').length;

  /// Cek apakah ada data yang masih menunggu verifikasi
  bool get _adaYangBelumVerifikasi =>
      _absensiList.any((a) => a.status == 'Menunggu Verifikasi');


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
                  // Header
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

                  // Pilih Tanggal Hadir
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
                        cancelText: 'Batal',
                        confirmText: 'Pilih',
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                          dateController.text =
                              '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
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
                                  ? 'MM/DD/YYYY'
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

                  // Info box
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
                            'Data kehadiran yang Anda kirimkan akan diverifikasi secara berkala oleh petugas kesehatan puskesmas setempat untuk validasi riwayat kesehatan.',
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

                  // Kirim button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving || selectedDate == null
                          ? null
                          : () {
                              showVerificationPopup(
                                context: context,
                                type: VerificationPopupType.save,
                                title: 'Konfirmasi Simpan',
                                content:
                                    'Apakah Anda yakin data absensi sudah benar? Data yang sudah disimpan tidak dapat diubah kembali.',
                                onConfirm: () async {
                                  Navigator.pop(context); // close popup
                                  setModalState(() => isSaving = true);
                                  try {
                                    final newItem = await _apiService.save(
                                      AbsensiKelasIbuBalitaModel(
                                        pertemuanKe:
                                            _absensiList.length + 1,
                                        tanggal:
                                            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                        namaKader: '',
                                        tanggalParaf: '',
                                      ),
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    setState(
                                        () => _absensiList.add(newItem));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Absensi berhasil dikirim'),
                                        behavior:
                                            SnackBarBehavior.floating,
                                      ),
                                    );
                                  } catch (e) {
                                    setModalState(() => isSaving = false);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        behavior:
                                            SnackBarBehavior.floating,
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
                        backgroundColor: const Color(0xFF1A5FA8),
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

  /// Badge chip status verifikasi
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData iconData;
    String textLabel;

    if (status == 'Diterima') {
      bgColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFF10B981);
      textColor = const Color(0xFF059669);
      iconData = Icons.verified_rounded;
      textLabel = 'Diterima';
    } else if (status == 'Ditolak') {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFFB91C1C);
      iconData = Icons.cancel_rounded;
      textLabel = 'Ditolak';
    } else {
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFD97706);
      iconData = Icons.hourglass_top_rounded;
      textLabel = 'Menunggu';
    }

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
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Absensi Kelas Ibu Balita',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAbsensi,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Info banner
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
                              'Diisi oleh ibu pada setiap pertemuan. Kader memverifikasi kehadiran dengan paraf pada kolom yang tersedia.',
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

                    // Log Kehadiran
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
                          // Summary row
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
                                    value: '$_tervalidasi kali',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_absensiList.isNotEmpty) ...[
                            const Divider(height: 1),
                            // Table header
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
                                  // ── KOLOM STATUS BARU ──
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
                            // Table rows (paginated)
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
                                                  color:
                                                      Color(0xFF374151))),
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
                                        // ── BADGE STATUS ──
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
                                          color: const Color(0xFF1A5FA8),
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
                                          color: const Color(0xFF1A5FA8),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            const Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16, 0, 16, 20),
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

                    // ── BANNER PERINGATAN jika ada yang belum terverifikasi ──
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

                    // Tambah Absensi button — disabled jika ada yg belum verifikasi
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
                            backgroundColor: const Color(0xFF1A5FA8),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                            disabledForegroundColor:
                                Colors.grey.shade500,
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