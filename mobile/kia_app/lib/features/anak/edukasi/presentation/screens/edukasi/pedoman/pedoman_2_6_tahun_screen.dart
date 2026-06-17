import 'package:flutter/material.dart';

class Pedoman26TahunScreen extends StatefulWidget {
  const Pedoman26TahunScreen({Key? key}) : super(key: key);

  @override
  State<Pedoman26TahunScreen> createState() => _Pedoman26TahunScreenState();
}

class _Pedoman26TahunScreenState extends State<Pedoman26TahunScreen> {
  final List<bool> isOpen = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TITLE =================
          const Text(
            "2 - 6 Tahun: Pastikan Si Kecil Memiliki Tanda Anak Sehat",
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
              "Di usia 2 tahun ke atas, perkembangan fisik, mental dan sosial anak berkembang pesat hingga usia 6 tahun.",
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
                "• Anak mulai disapih, lebih banyak melakukan aktivitas, bergaul lebih luas dan memasuki masa pra sekolah.\n\n"
                "• Di usia 3 tahun pertama, otak anak berkembang sangat pesat, sehingga asupan gizi disertai stimulasi perkembangan penting.\n\n"
                "• Pelayanan kesehatan, pola asuh yang peka dengan kebutuhan anak, serta perlindungan dan keamanan juga penting bagi anak.",
          ),

          _accordion(
            index: 1,
            title: "Yang Harus Dilakukan",
            content:
                "• Penuhi gizi anak dengan pemberian makanan keluarga yang bervariasi dan kaya protein hewani.\n\n"
                "• Timbang dan ukur serta cek perkembangan anak setiap bulan di Posyandu atau fasilitas kesehatan lainnya.\n\n"
                "• Ajak anak mulai melibatkan diri dalam kegiatan bersama.\n\n"
                "• Ajarkan anak perbedaan jenis kelamin dan menjaga alat kelaminnya.\n\n"
                "• Kembangkan kreativitas anak dan kemampuan bergaul.\n\n"
                "• Cek kesehatan anak secara rutin dan segera ke fasilitas kesehatan jika anak sakit.\n\n"
                "• Pastikan anak mendapatkan suplementasi Vitamin A dan obat cacing 2 kali setahun.",
          ),

          _accordion(
            index: 2,
            title: "Mengapa Harus Dilakukan",
            content:
                "• Untuk memastikan anak memiliki kondisi yang sehat, status gizi dan perkembangan terbaik sesuai usianya.\n\n"
                "• Mempersiapkan anak memasuki masa pra sekolah dan sekolah dasar.",
          ),

          const SizedBox(height: 16),

          // ================= DIARE & DEHIDRASI =================
          _accordion(
            index: 3,
            title: "Cegah Diare dan Dehidrasi pada Balita",
            content:
                "Pemenuhan gizi balita usia 2 hingga 6 tahun merupakan salah satu upaya agar si kecil memiliki tanda anak sehat.\n\n"
                "• Memberikan gizi seimbang (makanan pokok, lauk hewani & nabati, sayur dan buah).\n\n"
                "• Mengutamakan kebersihan makanan.\n\n"
                "• Mencukupi kebutuhan cairan (5 - 7 gelas air per hari).\n\n"
                "Pengolahan makanan yang tidak bersih dapat menyebabkan diare yang berujung dehidrasi.\n\n"
                "Pencegahan saat diare:\n"
                "1. Memberikan ASI lebih sering dan lebih lama.\n"
                "2. Memberikan oralit sampai diare berhenti.\n"
                "3. Memberikan obat zinc selama 10 hari berturut-turut.\n"
                "4. Memberikan air minum dan makanan berkuah.\n\n"
                "Segera bawa anak ke fasilitas kesehatan jika kondisi tidak membaik.",
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