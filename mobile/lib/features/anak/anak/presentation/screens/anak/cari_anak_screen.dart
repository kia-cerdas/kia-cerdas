import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/services/pertumbuhan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/repositories/pertumbuhan_repository.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/widgets/index.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/presentation/screens/pertumbuhan_info_screen.dart';

enum SearchFilter { namaAnak, namaIbu, noKk }

class CariAnakScreen extends StatefulWidget {
  const CariAnakScreen({Key? key}) : super(key: key);

  @override
  State<CariAnakScreen> createState() => _CariAnakScreenState();
}

class _CariAnakScreenState extends State<CariAnakScreen> {
  late PertumbuhanRepository _repository;
  late TextEditingController _searchController;
  Timer? _debounce; // Tambahkan debouncer

  String _searchQuery = '';
  SearchFilter _selectedFilter = SearchFilter.namaAnak;
  List<AnakSearchModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = PertumbuhanRepository(
      apiService: PertumbuhanApiService(),
    );
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Bersihkan memori timer
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi dipanggil saat text berubah
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Tunggu 500ms setelah user berhenti mengetik baru hit API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _repository.searchAnak(
        namaAnak: _selectedFilter == SearchFilter.namaAnak ? query : '',
        namaIbu: _selectedFilter == SearchFilter.namaIbu ? query : '',
        noKk: _selectedFilter == SearchFilter.noKk ? query : '',
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _searchResults = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onFilterChanged(SearchFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pertumbuhan Anak',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard saat tap luar
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged, // Gunakan debouncer
                    decoration: InputDecoration(
                      hintText: 'Cari ${_selectedFilter.name.replaceAll('namaAnak', 'nama anak').replaceAll('noKk', 'nomor KK')}...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Filter Chips
                const Text(
                  'Filter Pencarian',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Nama Anak',
                        filter: SearchFilter.namaAnak,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Nama Ibu',
                        filter: SearchFilter.namaIbu,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'No. KK',
                        filter: SearchFilter.noKk,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Results Area
                _buildResultsArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(
            color: Color(0xFF185FA5),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFA32D2D)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFA32D2D),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Cari anak berdasarkan nama, ibu, atau KK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Data anak tidak ditemukan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} hasil ditemukan',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _searchResults.length,
          (index) {
            final anak = _searchResults[index];
            return ChildListCard(
              anak: anak,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PertumbuhanInfoScreen(anak: anak),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required SearchFilter filter,
  }) {
    final isActive = _selectedFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => _onFilterChanged(filter),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF185FA5).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isActive ? const Color(0xFF185FA5) : Colors.grey.shade600,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isActive ? const Color(0xFF185FA5) : Colors.grey.shade300,
      ),
      showCheckmark: false, // UI lebih clean tanpa checkmark bawaan
    );
  }
}