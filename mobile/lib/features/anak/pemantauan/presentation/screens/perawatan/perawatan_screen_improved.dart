import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../pemantauan/data/models/perawatan_model.dart';
import '../../../../pemantauan/data/services/perawatan_api_service.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

/// Perawatan Screen - Displays development/milestone questionnaire for children
/// Supports both viewing and answering questionnaires across different age ranges
class PerawatanScreenImproved extends StatefulWidget {
  final int anakId;
  final String anakName;

  const PerawatanScreenImproved({
    super.key,
    required this.anakId,
    required this.anakName,
  });

  @override
  State<PerawatanScreenImproved> createState() =>
      _PerawatanScreenImprovedState();
}

class _PerawatanScreenImprovedState extends State<PerawatanScreenImproved>
    with SingleTickerProviderStateMixin {
  late PerawatanApiService _apiService;
  late TabController _tabController;
  late List<String> _ageRanges;

  // State management
  Map<String, List<KategoriCapaianModel>> _kategoriByCageRange = {};
  Map<String, Map<int, bool?>> _checklistByRange = {};
  Map<String, Map<int, int?>> _perawatanIdsByRange = {};
  Map<String, bool> _loadingStatus = {};
  Map<String, String> _errorStatus = {};
  Map<String, bool> _submittingStatus = {};

  // Material mapping untuk setiap kategori
  final Map<String, String> _materiByKategori = {
    'Perkembangan Motorik': '''
Perkembangan Motorik (Gerakan Tubuh):
• Kemampuan bayi/anak untuk menggerakkan tubuh dan otot besar
• Meliputi: duduk, berdiri, berjalan, berlari, melompat
• Penting untuk mobilitas dan kemandirian anak

Stimulasi Motorik:
- Beri bayi kesempatan bergerak bebas (tummy time)
- Ajak anak bermain aktif (berlari, melompat)
- Sediakan mainan yang merangsang gerakan
- Biarkan anak belajar dari jatuh yang aman
    ''',
    'Perkembangan Bahasa': '''
Perkembangan Bahasa (Komunikasi):
• Kemampuan bayi/anak untuk mengerti dan menggunakan bahasa
• Meliputi: berceloteh, mengucapkan kata, membuat kalimat
• Penting untuk komunikasi dan pembelajaran

Stimulasi Bahasa:
- Ajari nama-nama benda sehari-hari
- Baca buku bersama anak
- Sering mengajak anak berbicara
- Dengarkan dan respons setiap ucapan anak
- Bernyanyi bersama
    ''',
    'Perkembangan Kognitif': '''
Perkembangan Kognitif (Pemikiran):
• Kemampuan anak berpikir, memahami, dan belajar
• Meliputi: memperhatikan, mengingat, memecahkan masalah
• Penting untuk pembelajaran dan problem solving

Stimulasi Kognitif:
- Mainkan permainan yang mengasah pikiran
- Tunjukkan benda dan namanya
- Bermain tebak-tebakan
- Biarkan anak mengeksplorasi lingkungan
- Bercerita dan membaca
    ''',
    'Perkembangan Sosial Emosional': '''
Perkembangan Sosial Emosional:
• Kemampuan anak berinteraksi dengan orang lain dan mengelola emosi
• Meliputi: tersenyum, bermain bersama, berbagi, mengontrol emosi
• Penting untuk hubungan sosial yang sehat

Stimulasi Sosial Emosional:
- Berikan kasih sayang dan perhatian
- Ajak bermain dengan anak lain
- Ajarkan berbagi dan tolong menolong
- Bantu anak mengenali dan mengelola emosi
- Beri pujian atas pencapaian anak
    ''',
    'Perkembangan Motorik Halus': '''
Perkembangan Motorik Halus (Gerakan Tangan):
• Kemampuan menggerakkan tangan, jari, dan mata dengan presisi
• Meliputi: menggenggam, memegang pensil, menulis, makan sendiri
• Penting untuk kemandirian dan tulis menulis

Stimulasi Motorik Halus:
- Mainkan dengan mainan kecil (playdough, puzzle)
- Ajak menggambar dan mewarnai
- Biarkan bermain dengan pasir atau air
- Ajari memegang sendok dengan benar
- Berikan mainan yang merangsang jari-jari
    ''',
  };

  @override
  void initState() {
    super.initState();
    _ageRanges = [
      '0-12 Bulan',
      '1-2 Tahun',
      '2-3 Tahun',
      '3-4 Tahun',
      '4-5 Tahun',
      '5-6 Tahun',
    ];
    _tabController = TabController(length: _ageRanges.length, vsync: this);
    _apiService = PerawatanApiService(dio: Dio());

    // Initialize all ranges with empty maps
    for (final range in _ageRanges) {
      _checklistByRange[range] = {};
      _perawatanIdsByRange[range] = {};
      _loadingStatus[range] = false;
      _errorStatus[range] = '';
      _submittingStatus[range] = false;
    }

    _loadKategoriCapaian();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadKategoriCapaian() async {
    try {
      // Set all as loading
      for (final range in _ageRanges) {
        if (mounted) {
          setState(() {
            _loadingStatus[range] = true;
            _errorStatus[range] = '';
          });
        }
      }

      for (final range in _ageRanges) {
        try {
          debugPrint('[Perawatan] Loading kategori capaian for: $range');

          // Load kategori capaian
          final kategori =
              await _apiService.getKategoriCapaianByRentangUsia(range);
          debugPrint('[Perawatan] ✓ Loaded ${kategori.length} kategori for $range');

          if (mounted) {
            setState(() {
              _kategoriByCageRange[range] = kategori;
            });
          }

          // Load existing perawatan data for this age range
          try {
            final perawatan = await _apiService
                .getPerawatanByAnakIdAndRentangUsia(widget.anakId, range);
            debugPrint(
                '[Perawatan] ✓ Loaded ${perawatan.length} existing perawatan for $range');

            final checklist = <int, bool?>{};
            final perawatanIds = <int, int?>{};

            for (final item in perawatan) {
              checklist[item.kategoriCapaianId] = item.jawaban;
              perawatanIds[item.kategoriCapaianId] = item.id;
            }

            if (mounted) {
              setState(() {
                _checklistByRange[range] = checklist;
                _perawatanIdsByRange[range] = perawatanIds;
              });
            }
          } catch (e) {
            debugPrint('[Perawatan] ⚠ No existing perawatan for $range: $e');
            // No existing data is OK, continue
          }

          if (mounted) {
            setState(() {
              _loadingStatus[range] = false;
            });
          }
        } catch (e) {
          debugPrint('[Perawatan] ✗ Error loading $range: $e');
          if (mounted) {
            setState(() {
              _loadingStatus[range] = false;
              _errorStatus[range] = e.toString();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[Perawatan] ✗ Unexpected error: $e');
    }
  }

  Future<void> _submitChecklist(String rentangUsia) async {
    final checklist = _checklistByRange[rentangUsia] ?? {};
    final perawatanIds = _perawatanIdsByRange[rentangUsia] ?? {};

    if (checklist.isEmpty) {
      _showSnackBar('Silakan isi minimal satu pertanyaan terlebih dahulu',
          isError: true);
      return;
    }

    if (mounted) {
      setState(() => _submittingStatus[rentangUsia] = true);
    }

    try {
      final kategori = _kategoriByCageRange[rentangUsia] ?? [];
      int successCount = 0;
      int errorCount = 0;

      for (final kat in kategori) {
        final jawaban = checklist[kat.id];
        if (jawaban != null) {
          try {
            final perawatanId = perawatanIds[kat.id];

            if (perawatanId != null) {
              // Update existing
              await _apiService.updatePerawatan(
                perawatanId,
                UpdatePerawatanRequest(
                  jawaban: jawaban,
                  tanggalPeriksa: DateTime.now(),
                ),
              );
              debugPrint('[Perawatan] ✓ Updated perawatan $perawatanId');
            } else {
              // Create new
              final response = await _apiService.createPerawatan(
                CreatePerawatanRequest(
                  anakId: widget.anakId,
                  kategoriCapaianId: kat.id,
                  jawaban: jawaban,
                  tanggalPeriksa: DateTime.now(),
                ),
              );
              debugPrint('[Perawatan] ✓ Created perawatan ${response.id}');
              
              // Update ID for future reference
              if (mounted) {
                setState(() {
                  _perawatanIdsByRange[rentangUsia]![kat.id] = response.id;
                });
              }
            }
            successCount++;
          } catch (e) {
            debugPrint('[Perawatan] ✗ Error save jawaban untuk kategori ${kat.id}: $e');
            errorCount++;
          }
        }
      }

      if (mounted) {
        if (errorCount == 0) {
          _showSnackBar(
            '$successCount jawaban berhasil disimpan',
            isError: false,
          );
          // Reload data
          await _loadKategoriCapaian();
        } else {
          _showSnackBar(
            'Tersimpan: $successCount, Gagal: $errorCount',
            isError: true,
          );
        }
      }
    } catch (e) {
      debugPrint('[Perawatan] ✗ Unexpected error during submit: $e');
      _showSnackBar('Terjadi kesalahan saat menyimpan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submittingStatus[rentangUsia] = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getMaterial(String aspek) {
    return _materiByKategori[aspek] ??
        '''Perkembangan Anak:
Pantau perkembangan anak secara berkala. Jika ada keterlambatan, segera konsultasikan dengan tenaga kesehatan.''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Perawatan ${widget.anakName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFD97706),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD97706),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: _ageRanges.map((range) => Tab(text: range)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadKategoriCapaian,
        child: TabBarView(
          controller: _tabController,
          children: _ageRanges.map((range) {
            return _buildAgeRangeTab(range);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAgeRangeTab(String rentangUsia) {
    final isLoading = _loadingStatus[rentangUsia] ?? false;
    final error = _errorStatus[rentangUsia] ?? '';
    final kategori = _kategoriByCageRange[rentangUsia] ?? [];

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data untuk $rentangUsia',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.length > 100 ? '${error.substring(0, 100)}...' : error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadKategoriCapaian,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (kategori.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data untuk $rentangUsia',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Data kategori capaian belum tersedia untuk usia ini',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadKategoriCapaian,
                child: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            'Perawatan Anak\nUmur $rentangUsia',
            const Color(0xFFD97706),
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(),
          const SizedBox(height: 16),
          _buildChecklistTable(kategori, rentangUsia),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: (_submittingStatus[rentangUsia] ?? false)
                ? null
                : () => _submitChecklist(rentangUsia),
            icon: const Icon(Icons.save),
            label: (_submittingStatus[rentangUsia] ?? false)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan Perawatan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (kategori.isNotEmpty && kategori.first.aspek.isNotEmpty)
            _buildMaterialCard(kategori.first.aspek),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF08A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.2)),
      ),
      child: const Text(
        'Beri tanda ✓ (centang) pada kolom Ya/Tidak. Jika anak belum bisa melakukan salah satu dari hal berikut ini, segera bawa ke Puskesmas untuk pemeriksaan lebih lanjut.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF713F12),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildChecklistTable(
      List<KategoriCapaianModel> kategori, String rentangUsia) {
    final checklist = _checklistByRange[rentangUsia] ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF08A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Daftar Penanda Perkembangan Anak',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF713F12),
                height: 1.4,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFD97706).withOpacity(0.12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  child: Text(
                    'No.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Penanda Perkembangan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'Ya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      'Tidak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: List.generate(kategori.length, (i) {
                final item = kategori[i];
                final isEven = i % 2 == 0;
                final jawaban = checklist[item.id];

                return Container(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.white : const Color(0xFFF8FAFC),
                    borderRadius: i == kategori.length - 1
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))
                        : null,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.pertanyaanCeklist,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E40AF),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: jawaban == true,
                          activeColor: const Color(0xFFD97706),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _checklistByRange[rentangUsia]![item.id] = true;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Checkbox(
                          value: jawaban == false,
                          activeColor: Colors.red,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _checklistByRange[rentangUsia]![item.id] = false;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(String aspek) {
    final material = _getMaterial(aspek);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Informasi Perkembangan',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            material,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
