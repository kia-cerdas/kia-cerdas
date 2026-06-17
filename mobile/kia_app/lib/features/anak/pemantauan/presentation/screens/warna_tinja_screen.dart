import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/models/warna_tinja_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/services/warna_tinja_api_service.dart';
import 'package:ta_pa2_pa3_project/core/widgets/verification_popup.dart';

class WarnaTinjaScreen extends StatefulWidget {
  final Map<String, dynamic> anak;

  const WarnaTinjaScreen({Key? key, required this.anak}) : super(key: key);

  @override
  State<WarnaTinjaScreen> createState() => _WarnaTinjaScreenState();
}

class _WarnaTinjaScreenState extends State<WarnaTinjaScreen> {
  final WarnaTinjaApiService _api = WarnaTinjaApiService();
  final Map<String, String> _periodeLabels = {
    '2_minggu': '2 Minggu',
    '1_bulan': '1 Bulan',
    '2_4_bulan': '2 - 4 Bulan',
  };
  final Map<String, DateTime?> _tanggalByPeriode = {
    '2_minggu': null,
    '1_bulan': null,
    '2_4_bulan': null,
  };
  final Map<String, int?> _nomorWarnaByPeriode = {
    '2_minggu': null,
    '1_bulan': null,
    '2_4_bulan': null,
  };
  final Map<String, bool> _isSubmittedByPeriode = {
    '2_minggu': false,
    '1_bulan': false,
    '2_4_bulan': false,
  };

  bool _loading = true;
  bool _saving = false;

  int get _anakId {
    final dynamic id = widget.anak['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.tryParse(id?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final List<WarnaTinjaModel> rows = await _api.getByAnakId(_anakId);
      for (final row in rows) {
        if (!_periodeLabels.containsKey(row.periodeKey)) {
          continue;
        }
        _nomorWarnaByPeriode[row.periodeKey] =
            row.nomorWarna > 0 ? row.nomorWarna : null;
        _tanggalByPeriode[row.periodeKey] = DateTime.tryParse(row.tanggalCatat);
        if (row.nomorWarna > 0 && row.tanggalCatat.isNotEmpty) {
          _isSubmittedByPeriode[row.periodeKey] = true;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickDate(String periodeKey) async {
    if (_isSubmittedByPeriode[periodeKey] == true) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalByPeriode[periodeKey] ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _tanggalByPeriode[periodeKey] = picked;
      });
    }
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  Future<void> _simpan() async {
    final keys = _periodeLabels.keys.toList(growable: false);
    final newlyFilledCount = keys
        .where((k) =>
            _isSubmittedByPeriode[k] != true &&
            _tanggalByPeriode[k] != null &&
            _nomorWarnaByPeriode[k] != null)
        .length;

    if (newlyFilledCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data baru untuk disimpan.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      for (final key in keys) {
        if (_isSubmittedByPeriode[key] == true) continue;

        final tanggal = _tanggalByPeriode[key];
        final nomor = _nomorWarnaByPeriode[key];
        if (tanggal == null || nomor == null) {
          continue;
        }
        await _api.save(
          anakId: _anakId,
          periodeKey: key,
          tanggalCatat: _fmtDate(tanggal),
          nomorWarna: nomor,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data warna tinja berhasil disimpan.')),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showExitPopup() {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.exit,
      title: 'Yakin ingin keluar?',
      content:
          'Apakah Anda yakin ingin keluar tanpa menyimpan? Data yang belum disimpan akan hilang dan tidak dapat dikembalikan.',
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  void _showSavePopup() {
    final keys = _periodeLabels.keys.toList(growable: false);
    final newlyFilledCount = keys
        .where((k) =>
            _isSubmittedByPeriode[k] != true &&
            _tanggalByPeriode[k] != null &&
            _nomorWarnaByPeriode[k] != null)
        .length;

    if (newlyFilledCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data baru untuk disimpan.')),
      );
      return;
    }

    showVerificationPopup(
      context: context,
      type: VerificationPopupType.save,
      title: 'Konfirmasi Simpan',
      content:
          'Apakah Anda yakin data warna tinja sudah benar? Data yang sudah disimpan tidak dapat diubah kembali.',
      onConfirm: () {
        Navigator.pop(context);
        _simpan();
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  Widget _buildAnakCard() {
    final nama = widget.anak['nama'] ?? widget.anak['nama_anak'] ?? 'Anak';

    final usia = widget.anak['usia_teks'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFD7ECFF),
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Usia: $usia',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF185FA5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Warna Tinja',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: _showExitPopup,
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _showExitPopup();
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnakCard(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFBBF24)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Periksa warna tinja bayi setiap hari.',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Periksa warna tinja bayi setiap hari hingga berumur 4 bulan, dan catat saat berumur 2 minggu, 1 bulan dan 1-4 bulan.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jika menemukan warna tinja lebih pucat mendekati nomor 1 sampai 3, segera bawa bayi ke dokter karena ada kemungkinan bayi menderita sumbatan kandung empedu (Atresia Bilier).',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Table(
                            border:
                                TableBorder.all(color: const Color(0xFF9E9E9E)),
                            columnWidths: const {
                              0: FixedColumnWidth(96),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFEDE1A7)),
                                children: [
                                  _headerCell('Usia'),
                                  _headerCell(_periodeLabels['2_minggu']!),
                                  _headerCell(_periodeLabels['1_bulan']!),
                                  _headerCell(_periodeLabels['2_4_bulan']!),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _rowTitle('Tanggal\n(DD/MM/YYYY)'),
                                  _dateCell('2_minggu'),
                                  _dateCell('1_bulan'),
                                  _dateCell('2_4_bulan'),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _rowTitle('Nomor\nWarna Tinja'),
                                  _nomorCell('2_minggu'),
                                  _nomorCell('1_bulan'),
                                  _nomorCell('2_4_bulan'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: List.generate(7, (i) {
                            final nomor = i + 1;
                            final shades = [
                              const Color(0xFFF7F3D8),
                              const Color(0xFFEDE5B8),
                              const Color(0xFFE6D88D),
                              const Color(0xFFEBD130),
                              const Color(0xFFD9B126),
                              const Color(0xFFC99A22),
                              const Color(0xFFA59A2C),
                            ];
                            return Container(
                              width: 46,
                              height: 30,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: shades[i],
                                border:
                                    Border.all(color: const Color(0xFF9E9E9E)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$nomor',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Perhatikan warna tinja bayi sampai berumur 4 bulan. Jika mata bayi masih kuning atau urin berwarna kuning keruh setelah usia 2 minggu, segera bawa bayi ke dokter.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _showSavePopup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF185FA5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _saving ? 'Menyimpan...' : 'Simpan Data',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _rowTitle(String text) {
    return SizedBox(
      height: 68,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _dateCell(String periodeKey) {
    final bool isSubmitted = _isSubmittedByPeriode[periodeKey] == true;
    return InkWell(
      onTap: isSubmitted ? null : () => _pickDate(periodeKey),
      child: SizedBox(
        height: 68,
        child: Center(
          child: Text(
            _tanggalByPeriode[periodeKey] == null
                ? 'Pilih'
                : _fmtDate(_tanggalByPeriode[periodeKey]),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isSubmitted
                  ? Colors.grey.shade700
                  : _tanggalByPeriode[periodeKey] == null
                      ? Colors.grey.shade600
                      : Colors.black87,
              fontWeight: isSubmitted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nomorCell(String periodeKey) {
    final bool isSubmitted = _isSubmittedByPeriode[periodeKey] == true;
    return SizedBox(
      height: 68,
      child: Center(
        child: DropdownButton<int>(
          value: _nomorWarnaByPeriode[periodeKey],
          hint: const Text('No.', style: TextStyle(fontSize: 11)),
          underline: const SizedBox.shrink(),
          icon: isSubmitted ? const SizedBox.shrink() : null,
          disabledHint: Text(
            _nomorWarnaByPeriode[periodeKey]?.toString() ?? 'No.',
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600),
          ),
          items: List.generate(
            7,
            (index) => DropdownMenuItem<int>(
              value: index + 1,
              child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
            ),
          ),
          onChanged: isSubmitted
              ? null
              : (val) {
                  setState(() {
                    _nomorWarnaByPeriode[periodeKey] = val;
                  });
                },
        ),
      ),
    );
  }
}
