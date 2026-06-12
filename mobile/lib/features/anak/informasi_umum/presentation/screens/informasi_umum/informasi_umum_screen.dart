// import 'package:flutter/material.dart';

// import 'package:ta_pa2_pa3_project/features/anak/informasi_umum/data/services/informasi_umum_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/anak/informasi_umum/data/models/informasi_umum_model.dart';

// import 'package:ta_pa2_pa3_project/features/edukasi/data/services/informasi_umum_api_service.dart';
// import 'package:ta_pa2_pa3_project/features/edukasi/data/models/informasi_umum_model.dart';

// import 'informasi_umum_detail_screen.dart';

// class InformasiUmumScreen extends StatefulWidget {
//   const InformasiUmumScreen({Key? key}) : super(key: key);

//   @override
//   State<InformasiUmumScreen> createState() => _InformasiUmumScreenState();
// }

// class _InformasiUmumScreenState extends State<InformasiUmumScreen> {
//   final InformasiUmumApiService _apiService = InformasiUmumApiService();
//   final TextEditingController _searchController = TextEditingController();

//   late Future<List<InformasiUmumModel>> _itemsFuture;
//   String _selectedFilter = 'Semua';
//   String _searchQuery = '';

//   final List<String> _filters = const ['Semua', 'ARTIKEL', 'VIDEO'];

//   @override
//   void initState() {
//     super.initState();
//     _itemsFuture = _apiService.listInformasiUmum();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _apiService.dispose();
//     super.dispose();
//   }

//   Future<void> _reload() async {
//     setState(() {
//       _itemsFuture = _apiService.listInformasiUmum();
//     });
//   }

//   List<InformasiUmumModel> _filterItems(List<InformasiUmumModel> items) {
//     final keyword = _searchQuery.trim().toLowerCase();

//     return items.where((item) {
//       final matchesFilter = _selectedFilter == 'Semua' ||
//           item.tipe.toUpperCase() == _selectedFilter;
//       final matchesSearch = keyword.isEmpty ||
//           [item.judul, item.ringkasan, item.umurTarget, item.konten]
//               .where((value) => value.trim().isNotEmpty)
//               .any((value) => value.toLowerCase().contains(keyword));
//       return matchesFilter && matchesSearch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Informasi Umum',
//           style: TextStyle(
//             color: Color(0xFF1E293B),
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: _reload,
//             icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1.0),
//           child: Container(color: Colors.grey.shade200, height: 1.0),
//         ),
//       ),
//       body: FutureBuilder<List<InformasiUmumModel>>(
//         future: _itemsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return _EmptyState(
//               title: 'Gagal memuat informasi umum',
//               message: snapshot.error.toString(),
//               actionLabel: 'Coba lagi',
//               onAction: _reload,
//             );
//           }

//           final items = _filterItems(snapshot.data ?? const []);

//           return RefreshIndicator(
//             onRefresh: _reload,
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//               children: [
//                 _buildBanner(),
//                 const SizedBox(height: 16),
//                 _buildSearchBox(),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 44,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _filters.length,
//                     separatorBuilder: (_, __) => const SizedBox(width: 10),
//                     itemBuilder: (context, index) {
//                       final label = _filters[index];
//                       final isActive = _selectedFilter == label;
//                       return ChoiceChip(
//                         label: Text(label),
//                         selected: isActive,
//                         onSelected: (_) {
//                           setState(() {
//                             _selectedFilter = label;
//                           });
//                         },
//                         selectedColor: const Color(0xFF2563EB),
//                         labelStyle: TextStyle(
//                           color:
//                               isActive ? Colors.white : const Color(0xFF475569),
//                           fontWeight: FontWeight.w600,
//                         ),
//                         backgroundColor: Colors.white,
//                         shape: StadiumBorder(
//                           side: BorderSide(
//                             color: isActive
//                                 ? const Color(0xFF2563EB)
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Konten dari CRUD web',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1E293B),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 if (items.isEmpty)
//                   const _EmptyState(
//                     title: 'Belum ada data',
//                     message:
//                         'Tambahkan Informasi Umum dari web dashboard supaya tampil di mobile.',
//                   )
//                 else
//                   ...items.map((item) => _InformasiUmumCard(
//                         item: item,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   InformasiUmumDetailScreen(item: item),
//                             ),
//                           );
//                         },
//                       )),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF6FF),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB), size: 28),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Konten di halaman ini diambil langsung dari data Informasi Umum yang kamu simpan lewat web.',
//               style: TextStyle(
//                 color: Color(0xFF1D4ED8),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBox() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               decoration: const InputDecoration(
//                 hintText: 'Cari informasi umum...',
//                 hintStyle: TextStyle(
//                   color: Color(0xFF94A3B8),
//                   fontSize: 13,
//                 ),
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 _searchController.clear();
//                 _searchQuery = '';
//                 _selectedFilter = 'Semua';
//               });
//             },
//             icon: const Icon(Icons.filter_alt_outlined,
//                 color: Color(0xFF94A3B8), size: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InformasiUmumCard extends StatelessWidget {
//   final InformasiUmumModel item;
//   final VoidCallback onTap;

//   const _InformasiUmumCard({required this.item, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final Color topBgColor =
//         item.isVideo ? const Color(0xFFE6EFFF) : const Color(0xFFFFF0D4);
//     final Color typeColor =
//         item.isVideo ? const Color(0xFF3B82F6) : const Color(0xFFFF5C00);
//     final Color typeBgColor =
//         item.isVideo ? const Color(0xFFE6EFFF) : const Color(0xFFFFF0D4);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: onTap,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 140,
//                 decoration: BoxDecoration(
//                   color: topBgColor,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: Stack(
//                   children: [
//                     Center(
//                       child: item.isVideo
//                           ? const Icon(Icons.play_circle_outline,
//                               color: Color(0xFF3B82F6), size: 42)
//                           : const Icon(Icons.menu_book_rounded,
//                               color: Color(0xFFE2C499), size: 64),
//                     ),
//                     Positioned(
//                       top: 12,
//                       left: 12,
//                       child: _Badge(text: item.displayAgeText),
//                     ),
//                     Positioned(
//                       bottom: 12,
//                       right: 12,
//                       child: _Badge(
//                         text: item.displayDurationText,
//                         backgroundColor: const Color(0xFF64748B),
//                         textColor: Colors.white,
//                       ),
//                     ),
//                     Positioned(
//                       top: 12,
//                       right: 12,
//                       child: _Badge(
//                         text: item.tipe.toUpperCase(),
//                         backgroundColor: typeBgColor,
//                         textColor: typeColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.judul,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1E293B),
//                       ),
//                     ),
//                     if (item.ringkasan.trim().isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         item.ringkasan,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF64748B),
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Badge extends StatelessWidget {
//   final String text;
//   final Color backgroundColor;
//   final Color textColor;

//   const _Badge({
//     required this.text,
//     this.backgroundColor = Colors.white,
//     this.textColor = const Color(0xFF1E293B),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final String title;
//   final String message;
//   final String? actionLabel;
//   final VoidCallback? onAction;

//   const _EmptyState({
//     required this.title,
//     required this.message,
//     this.actionLabel,
//     this.onAction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.menu_book_rounded,
//                 size: 52, color: Color(0xFF94A3B8)),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF64748B),
//                 height: 1.5,
//               ),
//             ),
//             if (actionLabel != null && onAction != null) ...[
//               const SizedBox(height: 14),
//               FilledButton(
//                 onPressed: onAction,
//                 child: Text(actionLabel!),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/features/anak/informasi_umum/data/services/informasi_umum_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/informasi_umum/data/models/informasi_umum_model.dart';


import 'informasi_umum_detail_screen.dart';

class InformasiUmumScreen extends StatefulWidget {
  const InformasiUmumScreen({Key? key}) : super(key: key);

  @override
  State<InformasiUmumScreen> createState() => _InformasiUmumScreenState();
}

class _InformasiUmumScreenState extends State<InformasiUmumScreen> {
  final InformasiUmumApiService _apiService = InformasiUmumApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<InformasiUmumModel>> _itemsFuture;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  final List<String> _filters = const ['Semua', 'ARTIKEL', 'VIDEO'];

  @override
  void initState() {
    super.initState();
    _itemsFuture = _apiService.listInformasiUmum();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _itemsFuture = _apiService.listInformasiUmum();
    });
  }

  List<InformasiUmumModel> _filterItems(List<InformasiUmumModel> items) {
    final keyword = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      final matchesFilter = _selectedFilter == 'Semua' ||
          item.tipe.toUpperCase() == _selectedFilter;
      final matchesSearch = keyword.isEmpty ||
          [item.judul, item.ringkasan, item.umurTarget, item.konten]
              .where((value) => value.trim().isNotEmpty)
              .any((value) => value.toLowerCase().contains(keyword));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Informasi Umum',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<InformasiUmumModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EmptyState(
              title: 'Gagal memuat informasi umum',
              message: snapshot.error.toString(),
              actionLabel: 'Coba lagi',
              onAction: _reload,
            );
          }

          final items = _filterItems(snapshot.data ?? const []);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                _buildBanner(),
                const SizedBox(height: 16),
                _buildSearchBox(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final label = _filters[index];
                      final isActive = _selectedFilter == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isActive,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = label;
                          });
                        },
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          color:
                              isActive ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isActive
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Konten dari CRUD web',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const _EmptyState(
                    title: 'Belum ada data',
                    message:
                        'Tambahkan Informasi Umum dari web dashboard supaya tampil di mobile.',
                  )
                else
                  ...items.map((item) => _InformasiUmumCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InformasiUmumDetailScreen(item: item),
                            ),
                          );
                        },
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Konten di halaman ini diambil langsung dari data Informasi Umum yang kamu simpan lewat web.',
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari informasi umum...',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedFilter = 'Semua';
              });
            },
            icon: const Icon(Icons.filter_alt_outlined,
                color: Color(0xFF94A3B8), size: 20),
          ),
        ],
      ),
    );
  }
}

class _InformasiUmumCard extends StatelessWidget {
  final InformasiUmumModel item;
  final VoidCallback onTap;

  const _InformasiUmumCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color topBgColor =
        item.isVideo ? const Color(0xFFE6EFFF) : const Color(0xFFFFF0D4);
    final Color typeColor =
        item.isVideo ? const Color(0xFF3B82F6) : const Color(0xFFFF5C00);
    final Color typeBgColor =
        item.isVideo ? const Color(0xFFE6EFFF) : const Color(0xFFFFF0D4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: topBgColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: item.isVideo
                          ? const Icon(Icons.play_circle_outline,
                              color: Color(0xFF3B82F6), size: 42)
                          : const Icon(Icons.menu_book_rounded,
                              color: Color(0xFFE2C499), size: 64),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _Badge(text: item.displayAgeText),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _Badge(
                        text: item.displayDurationText,
                        backgroundColor: const Color(0xFF64748B),
                        textColor: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _Badge(
                        text: item.tipe.toUpperCase(),
                        backgroundColor: typeBgColor,
                        textColor: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (item.ringkasan.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.ringkasan,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
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

class _Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.text,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1E293B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 52, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}