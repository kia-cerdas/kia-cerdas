import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/riwayat_proses_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/repositories/riwayat_proses_melahirkan_repository.dart';

class RiwayatProsesMelahirkanScreen extends StatefulWidget {
  const RiwayatProsesMelahirkanScreen({super.key});

  @override
  State<RiwayatProsesMelahirkanScreen> createState() =>
      _RiwayatProsesMelahirkanScreenState();
}

class _RiwayatProsesMelahirkanScreenState
    extends State<RiwayatProsesMelahirkanScreen> {
  late final RiwayatProsesMelahirkanRepository _repository;
  late Future<RiwayatProsesMelahirkanModel> _future;

  static const Color _primary = AppColors.primary;
  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _accent = Color(0xFFE0A300);

  @override
  void initState() {
    super.initState();
    _repository = RiwayatProsesMelahirkanRepository();
    _future = _repository.getMine();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Riwayat Proses Melahirkan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _repository.getMine());
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<RiwayatProsesMelahirkanModel>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const _LoadingCard();
                  }
                  if (snap.hasError) {
                    return _ErrorCard(
                      message: snap.error.toString(),
                      onRetry: () =>
                          setState(() => _future = _repository.getMine()),
                    );
                  }
                  final data = snap.data ?? RiwayatProsesMelahirkanModel.empty();
                  if (!data.hasData) {
                    return const _EmptyCard();
                  }
                  return _buildContent(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_edu_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Proses Melahirkan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Catatan proses persalinan yang diisi oleh tenaga kesehatan',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FA84F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Diisi oleh Tenaga Kesehatan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildContent(RiwayatProsesMelahirkanModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Data Persalinan ───────────────────────────────────────────────
        _InfoCard(title: 'Data Persalinan', children: [
          // G/P/A
          Row(children: [
            Expanded(
                child: _SmallLine(
                    label: 'G', value: _intDisplay(data.gGravida))),
            const SizedBox(width: 10),
            Expanded(
                child: _SmallLine(
                    label: 'P', value: _intDisplay(data.pPartus))),
            const SizedBox(width: 10),
            Expanded(
                child: _SmallLine(
                    label: 'A', value: _intDisplay(data.aAbortus))),
          ]),
          const SizedBox(height: 14),
          _InfoRow(label: 'Hari', value: data.hariMelahirkan),
          _InfoRow(label: 'Tanggal', value: data.tanggalFormatted),
          _InfoRow(label: 'Pukul', value: _display(data.pukulMelahirkan)),
          const SizedBox(height: 10),
          _CheckGroup(
            title: 'Cara Melahirkan',
            allItems: const ['Spontan', 'Sungsang'],
            selectedItems: data.caraMelahirkanList,
          ),
          const SizedBox(height: 12),
          _CheckGroup(
            title: 'Dengan Tindakan',
            allItems: const ['Ekstraksi Vakum', 'Ekstraksi Forsep', 'SC'],
            selectedItems: data.tindakanList,
          ),
          const SizedBox(height: 12),
          _CheckGroup(
            title: 'Penolong Kelahiran',
            allItems: const ['Dokter Spesialis', 'Dokter', 'Bidan'],
            selectedItems: data.penolongList,
          ),
        ]),
        const SizedBox(height: 16),

        // ── Catatan Pemeriksaan ───────────────────────────────────────────
        _InfoCard(title: 'Catatan Pemeriksaan', children: [
          _TableLine(
              label: 'Taksiran Melahirkan',
              value: _display(data.taksiranMelahirkan)),
          _TableLine(
              label: 'Fasyankes',
              value: _display(data.fasyankesTempatMelahirkan)),
          _TableLine(
              label: 'Rujukan',
              value: _display(data.rujukanKeterangan)),
          _TableLine(
              label: 'Inisiasi Menyusu Dini',
              value: _display(data.inisiasiMenyusuDiniKeterangan)),
        ]),
        const SizedBox(height: 16),

        // ── Cap Kaki Bayi ─────────────────────────────────────────────────
        const _InfoCard(
            title: 'Cap Kaki Bayi',
            children: [_FootPrintPlaceholder()]),

        const SizedBox(height: 16),
        // ── Info banner ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Data riwayat proses melahirkan dicatat oleh tenaga kesehatan pasca persalinan. Jika data belum muncul, hubungi bidan atau petugas puskesmas.',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF1E3A8A), height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6DFA8), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                    color: const Color(0xFFE0A300),
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937)))),
          ]),
          const SizedBox(height: 14),
          ...children,
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 128,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w700))),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1))),
            child: Text(
              value.trim().isEmpty ? 'Belum diisi' : value,
              style: TextStyle(
                  fontSize: 12,
                  color: value.trim().isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF374151),
                  height: 1.3),
            ),
          )),
        ]),
      );
}

class _SmallLine extends StatelessWidget {
  final String label, value;
  const _SmallLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Expanded(
            child: Container(
          padding: const EdgeInsets.only(bottom: 3),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFD1D5DB)))),
          child: Text(value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 12)),
        )),
      ]);
}

class _TableLine extends StatelessWidget {
  final String label, value;
  const _TableLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800))),
          Expanded(
              child: Text(value.trim().isEmpty ? 'Belum diisi' : value,
                  style: TextStyle(
                      fontSize: 12,
                      color: value.trim().isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF374151)))),
        ]),
      );
}

class _CheckGroup extends StatelessWidget {
  final String title;
  final List<String> allItems;
  final List<String> selectedItems;
  const _CheckGroup(
      {required this.title,
      required this.allItems,
      required this.selectedItems});

  bool _isSelected(String item) =>
      selectedItems.any((v) => v.toLowerCase().trim() == item.toLowerCase().trim());

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Wrap(
            spacing: 10,
            runSpacing: 8,
            children: allItems.map((item) {
              final checked = _isSelected(item);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: checked
                      ? const Color(0xFFFFF8D6)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: checked
                          ? const Color(0xFFE0A300)
                          : const Color(0xFFE5E7EB)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    checked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 15,
                    color: checked
                        ? const Color(0xFFE0A300)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 7),
                  Text(item,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList()),
      ]);
}

class _FootPrintPlaceholder extends StatelessWidget {
  const _FootPrintPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        height: 130,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            const Text('Area cap kaki bayi',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const _InfoCard(
        title: 'Memuat Data...',
        children: [
          Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator()))
        ],
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) => _InfoCard(
        title: 'Data Belum Tersedia',
        children: [
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline,
                color: Color(0xFF9CA3AF), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Riwayat proses melahirkan belum diinput oleh tenaga kesehatan. Data akan muncul setelah dicatat oleh bidan atau petugas puskesmas.',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.45),
              ),
            ),
          ]),
        ],
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => _InfoCard(
        title: 'Data belum dapat ditampilkan',
        children: [
          Text(message.replaceFirst('Exception: ', ''),
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi')),
        ],
      );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _display(String value) =>
    value.trim().isEmpty ? 'Belum diisi' : value;

String _intDisplay(int value) => value == 0 ? '-' : value.toString();