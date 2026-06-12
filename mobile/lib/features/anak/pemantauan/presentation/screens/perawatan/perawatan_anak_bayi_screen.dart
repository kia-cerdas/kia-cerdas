import 'package:flutter/material.dart';

class PerawatanAnakBayiScreen extends StatelessWidget {
  const PerawatanAnakBayiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: const Text('Perawatan Anak Bayi',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF16A34A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF16A34A),
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: '12–18 Bulan'),
              Tab(text: '18–24 Bulan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Tab1218Bulan(),
            _Tab1824Bulan(),
          ],
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
                      : const Color(0xFF16A34A),
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
          Container(
            color: widget.accentColor.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                    width: 28,
                    child: Text('No.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const Expanded(
                    child: Text('Penanda Perkembangan Anak',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
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
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)))),
              ],
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 28,
                          child: Text('${i + 1}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54))),
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
// TAB 1 — 12 – 18 BULAN
// ─────────────────────────────────────────────
class _Tab1218Bulan extends StatelessWidget {
  const _Tab1218Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak Bayi\nUmur 12 – 18 Bulan', const Color(0xFF16A34A)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pelayanan Kesehatan'),
                _BulletItem(
                    'Bawa anak anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem(
                    'Kapsul Vitamin A (bulan Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Obat cacing.', isSubBullet: true),
                _BulletItem('Imunisasi (lihat halaman 124-125).',
                    isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Manfaat Imunisasi Lanjutan'),
                _BulletItem(
                    'Pengulangan imunisasi dasar untuk mempertahankan tingkat kekebalan dan untuk memperpanjang masa perlindungan anak yang sudah mendapatkan imunisasi dasar.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Manfaat Obat Cacing'),
                _BulletItem(
                    'Untuk pencegahan dan pengobatan infeksi cacingan sehingga dampak cacingan pada tubuh dapat dicegah.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Perhatikan tumbuhnya gigi, pada usia 18 bulan adanya gigi susu berjumlah 16 buah.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 12–18 bulan:',
                    color: Color(0xFF16A34A)),
                const _BulletItem('Berjalan mundur, naik tangga.'),
                const _BulletItem('Tangkap dan lempar bola.'),
                const _BulletItem('Menyusun balok atau puzzle, menggambar.'),
                const _BulletItem('Bermain air, meniup, menendang bola.'),
                const _BulletItem('Bercerita tentang gambar di buku.'),
                const _BulletItem('Menyebutkan nama benda, menyanyi.'),
                const _BulletItem(
                    'Main telpon-telponan, menyatakan keinginan.'),
                const _BulletItem(
                    'Bermain dengan teman sebaya, petak umpet.'),
                const _BulletItem('Merapikan mainan, membuka baju.'),
                const _BulletItem('Makan bersama.'),
                const _BulletItem('Merangkai manik besar.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF16A34A),
            items: const [
              'Anak bisa berdiri sendiri tanpa berpegangan?',
              'Anak bisa membungkuk memungut mainan kemudian berdiri kembali?',
              'Anak bisa berjalan mundur lima langkah?',
              'Anak bisa memanggil ayah dengan kata "papa", memanggil ibu dengan kata "mama"?',
              'Anak bisa menumpuk dua kubus?',
              'Anak bisa memasukkan kubus di kotak?',
              'Anak bisa menunjuk apa yang diinginkan tanpa menangis/merengek, anak bisa mengeluarkan suara yang menyenangkan atau menarik tangan ibu?',
              'Anak bisa memperlihatkan rasa cemburu/bersaing?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — 18 – 24 BULAN
// ─────────────────────────────────────────────
class _Tab1824Bulan extends StatelessWidget {
  const _Tab1824Bulan();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak Bayi\nUmur 18 – 24 Bulan', const Color(0xFF0891B2)),
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Pelayanan Kesehatan'),
                _BulletItem(
                    'Bawa anak anda setiap bulan ke Posyandu/Puskesmas/Fasilitas Kesehatan untuk mendapat pelayanan:'),
                _BulletItem('Pemantauan pertumbuhan dan perkembangan.',
                    isSubBullet: true),
                _BulletItem(
                    'Ibu/Ayah/Keluarga mengikuti kelas Ibu Balita.',
                    isSubBullet: true),
                _BulletItem(
                    'Kapsul Vitamin A (bulan Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Obat cacing.', isSubBullet: true),
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
                    'Lanjutkan perawatan gigi anak. Perhatikan tumbuhnya gigi, pada usia 24 bulan adanya gigi susu berjumlah 20 buah.'),
                _BulletItem(
                    'Gosok giginya setelah sarapan dan sebelum tidur dengan sikat gigi kecil khusus anak yang berbulu lembut, pakai pasta gigi mengandung fluor cukup selapis tipis (1/2 biji kacang polong).'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Bayi Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 18–24 bulan:',
                    color: Color(0xFF0891B2)),
                const _BulletItem('Bicara, bertanya, bercerita, bernyanyi.'),
                const _BulletItem('Tanya jawab, main telpon-telponan.'),
                const _BulletItem(
                    'Perintah sederhana, membantu pekerjaan.'),
                const _BulletItem('Melepas baju, rapikan mainan.'),
                const _BulletItem(
                    'Makan bersama dengan sendok garpu.'),
                const _BulletItem(
                    'Menyusun balok, memasang puzzle, menggambar, membentuk lilin.'),
                const _BulletItem(
                    'Buat rumah-rumahan, petak umpet.'),
                const _BulletItem(
                    'Berjalan, berlari, melompat.'),
                const _BulletItem('Berdiri satu kaki, naik turun tangga.'),
                const _BulletItem(
                    'Melempar, menangkap, menendang bola.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF0891B2),
            items: const [
              'Anak bisa berdiri sendiri tanpa berpegangan 30 detik?',
              'Anak bisa berjalan tanpa terhuyung-huyung?',
              'Anak bisa menumpuk 4 buah kubus?',
              'Anak bisa memungut benda kecil dengan ibu jari dan jari telunjuk?',
              'Anak bisa menggelindingkan bola ke arah sasaran?',
              'Anak bisa menyebut 3 – 6 kata yang mempunyai arti?',
              'Anak bisa membantu/menirukan pekerjaan rumah tanggal?',
              'Anak bisa memegang cangkir sendiri, belajar makan-minum sendiri?',
            ],
          ),
        ],
      ),
    );
  }
}