import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'absensi_kelas_ibu_hamil_kader_api_service.dart'; // <-- import service
import 'absensi_kelas_ibu_hamil_model.dart';              // <-- import model

class VerifikasiAbsensiKelasIbuHamilScreen extends StatefulWidget {
  const VerifikasiAbsensiKelasIbuHamilScreen({super.key});

  @override
  State<VerifikasiAbsensiKelasIbuHamilScreen> createState() =>
      _VerifikasiAbsensiKelasIbuHamilScreenState();
}

class _VerifikasiAbsensiKelasIbuHamilScreenState
    extends State<VerifikasiAbsensiKelasIbuHamilScreen> {
  final _apiService = AbsensiKelasIbuHamilKaderApiService();

  List<AbsensiKelasIbuHamilModel> _list = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool? _filterVerified;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await _apiService.getAll();
      if (!mounted) return;
      setState(() => _list = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // List<AbsensiKelasIbuHamilModel> get _filtered {
  //   if (_filterVerified == null) return _list;
  //   return _list.where((item) {
  //     final isVerified =
  //         item.namaKader.isNotEmpty && item.tanggalParaf.isNotEmpty;
  //     return isVerified == _filterVerified;
  //   }).toList();
  // }

  List<AbsensiKelasIbuHamilModel> get _filtered {
  if (_filterVerified == null) return _list;
    return _list.where((item) {
      // Anggap "Terverifikasi" true, sisanya (Menunggu/Ditolak) false
      final isVerified = item.status == 'Terverifikasi';
      return isVerified == _filterVerified;
    }).toList();
  }

  int get _jumlahBelumVerif =>
      _list.where((e) => e.namaKader.isEmpty || e.tanggalParaf.isEmpty).length;
  int get _jumlahSudahVerif =>
      _list.where((e) => e.namaKader.isNotEmpty && e.tanggalParaf.isNotEmpty).length;

  Future<void> _verify(AbsensiKelasIbuHamilModel item) async {
    final namaKader = AuthSession.userName ?? 'Kader';
    final tanggalParaf = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.verify(item.id!, namaKader, tanggalParaf);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memverifikasi kehadiran'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal verifikasi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reject(AbsensiKelasIbuHamilModel item) async {
    // Konfirmasi sebelum menolak
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Tolak'),
        content: const Text('Apakah Anda yakin ingin MENOLAK absensi ini? Ibu akan diminta untuk mengirim absensi baru.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Tolak', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    // FIX: setelah await dialog konfirmasi, pastikan widget masih aktif
    // sebelum memakai context lagi (memperbaiki use_build_context_synchronously).
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.reject(item.id!);
      if (!mounted) return;
      Navigator.pop(context); // tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil ditolak'),
          backgroundColor: Colors.red,
        ),
      );
      _fetchData(); // refresh list
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Kelas Ibu Hamil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryRow(),
                      const SizedBox(height: 14),
                      _buildFilterChips(),
                      const SizedBox(height: 12),
                      if (_filtered.isEmpty)
                        _buildEmpty()
                      else
                        ..._filtered.map(_buildCard),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryPill(label: 'Semua', count: _list.length, color: Colors.blueGrey),
        const SizedBox(width: 8),
        _summaryPill(label: 'Belum Verif', count: _jumlahBelumVerif, color: Colors.orange),
        const SizedBox(width: 8),
        _summaryPill(label: 'Terverifikasi', count: _jumlahSudahVerif, color: Colors.green),
      ],
    );
  }

  Widget _summaryPill({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(label: 'Semua (${_list.length})', value: null),
          const SizedBox(width: 8),
          _filterChip(label: 'Belum Verif ($_jumlahBelumVerif)', value: false, color: Colors.orange),
          const SizedBox(width: 8),
          _filterChip(label: 'Terverifikasi ($_jumlahSudahVerif)', value: true, color: Colors.green),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required bool? value, Color? color}) {
    final isSelected = _filterVerified == value;
    final activeColor = color ?? Colors.pink.shade600;
    return GestureDetector(
      onTap: () => setState(() => _filterVerified = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Widget _buildCard(AbsensiKelasIbuHamilModel item) {
  //   final isVerified = item.namaKader.isNotEmpty && item.tanggalParaf.isNotEmpty;
  //   final Color borderColor = isVerified ? Colors.green.shade200 : Colors.orange.shade200;
  //   final Color badgeColor = isVerified ? Colors.green.shade50 : Colors.orange.shade50;
  //   final Color badgeTextColor = isVerified ? Colors.green.shade700 : Colors.orange.shade700;
  //   final String badgeLabel = isVerified ? 'Terverifikasi' : 'Belum Verifikasi';

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: borderColor),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 40,
  //               height: 40,
  //               decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
  //               alignment: Alignment.center,
  //               child: Text(
  //                 _initials(item.namaIbu),
  //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: badgeTextColor),
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     item.namaIbu.isNotEmpty ? 'Ibu ${item.namaIbu}' : 'Data tidak lengkap',
  //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     'Pertemuan ke-${item.pertemuanKe}',
  //                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: badgeColor,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 badgeLabel,
  //                 style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         const Divider(height: 1),
  //         const SizedBox(height: 10),
  //         Row(
  //           children: [
  //             const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
  //             const SizedBox(width: 6),
  //             Text(
  //               'Tanggal hadir: ${item.tanggal.isNotEmpty ? item.tanggal : "-"}',
  //               style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
  //             ),
  //           ],
  //         ),
  //         if (isVerified) ...[
  //           const SizedBox(height: 6),
  //           Row(
  //             children: [
  //               const Icon(Icons.verified_user_outlined, size: 14, color: Colors.green),
  //               const SizedBox(width: 6),
  //               Text(
  //                 'Diverifikasi oleh: ${item.namaKader}',
  //                 style: const TextStyle(fontSize: 13, color: Colors.green),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 4),
  //           Row(
  //             children: [
  //               const Icon(Icons.event_available_outlined, size: 14, color: Colors.green),
  //               const SizedBox(width: 6),
  //               Text(
  //                 'Tanggal paraf: ${item.tanggalParaf}',
  //                 style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
  //               ),
  //             ],
  //           ),
  //         ],
  //         if (!isVerified) ...[
  //           const SizedBox(height: 14),
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton.icon(
  //               onPressed: () => _verify(item),
  //               icon: const Icon(Icons.check_circle_outline, size: 18),
  //               label: const Text('Verifikasi Kehadiran'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.pink.shade600,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                 padding: const EdgeInsets.symmetric(vertical: 12),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCard(AbsensiKelasIbuHamilModel item) {
    final isVerified = item.status == 'Terverifikasi';
    final isRejected = item.status == 'Ditolak';
    
    Color borderColor = Colors.orange.shade200;
    Color badgeColor = Colors.orange.shade50;
    Color badgeTextColor = Colors.orange.shade700;
    String badgeLabel = 'Menunggu Verifikasi';

    if (isVerified) {
      borderColor = Colors.green.shade200;
      badgeColor = Colors.green.shade50;
      badgeTextColor = Colors.green.shade700;
      badgeLabel = 'Terverifikasi';
    } else if (isRejected) {
      borderColor = Colors.red.shade200;
      badgeColor = Colors.red.shade50;
      badgeTextColor = Colors.red.shade700;
      badgeLabel = 'Ditolak';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  _initials(item.namaIbu),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: badgeTextColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaIbu.isNotEmpty ? 'Ibu ${item.namaIbu}' : 'Data tidak lengkap',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pertemuan ke-${item.pertemuanKe}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Tanggal hadir: ${item.tanggal.isNotEmpty ? item.tanggal : "-"}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          if (isVerified) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Diverifikasi oleh: ${item.namaKader}',
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_available_outlined, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Tanggal paraf: ${item.tanggalParaf}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
          // Tampilkan tombol HANYA jika statusnya Menunggu Verifikasi
          if (!isVerified && !isRejected) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(item),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verify(item),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Verifikasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.group_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Belum ada data absensi\nkelas ibu hamil',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  String _initials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}