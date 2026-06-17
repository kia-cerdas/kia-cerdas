import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'pemantauan_ibu_hamil_kader_api_service.dart';
import 'pemantauan_ibu_hamil_kader_model.dart';

class VerifikasiPemantauanIbuHamilScreen extends StatefulWidget {
  const VerifikasiPemantauanIbuHamilScreen({super.key});

  @override
  State<VerifikasiPemantauanIbuHamilScreen> createState() =>
      _VerifikasiPemantauanIbuHamilScreenState();
}

class _VerifikasiPemantauanIbuHamilScreenState
    extends State<VerifikasiPemantauanIbuHamilScreen> {
  final _apiService = PemantauanIbuHamilKaderApiService();

  List<PemantauanIbuHamilKaderModel> _list = [];
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

  List<PemantauanIbuHamilKaderModel> get _filtered {
    if (_filterVerified == null) return _list;
    return _list.where((item) => item.sudahDitinjau == _filterVerified).toList();
  }

  int get _jumlahBelumTinjau => _list.where((e) => !e.sudahDitinjau).length;
  int get _jumlahSudahTinjau => _list.where((e) => e.sudahDitinjau).length;

  Future<void> _verify(PemantauanIbuHamilKaderModel item) async {
    final namaKader = AuthSession.userName ?? 'Kader';
    final tanggalVerifikasi = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _apiService.verify(item.id!, namaKader, tanggalVerifikasi);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil meninjau data pemantauan'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemantauan Ibu Hamil'),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
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
        _summaryPill(
            label: 'Semua', count: _list.length, color: Colors.blueGrey),
        const SizedBox(width: 8),
        _summaryPill(
            label: 'Belum Ditinjau',
            count: _jumlahBelumTinjau,
            color: Colors.orange),
        const SizedBox(width: 8),
        _summaryPill(
            label: 'Sudah Ditinjau',
            count: _jumlahSudahTinjau,
            color: Colors.green),
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
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: color),
                textAlign: TextAlign.center),
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
          _filterChip(
              label: 'Belum Ditinjau ($_jumlahBelumTinjau)',
              value: false,
              color: Colors.orange),
          const SizedBox(width: 8),
          _filterChip(
              label: 'Sudah Ditinjau ($_jumlahSudahTinjau)',
              value: true,
              color: Colors.green),
        ],
      ),
    );
  }

  Widget _filterChip(
      {required String label, required bool? value, Color? color}) {
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

  Widget _buildCard(PemantauanIbuHamilKaderModel item) {
    final isVerified = item.sudahDitinjau;
    final Color borderColor =
        isVerified ? Colors.green.shade200 : Colors.orange.shade200;
    final Color badgeColor =
        isVerified ? Colors.green.shade50 : Colors.orange.shade50;
    final Color badgeTextColor =
        isVerified ? Colors.green.shade700 : Colors.orange.shade700;
    final String badgeLabel =
        isVerified ? 'Sudah Ditinjau' : 'Belum Ditinjau';

    // Warna indikator keluhan
    final bool adaKeluhan = item.jumlahKeluhan > 0;
    final Color keluhanColor = adaKeluhan ? Colors.red.shade400 : Colors.grey.shade400;

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
          // Header: avatar + nama + badge status
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: badgeColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  _initials(item.namaIbu),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaIbu.isNotEmpty
                          ? 'Ibu ${item.namaIbu}'
                          : 'Data tidak lengkap',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Minggu ke-${item.mingguKehamilan}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Ringkasan keluhan
          Row(
            children: [
              Icon(
                adaKeluhan
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 15,
                color: keluhanColor,
              ),
              const SizedBox(width: 6),
              Text(
                adaKeluhan
                    ? '${item.jumlahKeluhan} keluhan tercatat'
                    : 'Tidak ada keluhan',
                style: TextStyle(
                    fontSize: 13,
                    color: keluhanColor,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Detail keluhan (hanya tampilkan yang aktif)
          if (adaKeluhan) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (item.demamLebih2Hari) _keluhanChip('Demam > 2 hari'),
                if (item.sakitKepala) _keluhanChip('Sakit kepala'),
                if (item.cemasBerlebih) _keluhanChip('Cemas berlebih'),
                if (item.resikoTB) _keluhanChip('Risiko TB'),
                if (item.gerakanBayiKurang)
                  _keluhanChip('Gerakan bayi kurang'),
                if (item.nyeriPerut) _keluhanChip('Nyeri perut'),
                if (item.cairanJalanLahir)
                  _keluhanChip('Cairan jalan lahir'),
                if (item.masalahKemaluan) _keluhanChip('Masalah kemaluan'),
                if (item.diareBerulang) _keluhanChip('Diare berulang'),
              ],
            ),
          ],

          // Info verifikasi (jika sudah ditinjau)
          if (isVerified) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Ditinjau oleh: ${item.namaKader}',
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_available_outlined,
                    size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Tanggal tinjauan: ${item.tanggalVerifikasi}',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],

          // Tombol verifikasi (jika belum ditinjau)
          if (!isVerified) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _verify(item),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Tandai Sudah Ditinjau'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _keluhanChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.pregnant_woman_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Belum ada data pemantauan\nibu hamil',
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
            ElevatedButton(
                onPressed: _fetchData, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  String _initials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }
}
