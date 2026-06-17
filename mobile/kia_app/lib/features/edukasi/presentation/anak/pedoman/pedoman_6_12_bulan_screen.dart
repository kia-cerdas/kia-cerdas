import 'package:flutter/material.dart';

class Pedoman612BulanScreen extends StatefulWidget {
  const Pedoman612BulanScreen({Key? key}) : super(key: key);

  @override
  State<Pedoman612BulanScreen> createState() => _Pedoman612BulanScreenState();
}

class _Pedoman612BulanScreenState extends State<Pedoman612BulanScreen> {
  final List<bool> isOpen = [true, true, false];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "6 - 12 Bulan:",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 6),
                Text(
                  "Cegah Stunting dengan MPASI Kaya Protein Hewani",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= WARNING =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Stunting menghambat pertumbuhan fisik dan otak anak. Masa 6–12 bulan adalah periode kritis untuk pemenuhan gizi melalui MPASI yang tepat.",
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= ACCORDION =================
          _accordion(
            index: 0,
            icon: Icons.emoji_emotions_outlined,
            title: "Yang Akan Dialami",
            child: Column(
              children: [
                _bullet("Merasakan tekstur makanan untuk pertama kalinya (MPASI)."),
                _bullet("Mulai tumbuh gigi dan gatal pada gusi."),
                _bullet("Bisa berguling ke arah kiri dan kanan dengan lancar."),
                _bullet("Meraih dan memegang benda-benda di sekitarnya."),
                _bullet("Mulai merangkak untuk mengeksplorasi lingkungan."),
              ],
            ),
          ),

          _accordion(
            index: 1,
            icon: Icons.check_circle_outline,
            title: "Yang Harus Dilakukan",
            child: Column(
              children: [
                _iconText(Icons.restaurant, "Berikan MPASI dengan gizi seimbang, utamakan protein hewani."),
                _iconText(Icons.menu_book, "Lakukan Food Training untuk membiasakan rasa makanan alami."),
                _iconText(Icons.child_care, "Lanjutkan pemberian ASI hingga usia 2 tahun atau lebih."),
                _iconText(Icons.local_hospital, "Rutin ke Posyandu untuk memantau pertumbuhan & berat badan."),
                _iconText(Icons.medication, "Pastikan anak mendapatkan kapsul Vitamin A di bulan Februari/Agustus."),
                _iconText(Icons.vaccines, "Lengkapi imunisasi dasar sesuai jadwal yang ditentukan."),
              ],
            ),
          ),

          _accordion(
            index: 2,
            icon: Icons.help_outline,
            title: "Mengapa Harus Dilakukan",
            child: Column(
              children: [
                _infoBox(
                  "Mencegah Stunting & Infeksi",
                  "Gizi yang baik memperkuat imun tubuh bayi agar terhindar dari penyakit kronis.",
                ),
                const SizedBox(height: 10),
                _infoBox(
                  "Keterampilan Sosial & Kemandirian",
                  "Proses makan melatih motorik halus dan interaksi antara ibu dan buah hati.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACCORDION =================
  Widget _accordion({
    required int index,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        initiallyExpanded: isOpen[index],
        onExpansionChanged: (val) {
          setState(() {
            isOpen[index] = val;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        children: [child],
      ),
    );
  }

  // ================= BULLET =================
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // ================= ICON TEXT =================
  Widget _iconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // ================= INFO BOX =================
  Widget _infoBox(String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(desc),
        ],
      ),
    );
  }
}