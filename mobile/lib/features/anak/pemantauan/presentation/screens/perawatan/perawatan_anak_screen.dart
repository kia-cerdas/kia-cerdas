import 'package:flutter/material.dart';

class PerawatanAnakScreen extends StatelessWidget {
  const PerawatanAnakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: const Text('Perawatan Anak',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFFD97706),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFD97706),
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: '2–3 Tahun'),
              Tab(text: '3–4 Tahun'),
              Tab(text: '4–5 Tahun'),
              Tab(text: '5–6 Tahun'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Tab23Tahun(),
            _Tab34Tahun(),
            _Tab45Tahun(),
            _Tab56Tahun(),
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
                      : const Color(0xFFD97706),
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
// TAB 1 — 2 – 3 TAHUN
// ─────────────────────────────────────────────
class _Tab23Tahun extends StatelessWidget {
  const _Tab23Tahun();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak\nUmur 2 – 3 Tahun', const Color(0xFFD97706)),
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
                    'Kapsul Vitamin A (Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Obat cacing.', isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Lanjutkan perawatan gigi dengan mengingatkan anak menyikat gigi setelah makan dan sebelum tidur.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Anak Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 2–3 tahun:',
                    color: Color(0xFFD97706)),
                const _BulletItem('Sebutkan nama benda, sifat, guna benda.'),
                const _BulletItem('Bacakan cerita, tanya jawab.'),
                const _BulletItem(
                    'Anak diminta bercerita pengalaman menonton TV didampingi maksimal 1 jam, menyanyi.'),
                const SizedBox(height: 8),
                const _SectionTitle('Aktivitas Stimulasi:',
                    color: Color(0xFFD97706)),
                const _BulletItem('Cuci tangan, cebok, berpakaian, rapikan mainan.'),
                const _BulletItem('Makan dengan sendok garpu.'),
                const _BulletItem(
                    'Menyusun balok, memasang puzzle, menggambar, menempel.'),
                const _BulletItem('Mengelompokkan benda sejenis.'),
                const _BulletItem('Mencocokkan gambar dan benda.'),
                const _BulletItem('Menghitung.'),
                const _BulletItem(
                    'Berlari, melompat, memanjat, merayap.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFFD97706),
            items: const [
              'Anak bisa jalan naik tangga sendiri?',
              'Anak bisa bermain dan menendang bola kecil?',
              'Anak bisa mencoret-coret pensil pada kertas?',
              'Anak bisa bicara dengan baik, menggunakan 2 kata?',
              'Anak bisa menunjuk 1 atau lebih bagian tubuhnya ketika diminta?',
              'Anak bisa melihat gambar dan dapat menyebut dengan benar nama 2 benda atau lebih?',
              'Anak bisa membantu memungut mainannya sendiri atau membantu mengangkat piring jika diminta?',
              'Anak bisa makan nasi sendiri tanpa banyak tumpah?',
              'Anak bisa melepas pakaiannya sendiri?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — 3 – 4 TAHUN
// ─────────────────────────────────────────────
class _Tab34Tahun extends StatelessWidget {
  const _Tab34Tahun();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak\nUmur 3 – 4 Tahun', const Color(0xFF7C3AED)),
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
                    'Kapsul Vitamin A (Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Obat cacing.', isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Lanjutkan perawatan gigi dengan mengingatkan anak menyikat gigi setelah makan dan sebelum tidur.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Anak Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 3–4 tahun:',
                    color: Color(0xFF7C3AED)),
                const _BulletItem('Menyebutkan nama benda, sifat, guna benda.'),
                const _BulletItem('Bacakan cerita, tanya jawab.'),
                const _BulletItem('Anak diminta bercerita pengalaman.'),
                const _BulletItem('Menonton TV didampingi, menyanyi.'),
                const SizedBox(height: 8),
                const _SectionTitle('Aktivitas Stimulasi:',
                    color: Color(0xFF7C3AED)),
                const _BulletItem('Cuci tangan, cebok, berpakaian, rapikan mainan.'),
                const _BulletItem('Makan dengan sendok garpu.'),
                const _BulletItem(
                    'Menyusun balok, memasang puzzle, menggambar, menempel.'),
                const _BulletItem('Mengelompokkan benda sejenis.'),
                const _BulletItem('Mencocokkan gambar dan benda.'),
                const _BulletItem('Menghitung.'),
                const _BulletItem('Melempar, menangkap.'),
                const _BulletItem(
                    'Berlari, melompat, memanjat, merayap.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF7C3AED),
            items: const [
              'Anak bisa berdiri 1 kaki 2 detik?',
              'Anak bisa melompat kedua kaki diangkat?',
              'Anak bisa mengayuh sepeda roda tiga?',
              'Anak bisa menggambar garis lurus?',
              'Anak bisa menumpuk 8 buah kubus?',
              'Anak bisa mengenal 2-4 warna?',
              'Anak bisa menyebut nama, umur, tempat?',
              'Anak bisa mengerti arti kata di atas, di bawah, di depan?',
              'Anak bisa mendengarkan cerita?',
              'Anak bisa mencuci dan mengeringkan tangan sendiri?',
              'Anak bermain bersama teman, mengikuti aturan permainan?',
              'Anak bisa mengenakan sepatu sendiri?',
              'Anak bisa mengenakan celana panjang, kemeja, baju?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3 — 4 – 5 TAHUN
// ─────────────────────────────────────────────
class _Tab45Tahun extends StatelessWidget {
  const _Tab45Tahun();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak\nUmur 4 – 5 Tahun', const Color(0xFFDC2626)),
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
                    'Kapsul Vitamin A (Februari atau Agustus).',
                    isSubBullet: true),
                _BulletItem('Obat cacing.', isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Lanjutkan perawatan gigi dengan mengingatkan anak menyikat gigi setelah makan dan sebelum tidur.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Anak Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 4–5 tahun:',
                    color: Color(0xFFDC2626)),
                const _BulletItem(
                    'Bermain peran, anak diminta bercerita pengalaman.'),
                const _BulletItem('Menggambar orang, mengenal huruf.'),
                const _BulletItem('Main bola, lompat tali.'),
                const _BulletItem(
                    'Latih untuk dapat mengikuti aturan permainan.'),
                const _BulletItem('Kenalkan nama-nama hari.'),
                const _BulletItem('Menyebut angka berurutan.'),
                const _BulletItem(
                    'Mengajak anak sikat gigi bersama dan melatih sikat gigi sendiri.'),
                const _BulletItem('Melatih memakai pakaian sendiri.'),
                const _BulletItem('Menguatkan kepercayaan diri anak.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFFDC2626),
            items: const [
              'Anak bisa berdiri 1 kaki 6 detik?',
              'Anak bisa melompat-lompat 1 kaki?',
              'Anak bisa menari?',
              'Anak bisa menggambar tanda silang?',
              'Anak bisa menggambar lingkaran?',
              'Anak bisa menggambar orang dengan 3 bagian tubuh?',
              'Anak bisa mengancing baju atau pakaian boneka?',
              'Anak bisa menyebut nama lengkap tanpa dibantu?',
              'Anak bisa senang menyebut kata-kata baru?',
              'Anak bisa senang bertanya tentang sesuatu?',
              'Anak bisa menjawab pertanyaan dengan kata-kata yang benar?',
              'Anak bisa bicara yang mudah dimengerti?',
              'Anak bisa membandingkan/membedakan sesuatu dari ukuran dan bentuknya?',
              'Anak bisa menyebut angka, menghitung jari?',
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 4 — 5 – 6 TAHUN
// ─────────────────────────────────────────────
class _Tab56Tahun extends StatelessWidget {
  const _Tab56Tahun();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBanner(
              'Perawatan Anak\nUmur 5 – 6 Tahun', const Color(0xFF0891B2)),
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
                _BulletItem('Obat cacing.', isSubBullet: true),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Perawatan Gigi'),
                _BulletItem(
                    'Lanjutkan perawatan gigi anak dengan: gigi susu sudah tumbuh semua: 20 buah, mulai tumbuh 2 gigi geraham tetap, rahang bawah pertama kiri dan kanan.'),
                _BulletItem(
                    'Periksa gigi anak secara rutin setiap 3-6 bulan sekali ke dokter gigi atau perawat gigi di Puskesmas atau fasilitas kesehatan lainnya.'),
              ],
            ),
          ),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Pantau Tumbuh Kembang Anak Anda'),
                const _BulletItem(
                    'Dukung tumbuh kembang si kecil sesuai perkembangan anak seusianya dengan melakukan stimulasi dalam suasana aman, nyaman dan menyenangkan.'),
                const SizedBox(height: 8),
                const _SectionTitle('Stimulasi usia 5–6 tahun:',
                    color: Color(0xFF0891B2)),
                const _BulletItem('Mengenal nama, fungsi benda-benda.'),
                const _BulletItem(
                    'Bacakan buku, tanya jawab, bercerita.'),
                const _BulletItem(
                    'Menonton TV didampingi maksimal 1 jam, menyanyi.'),
                const _BulletItem(
                    'Cuci tangan, cebok, berpakaian, rapikan mainan.'),
                const _BulletItem('Melempar, menangkap, berlari, melompat.'),
                const SizedBox(height: 8),
                const _SectionTitle('Aktivitas Stimulasi:',
                    color: Color(0xFF0891B2)),
                const _BulletItem('Makan dengan sendok garpu, masak-masakan.'),
                const _BulletItem('Menggunting, menempel, menjahit.'),
                const _BulletItem(
                    'Menyusun balok, memasang puzzle, menggambar, mewarnai, menulis nama.'),
                const _BulletItem(
                    'Mengingat, menghafal, mengerti aturan dan urutan.'),
                const _BulletItem(
                    'Membandingkan besar kecil, banyak sedikit.'),
                const _BulletItem(
                    'Menghitung, konsep satu dan setengah.'),
                const _BulletItem(
                    'Mengenal angka, huruf, simbol, jam, hari dan tanggal.'),
                const _BulletItem(
                    'Memanjat, merayap, sepeda roda 3, ayunan.'),
                const _BulletItem(
                    'Bermain berjualan, bertukang, dan mengukur.'),
              ],
            ),
          ),
          _PenandaTable(
            accentColor: const Color(0xFF0891B2),
            items: const [
              'Anak bisa berjalan lurus?',
              'Anak bisa berdiri dengan 1 kaki selama 11 detik?',
              'Anak bisa menggambar dengan 6 bagian, menggambar orang lengkap?',
              'Anak bisa menangkap bola kecil dengan kedua tangan?',
              'Anak bisa menggambar segi empat?',
              'Anak bisa mengerti arti lawan kata?',
              'Anak bisa mengerti pembicaraan yang menggunakan 7 kata atau lebih?',
              'Anak bisa menjawab pertanyaan tentang benda terbuat dari apa dan kegunaannya?',
              'Anak bisa mengenal angka, bisa menghitung angka 5-10?',
              'Anak bisa mengenal warna-warni?',
              'Anak bisa mengungkapkan simpati?',
              'Anak bisa mengikuti aturan permainan?',
              'Anak bisa berpakaian sendiri tanpa dibantu?',
            ],
          ),
        ],
      ),
    );
  }
}