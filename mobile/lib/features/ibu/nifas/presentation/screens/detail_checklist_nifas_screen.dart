import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/services/unauthorized_handler.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

/// Screen read-only untuk melihat isi checklist nifas pada hari tertentu.
/// Dipanggil dari NifasScreen saat user tap card hari yang sudah terisi.
///
/// Cara pakai:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => DetailChecklistNifasScreen(hariNifas: item.hariNifas),
///   ));
class DetailChecklistNifasScreen extends StatefulWidget {
  final int hariNifas;
  final bool terverifikasi;
  final String namaKader;
  final String? tanggalVerifikasi;

  const DetailChecklistNifasScreen({
    super.key,
    required this.hariNifas,
    this.terverifikasi = false,
    this.namaKader = '',
    this.tanggalVerifikasi,
  });

  @override
  State<DetailChecklistNifasScreen> createState() =>
      _DetailChecklistNifasScreenState();
}

class _DetailChecklistNifasScreenState
    extends State<DetailChecklistNifasScreen> {
  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMsg = 'Sesi tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      // GET /modul-ibu/checklist-pemantauan-ibu-nifas/me?hari_nifas=X
      // Backend wajib menerima query param hari_nifas dan return single object
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.checklistNifasMe}',
      ).replace(queryParameters: {'hari_nifas': widget.hariNifas.toString()});

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        await UnauthorizedHandler.handle();
        return;
      }

      if (response.statusCode == 404) {
        setState(() {
          _errorMsg = 'Data hari ke-${widget.hariNifas} tidak ditemukan.';
          _isLoading = false;
        });
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _errorMsg = 'Gagal memuat data (${response.statusCode})';
          _isLoading = false;
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawData = body['data'];

      setState(() {
        _data = rawData is Map<String, dynamic> ? rawData : null;
        _isLoading = false;
        if (_data == null) {
          _errorMsg = 'Data hari ke-${widget.hariNifas} tidak ditemukan.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Detail Hari ke-${widget.hariNifas}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBanner(),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'NIFAS A',
                          icon: Icons.favorite_outline,
                          items: _nifasAItems(),
                        ),
                        const SizedBox(height: 14),
                        _buildSection(
                          title: 'NIFAS B',
                          icon: Icons.monitor_heart_outlined,
                          items: _nifasBItems(),
                        ),
                        const SizedBox(height: 14),
                        _buildKeluhanCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ─── Status banner ────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    final isVerified = widget.terverifikasi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVerified
              ? [Colors.green.shade600, Colors.green.shade400]
              : [Colors.orange.shade600, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.green : Colors.orange).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isVerified
                  ? Icons.verified_rounded
                  : Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ke-${widget.hariNifas}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified
                      ? 'Diverifikasi oleh ${widget.namaKader.isNotEmpty ? widget.namaKader : "Kader"}'
                          '${widget.tanggalVerifikasi != null ? "\n${_formatTanggal(widget.tanggalVerifikasi!)}" : ""}'
                      : 'Menunggu verifikasi kader',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Text(
              isVerified ? 'Terverifikasi' : 'Menunggu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section checklist ────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<_CheckItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        children: items.map((item) => _buildReadOnlyItem(item)).toList(),
      ),
    );
  }

  Widget _buildReadOnlyItem(_CheckItem item) {
    final checked = item.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: checked ? AppColors.primary : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: checked
                ? Icon(Icons.check, color: AppColors.primary, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: checked ? AppColors.primary : Colors.black54,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: checked
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              checked ? 'Ya' : 'Tidak',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: checked
                    ? Colors.green.shade700
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Keluhan card ─────────────────────────────────────────────────

  Widget _buildKeluhanCard() {
    final keluhan =
        (_data?['keluhan'] as String?)?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Keluhan Tambahan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Text(
              keluhan.isNotEmpty ? keluhan : 'Tidak ada keluhan',
              style: TextStyle(
                fontSize: 13,
                color: keluhan.isNotEmpty
                    ? Colors.black87
                    : Colors.black38,
                fontStyle: keluhan.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: Colors.red.shade300, size: 52),
            const SizedBox(height: 14),
            Text(
              _errorMsg ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  bool _bool(String key) =>
      (_data?[key] as bool?) ?? false;

  List<_CheckItem> _nifasAItems() => [
        _CheckItem('Pemeriksaan nifas', _bool('pemeriksaan_nifas')),
        _CheckItem('Konsumsi vitamin A', _bool('konsumsi_vitamin_a')),
        _CheckItem('Pemenuhan gizi', _bool('pemenuhan_gizi')),
        _CheckItem('Demam > 38°C', _bool('demam_lebih_38')),
        _CheckItem('Sakit kepala', _bool('sakit_kepala')),
        _CheckItem('Pandangan kabur', _bool('pandangan_kabur')),
        _CheckItem('Nyeri ulu hati', _bool('nyeri_ulu_hati')),
        _CheckItem(
            'Masalah kesehatan jiwa', _bool('masalah_kesehatan_jiwa')),
      ];

  List<_CheckItem> _nifasBItems() => [
        _CheckItem('Jantung berdebar', _bool('jantung_berdebar')),
        _CheckItem('Cairan jalan lahir', _bool('cairan_jalan_lahir')),
        _CheckItem('Napas pendek', _bool('napas_pendek')),
        _CheckItem('Payudara bermasalah', _bool('payudara_bermasalah')),
        _CheckItem('Gangguan BAK', _bool('gangguan_bak')),
        _CheckItem('Kelamin bermasalah', _bool('kelamin_bermasalah')),
        _CheckItem('Darah nifas berbau', _bool('darah_nifas_berbau')),
        _CheckItem('Pendarahan berat', _bool('pendarahan_berat')),
        _CheckItem('Keputihan', _bool('keputihan')),
      ];

  String _formatTanggal(String iso) {
    try {
      return DateFormat('d MMMM yyyy', 'id').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

class _CheckItem {
  final String label;
  final bool value;
  const _CheckItem(this.label, this.value);
}