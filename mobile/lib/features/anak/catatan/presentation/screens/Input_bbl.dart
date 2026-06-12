import 'package:flutter/material.dart';
import '../../data/models/bbl_model.dart';
import '../../data/services/bbl_api_service.dart';

// ── Palette sesuai tema aplikasi ──
const _kPrimary    = Color(0xFF185FA5);
const _kPrimaryBg  = Color(0xFFE8F1FB);

/// Daftar periode waktu default BBL
const List<String> _kDefaultPeriode = [
  '0–6 jam',
  '6–48 jam',
  'Hari 3–7',
  'Hari 8–28',
];

class InputBblScreen extends StatefulWidget {
  final String namaAnak;
  final String usiaTeks;
  final String? anakId;

  const InputBblScreen({
    Key? key,
    required this.namaAnak,
    required this.usiaTeks,
    this.anakId,
  }) : super(key: key);

  @override
  State<InputBblScreen> createState() => _InputBblScreenState();
}

class _BblCheckItem {
  final String periodeWaktu;
  bool statusPemeriksaan;
  bool locked;
  DateTime? tanggalSubmit;
  int existingId;
  bool isVerified;
  DateTime? verifiedAt;
  String? namaKaderVerifikasi;

  _BblCheckItem({
    required this.periodeWaktu,
    required this.statusPemeriksaan,
    required this.locked,
    this.tanggalSubmit,
    this.existingId = 0,
    this.isVerified = false,
    this.verifiedAt,
    this.namaKaderVerifikasi,
  });
}

class _InputBblScreenState extends State<InputBblScreen> {
  late List<_BblCheckItem> _checkItems;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  late BblApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = BblApiService();
    _checkItems = _kDefaultPeriode
        .map((p) => _BblCheckItem(
              periodeWaktu: p,
              statusPemeriksaan: false,
              locked: false,
              tanggalSubmit: null,
            ))
        .toList();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.anakId == null) return;
    final anakId = int.tryParse(widget.anakId!);
    if (anakId == null) return;

    setState(() => _isLoading = true);
    try {
      final bbl = await _apiService.getByAnakId(anakId);
      if (bbl != null) {
        setState(() {
          // Map checklist dari server ke UI items
          for (var i = 0; i < _checkItems.length; i++) {
            final serverCheck = bbl.getCheckByPeriode(_checkItems[i].periodeWaktu);
            if (serverCheck != null) {
              _checkItems[i].statusPemeriksaan = serverCheck.statusPemeriksaan;
              _checkItems[i].locked = serverCheck.statusPemeriksaan;
              _checkItems[i].tanggalSubmit = serverCheck.tanggalSubmit;
              _checkItems[i].existingId = serverCheck.id;
              _checkItems[i].isVerified = serverCheck.isVerified;
              _checkItems[i].verifiedAt = serverCheck.verifiedAt;
              _checkItems[i].namaKaderVerifikasi = serverCheck.namaKaderVerifikasi;
            }
          }

          // Jika ada checklist dari server yang tidak ada di default, tambahkan
          for (final check in bbl.checklist) {
            final exists = _checkItems.any((item) => item.periodeWaktu == check.periodeWaktu);
            if (!exists) {
              _checkItems.add(_BblCheckItem(
                periodeWaktu: check.periodeWaktu,
                statusPemeriksaan: check.statusPemeriksaan,
                locked: check.statusPemeriksaan,
                tanggalSubmit: check.tanggalSubmit,
                existingId: check.id,
                isVerified: check.isVerified,
                verifiedAt: check.verifiedAt,
                namaKaderVerifikasi: check.namaKaderVerifikasi,
              ));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data BBL: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (widget.anakId == null) return;
    final anakId = int.tryParse(widget.anakId!);
    if (anakId == null) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final checklistData = _checkItems
            .map((item) => BblCheckModel(
                  id: item.existingId,
                  bblId: 0,
                  periodeWaktu: item.periodeWaktu,
                  statusPemeriksaan: item.statusPemeriksaan,
                  tanggalSubmit: item.tanggalSubmit,
                ))
            .toList();

        final model = BblModel(
          id: 0,
          anakId: anakId,
          checklist: checklistData,
        );

        await _apiService.upsert(anakId, model);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data BBL berhasil disimpan!'),
              backgroundColor: _kPrimary,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data BBL: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF172033),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bayi Baru Lahir (BBL)',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Card Profil Anak ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD7ECFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF185FA5),
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.namaAnak,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7ECFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Usia: ${widget.usiaTeks}',
                                    style: const TextStyle(
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
                    ),

                    const SizedBox(height: 20),

                    // ─── Status Verifikasi Card ─────────────────────────
                    _buildVerifikasiCard(),

                    const SizedBox(height: 20),

                    // ─── Seksi: Pemeriksaan Kesehatan ─────────────────────────────
                    _SectionTitle(
                      title: 'Pemeriksaan Kesehatan di Puskesmas',
                      color: _kPrimary,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Beri tanda ✓ jika si kecil sudah mendapat pemeriksaan oleh tenaga kesehatan:',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    // ─── Tabel Checklist Dinamis ─────────────────────────────
                    _buildChecklistTable(),

                    const SizedBox(height: 20),

                    // ─── Info card ────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFBBF24)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tanyakan kepada bidan/dokter/perawat untuk penjelasan lebih lanjut terkait perawatan bayi baru lahir.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── Tombol Simpan ────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: _isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.save_alt_rounded),
                        label: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Simpan Data BBL',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ─────────────────────── Verifikasi Card ────────────────────────────────

  Widget _buildVerifikasiCard() {
    final submittedItems = _checkItems.where((c) => c.statusPemeriksaan).toList();
    if (submittedItems.isEmpty) return const SizedBox.shrink();

    final isVerified = submittedItems.every((c) => c.isVerified);
    
    final latestVerified = submittedItems.where((c) => c.isVerified).toList()
      ..sort((a, b) => (b.verifiedAt ?? DateTime(0)).compareTo(a.verifiedAt ?? DateTime(0)));
      
    final namaKaderVerifikasi = latestVerified.isNotEmpty ? latestVerified.first.namaKaderVerifikasi : null;
    final verifiedAt = latestVerified.isNotEmpty ? latestVerified.first.verifiedAt : null;

    final Color cardColor;
    final Color borderColor;
    final IconData statusIcon;
    final String statusText;
    final Color iconColor;

    if (isVerified) {
      cardColor = const Color(0xFFECFDF5);
      borderColor = const Color(0xFF10B981);
      statusIcon = Icons.verified;
      iconColor = const Color(0xFF059669);
      statusText = 'Semua data terverifikasi';
    } else {
      cardColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFB923C);
      statusIcon = Icons.pending;
      iconColor = const Color(0xFFEA580C);
      statusText = 'Menunggu Verifikasi (${submittedItems.where((c) => c.isVerified).length}/${submittedItems.length})';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $statusText',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                if (isVerified && namaKaderVerifikasi != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir diverifikasi oleh: $namaKaderVerifikasi',
                    style: TextStyle(fontSize: 12, color: iconColor.withOpacity(0.8)),
                  ),
                ],
                if (isVerified && verifiedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tanggal: ${_formatDate(verifiedAt)}',
                    style: TextStyle(fontSize: 12, color: iconColor.withOpacity(0.8)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Checklist Table ────────────────────────────────

  Widget _buildChecklistTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // HEADER TABLE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 36, child: Text('No', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  Expanded(flex: 3, child: Text('Periode Waktu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  Expanded(flex: 3, child: Text('Tanggal Submit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  SizedBox(width: 80, child: Center(child: Text('Checklist', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)))),
                ],
              ),
            ),

            const Divider(height: 1),

            // BODY TABLE
            Column(
              children: List.generate(_checkItems.length, (index) {
                final item = _checkItems[index];

                return Container(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
                    border: index < _checkItems.length - 1
                        ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      // NO
                      SizedBox(
                        width: 36,
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 13)),
                      ),

                      // PERIODE WAKTU
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.periodeWaktu,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),

                      // TANGGAL SUBMIT (AUTO)
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.statusPemeriksaan ? _formatDate(item.tanggalSubmit) : '-',
                          style: TextStyle(
                            fontSize: 13,
                            color: item.statusPemeriksaan ? const Color(0xFF1E293B) : Colors.grey,
                          ),
                        ),
                      ),

                      // CHECKLIST IBU (checkbox dinamis)
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: Checkbox(
                            value: item.statusPemeriksaan,
                            activeColor: _kPrimary,
                            onChanged: item.locked
                                ? null
                                : (val) {
                                    setState(() {
                                      item.statusPemeriksaan = val ?? false;
                                      if (val == true) {
                                        item.tanggalSubmit ??= DateTime.now();
                                      } else {
                                        item.tanggalSubmit = null;
                                      }
                                    });
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Sub-widgets ──────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}