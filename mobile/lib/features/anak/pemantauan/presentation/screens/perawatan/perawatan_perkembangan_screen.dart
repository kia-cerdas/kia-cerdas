import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../pemantauan/data/models/perawatan_model.dart';
import '../../../../pemantauan/data/services/perawatan_api_service.dart';
import '../../../../../../core/widgets/verification_popup.dart';

/// PerawatanPerkembanganScreen
/// Menampilkan materi perawatan + kuesioner perkembangan anak per rentang usia
/// Mengikuti pola yang sama dengan LembarPemantauanScreen (tab Isi + Riwayat)
class PerawatanPerkembanganScreen extends StatefulWidget {
  final Map<String, dynamic>? anak;

  const PerawatanPerkembanganScreen({
    super.key,
    this.anak,
  });

  @override
  State<PerawatanPerkembanganScreen> createState() =>
      _PerawatanPerkembanganScreenState();
}

class _PerawatanPerkembanganScreenState
    extends State<PerawatanPerkembanganScreen> {
  late PerawatanApiService _apiService;

  final List<String> _ageRanges = [
    '0-3 bulan',
    '3-6 bulan',
    '6-9 bulan',
    '9-12 bulan',
    '12-18 bulan',
    '18-24 bulan',
    '2-3 tahun',
    '3-4 tahun',
    '4-5 tahun',
    '5-6 tahun',
  ];

  final Map<String, String> _ageRangeDisplay = {
    '0-3 bulan': '0-3 bulan',
    '3-6 bulan': '3-6 bulan',
    '6-9 bulan': '6-9 bulan',
    '9-12 bulan': '9-12 bulan',
    '12-18 bulan': '12-18 bulan',
    '18-24 bulan': '18-24 bulan',
    '2-3 tahun': '2-3 tahun',
    '3-4 tahun': '3-4 tahun',
    '4-5 tahun': '4-5 tahun',
    '5-6 tahun': '5-6 tahun',
  };

  int _selectedAgeIndex = 0;

  // State per rentang usia
  Map<String, List<KategoriCapaianModel>> _kategoriByRange = {};
  Map<String, Map<int, bool?>> _checklistByRange = {};
  Map<String, Map<int, int?>> _idsByRange = {}; // perawatan ID untuk update
  Map<String, bool> _loadingByRange = {};
  Map<String, String> _errorByRange = {};
  Map<String, bool> _submittingByRange = {};
  Map<String, bool> _submittedByRange = {}; // sudah tersimpan?
  Map<String, DateTime?> _tanggalPeriksaByRange =
      {}; // tanggal pengisian per range

  // Tanggal periksa (sama untuk seluruh submit)
  DateTime _tanggalPeriksa = DateTime.now();

  // Dirty state: true jika ada perubahan checklist yang belum disimpan
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _apiService = PerawatanApiService(dio: Dio());
    _loadAllData();
  }

  int get _anakId {
    final raw = widget.anak?['id'];
    if (raw is int) return raw;
    return int.tryParse((raw ?? '').toString()) ?? 0;
  }

  String get _anakNama => widget.anak?['nama'] ?? 'Anak';
  String get _anakUsia => widget.anak?['usia_teks'] ?? '-';

  Future<void> _loadAllData() async {
    // Inisialisasi loading state semua range
    for (final range in _ageRanges) {
      _loadingByRange[range] = true;
      _errorByRange[range] = '';
    }
    if (mounted) setState(() {});

    await Future.wait([
      ..._ageRanges.map((range) => _loadRangeData(range)),
    ]);
  }

  Future<void> _loadRangeData(String range) async {
    try {
      final kategori = await _apiService.getKategoriCapaianByRentangUsia(range);
      final checklistMap = <int, bool?>{};
      final idMap = <int, int?>{};

      if (_anakId > 0) {
        try {
          final existing = await _apiService.getPerawatanByAnakIdAndRentangUsia(
              _anakId, range);
          DateTime? latestTanggal;
          for (final item in existing) {
            checklistMap[item.kategoriCapaianId] = item.jawaban;
            idMap[item.kategoriCapaianId] = item.id;
            if (item.tanggalPeriksa != null) {
              if (latestTanggal == null ||
                  item.tanggalPeriksa!.isAfter(latestTanggal)) {
                latestTanggal = item.tanggalPeriksa;
              }
            }
          }
          if (latestTanggal != null) {
            _tanggalPeriksaByRange[range] = latestTanggal;
          }
        } catch (_) {
          // belum ada data → kosong, no-op
        }
      }

      if (!mounted) return;
      setState(() {
        _kategoriByRange[range] = kategori;
        _checklistByRange[range] = checklistMap;
        _idsByRange[range] = idMap;
        _loadingByRange[range] = false;
        _submittedByRange[range] =
            checklistMap.isNotEmpty; // sudah pernah diisi
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingByRange[range] = false;
        _errorByRange[range] = e.toString();
      });
    }
  }

  void _handleBackPress() {
    if (_isDirty) {
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
    } else {
      Navigator.pop(context);
    }
  }

  void _showSavePopup(String range) {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.save,
      title: 'Konfirmasi Simpan',
      content:
          'Apakah Anda yakin data perawatan/perkembangan sudah benar? Data yang sudah disimpan tidak dapat diubah kembali.',
      onConfirm: () {
        Navigator.pop(context);
        _submit(range);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  Future<void> _submit(String range) async {
    final checklist = _checklistByRange[range] ?? {};
    final kategori = _kategoriByRange[range] ?? [];
    final ids = _idsByRange[range] ?? {};

    if (kategori.isEmpty) {
      _showSnack('Kuesioner belum tersedia untuk $range');
      return;
    }

    // Validasi: semua harus diisi
    final unanswered = kategori.where((k) => !checklist.containsKey(k.id));
    if (unanswered.isNotEmpty) {
      _showSnack(
          'Harap isi semua pertanyaan (${unanswered.length} belum dijawab)');
      return;
    }

    setState(() => _submittingByRange[range] = true);

    int successCount = 0;
    int failCount = 0;
    final errorMessages = <String>[];

    final List<BulkPerawatanItem> itemsToSave = [];

    for (final kat in kategori) {
      final jawaban = checklist[kat.id];
      if (jawaban == null) continue;

      itemsToSave.add(BulkPerawatanItem(
        kategoriCapaianId: kat.id,
        jawaban: jawaban,
        tanggalPeriksa: _tanggalPeriksa,
      ));
    }

    if (itemsToSave.isEmpty) {
      setState(() => _submittingByRange[range] = false);
      return;
    }

    try {
      final request = BulkPerawatanRequest(
        anakId: _anakId,
        data: itemsToSave,
      );

      final response = await _apiService.createBulkPerawatan(request);

      for (final peraw in response) {
        ids[peraw.kategoriCapaianId] = peraw.id;
      }

      successCount = response.length;
      failCount = itemsToSave.length - response.length;
    } catch (e) {
      failCount = itemsToSave.length;
      errorMessages.add(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _submittingByRange[range] = false;
      _idsByRange[range] = ids;
      if (failCount == 0) {
        _submittedByRange[range] = true;
        _isDirty = false;
      }
    });

    if (failCount == 0) {
      _showSnack(
        'Data perawatan $range berhasil disimpan. Kader akan diberitahu.',
        isSuccess: true,
      );
      setState(() {
        _tanggalPeriksaByRange[range] = _tanggalPeriksa;
      });
    } else {
      final firstError =
          errorMessages.isNotEmpty ? errorMessages.first : 'Coba lagi.';
      _showSnack(
          '$successCount berhasil, $failCount gagal disimpan. $firstError');
    }
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPeriksa,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF10B981),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _tanggalPeriksa = picked);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? const Color(0xFF10B981) : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────────────────────
  // MATERI PERAWATAN (sesuai gambar referensi)
  // ─────────────────────────────────────────────────────────
  Map<String, List<_MateriSection>> get _materiByRange => {
        '0-12 Bulan': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas untuk mendapatkan pelayanan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Kapsul Vitamin A (Februari atau Agustus)',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Perawatan Gigi',
            icon: Icons.sentiment_satisfied_alt_outlined,
            color: Color(0xFF8B5CF6),
            items: [
              'Lanjutkan perawatan gigi dengan mengingatkan anak menyikat gigi setelah makan dan sebelum tidur.',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Dukung tumbuh kembang si kecil sesuai perkembangan anak usianya:',
              '• Main bola, lompat tali',
              '• Latih untuk dapat mengikuti aturan permainan',
              '• Kenalkan nama-nama hari',
              '• Menyebut angka berurutan',
              '• Mengajak anak sikap gigi bersama dan melatih sikap gigi sendiri',
              '• Melatih memakai pakaian sendiri',
              '• Menguatkan kepercayaan diri anak',
            ],
          ),
        ],
        '1-2 Tahun': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapatkan pelayanan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Stimulasi bayi pada rentang usia 1-2 tahun:',
              '• Mengenal nama, fungsi benda-benda',
              '• Bacakan buku, tanya jawab, bercerita',
              '• Menonton TV didampingi maksimal 1 jam, menyanyai',
              '• Cuci tangan, cebok, berpakaian, rapikan mainan',
              '• Melempar, menangkap, berlari, melompat',
            ],
          ),
        ],
        '2-3 Tahun': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapatkan pelayanan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Stimulasi bayi pada rentang usia 2-3 tahun:',
              '• Makan dengan sendok garpu, masak-masakan',
              '• Menggunting, menempel, menjahit',
              '• Menyusun balok, memasang puzzle, menggambar, mewarnai, menulis nama',
              '• Membuang, mengerti aturan dan urutan',
              '• Membandingkan besar kecil, banyak sedikit',
              '• Menghitung, konsep satu dan sekelompok',
              '• Mengenal angka, huruf, simbol, jam, lidi, menyanyai',
              '• Memanjat, meraya, sepeda roda 3, ayunan',
              '• Bermain berjualan, bertukang, dan mengukur',
            ],
          ),
        ],
        '3-4 Tahun': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Stimulasi bayi pada rentang usia 3-4 tahun:',
              '• Bermain peran, pura-pura',
              '• Bercerita, bernyanyi, berdoa',
              '• Mengenal huruf, angka, bentuk, warna',
              '• Bermain pasir, air, tanah liat',
              '• Mengenal konsep waktu dan musim',
              '• Latih kemandirian: makan, berpakaian, mandi sendiri',
            ],
          ),
        ],
        '4-5 Tahun': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Perawatan Gigi',
            icon: Icons.sentiment_satisfied_alt_outlined,
            color: Color(0xFF8B5CF6),
            items: [
              'Lanjutkan perawatan gigi dengan mengingatkan anak menyikat gigi setelah makan dan sebelum tidur.',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Stimulasi bayi pada rentang usia 4-5 tahun:',
              '• Main bola, lompat tali',
              '• Latih untuk dapat mengikuti aturan permainan',
              '• Kenalkan nama-nama hari',
              '• Menyebut angka berurutan',
              '• Mengajak anak sikap gigi bersama dan melatih sikap gigi sendiri',
              '• Melatih memakai pakaian sendiri',
              '• Menguatkan kepercayaan diri anak',
            ],
          ),
        ],
        '5-6 Tahun': [
          const _MateriSection(
            title: 'Pelayanan Kesehatan',
            icon: Icons.local_hospital_outlined,
            color: Color(0xFF3B82F6),
            items: [
              'Bawa anak setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan:',
              '• Pemantauan pertumbuhan dan perkembangan',
              '• Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita',
              '• Obat cacing',
            ],
          ),
          const _MateriSection(
            title: 'Perawatan Gigi',
            icon: Icons.sentiment_satisfied_alt_outlined,
            color: Color(0xFF8B5CF6),
            items: [
              'Lanjutkan perawatan gigi anak Anda dengan:',
              '• Gigi susu anak: sebanyak 20 buah, mulai tumbuh 2 gigi geraham 1 atap, rahang bawah pertama kiri dan kanan',
              '• Periksakan gigi secara rutin setiap 3-6 bulan sekali ke dokter gigi atau perawat gigi di Puskesmas atau fasilitas kesehatan lainnya',
            ],
          ),
          const _MateriSection(
            title: 'Pantau Tumbuh Kembang Anak',
            icon: Icons.child_care,
            color: Color(0xFF10B981),
            items: [
              'Stimulasi bayi pada rentang usia 5-6 tahun:',
              '• Makan dengan sendok garpu, masak-masakan',
              '• Menggunting, menempel, menjahit',
              '• Menyusun balok, memasang puzzle, menggambar, mewarnai, menulis nama',
              '• Membuang, mengerti aturan dan urutan',
              '• Membandingkan besar kecil, banyak sedikit',
              '• Menghitung, konsep satu dan sekelompok',
              '• Mengenal angka, huruf, simbol, jam, lidi, menyanyai',
              '• Memanjat, meraya, sepeda roda 3, ayunan',
              '• Bermain berjualan, bertukang, dan mengukur',
            ],
          ),
        ],
      };

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeRange = _ageRanges[_selectedAgeIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perawatan Perkembangan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              _anakNama,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D4ED8),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPress,
        ),
      ),
      body: PopScope(
        canPop: !_isDirty,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _handleBackPress();
        },
        child: _buildKuesionerTab(),
      ),
      bottomNavigationBar: _buildSubmitBar(activeRange),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB 1: KUESIONER
  // ─────────────────────────────────────────────────────────
  Widget _buildKuesionerTab() {
    return RefreshIndicator(
      color: const Color(0xFF1D4ED8),
      onRefresh: () => _loadRangeData(_ageRanges[_selectedAgeIndex]),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          const SizedBox(height: 16),
          // Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                          _anakNama,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Usia: $_anakUsia',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tanggal Pemeriksaan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _pickTanggal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_month,
                            color: Color(0xFF3B82F6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tanggal Pemeriksaan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF)),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(_tanggalPeriksa),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tahapan Perkembangan Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'TAHAPAN PERKEMBANGAN',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B)),
                ),
                Text(
                  'Pilih kuisioner berdasarkan usia anak',
                  style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Age category grid (cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ageRanges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, i) {
                final isSelected = i == _selectedAgeIndex;
                final range = _ageRanges[i];
                final isDone = _submittedByRange[range] == true;
                final displayStr = _ageRangeDisplay[range] ?? range;

                return GestureDetector(
                  onTap: () => setState(() => _selectedAgeIndex = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF1D4ED8) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayStr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isDone ? Icons.check_circle : Icons.circle_outlined,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : (isDone
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFFCBD5E1)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          _buildRangeContent(_ageRanges[_selectedAgeIndex]),
        ],
      ),
    );
  }

  Widget _buildRangeContent(String range) {
    final isLoading = _loadingByRange[range] ?? true;
    final error = _errorByRange[range] ?? '';
    final kategori = _kategoriByRange[range] ?? [];
    final checklist = _checklistByRange[range] ?? {};

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1D4ED8)),
              SizedBox(height: 12),
              Text('Memuat data...',
                  style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat data untuk $range',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadRangeData(range),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final answeredCount = checklist.values.where((v) => v != null).length;
    final totalCount = kategori.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Materi Perawatan ──
          _buildMateriSection(range),
          if (_materiByRange[range]?.isNotEmpty ?? false)
            const SizedBox(height: 16),

          // ── Header Kuesioner ──
          _buildKuesionerHeader(range, answeredCount, totalCount),
          const SizedBox(height: 12),

          // ── Daftar Pertanyaan ──
          if (kategori.isEmpty)
            _buildEmptyKuesioner(range)
          else
            _buildChecklistTable(
                range, kategori, checklist, _submittedByRange[range] ?? false),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Materi ──
  Widget _buildMateriSection(String range) {
    final sections = _materiByRange[range] ?? [];
    if (sections.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header materi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perawatan Anak Umur $range',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'Diisi oleh Ibu',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sections
          ...sections.asMap().entries.map((entry) {
            final i = entry.key;
            final section = entry.value;
            return Column(
              children: [
                if (i > 0)
                  Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 16,
                      endIndent: 16),
                _buildSingleMateriSection(section),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSingleMateriSection(_MateriSection section) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: section.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(section.icon, color: section.color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                section.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: section.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...section.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Color(0xFF374151),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildKuesionerHeader(String range, int answered, int total) {
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3), // light yellow background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? answered / total : 0,
              minHeight: 4,
              backgroundColor:
                  const Color(0xFFFDE047).withOpacity(0.4), // pale yellow
              color: const Color(0xFFFACC15), // distinct yellow
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$answered dari $total pertanyaan dijawab',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF92400E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyKuesioner(String range) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline,
                color: Color(0xFF64748B), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuesioner belum tersedia',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kuesioner untuk $range belum tersedia',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabel Checklist Ya/Tidak ──
  Widget _buildChecklistTable(
    String range,
    List<KategoriCapaianModel> kategori,
    Map<int, bool?> checklist,
    bool isLocked,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text('NO.',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B))),
                ),
                Expanded(
                  child: Text(
                    'PENANDA PERKEMBANGAN ANAK',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B)),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text('YA',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8))),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Center(
                    child: Text('TIDAK',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEA580C))),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          // Rows
          ...List.generate(kategori.length, (i) {
            final item = kategori[i];
            final jawaban = checklist[item.id];

            return Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ),
                        Expanded(
                          child: Text(
                            item.pertanyaanCeklist,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ),
                        // Ya checkbox
                        SizedBox(
                          width: 44,
                          child: Checkbox(
                            value: jawaban == true,
                            activeColor: const Color(0xFF1D4ED8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: isLocked
                                ? null
                                : (v) {
                                    setState(() {
                                      final map = Map<int, bool?>.from(
                                          _checklistByRange[range] ?? {});
                                      map[item.id] = (v == true) ? true : null;
                                      _checklistByRange[range] = map;
                                      _isDirty = true;
                                    });
                                  },
                          ),
                        ),
                        // Tidak checkbox
                        SizedBox(
                          width: 52,
                          child: Checkbox(
                            value: jawaban == false,
                            activeColor: const Color(0xFFEA580C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: isLocked
                                ? null
                                : (v) {
                                    setState(() {
                                      final map = Map<int, bool?>.from(
                                          _checklistByRange[range] ?? {});
                                      map[item.id] = (v == true) ? false : null;
                                      _checklistByRange[range] = map;
                                      _isDirty = true;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < kategori.length - 1)
                  Divider(height: 1, color: Colors.grey.shade100),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Tombol Simpan ──
  Widget _buildSubmitButton(
      String range, bool isSubmitting, int answered, int total) {
    final allAnswered = answered == total && total > 0;
    final alreadySubmitted = _submittedByRange[range] ?? false;
    final isDisabled = isSubmitting || alreadySubmitted || !allAnswered;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : () => _showSavePopup(range),
        icon: isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          isSubmitting ? 'Menyimpan...' : 'Simpan Kuisioner',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D4ED8),
          disabledBackgroundColor: const Color(0xFF9CA3AF),
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSubmitBar(String range) {
    final kategori = _kategoriByRange[range] ?? [];
    final answered =
        _checklistByRange[range]?.values.where((v) => v != null).length ?? 0;
    final total = kategori.length;
    final isSubmitting = _submittingByRange[range] ?? false;

    if (kategori.isEmpty && (_loadingByRange[range] ?? true)) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.transparent,
        child: _buildSubmitButton(range, isSubmitting, answered, total),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────
// DATA CLASS
// ─────────────────────────────────────────────────────────
class _MateriSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _MateriSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}
