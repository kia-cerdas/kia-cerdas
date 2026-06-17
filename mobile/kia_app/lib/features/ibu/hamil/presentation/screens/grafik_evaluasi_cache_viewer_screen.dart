import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/grafik_evaluasi_kehamilan_api_service.dart';

/// Screen debug untuk melihat isi cache grafik DJJ & TFU.
class GrafikEvaluasiCacheViewerScreen extends StatefulWidget {
  const GrafikEvaluasiCacheViewerScreen({super.key});

  @override
  State<GrafikEvaluasiCacheViewerScreen> createState() =>
      _GrafikEvaluasiCacheViewerScreenState();
}

class _GrafikEvaluasiCacheViewerScreenState
    extends State<GrafikEvaluasiCacheViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _rawJson;
  DateTime? _timestamp;
  bool _loading = true;
  bool _prettyMode = true;

  // Data parsed untuk tab TFU & DJJ
  List<dynamic> _tfuList = [];
  List<dynamic> _djjList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCache();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    setState(() => _loading = true);

    final raw = await GrafikEvaluasiKehamilanApiService.getRawCache();
    final ts = await GrafikEvaluasiKehamilanApiService.getCacheTimestamp();

    List<dynamic> tfu = [];
    List<dynamic> djj = [];

    if (raw != null) {
      try {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        tfu = parsed['grafik_tfu'] as List? ?? [];
        djj = parsed['grafik_djj'] as List? ?? [];
      } catch (_) {}
    }

    setState(() {
      _rawJson = raw;
      _timestamp = ts;
      _tfuList = tfu;
      _djjList = djj;
      _loading = false;
    });
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Cache?'),
        content: const Text(
            'Data grafik DJJ & TFU yang tersimpan lokal akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await GrafikEvaluasiKehamilanApiService.clearCache();
      await _loadCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache berhasil dihapus')),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_rawJson == null) return;
    Clipboard.setData(ClipboardData(text: _rawJson!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON disalin ke clipboard')),
    );
  }

  String _prettyJson(String raw) {
    try {
      final obj = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(obj);
    } catch (_) {
      return raw;
    }
  }

  String _formatTs(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/'
        '${l.month.toString().padLeft(2, '0')}/'
        '${l.year}  '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text(
          '🗄️ Cache Viewer — DJJ & TFU',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _prettyMode ? Icons.code : Icons.format_align_left,
              color: Colors.white70,
            ),
            tooltip: _prettyMode ? 'Raw' : 'Pretty',
            onPressed: () => setState(() => _prettyMode = !_prettyMode),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70),
            tooltip: 'Salin JSON',
            onPressed: _rawJson != null ? _copyToClipboard : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh',
            onPressed: _loadCache,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Hapus Cache',
            onPressed: _rawJson != null ? _clearCache : null,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'TFU (${_tfuList.length})'),
            Tab(text: 'DJJ (${_djjList.length})'),
            const Tab(text: 'Raw JSON'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildStatusBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTFUTab(),
                      _buildDJJTab(),
                      _buildRawJsonTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Status bar ────────────────────────────────────────────────────────────
  Widget _buildStatusBar() {
    final hasCache = _rawJson != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black54,
      child: Row(
        children: [
          Icon(
            hasCache ? Icons.check_circle : Icons.cancel,
            size: 13,
            color: hasCache ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 6),
          Text(
            hasCache ? 'Cache tersedia' : 'Tidak ada cache',
            style: TextStyle(
              fontSize: 11,
              color: hasCache ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_timestamp != null) ...[
            const SizedBox(width: 10),
            Text(
              '• ${_formatTs(_timestamp!)}',
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
          const Spacer(),
          if (hasCache)
            Text(
              '${_rawJson!.length} chars',
              style: const TextStyle(fontSize: 10, color: Colors.white24),
            ),
        ],
      ),
    );
  }

  // ── Tab TFU ───────────────────────────────────────────────────────────────
  Widget _buildTFUTab() {
    if (_tfuList.isEmpty) return _buildEmptyTab('TFU');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tfuList.length,
      itemBuilder: (_, i) {
        final p = _tfuList[i] as Map<String, dynamic>;
        final status = p['status_tfu']?.toString() ?? '-';
        final statusColor = status == 'normal'
            ? Colors.greenAccent
            : status == 'tinggi'
                ? Colors.redAccent
                : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Usia ${p['usia']} minggu',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _dataRow('TFU', '${p['tfu'] ?? '-'} cm'),
              _dataRow('Normal', '${p['lower']}–${p['upper']} cm'),
              _dataRow('Tanggal', p['tanggal_periksa']?.toString() ?? '-'),
              _dataRow('Tekanan Darah', p['tekanan_darah']?.toString() ?? '-'),
              _dataRow('Hemoglobin', '${p['hemoglobin'] ?? '-'} g/dL'),
              _dataRow('Urin Protein', p['urin_protein']?.toString() ?? '-'),
              _dataRow('Gerakan Bayi', p['gerakan_bayi']?.toString() ?? '-'),
              _dataRow('Tablet TTD', '${p['tablet_tambah_darah'] ?? '-'}'),
            ],
          ),
        );
      },
    );
  }

  // ── Tab DJJ ───────────────────────────────────────────────────────────────
  Widget _buildDJJTab() {
    if (_djjList.isEmpty) return _buildEmptyTab('DJJ');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _djjList.length,
      itemBuilder: (_, i) {
        final p = _djjList[i] as Map<String, dynamic>;
        final status = p['status_djj']?.toString() ?? '-';
        final statusColor = status == 'normal'
            ? Colors.greenAccent
            : Colors.redAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Usia ${p['usia']} minggu',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _dataRow('DJJ', '${p['djj']} bpm'),
              _dataRow('Normal', '${p['lower']}–${p['upper']} bpm'),
              _dataRow('Tanggal', p['tanggal_periksa']?.toString() ?? '-'),
            ],
          ),
        );
      },
    );
  }

  // ── Tab Raw JSON ──────────────────────────────────────────────────────────
  Widget _buildRawJsonTab() {
    if (_rawJson == null) return _buildEmptyTab('JSON');

    final display = _prettyMode ? _prettyJson(_rawJson!) : _rawJson!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        display,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: Color(0xFF9CDCFE),
          height: 1.6,
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildEmptyTab(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            'Tidak ada data $label',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Buka grafik saat online agar data tersimpan.',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.white38)),
          ),
          Text(': ',
              style: const TextStyle(fontSize: 11, color: Colors.white24)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}