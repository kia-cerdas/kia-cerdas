import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/grafik_peningkatan_bb_api_service.dart';

/// Screen debug untuk melihat isi cache grafik BB yang tersimpan di lokal.
/// Bisa diakses dari menu developer / settings tersembunyi.
class GrafikBBCacheViewerScreen extends StatefulWidget {
  const GrafikBBCacheViewerScreen({super.key});

  @override
  State<GrafikBBCacheViewerScreen> createState() =>
      _GrafikBBCacheViewerScreenState();
}

class _GrafikBBCacheViewerScreenState
    extends State<GrafikBBCacheViewerScreen> {
  String? _rawJson;
  DateTime? _timestamp;
  bool _loading = true;
  bool _prettyMode = true;

  @override
  void initState() {
    super.initState();
    _loadCache();
  }

  Future<void> _loadCache() async {
    setState(() => _loading = true);

    final raw = await GrafikPeningkatanBBApiService.getRawCache();
    final ts = await GrafikPeningkatanBBApiService.getCacheTimestamp();

    setState(() {
      _rawJson = raw;
      _timestamp = ts;
      _loading = false;
    });
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Cache?'),
        content: const Text(
            'Data grafik BB yang tersimpan lokal akan dihapus.\nData baru akan diambil dari server saat online.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await GrafikPeningkatanBBApiService.clearCache();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text(
          '🗄️ Cache Viewer — Grafik BB',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          // Toggle pretty / raw
          IconButton(
            icon: Icon(
              _prettyMode ? Icons.code : Icons.format_align_left,
              color: Colors.white70,
            ),
            tooltip: _prettyMode ? 'Tampilkan Raw' : 'Tampilkan Pretty',
            onPressed: () => setState(() => _prettyMode = !_prettyMode),
          ),
          // Copy
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70),
            tooltip: 'Salin JSON',
            onPressed: _rawJson != null ? _copyToClipboard : null,
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh',
            onPressed: _loadCache,
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Hapus Cache',
            onPressed: _rawJson != null ? _clearCache : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // ── Status bar ───────────────────────────────────────────
                _buildStatusBar(),
                // ── JSON content ─────────────────────────────────────────
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildStatusBar() {
    final hasCache = _rawJson != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.black54,
      child: Row(
        children: [
          Icon(
            hasCache ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: hasCache ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Text(
            hasCache ? 'Cache tersedia' : 'Tidak ada cache',
            style: TextStyle(
              fontSize: 12,
              color: hasCache ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_timestamp != null) ...[
            const SizedBox(width: 12),
            Text(
              '• Diperbarui: ${_formatTs(_timestamp!)}',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
          const Spacer(),
          if (hasCache)
            Text(
              '${_rawJson!.length} chars',
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_rawJson == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Belum ada cache',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buka grafik BB saat online\nagar data tersimpan otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      );
    }

    final displayText =
        _prettyMode ? _prettyJson(_rawJson!) : _rawJson!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        displayText,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF9CDCFE), // warna khas VS Code JSON
          height: 1.6,
        ),
      ),
    );
  }

  String _formatTs(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}