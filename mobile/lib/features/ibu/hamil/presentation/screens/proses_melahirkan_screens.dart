import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/proses_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/repositories/proses_melahirkan_repository.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/repositories/keterangan_lahir_repository.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

// ─── Screen 1: Ringkasan Pelayanan ───────────────────────────────────────────

class RingkasanPelayananProsesMelahirkanScreen extends StatelessWidget {
  const RingkasanPelayananProsesMelahirkanScreen({super.key});

  @override
  Widget build(BuildContext context) => _DataScreen(
        title: 'Ringkasan Pelayanan',
        subtitle: 'Ringkasan ibu bersalin, nifas, dan kondisi bayi saat lahir',
        icon: Icons.summarize_outlined,
        builder: (data) {
          final r = data.ringkasan;
          return Column(children: [
            _InfoCard(title: 'Ibu Bersalin dan Ibu Nifas', children: [
              _InfoRow(label: 'Tanggal Melahirkan', value: r.tanggalMelahirkan),
              _InfoRow(label: 'Pukul', value: r.pukul),
              _InfoRow(label: 'Umur Kehamilan', value: _withSuffix(r.umurKehamilan, 'minggu')),
              _InfoRow(label: 'Penolong Proses Melahirkan', value: r.penolongProsesMelahirkan),
              _InfoRow(label: 'Cara Melahirkan', value: r.caraMelahirkan),
              _InfoRow(label: 'Keadaan Ibu', value: r.keadaanIbu),
              _InfoRow(label: 'KB Pasca Melahirkan', value: r.kbPascaMelahirkan),
              _InfoRow(label: 'Keterangan Tambahan', value: r.keteranganTambahan),
            ]),
            const SizedBox(height: 16),
            _InfoCard(title: 'Bayi Saat Lahir', children: [
              _InfoRow(label: 'Anak ke', value: r.anakKe),
              _InfoRow(label: 'Berat Lahir', value: _withSuffix(r.beratLahir, 'gram')),
              _InfoRow(label: 'Panjang Badan', value: _withSuffix(r.panjangBadan, 'cm')),
              _InfoRow(label: 'Lingkar Kepala', value: _withSuffix(r.lingkarKepala, 'cm')),
              _InfoRow(label: 'Jenis Kelamin', value: r.jenisKelamin),
              const SizedBox(height: 10),
              _CheckGroup(
                title: 'Kondisi Bayi Saat Lahir',
                items: const [
                  'Segera menangis', 'Menangis beberapa saat', 'Tidak menangis',
                  'Seluruh tubuh kemerahan', 'Anggota gerak kebiruan', 'Seluruh tubuh biru', 'Kelainan bawaan',
                ],
                selectedItems: r.kondisiBayiSaatLahir,
              ),
              const SizedBox(height: 14),
              _CheckGroup(
                title: 'Asuhan Bayi Baru Lahir',
                items: const [
                  'Inisiasi menyusu dini (IMD) dalam 1 jam pertama',
                  'Suntikan Vitamin K1',
                  'Salep mata antibiotika profilaksis',
                  'Imunisasi HB0',
                ],
                selectedItems: r.asuhanBayiBaruLahir,
              ),
            ]),
          ]);
        },
      );
}

// ─── Screen 2: Riwayat Proses Melahirkan ─────────────────────────────────────

class _RiwayatProsesMelahirkanScreen extends StatelessWidget {
  const _RiwayatProsesMelahirkanScreen({super.key});

  @override
  Widget build(BuildContext context) => _DataScreen(
        title: 'Riwayat Proses Melahirkan',
        subtitle: 'Catatan proses persalinan dan pemeriksaan tenaga kesehatan',
        icon: Icons.history_edu_outlined,
        builder: (data) {
          final r = data.riwayat;
          return Column(children: [
            _InfoCard(title: 'Data Persalinan', children: [
              Row(children: [
                Expanded(child: _SmallLine(label: 'G', value: r.gravida)),
                const SizedBox(width: 10),
                Expanded(child: _SmallLine(label: 'P', value: r.para)),
                const SizedBox(width: 10),
                Expanded(child: _SmallLine(label: 'A', value: r.abortus)),
              ]),
              const SizedBox(height: 12),
              _InfoRow(label: 'Pada Hari', value: r.hari),
              _InfoRow(label: 'Tanggal', value: r.tanggal),
              _InfoRow(label: 'Pukul', value: r.pukul),
              const SizedBox(height: 8),
              _CheckGroup(
                title: 'Cara Melahirkan',
                items: const ['Spontan', 'Sungsang'],
                selectedItems: r.caraMelahirkan,
              ),
              const SizedBox(height: 12),
              _CheckGroup(
                title: 'Dengan Tindakan',
                items: const ['Ekstraksi Vakum', 'Ekstraksi Forsep', 'SC'],
                selectedItems: r.tindakan,
              ),
              const SizedBox(height: 12),
              _CheckGroup(
                title: 'Penolong Kelahiran',
                items: const ['Dokter Spesialis', 'Dokter', 'Bidan'],
                selectedItems: r.penolongKelahiran,
              ),
            ]),
            const SizedBox(height: 16),
            _InfoCard(title: 'Catatan Pemeriksaan', children: [
              _TableLine(label: 'Taksiran Melahirkan', value: r.taksiranMelahirkan),
              _TableLine(label: 'Fasyankes', value: r.fasyankes),
              _TableLine(label: 'Rujukan', value: r.rujukan),
              _TableLine(label: 'Inisiasi Menyusu Dini', value: r.inisiasiMenyusuDini),
            ]),
            const SizedBox(height: 16),
            const _InfoCard(title: 'Cap Kaki Bayi', children: [_FootPrintPlaceholder()]),
          ]);
        },
      );
}

// ─── Screen 3: Keterangan Lahir ──────────────────────────────────────────────

class KeteranganLahirScreen extends StatefulWidget {
  const KeteranganLahirScreen({super.key});

  @override
  State<KeteranganLahirScreen> createState() => _KeteranganLahirScreenState();
}

class _KeteranganLahirScreenState extends State<KeteranganLahirScreen> {
  late final KeteranganLahirRepository _repository;
  late Future<KeteranganLahirModel> _future;

  @override
  void initState() {
    super.initState();
    _repository = KeteranganLahirRepository();
    _future = _repository.getMe();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BaseBirthScreen(
        title: 'Keterangan Lahir',
        subtitle: 'Informasi keterangan kelahiran bayi dan data orang tua',
        icon: Icons.child_friendly_outlined,
        child: FutureBuilder<KeteranganLahirModel>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }
            if (snap.hasError) {
              return _ErrorCard(
                message: snap.error.toString(),
                onRetry: () => setState(() => _future = _repository.getMe()),
              );
            }
            final k = snap.data ?? KeteranganLahirModel.empty();
            return Column(children: [
              // ── Identitas Surat ─────────────────────────────────────────
              _InfoCard(title: 'Identitas Surat', children: [
                _InfoRow(label: 'Nomor Surat', value: k.nomorSurat),
                _InfoRow(label: 'Tanggal Surat', value: k.tanggalSurat),
              ]),
              const SizedBox(height: 16),

              // ── Data Kelahiran Bayi ──────────────────────────────────────
              _InfoCard(title: 'Data Kelahiran Bayi', children: [
                _InfoRow(label: 'Hari Lahir', value: k.hariLahir),
                _InfoRow(label: 'Tanggal Lahir', value: k.tanggalLahir),
                _InfoRow(label: 'Pukul', value: k.pukulLahir),
                _InfoRow(label: 'Jenis Kelamin', value: k.jenisKelamin),
                _InfoRow(label: 'Jenis Kelahiran', value: k.jenisKelahiran),
                _InfoRow(label: 'Anak ke', value: k.anakKe),
                _InfoRow(label: 'Usia Gestasi', value: _withSuffix(k.usiaGestasiMinggu, 'minggu')),
                _InfoRow(label: 'Berat Lahir', value: _withSuffix(k.beratLahirGram, 'gram')),
                _InfoRow(label: 'Panjang Badan', value: _withSuffix(k.panjangBadanCm, 'cm')),
                _InfoRow(label: 'Lingkar Kepala', value: _withSuffix(k.lingkarKepalaCm, 'cm')),
                _InfoRow(label: 'Nama Bayi', value: k.namaBayiDiberiNama),
              ]),
              const SizedBox(height: 16),

              // ── Lokasi Persalinan ────────────────────────────────────────
              _InfoCard(title: 'Lokasi Persalinan', children: [
                _InfoRow(label: 'Tempat Lahir', value: k.lokasiPersalinan),
                _InfoRow(label: 'Alamat', value: k.alamatLokasiPersalinan),
              ]),
              const SizedBox(height: 16),

              // ── Data Orang Tua ───────────────────────────────────────────
              _InfoCard(title: 'Dari Orang Tua', children: [
                _InfoRow(label: 'Nama Ibu', value: k.namaIbu),
                _InfoRow(label: 'Umur Ibu', value: _withSuffix(k.umurIbu, 'tahun')),
                _InfoRow(label: 'NIK Ibu', value: k.nikIbu),
                _InfoRow(label: 'Nama Ayah', value: k.namaAyah),
                _InfoRow(label: 'NIK Ayah', value: k.nikAyah),
                _InfoRow(label: 'Pekerjaan', value: k.pekerjaanOrangTua),
                _InfoRow(label: 'Alamat', value: k.alamatOrangTua),
                _InfoRow(label: 'RW/RT', value: k.rwRtOrangTua),
                _InfoRow(label: 'Kecamatan', value: k.kecamatanOrangTua),
                _InfoRow(label: 'Kab./Kota', value: k.kabKotaOrangTua),
              ]),
              const SizedBox(height: 16),

              // ── Tanda Tangan ─────────────────────────────────────────────
              _InfoCard(title: 'Data Saksi & Penolong', children: [
                Row(children: [
                  Expanded(child: _SignatureBox(label: 'Saksi I', value: k.namaSaksi1)),
                  const SizedBox(width: 10),
                  Expanded(child: _SignatureBox(label: 'Saksi II', value: k.namaSaksi2)),
                  const SizedBox(width: 10),
                  Expanded(child: _SignatureBox(label: 'Penolong Kelahiran', value: k.namaPenolongKelahiran)),
                ]),
              ]),
            ]);
          },
        ),
      );
}

// ─── Shared: _DataScreen (StatefulWidget base) ───────────────────────────────

class _DataScreen extends StatefulWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget Function(ProsesMelahirkanModel data) builder;

  const _DataScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  @override
  State<_DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<_DataScreen> {
  late final ProsesMelahirkanRepository _repository;
  late Future<ProsesMelahirkanModel> _future;

  @override
  void initState() {
    super.initState();
    _repository = ProsesMelahirkanRepository();
    _future = _repository.getMine();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BaseBirthScreen(
        title: widget.title,
        subtitle: widget.subtitle,
        icon: widget.icon,
        child: FutureBuilder<ProsesMelahirkanModel>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }
            if (snap.hasError) {
              return _ErrorCard(
                message: snap.error.toString(),
                onRetry: () => setState(() => _future = _repository.getMine()),
              );
            }
            return widget.builder(snap.data ?? ProsesMelahirkanModel.empty());
          },
        ),
      );
}

// ─── Shared: Base Layout Screen ──────────────────────────────────────────────

class _BaseBirthScreen extends StatelessWidget {
  static const Color _green = Color(0xFF2FA84F);

  final String title, subtitle;
  final IconData icon;
  final Widget child;

  const _BaseBirthScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: TrimesterTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'Catatan Persalinan',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.shade200, height: 1.0),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(padding: EdgeInsets.zero, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Color(0xFF1E3A5F), fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF4A6FA5), fontSize: 11.5, height: 1.35)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Diisi oleh Tenaga Kesehatan',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ])),
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), child: child),
          ]),
        ),
      );
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 4, height: 22, decoration: BoxDecoration(color: const Color(0xFFE0A300), borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)))),
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
          SizedBox(width: 128, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w700))),
          Expanded(child: Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1))),
            child: Text(_display(value), style: TextStyle(fontSize: 12, color: value.trim().isEmpty ? const Color(0xFF9CA3AF) : const Color(0xFF374151), height: 1.3)),
          )),
        ]),
      );
}

class _CheckGroup extends StatelessWidget {
  final String title;
  final List<String> items, selectedItems;
  const _CheckGroup({required this.title, required this.items, required this.selectedItems});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 8, children: items.map((item) => _CheckChip(label: item, checked: _isSelected(item, selectedItems))).toList()),
      ]);
}

class _CheckChip extends StatelessWidget {
  final String label;
  final bool checked;
  const _CheckChip({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFFFF8D6) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: checked ? const Color(0xFFE0A300) : const Color(0xFFE5E7EB)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, size: 15, color: checked ? const Color(0xFFE0A300) : const Color(0xFF9CA3AF)),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
        ]),
      );
}

class _SmallLine extends StatelessWidget {
  final String label, value;
  const _SmallLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Expanded(child: Container(
          padding: const EdgeInsets.only(bottom: 3),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD1D5DB)))),
          child: Text(_display(value), style: const TextStyle(fontSize: 12)),
        )),
      ]);
}

class _TableLine extends StatelessWidget {
  final String label, value;
  const _TableLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          SizedBox(width: 135, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          Expanded(child: Text(_display(value), style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        ]),
      );
}

class _SignatureBox extends StatelessWidget {
  final String label, value;
  const _SignatureBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        height: 96,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          Text(_display(value), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
          Container(height: 1, color: const Color(0xFFD1D5DB)),
        ]),
      );
}

class _FootPrintPlaceholder extends StatelessWidget {
  const _FootPrintPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        height: 130, width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text('Area cap kaki bayi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const _InfoCard(
        title: 'Memuat Data',
        children: [Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))],
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
          Text(message.replaceFirst('Exception: ', ''), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
        ],
      );
}

// ─── Helper functions (file-private) ─────────────────────────────────────────

String _display(String value) => value.trim().isEmpty ? 'Belum diisi' : value;

String _withSuffix(String value, String suffix) {
  if (value.trim().isEmpty) return '';
  return value.toLowerCase().contains(suffix.toLowerCase()) ? value : '$value $suffix';
}

bool _isSelected(String item, List<String> selected) =>
    selected.any((v) => v.toLowerCase().trim() == item.toLowerCase().trim());