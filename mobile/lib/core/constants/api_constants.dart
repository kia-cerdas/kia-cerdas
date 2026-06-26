// import 'package:flutter/foundation.dart';

// class ApiConstants {
//   ApiConstants._();

//   static String get baseUrl {
//     if (kIsWeb) {
//       return 'http://localhost:8080';
//     }

//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'http://192.168.50.200:8080';
//       default:
//         return 'http://127.0.0.1:8080';
//     }
//   }

// //   static String baseUrl = 'https://api.generasisehat.com';

//   static const String authLogin = '/auth/login';
//   static const String authMe = '/auth/me';

//   // MODUL IBU  ==================================================
//   static const String kehamilanAktif = '/modul-ibu/kehamilan-aktif';
//   static const String pemeriksaanKehamilan =
//       '/modul-ibu/pemeriksaan-kehamilan/me';
//   static const String pemeriksaanDokterTrimester1 =
//       '/modul-ibu/pemeriksaan-dokter-trimester-1/me';
//   static const String pemeriksaanDokterTrimester3 =
//       '/modul-ibu/pemeriksaan-dokter-trimester-3/me';
//   static const String skriningPreeklampsia =
//       '/modul-ibu/skrining-preeklampsia/me';
//   static const String evaluasiKesehatanIbu =
//       '/modul-ibu/evaluasi-kesehatan-ibu/me';
//   static const String absensiKelasIbuHamil =
//       '/modul-ibu/absensi-kelas-ibu-hamil/me';
//   static const String saveAbsensiKelasIbuHamil =
//       '/modul-ibu/absensi-kelas-ibu-hamil';
//   static const String logTTDMMS = '/modul-ibu/log-ttd-mms/me';
//   static const String saveLogTTDMMS = '/modul-ibu/log-ttd-mms';
//   // Pemantauan Ibu Hamil
//   static const String pemantauanIbuHamil = '/modul-ibu/pemantauan-ibu-hamil/me';
//   static const String savePemantauanIbuHamil =
//       '/modul-ibu/pemantauan-ibu-hamil';
//   static const String prosesMelahirkan = '/modul-ibu/proses-melahirkan/me';
//   // Pemantauan Ibu Nifas
//   static const String checklistPemantauanIbuNifas =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas';
//   // static const String checklistPemantauanIbuNifasFilledDays = '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
//   // static const String checklistNifasFilledDays = '/modul-ibu/checklist-pemantauan-nifas/filled-days';
//   // static const String saveChecklistNifas = '/modul-ibu/checklist-pemantauan-nifas';
//   static const String checklistNifasFilledDays =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
//   static const String checklistNifasSave =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas';
//   static const String checklistNifasMe =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas/me';
//   static const String grafikEvaluasiKehamilanV2 =
//       '/modul-ibu/grafik-evaluasi-kehamilan/v2';
//   static const String grafikPeningkatanBBV2 =
//       '/modul-ibu/grafik-peningkatan-bb/v2';
//   static const String keteranganLahir = '/modul-ibu/keterangan-lahir/me';
//   // Profile Ibu
//   static const String profilIbu = '/modul-ibu/profil';

//   // Pemeriksaan Dokter - list semua kunjungan (BARU)
//   static const String pemeriksaanDokterTrimester1All =
//       '/modul-ibu/pemeriksaan-dokter-trimester-1/all';
//   static const String pemeriksaanDokterTrimester3All =
//       '/modul-ibu/pemeriksaan-dokter-trimester-3/all';

//   // Persiapan Melahirkan (checklist ibu)
//   static const String persiapanMelahirkan =
//       '/modul-ibu/persiapan-melahirkan/me';
//   static const String savePersiapanMelahirkan =
//       '/modul-ibu/persiapan-melahirkan';
//   // Checklist Proses Melahirkan (checklist pemahaman ibu)
//   static const String checklistProsesMelahirkan =
//       '/modul-ibu/proses-melahirkan/me';
//   static const String saveChecklistProsesMelahirkan =
//       '/modul-ibu/proses-melahirkan';

//   static const String riwayatProsesMelahirkan =
//       '/modul-ibu/riwayat-proses-melahirkan/me';
//   static const String rujukanIbu = '/modul-ibu/rujukan';
//   static String get ringkasanPersalinan =>
//       '$baseUrl/modul-ibu/ringkasan-persalinan/me';

//   // Catatan Pelayanan Kehamilan unified (tabel baru untuk mobile)
//   // ?trimester=1 opsional (1/2/3). Kosong = semua trimester.
//   static const String catatanPelayananKehamilanMe =
//       '/modul-ibu/catatan-pelayanan-kehamilan/me';
//   // static String catatanPelayananT1(
//   //   int kehamilanId,
//   // ) =>
//   //     // '$baseUrl/modul-ibu/catatan-pelayanan-t1?kehamilan_id=$kehamilanId';
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=1';
//   // static String catatanPelayananT2(
//   //   int kehamilanId,
//   // ) =>
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-t2?kehamilan_id=$kehamilanId';
//   // static String catatanPelayananT3(
//   //   int kehamilanId,
//   // ) =>
//   //     // '$baseUrl/modul-ibu/catatan-pelayanan-t3?kehamilan_id=$kehamilanId';
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=3';

//   static String get catatanPelayananT1 =>
//     '$baseUrl/modul-ibu/pemeriksaan-dokter-trimester-1/all';

//   static String get catatanPelayananT3 =>
//       '$baseUrl/modul-ibu/pemeriksaan-dokter-trimester-3/all';

//   /*
//    *
//    * 
//    * 
//    * 
//    * 
//    * 
//   */

//   // MODUL ANAK ==================================================
//   // Modul Anak - Data Ibu & Anak
//   // Tumbuh Kembang
//   static const String ibuAnak = '/ibu/anak';
//   static const String ibuLembarPemantauan = '/ibu/lembar-pemantauan';
//   static const String ibuLembarPemantauanRentangUsia =
//       '/ibu/lembar-pemantauan/rentang-usia';
//   static const String ibuLembarPemantauanKategori =
//       '/ibu/lembar-pemantauan/kategori-tanda-sakit';
//   static const String ibuWarnaTinja = '/ibu/warna-tinja';
//   // Pencarian
//   static const String anakSearch = '/anak/search';
//   static String anakById(int anakId) => '/anak/$anakId';
//   // Pertumbuhan dan Standar
//   static const String pertumbuhan = '/pertumbuhan';
//   static String riwayatPertumbuhanByAnakId(int anakId) =>
//       '/ibu/pertumbuhan/anak/$anakId';
//   // Informasi Umum
//   static const String masterStandar = '/master-standar';
//   static const String edukasiInformasiUmum = '/edukasi-informasi-umum';

//   static String edukasiInformasiUmumById(int id) =>
//       '/edukasi-informasi-umum/$id';

//   static const String informasiUmum = edukasiInformasiUmum;

//   static String informasiUmumById(int id) => edukasiInformasiUmumById(id);
//   // Perawatan (Milestone/Perkembangan)
//   static const String ibuKategoriCapaian = '/ibu/kategori-capaian';
//   static String ibuKategoriCapaianByRentangUsia(String rentangUsia) =>
//       '/ibu/kategori-capaian/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
//   static const String ibuPerawatan = '/ibu/perawatan';
//   static String ibuPerawatanById(int id) => '/ibu/perawatan/$id';
//   static String ibuPerawatanByAnakId(int anakId) =>
//       '/ibu/perawatan/anak/$anakId';
//   static String ibuPerawatanByAnakIdAndRentangUsia(
//           int anakId, String rentangUsia) =>
//       '/ibu/perawatan/anak/$anakId/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
//   static const String ibuKeluhanAnak = '/ibu/keluhan-anak';

//   // MODUL EDUKASI ==================================================
//   // Edukasi Pola Asuh
//   static const String edukasiPolaAsuh = '/edukasi-pola-asuh';
//   static String edukasiPolaAsuhById(int id) => '/edukasi-pola-asuh/$id';

//   // Edukasi Perawatan Anak
//   static const String edukasiPerawatanAnak = '/edukasi-perawatan-anak';
//   static String edukasiPerawatanAnakById(int id) =>
//       '/edukasi-perawatan-anak/$id';
//   static String get edukasiASI => '$baseUrl/edukasi-menyusui-asi';
//   static String get edukasiIMD => '$baseUrl/edukasi-imd';
//   static String get edukasiKesehatanMental =>
//       '$baseUrl/edukasi-kesehatan-mental';
//   // static String get edukasiNifas => '$baseUrl/edukasi-nifas';
//   static String get edukasiNifas => '$baseUrl/edukasi-setelah-melahirkan';
//   static String get edukasiTandaMelahirkan =>
//       '$baseUrl/edukasi-tanda-melahirkan';
//   static String edukasiTrimester(
//     String trimester,
//   ) =>
//       '$baseUrl/edukasi-trimester/$trimester';
//   static String edukasiTrimesterKategori(
//     String trimester,
//     String kategori,
//   ) =>
//       '$baseUrl/edukasi-trimester/$trimester/$kategori';
// }

// import 'package:flutter/foundation.dart';

// class ApiConstants {
//   ApiConstants._();

//   static String get baseUrl {
//     if (kIsWeb) {
//       return 'http://localhost:8080';
//     }

//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'http://192.168.50.200:8080';
//       default:
//         return 'http://127.0.0.1:8080';
//     }
//   }

// //   static String baseUrl = 'https://api.generasisehat.com';

//   static const String authLogin = '/auth/login';
//   static const String authMe = '/auth/me';

//   // MODUL IBU  ==================================================
//   static const String kehamilanAktif = '/modul-ibu/kehamilan-aktif';
//   static const String pemeriksaanKehamilan =
//       '/modul-ibu/pemeriksaan-kehamilan/me';
//   static const String pemeriksaanDokterTrimester1 =
//       '/modul-ibu/pemeriksaan-dokter-trimester-1/me';
//   static const String pemeriksaanDokterTrimester3 =
//       '/modul-ibu/pemeriksaan-dokter-trimester-3/me';
//   static const String skriningPreeklampsia =
//       '/modul-ibu/skrining-preeklampsia/me';
//   static const String evaluasiKesehatanIbu =
//       '/modul-ibu/evaluasi-kesehatan-ibu/me';
//   static const String absensiKelasIbuHamil =
//       '/modul-ibu/absensi-kelas-ibu-hamil/me';
//   static const String saveAbsensiKelasIbuHamil =
//       '/modul-ibu/absensi-kelas-ibu-hamil';
//   static const String logTTDMMS = '/modul-ibu/log-ttd-mms/me';
//   static const String saveLogTTDMMS = '/modul-ibu/log-ttd-mms';
//   // Pemantauan Ibu Hamil
//   static const String pemantauanIbuHamil = '/modul-ibu/pemantauan-ibu-hamil/me';
//   static const String savePemantauanIbuHamil =
//       '/modul-ibu/pemantauan-ibu-hamil';
//   static const String prosesMelahirkan = '/modul-ibu/proses-melahirkan/me';
//   // Pemantauan Ibu Nifas
//   static const String checklistPemantauanIbuNifas =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas';
//   // static const String checklistPemantauanIbuNifasFilledDays = '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
//   // static const String checklistNifasFilledDays = '/modul-ibu/checklist-pemantauan-nifas/filled-days';
//   // static const String saveChecklistNifas = '/modul-ibu/checklist-pemantauan-nifas';
//   static const String checklistNifasFilledDays =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
//   static const String checklistNifasSave =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas';
//   static const String checklistNifasMe =
//       '/modul-ibu/checklist-pemantauan-ibu-nifas/me';
//   static const String grafikEvaluasiKehamilanV2 =
//       '/modul-ibu/grafik-evaluasi-kehamilan/v2';
//   static const String grafikPeningkatanBBV2 =
//       '/modul-ibu/grafik-peningkatan-bb/v2';
//   static const String keteranganLahir = '/modul-ibu/keterangan-lahir/me';
//   // Profile Ibu
//   static const String profilIbu = '/modul-ibu/profil';

//   // Pemeriksaan Dokter - list semua kunjungan (BARU)
//   static const String pemeriksaanDokterTrimester1All =
//       '/modul-ibu/pemeriksaan-dokter-trimester-1/all';
//   static const String pemeriksaanDokterTrimester3All =
//       '/modul-ibu/pemeriksaan-dokter-trimester-3/all';

//   // Persiapan Melahirkan (checklist ibu)
//   static const String persiapanMelahirkan =
//       '/modul-ibu/persiapan-melahirkan/me';
//   static const String savePersiapanMelahirkan =
//       '/modul-ibu/persiapan-melahirkan';
//   // Checklist Proses Melahirkan (checklist pemahaman ibu)
//   static const String checklistProsesMelahirkan =
//       '/modul-ibu/proses-melahirkan/me';
//   static const String saveChecklistProsesMelahirkan =
//       '/modul-ibu/proses-melahirkan';

//   static const String riwayatProsesMelahirkan =
//       '/modul-ibu/riwayat-proses-melahirkan/me';
//   static const String rujukanIbu = '/modul-ibu/rujukan';
//   static String get ringkasanPersalinan =>
//       '$baseUrl/modul-ibu/ringkasan-persalinan/me';

//   // Catatan Pelayanan Kehamilan unified (tabel baru untuk mobile)
//   // ?trimester=1 opsional (1/2/3). Kosong = semua trimester.
//   static const String catatanPelayananKehamilanMe =
//       '/modul-ibu/catatan-pelayanan-kehamilan/me';
//   // static String catatanPelayananT1(
//   //   int kehamilanId,
//   // ) =>
//   //     // '$baseUrl/modul-ibu/catatan-pelayanan-t1?kehamilan_id=$kehamilanId';
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=1';
//   // static String catatanPelayananT2(
//   //   int kehamilanId,
//   // ) =>
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-t2?kehamilan_id=$kehamilanId';
//   // static String catatanPelayananT3(
//   //   int kehamilanId,
//   // ) =>
//   //     // '$baseUrl/modul-ibu/catatan-pelayanan-t3?kehamilan_id=$kehamilanId';
//   //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=3';

//   static String get catatanPelayananT1 =>
//     '$baseUrl/modul-ibu/pemeriksaan-dokter-trimester-1/all';

//   static String get catatanPelayananT3 =>
//       '$baseUrl/modul-ibu/pemeriksaan-dokter-trimester-3/all';

//   /*
//    *
//    * 
//    * 
//    * 
//    * 
//    * 
//   */

//   // MODUL ANAK ==================================================
//   // Modul Anak - Data Ibu & Anak
//   // Tumbuh Kembang
//   static const String ibuAnak = '/ibu/anak';
//   static const String ibuLembarPemantauan = '/ibu/lembar-pemantauan';
//   static const String ibuLembarPemantauanRentangUsia =
//       '/ibu/lembar-pemantauan/rentang-usia';
//   static const String ibuLembarPemantauanKategori =
//       '/ibu/lembar-pemantauan/kategori-tanda-sakit';
//   static const String ibuWarnaTinja = '/ibu/warna-tinja';
//   // Pencarian
//   static const String anakSearch = '/anak/search';
//   static String anakById(int anakId) => '/anak/$anakId';
//   // Pertumbuhan dan Standar
//   static const String pertumbuhan = '/pertumbuhan';
//   static String riwayatPertumbuhanByAnakId(int anakId) =>
//       '/ibu/pertumbuhan/anak/$anakId';
//   // Informasi Umum
//   static const String masterStandar = '/master-standar';
//   static const String edukasiInformasiUmum = '/edukasi-informasi-umum';

//   static String edukasiInformasiUmumById(int id) =>
//       '/edukasi-informasi-umum/$id';

//   static const String informasiUmum = edukasiInformasiUmum;

//   static String informasiUmumById(int id) => edukasiInformasiUmumById(id);
//   // Perawatan (Milestone/Perkembangan)
//   static const String ibuKategoriCapaian = '/ibu/kategori-capaian';
//   static String ibuKategoriCapaianByRentangUsia(String rentangUsia) =>
//       '/ibu/kategori-capaian/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
//   static const String ibuPerawatan = '/ibu/perawatan';
//   static String ibuPerawatanById(int id) => '/ibu/perawatan/$id';
//   static String ibuPerawatanByAnakId(int anakId) =>
//       '/ibu/perawatan/anak/$anakId';
//   static String ibuPerawatanByAnakIdAndRentangUsia(
//           int anakId, String rentangUsia) =>
//       '/ibu/perawatan/anak/$anakId/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
//   static const String ibuKeluhanAnak = '/ibu/keluhan-anak';

//   // MODUL EDUKASI ==================================================
//   // Edukasi Pola Asuh
//   static const String edukasiPolaAsuh = '/edukasi-pola-asuh';
//   static String edukasiPolaAsuhById(int id) => '/edukasi-pola-asuh/$id';

//   // Edukasi Perawatan Anak
//   static const String edukasiPerawatanAnak = '/edukasi-perawatan-anak';
//   static String edukasiPerawatanAnakById(int id) =>
//       '/edukasi-perawatan-anak/$id';
//   static String get edukasiASI => '$baseUrl/edukasi-menyusui-asi';
//   static String get edukasiIMD => '$baseUrl/edukasi-imd';
//   static String get edukasiKesehatanMental =>
//       '$baseUrl/edukasi-kesehatan-mental';
//   // static String get edukasiNifas => '$baseUrl/edukasi-nifas';
//   static String get edukasiNifas => '$baseUrl/edukasi-setelah-melahirkan';
//   static String get edukasiTandaMelahirkan =>
//       '$baseUrl/edukasi-tanda-melahirkan';
//   static String edukasiTrimester(
//     String trimester,
//   ) =>
//       '$baseUrl/edukasi-trimester/$trimester';
//   static String edukasiTrimesterKategori(
//     String trimester,
//     String kategori,
//   ) =>
//       '$baseUrl/edukasi-trimester/$trimester/$kategori';
// }


import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:8080';
  //   }

  //   switch (defaultTargetPlatform) {
  //     case TargetPlatform.android:
  //       return 'http://192.168.50.200:8080';
  //     default:
  //       return 'http://127.0.0.1:8080';
  //   }
  // }

  static String baseUrl = 'https://api.generasisehat.com';

  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';

  // MODUL IBU  ==================================================
  static const String kehamilanAktif = '/modul-ibu/kehamilan-aktif';
  static const String pemeriksaanKehamilan =
      '/modul-ibu/pemeriksaan-kehamilan/me';
  static const String pemeriksaanDokterTrimester1 =
      '/modul-ibu/pemeriksaan-dokter-trimester-1/me';
  static const String pemeriksaanDokterTrimester3 =
      '/modul-ibu/pemeriksaan-dokter-trimester-3/me';
  static const String skriningPreeklampsia =
      '/modul-ibu/skrining-preeklampsia/me';
  static const String evaluasiKesehatanIbu =
      '/modul-ibu/evaluasi-kesehatan-ibu/me';
  static const String absensiKelasIbuHamil =
      '/modul-ibu/absensi-kelas-ibu-hamil/me';
  static const String saveAbsensiKelasIbuHamil =
      '/modul-ibu/absensi-kelas-ibu-hamil';
  static const String logTTDMMS = '/modul-ibu/log-ttd-mms/me';
  static const String saveLogTTDMMS = '/modul-ibu/log-ttd-mms';
  // Pemantauan Ibu Hamil
  static const String pemantauanIbuHamil = '/modul-ibu/pemantauan-ibu-hamil/me';
  static const String savePemantauanIbuHamil =
      '/modul-ibu/pemantauan-ibu-hamil';
  static const String prosesMelahirkan = '/modul-ibu/proses-melahirkan/me';
  // Pemantauan Ibu Nifas
  static const String checklistPemantauanIbuNifas =
      '/modul-ibu/checklist-pemantauan-ibu-nifas';
  // static const String checklistPemantauanIbuNifasFilledDays = '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
  // static const String checklistNifasFilledDays = '/modul-ibu/checklist-pemantauan-nifas/filled-days';
  // static const String saveChecklistNifas = '/modul-ibu/checklist-pemantauan-nifas';
  static const String checklistNifasFilledDays =
      '/modul-ibu/checklist-pemantauan-ibu-nifas/filled-days';
  static const String checklistNifasSave =
      '/modul-ibu/checklist-pemantauan-ibu-nifas';
  static const String checklistNifasMe =
      '/modul-ibu/checklist-pemantauan-ibu-nifas/me';
  static const String grafikEvaluasiKehamilanV2 =
      '/modul-ibu/grafik-evaluasi-kehamilan/v2';
  static const String grafikPeningkatanBBV2 =
      '/modul-ibu/grafik-peningkatan-bb/v2';
  static const String keteranganLahir = '/modul-ibu/keterangan-lahir/me';
  // Profile Ibu
  static const String profilIbu = '/modul-ibu/profil';

  // Pemeriksaan Dokter - list semua kunjungan (BARU)
  static const String pemeriksaanDokterTrimester1All =
      '/modul-ibu/pemeriksaan-dokter-trimester-1/all';
  static const String pemeriksaanDokterTrimester3All =
      '/modul-ibu/pemeriksaan-dokter-trimester-3/all';

  // Persiapan Melahirkan (checklist ibu)
  static const String persiapanMelahirkan =
      '/modul-ibu/persiapan-melahirkan/me';
  static const String savePersiapanMelahirkan =
      '/modul-ibu/persiapan-melahirkan';
  // Checklist Proses Melahirkan (checklist pemahaman ibu)
  static const String checklistProsesMelahirkan =
      '/modul-ibu/proses-melahirkan/me';
  static const String saveChecklistProsesMelahirkan =
      '/modul-ibu/proses-melahirkan';

  static const String riwayatProsesMelahirkan =
      '/modul-ibu/riwayat-proses-melahirkan/me';
  static const String rujukanIbu = '/modul-ibu/rujukan';
  static String get ringkasanPersalinan =>
      '$baseUrl/modul-ibu/ringkasan-persalinan/me';

  // Catatan Pelayanan Kehamilan unified (tabel baru untuk mobile)
  // ?trimester=1 opsional (1/2/3). Kosong = semua trimester.
  static const String catatanPelayananKehamilanMe =
      '/modul-ibu/catatan-pelayanan-kehamilan/me';
  // static String catatanPelayananT1(
  //   int kehamilanId,
  // ) =>
  //     // '$baseUrl/modul-ibu/catatan-pelayanan-t1?kehamilan_id=$kehamilanId';
  //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=1';
  // static String catatanPelayananT2(
  //   int kehamilanId,
  // ) =>
  //     '$baseUrl/modul-ibu/catatan-pelayanan-t2?kehamilan_id=$kehamilanId';
  // static String catatanPelayananT3(
  //   int kehamilanId,
  // ) =>
  //     // '$baseUrl/modul-ibu/catatan-pelayanan-t3?kehamilan_id=$kehamilanId';
  //     '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=3';

  static String get catatanPelayananT1 =>
      '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=1';

  static String get catatanPelayananT3 =>
      '$baseUrl/modul-ibu/pemeriksaan-dokter-trimester-3/all';
      // '$baseUrl/modul-ibu/catatan-pelayanan-kehamilan/me?trimester=3';

  /*
   *
   * 
   * 
   * 
   * 
   * 
  */

  // MODUL ANAK ==================================================
  // Modul Anak - Data Ibu & Anak
  // Tumbuh Kembang
  static const String ibuAnak = '/ibu/anak';
  static const String ibuLembarPemantauan = '/ibu/lembar-pemantauan';
  static const String ibuLembarPemantauanRentangUsia =
      '/ibu/lembar-pemantauan/rentang-usia';
  static const String ibuLembarPemantauanKategori =
      '/ibu/lembar-pemantauan/kategori-tanda-sakit';
  static const String ibuWarnaTinja = '/ibu/warna-tinja';
  // Pencarian
  static const String anakSearch = '/anak/search';
  static String anakById(int anakId) => '/anak/$anakId';
  // Pertumbuhan dan Standar
  static const String pertumbuhan = '/pertumbuhan';
  static String riwayatPertumbuhanByAnakId(int anakId) =>
      '/ibu/pertumbuhan/anak/$anakId';
  // Informasi Umum
  static const String masterStandar = '/master-standar';
  static const String edukasiInformasiUmum = '/edukasi-informasi-umum';

  static String edukasiInformasiUmumById(int id) =>
      '/edukasi-informasi-umum/$id';

  static const String informasiUmum = edukasiInformasiUmum;

  static String informasiUmumById(int id) => edukasiInformasiUmumById(id);
  // Perawatan (Milestone/Perkembangan)
  static const String ibuKategoriCapaian = '/ibu/kategori-capaian';
  static String ibuKategoriCapaianByRentangUsia(String rentangUsia) =>
      '/ibu/kategori-capaian/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
  static const String ibuPerawatan = '/ibu/perawatan';
  static String ibuPerawatanById(int id) => '/ibu/perawatan/$id';
  static String ibuPerawatanByAnakId(int anakId) =>
      '/ibu/perawatan/anak/$anakId';
  static String ibuPerawatanByAnakIdAndRentangUsia(
          int anakId, String rentangUsia) =>
      '/ibu/perawatan/anak/$anakId/rentang-usia/${Uri.encodeComponent(rentangUsia)}';
  static const String ibuKeluhanAnak = '/ibu/keluhan-anak';

  // MODUL EDUKASI ==================================================
  // Edukasi Pola Asuh
  static const String edukasiPolaAsuh = '/edukasi-pola-asuh';
  static String edukasiPolaAsuhById(int id) => '/edukasi-pola-asuh/$id';

  // Edukasi Perawatan Anak
  static const String edukasiPerawatanAnak = '/edukasi-perawatan-anak';
  static String edukasiPerawatanAnakById(int id) =>
      '/edukasi-perawatan-anak/$id';
  static String get edukasiASI => '$baseUrl/edukasi-menyusui-asi';
  static String get edukasiIMD => '$baseUrl/edukasi-imd';
  static String get edukasiKesehatanMental =>
      '$baseUrl/edukasi-kesehatan-mental';
  // static String get edukasiNifas => '$baseUrl/edukasi-nifas';
  static String get edukasiNifas => '$baseUrl/edukasi-setelah-melahirkan';
  static String get edukasiTandaMelahirkan =>
      '$baseUrl/edukasi-tanda-melahirkan';
  static String edukasiTrimester(
    String trimester,
  ) =>
      '$baseUrl/edukasi-trimester/$trimester';
  static String edukasiTrimesterKategori(
    String trimester,
    String kategori,
  ) =>
      '$baseUrl/edukasi-trimester/$trimester/$kategori';
}