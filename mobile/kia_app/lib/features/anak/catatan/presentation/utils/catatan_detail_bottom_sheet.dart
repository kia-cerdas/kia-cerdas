import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/keluhan_anak_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pemeriksaan_gigi_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/pengukuran_lila_model.dart';

const _kBlue = Color(0xFF1565C0);

String _fmtDate(DateTime d) => DateFormat('dd MMMM yyyy', 'id_ID').format(d);

void showCatatanDetailKesehatanAnak(BuildContext ctx, KeluhanAnakModel item) {
  _showSheet(ctx, icon: Icons.assignment_outlined, title: item.keluhan, children: [
    _InfoRow(icon: Icons.calendar_today, label: 'Tanggal', value: _fmtDate(item.tanggal)),
    _InfoRow(icon: Icons.person_outline, label: 'Pemeriksa', value: item.pemeriksa ?? '-'),
    const SizedBox(height: 8),
    _SectionLabel('KELUHAN'),
    _TextBox(item.keluhan),
    const SizedBox(height: 8),
    _SectionLabel('TINDAKAN'),
    _TextBox(item.tindakan ?? '-'),
    if (item.tanggalKembali != null) ...[
      const SizedBox(height: 8),
      _SectionLabel('TANGGAL KEMBALI'),
      _InfoRow(icon: Icons.calendar_today, label: 'Tanggal', value: _fmtDate(item.tanggalKembali!)),
    ],
  ]);
}

void showCatatanDetailGigi(BuildContext ctx, PemeriksaanGigiModel item) {
  _showSheet(ctx, icon: Icons.medical_services_outlined, title: 'Pemeriksaan Gigi - Bulan ke-${item.bulan}', children: [
    _InfoRow(icon: Icons.calendar_today, label: 'Tanggal', value: _fmtDate(item.tanggal)),
    _InfoRow(icon: Icons.child_care, label: 'Bulan ke-', value: '${item.bulan}'),
    const SizedBox(height: 12),
    _SectionLabel('JUMLAH GIGI'),
    _SpinnerField('${item.jumlahGigi} gigi'),
    const SizedBox(height: 8),
    _SectionLabel('GIGI BERLUBANG'),
    _SpinnerField('${item.gigiBerlubang} gigi'),
    const SizedBox(height: 8),
    _SectionLabel('STATUS PLAK'),
    _StatusBadge(item.statusPlak, _getPlakColor(item.statusPlak)),
    const SizedBox(height: 8),
    _SectionLabel('RISIKO GIGI BERLUBANG'),
    _StatusBadge(item.resikoGigiBerlubang, _getRisikoColor(item.resikoGigiBerlubang)),
  ]);
}

void showCatatanDetailLila(BuildContext ctx, PengukuranLilaModel item) {
  _showSheet(ctx, icon: Icons.straighten, title: 'Pengukuran LiLA - Bulan ke-${item.bulan}', children: [
    _InfoRow(icon: Icons.calendar_today, label: 'Tanggal', value: _fmtDate(item.tanggal)),
    _InfoRow(icon: Icons.child_care, label: 'Bulan ke-', value: '${item.bulan}'),
    const SizedBox(height: 12),
    _SectionLabel('HASIL LINGKAR LENGAN ATAS'),
    _SpinnerFieldWithUnit('${item.hasilLila}', 'cm'),
    const SizedBox(height: 8),
    _SectionLabel('KATEGORI RISIKO'),
    _StatusBadge(item.kategoriRisiko, _getKategoriRisikoColor(item.kategoriRisiko)),
  ]);
}

// --- Color helpers ---

Color _getPlakColor(String status) {
  final lower = status.toLowerCase();
  if (lower == 'bersih' || lower.contains('tidak')) return const Color(0xFF10B981);
  if (lower == 'kotor' || lower.contains('ada')) return const Color(0xFFF59E0B);
  return const Color(0xFF9CA3AF);
}

Color _getRisikoColor(String risiko) {
  final lower = risiko.toLowerCase();
  if (lower == 'rendah') return const Color(0xFF10B981);
  if (lower == 'sedang') return const Color(0xFFF59E0B);
  if (lower == 'tinggi') return const Color(0xFFEF4444);
  return const Color(0xFF9CA3AF);
}

Color _getKategoriRisikoColor(String kategori) {
  final lower = kategori.toLowerCase();
  if (lower == 'normal' || lower == 'hijau') return const Color(0xFF10B981);
  if (lower == 'berisiko' || lower == 'kuning') return const Color(0xFFF59E0B);
  if (lower == 'kurang gizi' || lower == 'buruk' || lower == 'merah') return const Color(0xFFEF4444);
  return const Color(0xFF9CA3AF);
}

void _showSheet(BuildContext ctx, {required IconData icon, required String title, required List<Widget> children}) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _kBlue, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DETAIL CATATAN', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF172033)),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 24),
            // Content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: children,
              ),
            ),
            // Tutup button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// --- Reusable widgets ---

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
  );
}

class _TextBox extends StatelessWidget {
  final String text;
  const _TextBox(this.text);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF172033))),
  );
}

class _SpinnerField extends StatelessWidget {
  final String value;
  const _SpinnerField(this.value);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        Icon(Icons.unfold_more, size: 18, color: Colors.grey[400]),
      ],
    ),
  );
}

class _SpinnerFieldWithUnit extends StatelessWidget {
  final String value;
  final String unit;
  const _SpinnerFieldWithUnit(this.value, this.unit);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        Text(unit, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(width: 4),
        Icon(Icons.unfold_more, size: 18, color: Colors.grey[400]),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    ),
  );
}
