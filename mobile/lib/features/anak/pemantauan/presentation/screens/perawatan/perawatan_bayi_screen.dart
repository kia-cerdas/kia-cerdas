import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/widgets/verification_popup.dart';

class PerawatanBayiScreen extends StatelessWidget {
  const PerawatanBayiScreen({super.key});

  void _showExitPopup(BuildContext context) {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.exit,
      title: 'Yakin ingin keluar?',
      content: 'Apakah Anda yakin ingin keluar tanpa menyimpan? Data yang belum disimpan akan hilang dan tidak dapat dikembalikan.',
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _showExitPopup(context);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: const Text('Perawatan Bayi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => _showExitPopup(context),
            ),
            bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2563EB),
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: '0–28 Hari'),
              Tab(text: '29 Hr – 3 Bln'),
              Tab(text: '3–6 Bulan'),
              Tab(text: '6–9 Bulan'),
              Tab(text: '9–12 Bulan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Tab028Hari(),
            _Tab29Hari3Bulan(),
            _Tab36Bulan(),
            _Tab69Bulan(),
            _Tab912Bulan(),
          ],
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, {this.color = const Color(0xFF1E3A5F)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool isSubBullet;
  const _BulletItem(this.text, {this.isSubBullet = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isSubBullet ? 20 : 0, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: isSubBullet ? 4 : 6,
              height: isSubBullet ? 4 : 6,
              decoration: BoxDecoration(
                  color: isSubBullet
                      ? Colors.black38
                      : const Color(0xFF2563EB),
                  shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13,
                      color: isSubBullet ? Colors.black54 : Colors.black87,
                      height: 1.5))),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// PENANDA TABLE WIDGET
// ─────────────────────────────────────────────
class _PenandaTable extends StatefulWidget {
  final List<String> items;
  final Color accentColor;
  const _PenandaTable({required this.items, required this.accentColor});

  @override
  State<_PenandaTable> createState() => _PenandaTableState();
}

class _PenandaTableState extends State<_PenandaTable> {
  late List<bool?> _ya;
  late List<bool?> _tidak;

  @override
  void initState() {
    super.initState();
    _ya = List<bool?>.filled(widget.items.length, null);
    _tidak = List<bool?>.filled(widget.items.length, null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner kuning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF08A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Beri tanda ✓ (centang) pada kolom Ya/Tidak. Jika anak belum bisa melakukan salah satu dari hal berikut ini, segera bawa ke Puskesmas.',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF713F12),
                  height: 1.4),
            ),
          ),
          // Table header
          Container(
            color: widget.accentColor.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                    width: 28,
                    child: Text('No.',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Penanda Perkembangan Anak',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(
                    width: 40,
                    child: Center(
                        child: Text('Ya',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.accentColor)))),
                SizedBox(
                    width: 48,
                    child: Center(
                        child: Text('Tidak',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)))),
              ],
            ),
          ),
          // Table rows
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: List.generate(widget.items.length, (i) {
                final isEven = i % 2 == 0;
                return Container(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.white : const Color(0xFFF8FAFC),
                    borderRadius: i == widget.items.length - 1
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))
                        : null,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 28,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54))),
                      Expanded(
                          child: Text(widget.items[i],
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E40AF),
                                  height: 1.4))),
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: _ya[i] == true,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() {
                            _ya[i] = v == true ? true : null;
                            if (v == true) _tidak[i] = null;
                          }),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Checkbox(
                          value: _tidak[i] == true,
                          activeColor: Colors.red,
                          onChanged: (v) => setState(() {
                            _tidak[i] = v == true ? true : null;
                            if (v == true) _ya[i] = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HEADER BANNER BUILDER
// ─────────────────────────────────────────────
Widget _headerBanner(String title, Color color) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.4),
    ),
  );
}

// ─────────────────────────────────────────────
// TAB 1 — 0 – 28 HARI
// ─────────────────────────────────────────────

class _Tab028Hari extends StatefulWidget {
  const _Tab028Hari();

  @override
  State<_Tab028Hari> createState() => _Tab028HariState();
}

class _Tab028HariState extends State<_Tab028Hari> {
  final List<bool?> _kunjunganValues = List.filled(4, null);
  bool _kunjunganSaved = false;

  final List<bool?> _perawatanValues = List.filled(16, null);
  bool _perawatanSaved = false;

  static const _kunjunganRows = [
    '0 - 6 jam setelah lahir.',
    '6 - 48 jam setelah lahir.',
    'Hari 3 - 7 setelah lahir.',
    'Hari 8 - 28 setelah lahir.',
  ];

  static const _perawatanRows = [
    'Mandikan bayi dengan air hangat 6 jam setelah lahir dengan syarat kondisi stabil.',
    'Sebelum tali pusat lepas, mandikan bayi dengan cara dilap.',
    'Setelah tali pusat lepas, bayi dapat dimandikan dengan dimasukkan ke dalam air. Hati-hati agar kepala tidak terendam.',
    'Bersihkan kemaluan bayi dari depan ke belakang dengan kapas yang dibasahi air bersih atau handuk bersih basah.',
    'Beri pakaian dan selimuti setiap saat.',
    'Pakaikan topi, kaos kaki, kaos tangan jika dirasakan cuaca dingin.',
    'Segera ganti baju dan popok jika basah.',
    'Lakukan perawatan metode kanguru jika berat badan bayi < 2500 gram.',
    'Bidan/Perawat/Dokter menjelaskan perawatan metode kanguru.',
    'Usahakan bayi berada dalam lingkungan udara sejuk.',
    'Jika menggunakan kipas angin, usahakan agar arah angin tidak langsung mengenai bayi.',
    'Suhu AC sekitar 25 – 26°C.',
    'Cuci tangan dengan sabun dan air mengalir sebelum dan sesudah memegang bayi.',
    'Jangan memberikan apapun pada tali pusat.',
    'Rawat tali pusat terbuka dan kering.',
    'Jika kotor/basah, cuci dengan air bersih dan sabun, lalu keringkan.',
  ];

  static const _perawatanGroupHeaders = {
    0: 'Cara Menjaga Bayi Tetap Hangat',
    8: 'Bidan/Perawat/Dokter Menjelaskan',
    12: 'Cara Merawat Tali Pusat',
  };

  void _simpanKunjungan() {
    setState(() => _kunjunganSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data kunjungan berhasil disimpan.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  void _confirmSimpanKunjungan() {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.save,
      title: 'Konfirmasi Simpan',
      content: 'Apakah Anda yakin data kunjungan sudah benar? Data yang sudah disimpan tidak dapat diubah kembali.',
      onConfirm: () {
        Navigator.pop(context);
        _simpanKunjungan();
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  void _simpanPerawatan() {
    setState(() => _perawatanSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data perawatan berhasil disimpan.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  void _confirmSimpanPerawatan() {
    showVerificationPopup(
      context: context,
      type: VerificationPopupType.save,
      title: 'Konfirmasi Simpan',
      content: 'Apakah Anda yakin data perawatan sudah benar? Data yang sudah disimpan tidak dapat diubah kembali.',
      onConfirm: () {
        Navigator.pop(context);
        _simpanPerawatan();
      },
      onCancel: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner('Bayi Baru Lahir (0 - 28 Hari)', const Color(0xFF2563EB)),
          const SizedBox(height: 12),
          const Text(
            'Satu bulan pertama kehidupan merupakan masa penting untuk mendukung kelangsungan hidup bayi.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('YANG AKAN DIALAMI'),
                _BulletItem('Bayi akan mengalami perubahan yang cepat, dari lingkungan yang terlindungi di dalam rahim ke dunia luar.'),
                _BulletItem('Orang tua atau pengasuh berperan penting dalam mendukung pertumbuhan dan perkembangan bayi pada masa awal kehidupan.'),
                _BulletItem('Pola tidur bayi sampai dengan 16 jam dalam sehari.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('YANG HARUS DILAKUKAN'),
                _BulletItem('Pastikan bayi mendapat pemeriksaan dan pelayanan kesehatan oleh tenaga kesehatan pada bayi baru lahir. Jika ada tanda bahaya, segera ke fasilitas pelayanan kesehatan.'),
                _BulletItem('Pastikan bayi mendapat imunisasi hepatitis B (HB0) sebelum 24 jam, skrining Hipotiroid Kongenital (SHK) 48 - 72 jam setelah lahir, dan skrining Penyakit Jantung Bawaan (PJB) kritis 24-48 jam setelah lahir.'),
                _BulletItem('Tetap berikan ASI saja selama 6 bulan, dan dilanjutkan hingga bayi berusia 2 tahun.'),
                _BulletItem('Tips pola tidur bayi yang sehat:'),
                _BulletItem('Sebaiknya beri tidur tertentu.', isSubBullet: true),
                _BulletItem('Gunakan alas yang rata.', isSubBullet: true),
                _BulletItem('Jauhkan benda yang dapat menutupi kepala.', isSubBullet: true),
                _BulletItem('Gunakan kelambu.', isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('YANG HARUS DILAKUKAN'),
                _BulletItem('Pastikan bayi mendapat pemeriksaan dan pelayanan kesehatan oleh tenaga kesehatan:'),
                _BulletItem('0-6 jam setelah lahir', isSubBullet: true),
                _BulletItem('6-48 jam setelah lahir', isSubBullet: true),
                _BulletItem('3-7 hari setelah lahir', isSubBullet: true),
                _BulletItem('8-28 hari setelah lahir', isSubBullet: true),
                _BulletItem('Susui bayi dengan penuh kasih sayang, dekatkan dengan hangat, dan jaga hubungan kasih sayang dengan menetap dan mengajak bicara.'),
                _BulletItem('Jaga bayi tetap hangat dan jaga kebersihan selama merawat bayi.'),
                _BulletItem('Cek kesehatan bayi dan kenali tanda bahaya.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('MENGAPA HARUS DILAKUKAN'),
                _BulletItem('Dua pertiga kematian balita di Indonesia terjadi di usia 1-28 hari pertama.'),
                _BulletItem('Pemeriksaan dan pelayanan kesehatan dilakukan untuk memantau kesehatan bayi secara menyeluruh, agar dapat segera diketahui penanganan apabila ditemukan adanya infeksi atau kondisi yang membahayakan bayi.'),
                _BulletItem('Menjalin kedekatan dengan bayi penting untuk pertumbuhan dan perkembangannya yang terbaik.'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Banner kuning 1
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              border: Border.all(color: const Color(0xFFF59E0B)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Beri tanda ✓ (centang) jika si kecil sudah mendapat pemeriksaan dan pelayanan kesehatan oleh tenaga kesehatan di Puskesmas pada:',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
            ),
          ),
          const SizedBox(height: 10),

          // Tabel 1: Kunjungan
          _buildTabel(
            rows: _kunjunganRows,
            values: _kunjunganValues,
            groupHeaders: const {},
            isSaved: _kunjunganSaved,
            isLocked: false,
          ),
          const SizedBox(height: 12),

          // Tombol Simpan Tabel 1
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _kunjunganSaved ? null : _confirmSimpanKunjungan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _kunjunganSaved ? 'Tersimpan ✓' : 'Simpan',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Banner kuning 2
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              border: Border.all(color: const Color(0xFFF59E0B)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Setelah ibu membaca dan memahami informasi, tandai hal-hal berikut ini.',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
            ),
          ),
          const SizedBox(height: 10),

          // Tabel 2: Perawatan (terkunci sampai tabel 1 disimpan)
          Stack(
            children: [
              _buildTabel(
                rows: _perawatanRows,
                values: _perawatanValues,
                groupHeaders: _perawatanGroupHeaders,
                isSaved: _perawatanSaved,
                isLocked: !_kunjunganSaved,
              ),
              if (!_kunjunganSaved)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.80),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 36, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Simpan data kunjungan terlebih dahulu\nuntuk mengisi bagian ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
          const Text(
            'Tanyakan kepada bidan / dokter / Perawat untuk penjelasan lebih lanjut berkaitan dengan perawatan bayi baru lahir.',
            style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.4,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),

          // Tombol Simpan Tabel 2
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (!_kunjunganSaved || _perawatanSaved) ? null : _confirmSimpanPerawatan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _perawatanSaved ? 'Tersimpan ✓' : 'Simpan',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabel({
    required List<String> rows,
    required List<bool?> values,
    required Map<int, String> groupHeaders,
    required bool isSaved,
    required bool isLocked,
  }) {
    const headerStyle =
        TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white);
    const cellStyle =
        TextStyle(fontSize: 12, color: Colors.black87, height: 1.4);
    const groupStyle = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E40AF));

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FixedColumnWidth(56),
          2: FixedColumnWidth(56),
        },
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFF2563EB)),
            children: const [
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Pernyataan', style: headerStyle)),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Ya',
                      textAlign: TextAlign.center, style: headerStyle)),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Tidak',
                      textAlign: TextAlign.center, style: headerStyle)),
            ],
          ),
          // Data rows
          ...List.generate(rows.length, (i) {
            final result = <TableRow>[];

            if (groupHeaders.containsKey(i)) {
              result.add(TableRow(
                decoration: const BoxDecoration(color: Color(0xFFDBEAFE)),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(groupHeaders[i]!, style: groupStyle),
                  ),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                ],
              ));
            }

            final isEven = i % 2 == 0;
            result.add(TableRow(
              decoration: BoxDecoration(
                  color: isEven ? Colors.white : const Color(0xFFF8FAFF)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(rows[i], style: cellStyle),
                ),
                GestureDetector(
                  onTap: (isLocked || isSaved)
                      ? null
                      : () => setState(() => values[i] = true),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: values[i] == true
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF16A34A), size: 22)
                        : const Icon(Icons.radio_button_unchecked,
                            color: Colors.grey, size: 22),
                  ),
                ),
                GestureDetector(
                  onTap: (isLocked || isSaved)
                      ? null
                      : () => setState(() => values[i] = false),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: values[i] == false
                        ? const Icon(Icons.cancel,
                            color: Color(0xFFDC2626), size: 22)
                        : const Icon(Icons.radio_button_unchecked,
                            color: Colors.grey, size: 22),
                  ),
                ),
              ],
            ));

            return result;
          }).expand((e) => e),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — 29 HARI – 3 BULAN
// ─────────────────────────────────────────────
class _Tab29Hari3Bulan extends StatelessWidget {
  const _Tab29Hari3Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner('Perawatan Bayi\nUmur 29 Hari – 3 Bulan',
              const Color(0xFF0891B2)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Layanan Kesehatan'),
                _BulletItem(
                    'Bawa bayi anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem('Imunisasi (lihat halaman 124-125).',
                    isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Manfaat Imunisasi'),
                _imunisasiRow('BCG', 'Mencegah penyakit TBC.'),
                _imunisasiRow('Polio',
                    'Mencegah polio yang menyebabkan lumpuh layu pada tungkai dan atau lengan.'),
                _imunisasiRow('DPT-HB-Hib',
                    'Mencegah penyakit difteri, pertusis (batuk rejan), tetanus, hepatitis B, dan meningitis.'),
                _imunisasiRow('PCV',
                    'Mencegah penyakit pneumonia akibat bakteri pneumokokus.'),
                _imunisasiRow('RV (Rotavirus)',
                    'Mencegah diare berat yang menyebabkan dehidrasi dan kematian.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                SizedBox(height: 8),
                _SectionTitle('Stimulasi usia 29 hari – 3 bulan:',
                    color: Color(0xFF0891B2)),
                _BulletItem('Peluk, cium, ayun bayi.'),
                _BulletItem('Senyum, tatap mata, ajak bicara.'),
                _BulletItem('Tirukan ocehan dan mimik bayi.'),
                _BulletItem(
                    'Interaksi langsung untuk mengenalkan berbagai suara, bunyi, atau nyanyian.'),
                _BulletItem('Gantung benda berwarna, berbunyi.'),
                _BulletItem('Meraih, meraba, pegang mainan.'),
                _BulletItem('Memasukkan benda ke dalam wadah.'),
                _BulletItem('Gulingkan kanan-kiri, tengkurap-telentang.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF0891B2),
            items: const [
              'Bayi bisa mengangkat kepala mandiri hingga tegak 90°?',
              'Bayi bisa mempertahankan posisi kepala tetap tegak dan stabil?',
              'Bayi bisa menggenggam mainan kecil atau mainan bertangkai?',
              'Bayi bisa meraih benda yang ada di dalam jangkauannya?',
              'Bayi bisa mengamati tangannya sendiri?',
              'Bayi berusaha memperluas pandangan?',
              'Bayi mengarahkan matanya pada benda-benda kecil?',
              'Bayi mengeluarkan suara gembira bernada tinggi atau memekik?',
              'Bayi tersenyum ketika melihat mainan/gambar yang menarik saat bermain sendiri?',
              'Bayi bisa berbalik dari telungkup ke telentang?',
            ],
          ),
        ],
      ),
    );
  }

  Widget _imunisasiRow(String nama, String manfaat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(nama,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E3A5F))),
          ),
          Expanded(
              child: Text(manfaat,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3 — 3 – 6 BULAN
// ─────────────────────────────────────────────
class _Tab36Bulan extends StatelessWidget {
  const _Tab36Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Bayi\nUmur 3 – 6 Bulan', const Color(0xFF7C3AED)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Layanan Kesehatan'),
                _BulletItem(
                    'Bawa bayi anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem('Imunisasi (lihat halaman 124-125).',
                    isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Cara membersihkan gigi bayi: Gendong atau pangku anak dengan satu tangan.'),
                _BulletItem(
                    'Bersihkan gusi anak secara perlahan dengan kain atau lap basah yang dilingkarkan pada jari telunjuk ibu.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                _BulletItem(
                    'Stimulasi bayi pada rentang usia 3–6 bulan dengan:'),
                _BulletItem(
                    'Peluk, cium, pandang mata, senyum, bicara.',
                    isSubBullet: true),
                SizedBox(height: 8),
                _SectionTitle('Aktivitas Stimulasi:',
                    color: Color(0xFF7C3AED)),
                _BulletItem('Mencari sumber suara.'),
                _BulletItem('Cilukba, lihat cermin.'),
                _BulletItem('Tunjuk dan sebut nama gambar.'),
                _BulletItem('Bacakan dongeng.'),
                _BulletItem('Pegang mainan dengan 2 tangan.'),
                _BulletItem('Sembunyikan dan cari mainan.'),
                _BulletItem('Memasukkan benda ke dalam wadah.'),
                _BulletItem('Mainan yang mengapung di air.'),
                _BulletItem('Memukul-mukul.'),
                _BulletItem('Duduk, merangkak, berdiri berpegangan.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF7C3AED),
            items: const [
              'Bayi bisa berbalik dari telungkup ke telentang?',
              'Bayi bisa mengangkat kepala secara mandiri hingga tegak 90 °?',
              'Bayi bisa mempertahankan posisi kepala tetap tegak dan stabil?',
              'Bayi bisa menggenggam mainan kecil atau mainan bertangkai?',
              'Bayi bisa meraih benda yang ada dalam jangkauannya?',
              'Bayi bisa mengamati tangannya sendiri?',
              'Bayi berusaha memperluas pandangan?',
              'Bayi mengarahkan matanya pada benda-benda kecil?',
              'Bayi mengeluarkan suara gembira bernada tinggi atau memekik?',
              'Bayi tersenyum ketika melihat mainan/gambar yang menarik saat bermain sendiri?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 4 — 6 – 9 BULAN
// ─────────────────────────────────────────────
class _Tab69Bulan extends StatelessWidget {
  const _Tab69Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Bayi\nUmur 6 – 9 Bulan', const Color(0xFF059669)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Layanan Kesehatan'),
                _BulletItem(
                    'Bawa bayi anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem(
                    'Kapsul Vitamin A (bulan Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Imunisasi (lihat halaman 124-125).',
                    isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Manfaat Imunisasi'),
                _BulletItem(
                    'Campak-Rubella mencegah penularan penyakit yang dapat mengakibatkan masalah radang paru, radang otak dan kebutaan.'),
                SizedBox(height: 8),
                _SectionTitle('Manfaat Vitamin A'),
                _BulletItem(
                    'Vitamin A untuk meningkatkan kesehatan mata dan pertumbuhan anak.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Perhatikan tumbuhnya 4 gigi seri rahang atas dan rahang bawah.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                _SectionTitle('Stimulasi usia 6–9 bulan:',
                    color: Color(0xFF059669)),
                _BulletItem('Peluk, senyum, bicara, panggil namanya.'),
                _BulletItem(
                    'Bersalaman, tepuk tangan, melambai ke orang lain.'),
                _BulletItem(
                    'Kenalkan/tunjuk nama orang (papa/mama).'),
                _BulletItem('Cilukba, lihat cermin.'),
                _BulletItem('Tunjuk dan sebut nama gambar.'),
                _BulletItem('Bacakan dongeng.'),
                _BulletItem('Pegang mainan dengan 2 tangan.'),
                _BulletItem('Masukkan benda kecil ke dalam wadah.'),
                _BulletItem('Sembunyikan dan cari mainan.'),
                _BulletItem('Mainan yang mengapung di air.'),
                _BulletItem('Memukul-mukul.'),
                _BulletItem('Duduk, merangkak, berdiri berpegangan.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF059669),
            items: const [
              'Bayi bisa duduk secara mandiri?',
              'Bayi belajar berdiri, kedua kakinya menyangga sebagian berat badan?',
              'Bayi bisa merangkak meraih mainan atau mendekati seseorang?',
              'Bayi bisa memindahkan benda dari satu tangan ke tangan lainnya?',
              'Bayi bisa memungut 2 benda, kedua tangan pegang 2 benda pada saat bersamaan?',
              'Bayi bisa memungut benda sebesar kacang dari cara meraup?',
              'Bayi bersuara tanpa arti, mamama, bababa, dadada, tatata?',
              'Bayi mencari mainan/benda yang dijatuhkan?',
              'Bayi bermain tepuk tangan/Cilukba?',
              'Bayi bergembira dengan melempar benda?',
              'Bayi bergembira dengan melempar benda?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 5 — 9 – 12 BULAN
// ─────────────────────────────────────────────
class _Tab912Bulan extends StatelessWidget {
  const _Tab912Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner('Perawatan Bayi\nUmur 9 – 12 Bulan',
              const Color(0xFFDC2626)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Layanan Kesehatan'),
                _BulletItem(
                    'Bawa bayi anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem(
                    'Kapsul Vitamin A (bulan Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Imunisasi (lihat halaman 124-125).',
                    isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Manfaat Imunisasi'),
                _BulletItem(
                    'JE: Mencegah anak dari penyakit radang otak.'),
                SizedBox(height: 8),
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Lanjutkan perawatan gigi. Pada usia 9 bulan biasanya sudah ada gigi seri 8 buah, gigi geraham 4 buah.'),
                _BulletItem(
                    'Bersihkan gigi anak menggunakan kasa yang diberi air hangat dengan sedikit pasta gigi anak.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                _SectionTitle('Stimulasi usia 9–12 bulan:',
                    color: Color(0xFFDC2626)),
                _BulletItem('Berbicara dengan boneka.'),
                _BulletItem(
                    'Menunjuk dan mengucapkan orang/benda/organ tubuh yang sudah dikenal.'),
                _BulletItem(
                    'Bacakan dongeng pada saat mengenalkan dan menyuruh menunjuk.'),
                _BulletItem('Pegang mainan dengan 2 tangan.'),
                _BulletItem('Memasukkan benda kecil ke dalam wadah.'),
                _BulletItem('Menyusun balok.'),
                _BulletItem('Sembunyikan dan cari mainan.'),
                _BulletItem(
                    'Memegang pensil dan mencoret-coret kertas.'),
                _BulletItem(
                    'Duduk, merangkak, berdiri berpegangan.'),
                _BulletItem('Berjalan mundur, jinjit.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFFDC2626),
            items: const [
              'Bayi bisa mengangkat badannya ke posisi berdiri?',
              'Bayi belajar berdiri selama 30 detik atau berpegangan di kursi?',
              'Bayi dapat berjalan dengan dituntun?',
              'Bayi mengulurkan lengan/badan untuk meraih mainan yang diinginkan?',
              'Bayi bisa menggenggam erat pensil?',
              'Bayi bisa memasukkan benda ke mulut?',
              'Bayi mengulang menirukan bunyi yang didengar?',
              'Bayi menyebut 2-3 suku kata yang sama tanpa arti?',
              'Bayi mengeksplorasi sekitar, ingin tahu, ingin menyentuh apa saja?',
              'Bayi bereaksi terhadap suara yang perlahan atau bisikan?',
              'Bayi senang diajak bermain Cilukba?',
              'Bayi mengenal anggota keluarga, takut pada orang yang belum dikenal?',
            ],
          ),
        ],
      ),
    );
  }
}