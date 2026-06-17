import 'package:flutter/material.dart';

class Pedoman06BulanScreen extends StatefulWidget {
  const Pedoman06BulanScreen({Key? key}) : super(key: key);

  @override
  State<Pedoman06BulanScreen> createState() => _Pedoman06BulanScreenState();
}

class _Pedoman06BulanScreenState extends State<Pedoman06BulanScreen> {
  final List<bool> isOpen = [true, false, false, false, false];

  final String imagePath = "assets/images/ibu_bayi.png";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TITLE =================
          const Text(
            "0 - 6 Bulan: Berikan ASI Saja Sampai Usia 6 Bulan",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // ================= IMAGE =================
          _buildImage(),

          const SizedBox(height: 16),

          // ================= QUOTE =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2F5ED7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '"Ibu, dukung pertumbuhan bayi Anda dengan memberinya hanya ASI saja hingga berusia 6 bulan."',
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
                "Bayi akan mengalami pertumbuhan dan perkembangan yang pesat, ditandai dengan penambahan berat badan dan panjang badan yang cepat.",
          ),

          _accordion(
            index: 1,
            title: "Yang Harus Dilakukan",
            content:
                "• Beri hanya ASI saja sampai usia 6 bulan.\n\n"
                "• Jangan tambahkan air putih, makanan, minuman, obat, vitamin atau mineral, kecuali dianjurkan dokter.\n\n"
                "• Susui semua bayi dan hindari penggunaan botol susu atau dot.\n\n"
                "• Timbang BB, ukur panjang badan dan cek perkembangan bayi tiap bulan di Posyandu.\n\n"
                "• Dapatkan imunisasi dasar lengkap sesuai usia (hal. 124).",
          ),

          _accordion(
            index: 2,
            title: "Mengapa Harus Dilakukan",
            content:
                "Meningkatkan ikatan antara ibu dan bayi serta mencegah stunting dengan gizi cukup.\n\n"
                "Mendukung perkembangan otak agar terbentuk sempurna dan meningkatkan kemampuan belajar.",
          ),

          const SizedBox(height: 16),

          // ================= UKURAN LAMBUNG =================
          _accordion(
            index: 3,
            title: "Ukuran Lambung Bayi Baru Lahir",
            content:
                "Hari ke-1: Kelereng\n"
                "Hari ke-3: Pingpong\n"
                "Minggu ke-1: Telur Ayam\n"
                "Bulan ke-1: Telur Bebek",
          ),

          // ================= PERILAKU MENYUSU =================
          _accordion(
            index: 4,
            title: "Perilaku Menyusu Bayi",
            content:
                "Hari Pertama\n"
                "Menyusu 5–12 kali dalam 24 jam.\n\n"
                "Hari ke-2 s/d ke-3\n"
                "Frekuensi meningkat menjadi 10–12 kali.\n\n"
                "Satu Minggu & Satu Bulan\n"
                "Frekuensi rata-rata 8–12 kali.",
          ),

          const SizedBox(height: 20),

          // ================= KONSULTASI =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_2, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Konsultasi Online\nPindai kode QR untuk mendapatkan layanan konsultasi online.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  Widget _buildImage() {
    return FutureBuilder(
      future: _checkImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<bool> _checkImage() async {
    try {
      await DefaultAssetBundle.of(context).load(imagePath);
      return true;
    } catch (_) {
      return false;
    }
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