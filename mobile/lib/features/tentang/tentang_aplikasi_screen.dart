import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart'; // Sesuaikan path jika perlu

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Aplikasi ──
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.health_and_safety,
                          size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Generasi Sehat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── 1. Mengenai Generasi Sehat ──
              _buildSectionTitle('1. Mengenai Generasi Sehat'),
              _buildParagraph(
                  'Generasi Sehat adalah aplikasi sarana pencatatan digital mandiri dan edukasi kesehatan yang dirancang untuk mendampingi masa kehamilan ibu, pemantauan masa nifas, serta tumbuh kembang anak secara optimal. Aplikasi ini dikembangkan untuk mempermudah digitalisasi layanan Buku Kesehatan Ibu dan Anak (Buku KIA) serta mendukung kegiatan pelayanan Posyandu secara terpadu.'),
              const Divider(height: 32),

              // ── 2. Fitur Utama ──
              _buildSectionTitle('2. Fitur Utama'),
              _buildFeatureCategory('Pemantauan Tumbuh Kembang Anak:'),
              _buildBullet(
                  'Pencatatan pengukuran fisik (Berat Badan, Tinggi Badan, Lingkar Kepala, Lingkar Lengan Atas/LILA).'),
              _buildBullet(
                  'Evaluasi grafik pertumbuhan interaktif berbasis kurva standar tumbuh kembang anak.'),
              _buildBullet('Pengingat dan pencatatan riwayat imunisasi anak.'),
              _buildBullet('Modul edukasi MPASI, resep gizi, dan pola asuh.'),
              const SizedBox(height: 12),

              _buildFeatureCategory('Pendamping Kesehatan Ibu (Hamil & Nifas):'),
              _buildBullet(
                  'Catatan pelayanan kesehatan kehamilan trimester I, II, dan III.'),
              _buildBullet(
                  'Fitur alat bantu deteksi awal mandiri (seperti Skrining Preeklampsia & Deteksi Gejala Darurat).'),
              _buildBullet(
                  'Pemantauan masa nifas dan panduan perawatan ibu melahirkan.'),
              _buildBullet(
                  'Materi edukasi kesehatan reproduksi, ASI eksklusif, dan Inisiasi Menyusu Dini.'),
              const SizedBox(height: 12),

              _buildFeatureCategory('Alat Bantu Pelayanan Kader Posyandu:'),
              _buildBullet('Pencatatan dan verifikasi kunjungan rumah/posyandu.'),
              _buildBullet('Verifikasi absensi kelas ibu hamil dan kelas ibu balita.'),
              _buildBullet(
                  'Rekapitulasi distribusi suplemen/vitamin (TTD/MMS) dan pemantauan kesehatan warga.'),
              const Divider(height: 32),

              // ── 3. Pengabaian Tanggung Jawab Medis (Disclaimer) ──
              _buildSectionTitle('3. Pengabaian Tanggung Jawab Medis'),
              _buildDisclaimerBox(),
              const Divider(height: 32),

              // ── 4. Status Independensi & Hak Cipta ──
              _buildSectionTitle('4. Status Independensi & Hak Cipta'),
              _buildParagraph(
                  'Aplikasi Generasi Sehat dikembangkan secara mandiri sebagai inovasi teknologi pendukung digitalisasi layanan kesehatan ibu dan anak.'),
              _buildBullet(
                  'Aplikasi ini tidak berafiliasi resmi dengan instansi pemerintah manapun.',
                  isBoldPrimary: true),
              _buildBullet(
                  'Standar acuan medis, pedoman imunisasi, dan kurva pertumbuhan yang digunakan dalam aplikasi merujuk pada standar publik yang dipublikasikan oleh Kementerian Kesehatan Republik Indonesia.'),
              const Divider(height: 32),

              // ── 5. Privasi Data & Pengelolaan Akun ──
              _buildSectionTitle('5. Privasi Data & Pengelolaan Akun'),
              _buildRichBullet('Keamanan Data: ',
                  'Data pribadi dan riwayat kesehatan disimpan secara aman dan tidak diperjualbelikan kepada pihak ketiga.'),
              _buildRichBullet('Sistem Akun: ',
                  'Akun pengguna dibuat dan dikelola secara terpusat oleh Administrator desa/Bidan desa setempat.'),
              _buildRichBullet('Penghapusan Akun/Data: ',
                  'Pengguna berhak meminta penonaktifan akun atau penghapusan data pribadi dari server kapan saja dengan menghubungi Admin Desa atau Bidan Desa penanggung jawab.'),
              const Divider(height: 40),

              // ── Footer Info ──
              Center(
                child: Column(
                  children: [
                    _buildFooterInfo('Nama Aplikasi', 'Generasi Sehat'),
                    _buildFooterInfo('Versi', '1.0.0'),
                    const SizedBox(height: 16),
                    const Text(
                      '© 2026 Generasi Sehat.\nAll Rights Reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers Widget ──

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF4B5563),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeatureCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildBullet(String text, {bool isBoldPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: isBoldPrimary ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF4B5563),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichBullet(String boldText, String normalText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
                children: [
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                  ),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Latar belakang merah pudar
        border: Border.all(color: const Color(0xFFFCA5A5)), // Border merah muda
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
              SizedBox(width: 8),
              Text(
                'PENTING UNTUK DIBACA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Seluruh konten, fitur, kalkulasi grafik, serta kuesioner deteksi awal di dalam aplikasi Generasi Sehat disediakan hanya untuk tujuan edukasi, pencatatan mandiri, dan informasi.',
            style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF7F1D1D)),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 12),
          _buildNumberedDisclaimer(
              '1', 'Sifat Saran & Rekomendasi:', ' Informasi dan rekomendasi aksi di dalam aplikasi ini hanya bersifat sebagai panduan atau saran aksi, bukan sebagai penentu/pembuat keputusan akhir.'),
          _buildNumberedDisclaimer(
              '2', 'Wajib Konsultasi Profesional:', ' Selalu konsultasikan kondisi kesehatan Ibu dan Anak secara langsung dengan Dokter, Bidan, atau Tenaga Kesehatan di Puskesmas, Posyandu, atau Rumah Sakit terdekat sebelum mengambil tindakan medis apa pun.'),
          _buildNumberedDisclaimer(
              '3', 'Kondisi Darurat:', ' Jika Ibu atau Anak mengalami gejala gawat darurat (seperti kejang, pendarahan, demam tinggi mendadak, atau sesak napas), segera kunjungi Instalasi Gawat Darurat (IGD) atau fasilitas kesehatan terdekat. Jangan menunda tindakan medis hanya berdasarkan informasi dari aplikasi ini.'),
        ],
      ),
    );
  }

  Widget _buildNumberedDisclaimer(String number, String boldText, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D))),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF991B1B)),
                children: [
                  TextSpan(
                      text: boldText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }
}