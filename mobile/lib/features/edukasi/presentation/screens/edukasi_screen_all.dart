import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/informasi_umum_api_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_pola_asuh_api_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_perawatan_anak_api_service.dart';

// Import Trimester
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_trimester_model.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_trimester_repository.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_trimester_service.dart';
import '../ibu/edukasi_trimester_detail_screen.dart';

// Import Detail Anak
import '../anak/detail_konten_edukasi_anak_screen.dart';

// Import 5 kategori Ibu lainnya (IMD, ASI, Mental, Nifas, Persalinan)
// Model = bentuk data, Repository = jembatan ambil data, Service = pemanggil API,
// Detail screen = halaman isi lengkap saat satu kartu diketuk.
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_imd_model.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_asi_model.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_mental_model.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_nifas_model.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_tanda_melahirkan_model.dart';

import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_imd_repository.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_asi_repository.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_mental_repository.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_nifas_repository.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/repositories/edukasi_tanda_melahirkan_repository.dart';

import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_imd_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_asi_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_mental_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_nifas_service.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/services/edukasi_tanda_melahirkan_service.dart';

import '../ibu/edukasi_imd_detail_screen.dart';
import '../ibu/edukasi_asi_detail_screen.dart';
import '../ibu/edukasi_mental_detail_screen.dart';
import '../ibu/edukasi_nifas_detail_screen.dart';
import '../ibu/edukasi_tanda_melahirkan_detail_screen.dart';

// =========================================================================
// HELPER: Normalisasi nilai trimester dari DB ke angka '1', '2', '3'
// =========================================================================
String normalizeTrimester(String raw) {
  final s = raw.trim().toLowerCase();
  if (s == '1') return '1';
  if (s == '2') return '2';
  if (s == '3') return '3';
  if (s == 'i') return '1';
  if (s == 'ii') return '2';
  if (s == 'iii') return '3';
  if (RegExp(r'^tm[\s_\-]?1$').hasMatch(s)) return '1';
  if (RegExp(r'^tm[\s_\-]?2$').hasMatch(s)) return '2';
  if (RegExp(r'^tm[\s_\-]?3$').hasMatch(s)) return '3';
  if (RegExp(r'^trimester[\s_\-]?1$').hasMatch(s)) return '1';
  if (RegExp(r'^trimester[\s_\-]?2$').hasMatch(s)) return '2';
  if (RegExp(r'^trimester[\s_\-]?3$').hasMatch(s)) return '3';
  if (RegExp(r'^trimester[\s_\-]?i$').hasMatch(s)) return '1';
  if (RegExp(r'^trimester[\s_\-]?ii$').hasMatch(s)) return '2';
  if (RegExp(r'^trimester[\s_\-]?iii$').hasMatch(s)) return '3';
  final digit = RegExp(r'[123]').firstMatch(s)?.group(0);
  if (digit != null) return digit;
  return s;
}

// =========================================================================
// PEWARNAAN PER KATEGORI
// =========================================================================
class _KategoriStyle {
  final Color background;
  final Color accent;
  const _KategoriStyle(this.background, this.accent);
}

_KategoriStyle _getKategoriStyle(String category) {
  switch (category) {
    case 'Trimester':
      return const _KategoriStyle(AppColors.blue100, AppColors.blue500);
    case 'Menyusui':
      return const _KategoriStyle(AppColors.pinkLight, AppColors.pink);
    case 'Kesehatan Mental':
      return const _KategoriStyle(AppColors.tealLight, AppColors.teal);
    case 'Nifas':
      return const _KategoriStyle(AppColors.purpleLight, AppColors.purple);
    case 'Persalinan':
      return const _KategoriStyle(AppColors.amberLight, AppColors.amber);
    case 'Informasi Umum':
      return const _KategoriStyle(Color(0xFFDBEAFE), Color(0xFF3B82F6));
    case 'Pola Asuh':
      return const _KategoriStyle(Color(0xFFFEF3C7), Color(0xFFD97706));
    case 'Perawatan':
      return const _KategoriStyle(Color(0xFFD1FAE5), Color(0xFF059669));
    default:
      return const _KategoriStyle(AppColors.purpleLight, AppColors.primary);
  }
}

// =========================================================================
// HALAMAN UTAMA EDUKASI
// =========================================================================
class EdukasiScreenAll extends StatefulWidget {
  const EdukasiScreenAll({super.key});

  @override
  State<EdukasiScreenAll> createState() => _EdukasiScreenAllState();
}

class _EdukasiScreenAllState extends State<EdukasiScreenAll>
    with SingleTickerProviderStateMixin {
  final InformasiUmumApiService _infoUmumService = InformasiUmumApiService();
  final EdukasiPolaAsuhApiService _polaAsuhService = EdukasiPolaAsuhApiService();
  final EdukasiPerawatanAnakApiService _perawatanService =
      EdukasiPerawatanAnakApiService();

  late TabController _tabController;

  String searchQuery = '';
  
  // State untuk Tab Ibu (Default langsung Trimester 1)
  String _selectedTrimesterFilter = '1';
  List<EdukasiTrimesterModel> _trimesterData = [];

  // Kategori yang sedang dipilih di tab Ibu (default: Trimester)
  String _selectedIbuKategori = 'Trimester';

  // Daftar materi untuk 5 kategori Ibu lainnya
  List<EdukasiIMDModel> _imdData = [];
  List<EdukasiASIModel> _asiData = [];
  List<EdukasiKesehatanMentalModel> _mentalData = [];
  List<EdukasiNifasModel> _nifasData = [];
  List<EdukasiTandaMelahirkanModel> _tandaData = [];

  // Pilihan chip filter di tab Ibu (urut sesuai alur kehamilan → persalinan → nifas)
  final List<String> _ibuKategoriFilters = const [
    'Trimester',
    'IMD',
    'ASI Eksklusif',
    'Kesehatan Mental',
    'Nifas',
    'Persalinan',
  ];

  // State untuk Tab Anak (Default langsung Informasi Umum)
  String _selectedFilterAnak = 'Informasi Umum';
  List<EdukasiAnakItem> _allAnakData = [];

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allItems = [];

  // Filter tanpa "Semua"
  final List<String> _anakFilters =
      ['Informasi Umum', 'Pola Asuh', 'Perawatan'];

  // =========================================================================
  // DATA STATIS: IBU & ANAK (Hanya dipakai di tab Semua)
  // =========================================================================
  final List<Map<String, dynamic>> _ibuItems = [
    {
      'type': 'ibu',
      'title': 'Edukasi Trimester',
      'desc': 'Panduan kesehatan ibu di setiap trimester kehamilan',
      'icon': Icons.pregnant_woman_rounded,
      'category': 'Trimester',
      'group': 'Ibu',
      // 'kategoriIbu' = nilai filter yang dipilih saat lompat ke tab Ibu
      'kategoriIbu': 'Trimester',
    },
    {
      'type': 'ibu',
      'title': 'Inisiasi Menyusu Dini (IMD)',
      'desc': 'Cara memulai menyusui sesaat setelah bayi lahir',
      'icon': Icons.child_care_rounded,
      'category': 'Menyusui',
      'group': 'Ibu',
      'kategoriIbu': 'IMD',
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Menyusui ASI Eksklusif',
      'desc': 'Manfaat dan tips memberikan ASI selama 6 bulan penuh',
      'icon': Icons.volunteer_activism_rounded,
      'category': 'Menyusui',
      'group': 'Ibu',
      'kategoriIbu': 'ASI Eksklusif',
    },
    {
      'type': 'ibu',
      'title': 'Kesehatan Mental Ibu Hamil',
      'desc': 'Mengenali dan menjaga kondisi emosi selama hamil',
      'icon': Icons.psychology_rounded,
      'category': 'Kesehatan Mental',
      'group': 'Ibu',
      'kategoriIbu': 'Kesehatan Mental',
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Perawatan Masa Nifas',
      'desc': 'Tips merawat diri dan pemulihan setelah melahirkan',
      'icon': Icons.favorite_rounded,
      'category': 'Nifas',
      'group': 'Ibu',
      'kategoriIbu': 'Nifas',
    },
    {
      'type': 'ibu',
      'title': 'Edukasi Tanda Melahirkan',
      'desc': 'Kenali tanda-tanda menjelang persalinan',
      'icon': Icons.medical_information_rounded,
      'category': 'Persalinan',
      'group': 'Ibu',
      'kategoriIbu': 'Persalinan',
    },
  ];

  final List<Map<String, dynamic>> _anakCategoryCards = [
    {
      'type': 'anak_category',
      'title': 'Informasi Umum',
      'desc': 'Panduan kesehatan dan pertumbuhan anak',
      'icon': Icons.info_outline_rounded,
      'category': 'Informasi Umum',
      'group': 'Anak',
    },
    {
      'type': 'anak_category',
      'title': 'Pola Asuh',
      'desc': 'Tips parenting dan pola asuh yang baik',
      'icon': Icons.family_restroom_rounded,
      'category': 'Pola Asuh',
      'group': 'Anak',
    },
    {
      'type': 'anak_category',
      'title': 'Perawatan Anak',
      'desc': 'Panduan merawat kesehatan anak sehari-hari',
      'icon': Icons.healing_rounded,
      'category': 'Perawatan',
      'group': 'Anak',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _infoUmumService.dispose();
    _polaAsuhService.dispose();
    _perawatanService.dispose();
    super.dispose();
  }

  // =========================================================================
  // LOAD DATA
  // =========================================================================
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tempAnakData = <EdukasiAnakItem>[];
    final errors = <String>[];

    // Load Trimester
    try {
      final repo = EdukasiTrimesterRepository(EdukasiTrimesterService());
      _trimesterData = await repo.getAll();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat Trimester: $e');
      errors.add('Trimester');
    }

    // Load IMD
    try {
      final repo = EdukasiIMDRepository(EdukasiIMDService());
      _imdData = await repo.getAllEdukasiIMD();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat IMD: $e');
      errors.add('IMD');
    }

    // Load ASI Eksklusif
    try {
      final repo = EdukasiASIRepository(EdukasiASIService());
      _asiData = await repo.getAllEdukasiASI();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat ASI: $e');
      errors.add('ASI');
    }

    // Load Kesehatan Mental
    try {
      final repo =
          EdukasiKesehatanMentalRepository(EdukasiKesehatanMentalService());
      _mentalData = await repo.getAllEdukasiKesehatanMental();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat Kesehatan Mental: $e');
      errors.add('Kesehatan Mental');
    }

    // Load Nifas
    try {
      final repo = EdukasiNifasRepository(EdukasiNifasService());
      _nifasData = await repo.getAllEdukasiNifas();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat Nifas: $e');
      errors.add('Nifas');
    }

    // Load Tanda Melahirkan (Persalinan)
    try {
      final repo = EdukasiTandaMelahirkanRepository(
          EdukasiTandaMelahirkanService());
      _tandaData = await repo.getAllEdukasiTandaMelahirkan();
    } catch (e) {
      debugPrint('[EdukasiIbu] Gagal memuat Tanda Melahirkan: $e');
      errors.add('Tanda Melahirkan');
    }

    // Load Anak Informasi Umum
    try {
      final list = await _infoUmumService.listInformasiUmum();
      tempAnakData.addAll(list.map((item) => EdukasiAnakItem(
            id: item.id,
            judul: item.judul ?? 'Tanpa Judul',
            kategori: 'Informasi Umum',
            tipe: (item.tipe?.isNotEmpty ?? false) ? item.tipe! : 'ARTIKEL',
            ringkasan: item.ringkasan ?? '',
            konten: item.konten ?? '',
            yangPerluDiingat: item.yangPerluDiingat ?? '',
            umurTarget: item.umurTarget ?? '',
            durasiBaca: item.durasiBaca ?? '',
            thumbnailUrl: item.thumbnailUrl ?? '',
          )));
    } catch (e) {
      errors.add('Informasi Umum');
    }

    // Load Anak Pola Asuh
    try {
      final list = await _polaAsuhService.listPolaAsuh();
      tempAnakData.addAll(list.map((item) => EdukasiAnakItem(
            id: item.id,
            judul: item.judul ?? 'Tanpa Judul',
            kategori: 'Pola Asuh',
            tipe: 'ARTIKEL',
            ringkasan: item.isi ?? '',
            konten: item.isi ?? '',
            thumbnailUrl: item.gambarUrl ?? '',
          )));
    } catch (e) {
      errors.add('Pola Asuh');
    }

    // Load Anak Perawatan
    try {
      final list = await _perawatanService.listPerawatanAnak();
      tempAnakData.addAll(list.map((item) => EdukasiAnakItem(
            id: item.id,
            judul: item.judul ?? 'Tanpa Judul',
            kategori: 'Perawatan',
            tipe: 'ARTIKEL',
            ringkasan: item.isiKonten ?? '',
            konten: item.isiKonten ?? '',
            thumbnailUrl: item.gambarUrl ?? '',
          )));
    } catch (e) {
      errors.add('Perawatan');
    }

    if (!mounted) return;

    setState(() {
      _allAnakData = tempAnakData;
      _allItems = [..._ibuItems, ..._anakCategoryCards];
      _isLoading = false;
      // Tampilkan layar error hanya kalau SEMUA sumber data (9) gagal dimuat
      if (errors.length == 9) {
        _errorMessage = 'Gagal memuat sebagian data edukasi.';
      }
    });
  }

  // =========================================================================
  // FILTER ITEMS UNTUK TAB SEMUA
  // =========================================================================
  List<Map<String, dynamic>> get _filteredItems {
    return _allItems.where((item) {
      final title = item['title'] as String;
      final desc = item['desc'] as String;

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!title.toLowerCase().contains(q) && !desc.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // =========================================================================
  // FILTER TRIMESTER UNTUK TAB IBU (Tanpa Semua)
  // =========================================================================
  List<EdukasiTrimesterModel> get _filteredTrimesterData {
    return _trimesterData
        .where((e) => normalizeTrimester(e.trimester) == _selectedTrimesterFilter)
        .toList();
  }

  // =========================================================================
  // FILTER ANAK UNTUK TAB ANAK (Tanpa Semua)
  // =========================================================================
  List<EdukasiAnakItem> get _filteredAnakData {
    return _allAnakData.where((e) => e.kategori == _selectedFilterAnak).toList();
  }

  // =========================================================================
  // NAVIGASI (TAB SEMUA) → lompat ke tab Ibu / Anak sesuai kategori
  // =========================================================================
  void _handleItemTap(Map<String, dynamic> item) {
    if (item['type'] == 'ibu') {
      // Semua kartu kategori Ibu cukup pindah ke tab Ibu lalu pilih kategorinya.
      // Kartu materi & isinya ditampilkan langsung di dalam tab (tanpa halaman
      // penampung terpisah).
      setState(() {
        _tabController.index = 1; // Pindah ke tab Ibu
        _selectedIbuKategori = item['kategoriIbu'] as String;
        if (item['kategoriIbu'] == 'Trimester') {
          _selectedTrimesterFilter = '1'; // Default ke Trimester I
        }
      });
    } else if (item['type'] == 'anak_category') {
      setState(() {
        _tabController.index = 2; // Pindah ke tab Anak
        _selectedFilterAnak = item['title']; // Filter sesuai kartu yang diklik
      });
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Column(
        children: [
          // ── Header putih ──
          Container(
            width: double.infinity,
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edukasi',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Informasi kesehatan ibu & anak',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Search bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          hintText: 'Cari edukasi disini...',
                          hintStyle: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // ── Tab bar ──
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Ibu'),
                      Tab(
                        height: 46,
                        child: Text(
                          'Tumbuh Kembang\nAnak',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Divider pembatas ──
          Container(color: const Color(0xFFE2E8F0), height: 1),

          // ── Konten ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadAllData,
                        color: AppColors.primary,
                        child: _tabController.index == 1
                            ? _buildIbuTabContent()
                            : _tabController.index == 2
                                ? _buildAnakTabContent()
                                : _filteredItems.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _filteredItems.length,
                                        itemBuilder: (context, index) {
                                          final item = _filteredItems[index];
                                          return _EdukasiKategoriCard(
                                            title: item['title'],
                                            desc: item['desc'],
                                            icon: item['icon'],
                                            category: item['category'],
                                            group: item['group'],
                                            onTap: () => _handleItemTap(item),
                                          );
                                        },
                                      ),
                      ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB IBU CONTENT
  // Struktur: chip filter kategori → langsung kartu materi (tanpa kartu penampung)
  // =========================================================================
  Widget _buildIbuTabContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Baris chip filter kategori Ibu ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _ibuKategoriFilters.map((kat) {
              final isSelected = _selectedIbuKategori == kat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIbuKategori = kat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        kat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Konten mengikuti kategori yang dipilih ──
        ..._buildIbuKategoriContent(),

        const SizedBox(height: 24),
      ],
    );
  }

  // =========================================================================
  // KONTEN PER-KATEGORI DI TAB IBU
  // Setiap kategori langsung mengeluarkan daftar kartu materinya. Saat kartu
  // diketuk, ibu dibawa ke halaman detail kategori tsb.
  // =========================================================================
  List<Widget> _buildIbuKategoriContent() {
    switch (_selectedIbuKategori) {
      case 'Trimester':
        return _buildTrimesterSection();

      case 'IMD':
        return _buildIbuCardList(
          isEmpty: _imdData.isEmpty,
          cards: _imdData.map(
            (item) => _IbuArticleCard(
              judul: item.judul,
              isi: item.isi,
              gambarUrl: item.gambarUrl,
              badgeText: 'IMD',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdukasiImdDetailScreen(item: item),
                ),
              ),
            ),
          ),
        );

      case 'ASI Eksklusif':
        return _buildIbuCardList(
          isEmpty: _asiData.isEmpty,
          cards: _asiData.map(
            (item) => _IbuArticleCard(
              judul: item.judul,
              isi: item.isi,
              gambarUrl: item.gambarUrl,
              badgeText: 'ASI Eksklusif',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdukasiAsiDetailScreen(item: item),
                ),
              ),
            ),
          ),
        );

      case 'Kesehatan Mental':
        return _buildIbuCardList(
          isEmpty: _mentalData.isEmpty,
          cards: _mentalData.map(
            (item) => _IbuArticleCard(
              judul: item.judul,
              isi: item.isi,
              gambarUrl: item.gambarUrl,
              badgeText: 'Kesehatan Mental',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdukasiMentalDetailScreen(item: item),
                ),
              ),
            ),
          ),
        );

      case 'Nifas':
        return _buildIbuCardList(
          isEmpty: _nifasData.isEmpty,
          cards: _nifasData.map(
            (item) => _IbuArticleCard(
              judul: item.judul,
              isi: item.isi,
              gambarUrl: item.gambarUrl,
              badgeText: 'Nifas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdukasiNifasDetailScreen(item: item),
                ),
              ),
            ),
          ),
        );

      case 'Persalinan':
        return _buildIbuCardList(
          isEmpty: _tandaData.isEmpty,
          cards: _tandaData.map(
            (item) => _IbuArticleCard(
              judul: item.judul,
              isi: item.isi,
              gambarUrl: item.gambarUrl,
              badgeText: 'Persalinan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdukasiTandaMelahirkanDetailScreen(item: item),
                ),
              ),
            ),
          ),
        );

      default:
        return const <Widget>[];
    }
  }

  /// Pembungkus daftar kartu: kalau kosong tampilkan pesan, kalau ada
  /// tampilkan kartunya. Dipakai semua kategori non-trimester biar tidak
  /// menulis ulang empty-state berkali-kali.
  List<Widget> _buildIbuCardList({
    required bool isEmpty,
    required Iterable<Widget> cards,
  }) {
    if (isEmpty) {
      return <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Belum ada edukasi tersedia',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
        ),
      ];
    }
    return cards.toList();
  }

  /// Bagian khusus Trimester: ada sub-filter TM I/II/III dulu, baru kartu materi.
  /// (Pola inilah yang dijadikan contoh untuk kategori lain.)
  List<Widget> _buildTrimesterSection() {
    final filtered = _filteredTrimesterData;

    return <Widget>[
      // Sub-filter Trimester (TM I / II / III)
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            {'value': '1', 'label': 'Trimester I'},
            {'value': '2', 'label': 'Trimester II'},
            {'value': '3', 'label': 'Trimester III'},
          ].map((f) {
            final isSelected = _selectedTrimesterFilter == f['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(
                    () => _selectedTrimesterFilter = f['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 12),

      if (filtered.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Belum ada edukasi tersedia',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
        )
      else
        ...filtered.map((item) => _TrimesterArticleCard(item: item)),
    ];
  }

  // =========================================================================
  // TAB ANAK CONTENT (Tanpa Semua)
  // =========================================================================
  Widget _buildAnakTabContent() {
    final filtered = _filteredAnakData;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sub-filter Anak
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _anakFilters.map((f) {
              final isSelected = _selectedFilterAnak == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilterAnak = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Belum ada edukasi tersedia',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
          )
        else
          ...filtered.map((item) => _AnakArticleCard(item: item)),
      ],
    );
  }

  // =========================================================================
  // STATE WIDGETS
  // =========================================================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 20),
            const Text('Gagal memuat sebagian data',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(_errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Edukasi tidak ditemukan',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Coba ubah filter atau kata kunci pencarian',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// =========================================================================
// KARTU KATEGORI (TAB SEMUA)
// =========================================================================
class _EdukasiKategoriCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final String category;
  final String group;
  final VoidCallback onTap;

  const _EdukasiKategoriCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.category,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getKategoriStyle(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: style.accent.withValues(alpha: 0.15),
          highlightColor: style.accent.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                        child: Icon(icon, size: 42, color: style.accent)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: style.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ARTIKEL CARD TRIMESTER
// =========================================================================
class _TrimesterArticleCard extends StatelessWidget {
  final EdukasiTrimesterModel item;
  const _TrimesterArticleCard({required this.item});

  String get _trimesterLabel {
    final n = normalizeTrimester(item.trimester);
    if (n == '1') return 'Trimester I';
    if (n == '2') return 'Trimester II';
    if (n == '3') return 'Trimester III';
    return item.trimester;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiTrimesterDetailScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.gambarUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.gambarUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              )
            else
              _placeholderImage(rounded: true),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.trimester.trim().isNotEmpty)
                        _Badge(
                          text: _trimesterLabel,
                          bgColor: const Color(0xFF1F5EA8),
                          textColor: Colors.white,
                        ),
                      if (item.trimester.trim().isNotEmpty &&
                          item.kategori.trim().isNotEmpty)
                        const SizedBox(width: 8),
                      if (item.kategori.trim().isNotEmpty)
                        _Badge(
                          text: item.kategori,
                          bgColor: const Color(0xFFE8F1FD),
                          textColor: const Color(0xFF1F5EA8),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.isi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F5EA8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1F5EA8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage({bool rounded = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: const Center(
        child: Icon(
          Icons.pregnant_woman_rounded,
          size: 36,
          color: Color(0xFF1F5EA8),
        ),
      ),
    );
  }
}

// =========================================================================
// ARTIKEL CARD GENERIK UNTUK KATEGORI IBU
// Satu kartu dipakai bersama oleh IMD, ASI, Mental, Nifas, dan Persalinan,
// karena tampilannya sama (gambar → badge → judul → cuplikan isi).
// Bedanya cuma teks badge & aksi saat diketuk, jadi keduanya dijadikan parameter.
// =========================================================================
class _IbuArticleCard extends StatelessWidget {
  final String judul;
  final String isi;
  final String gambarUrl;
  final String badgeText;
  final VoidCallback onTap;

  const _IbuArticleCard({
    required this.judul,
    required this.isi,
    required this.gambarUrl,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar atas (atau placeholder kalau URL kosong / gagal dimuat)
            if (gambarUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  gambarUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(rounded: true),
                ),
              )
            else
              _placeholderImage(rounded: true),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge nama kategori
                  _Badge(
                    text: badgeText,
                    bgColor: const Color(0xFFE8F1FD),
                    textColor: const Color(0xFF1F5EA8),
                  ),
                  const SizedBox(height: 12),

                  // Judul materi
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cuplikan isi (maksimal 3 baris)
                  Text(
                    isi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "Baca selengkapnya →"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F5EA8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1F5EA8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage({bool rounded = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: const Center(
        child: Icon(
          Icons.pregnant_woman_rounded,
          size: 36,
          color: Color(0xFF1F5EA8),
        ),
      ),
    );
  }
}

// =========================================================================
// ARTIKEL CARD ANAK
// =========================================================================
class _AnakArticleCard extends StatelessWidget {
  final EdukasiAnakItem item;
  const _AnakArticleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailKontenEdukasiAnakScreen(item: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.thumbnailUrl.trim().isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildAnakPlaceholder(),
                ),
              )
            else
              _buildAnakPlaceholder(rounded: true),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.kategori.trim().isNotEmpty)
                        _Badge(
                          text: item.kategori,
                          bgColor: const Color(0xFFE8F1FD),
                          textColor: const Color(0xFF1F5EA8),
                        ),
                      if (item.kategori.trim().isNotEmpty &&
                          item.tipe.trim().isNotEmpty)
                        const SizedBox(width: 8),
                      if (item.tipe.trim().isNotEmpty)
                        _Badge(
                          text: item.tipe,
                          bgColor: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.ringkasan,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F5EA8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1F5EA8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnakPlaceholder({bool rounded = false}) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: const Center(
        child: Icon(
          Icons.child_care_rounded,
          size: 36,
          color: Color(0xFF1F5EA8),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}