import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/keluhan_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/services/keluhan_anak_api_service.dart';

class KeluhanAnakScreen extends StatefulWidget {
  final int anakId;
  final String anakName;

  const KeluhanAnakScreen({super.key, required this.anakId, required this.anakName});

  @override
  State<KeluhanAnakScreen> createState() => _KeluhanAnakScreenState();
}

class _KeluhanAnakScreenState extends State<KeluhanAnakScreen> {
  final _service = KeluhanAnakApiService();
  bool _loading = true;
  List<KeluhanAnakModel> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getByAnakId(widget.anakId);
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return names[(m-1).clamp(0,11)];
  }

  void _showDetail(KeluhanAnakModel item) {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text('Detail Keluhan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal: ${_fmtDate(item.tanggal)}'),
              const SizedBox(height: 8),
              Text('Tanggal Kembali: ${_fmtDate(item.tanggalKembali)}'),
              const SizedBox(height: 8),
              Text('Keluhan:'),
              Text(item.keluhan),
              const SizedBox(height: 8),
              if (item.tindakan != null) ...[
                Text('Tindakan:'),
                Text(item.tindakan!),
                const SizedBox(height: 8),
              ],
              if (item.pemeriksa != null) Text('Pemeriksa: ${item.pemeriksa}')
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      );
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catatan Kesehatan Anak'),
            Text(widget.anakName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _items.isEmpty
                  ? Center(child: Text('Belum ada catatan kesehatan untuk anak ini'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final it = _items[idx];
                        return Card(
                          child: ListTile(
                            title: Text(_fmtDate(it.tanggal)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(it.keluhan, maxLines: 3, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text('Pemeriksa: ${it.pemeriksa ?? '-'}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () => _showDetail(it),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
