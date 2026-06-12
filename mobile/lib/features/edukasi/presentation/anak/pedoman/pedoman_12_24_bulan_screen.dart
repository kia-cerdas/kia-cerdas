import 'package:flutter/material.dart';

class Pedoman1224BulanScreen extends StatefulWidget {
  const Pedoman1224BulanScreen({Key? key}) : super(key: key);

  @override
  State<Pedoman1224BulanScreen> createState() => _Pedoman1224BulanScreenState();
}

class _Pedoman1224BulanScreenState extends State<Pedoman1224BulanScreen> {
  final List<bool> isOpen = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TITLE =================
          const Text(
            "12 - 24 Bulan: Beri Makanan Bergizi dan Periksa Rutin ke Posyandu untuk Cegah Stunting",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // ================= HIGHLIGHT =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2F5ED7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Beri makanan yang kaya protein hewani, seperti telur, ikan dan daging.\n\nMemasuki usia 1 tahun ke atas, kemampuan fisik, mental, dan sosial anak semakin berkembang.",
              style: TextStyle(
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ================= ACCORDION =================
          _accordion(
            index: 0,
            title: "Yang Akan Dialami",
            content:
                "• Anak telah makan makanan keluarga, mulai belajar berjalan dan berkata-kata.\n\n"
                "• 70% kebutuhan gizi anak dipenuhi dari MPASI. Namun ASI masih tetap dibutuhkan karena menyumbang 30% kebutuhan gizi anak.",
          ),

          _accordion(
            index: 1,
            title: "Yang Harus Dilakukan",
            content:
                "• Timbang, ukur dan cek perkembangan anak setiap bulan.\n\n"
                "• Penuhi kecukupan gizi anak dengan pemberian MPASI yang kaya protein hewani.\n\n"
                "• Berikan makanan beragam dan menarik.\n\n"
                "• Tetap berikan ASI hingga usia 2 tahun.\n\n"
                "• Hindari pemberian makanan atau jajanan yang rendah gizi, tinggi gula dan garam, berpengawet dan berpemanis.\n\n"
                "• Ajari anak untuk belajar makan sendiri.\n\n"
                "• Ajari anak berjalan di undakan/tangga, mencoret-coret di kertas, menyebut bagian tubuhnya, dan bergerak bebas dalam pengawasan.\n\n"
                "• Ajak anak membersihkan meja dan menyapu, membereskan mainan, bernyanyi, dan bermain dengan teman.\n\n"
                "• Bacakan cerita buat anak, dan bimbing anak untuk mematuhi aturan permainan.\n\n"
                "• Dapatkan imunisasi lanjutan.\n\n"
                "• Cek kesehatan anak secara rutin dan segera ke fasilitas kesehatan jika anak sakit atau ditemukan tanda bahaya.\n\n"
                "• Pastikan anak mendapatkan suplementasi vitamin A kapsul merah dan obat cacing sebanyak 2 kali dalam setahun.",
          ),

          _accordion(
            index: 2,
            title: "Mengapa Harus Dilakukan",
            content:
                "Stunting paling banyak terjadi di kelompok usia ini. Tetap lanjutkan pemantauan tumbuh kembang anak di Posyandu atau fasilitas kesehatan lainnya untuk memastikan anak memiliki kondisi yang sehat, status gizi dan perkembangan terbaik sesuai usianya.",
          ),
        ],
      ),
    );
  }

  // ================= ACCORDION =================
  Widget _accordion({
    required int index,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        initiallyExpanded: isOpen[index],
        onExpansionChanged: (val) {
          setState(() {
            isOpen[index] = val;
          });
        },
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Text(
            content,
            style: const TextStyle(height: 1.5),
          )
        ],
      ),
    );
  }
}