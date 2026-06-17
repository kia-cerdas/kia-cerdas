class SyncPayloadDto {
  // Kelompok Wilayah & Akun
  final List<Map<String, dynamic>> desa;
  final List<Map<String, dynamic>> puskesmas;
  final List<Map<String, dynamic>> posyandu;
  final List<Map<String, dynamic>> kartuKeluarga;
  final List<Map<String, dynamic>> penduduk;
  final List<Map<String, dynamic>> pengguna;
  final List<Map<String, dynamic>> bidan;
  final List<Map<String, dynamic>> kader;

  // Kelompok Ibu & Kehamilan
  final List<Map<String, dynamic>> ibu;
  final List<Map<String, dynamic>> kehamilan;
  final List<Map<String, dynamic>> pemeriksaanKehamilan;
  final List<Map<String, dynamic>> evaluasiKesehatanIbu;
  final List<Map<String, dynamic>> pemeriksaanDokterTrimester1;
  final List<Map<String, dynamic>> pemeriksaanDokterTrimester3;
  final List<Map<String, dynamic>> pemeriksaanLanjutanTrimester3;
  final List<Map<String, dynamic>> catatanPelayananTrimester1;
  final List<Map<String, dynamic>> catatanPelayananTrimester2;
  final List<Map<String, dynamic>> catatanPelayananTrimester3;
  final List<Map<String, dynamic>> skriningPreeklampsia;
  final List<Map<String, dynamic>> grafikEvaluasiKehamilan;
  final List<Map<String, dynamic>> grafikPeningkatanBb;
  final List<Map<String, dynamic>> penjelasanHasilGrafik;
  final List<Map<String, dynamic>> rencanaPersalinan;
  final List<Map<String, dynamic>> ringkasanPelayananPersalinan;
  final List<Map<String, dynamic>> riwayatProsesMelahirkan;
  final List<Map<String, dynamic>> keteranganLahir;
  final List<Map<String, dynamic>> pelayananIbuNifas;
  final List<Map<String, dynamic>> catatanPelayananNifas;
  final List<Map<String, dynamic>> checklistPemantauanIbuNifas;
  final List<Map<String, dynamic>> riwayatKehamilanLalu;
  final List<Map<String, dynamic>> rujukan;
  final List<Map<String, dynamic>> logTtdMms;

  // Kelompok Anak & Imunisasi
  final List<Map<String, dynamic>> anak;
  final List<Map<String, dynamic>> keluhanAnak;
  final List<Map<String, dynamic>> periksaGigi;
  final List<Map<String, dynamic>> pengukuranLila;
  final List<Map<String, dynamic>> catatanPertumbuhan;
  final List<Map<String, dynamic>> jadwalLayanan;
  final List<Map<String, dynamic>> jadwalImunisasiAnak;
  final List<Map<String, dynamic>> requestPerubahanImunisasi;

  SyncPayloadDto({
    required this.desa, required this.puskesmas, required this.posyandu,
    required this.kartuKeluarga, required this.penduduk, required this.pengguna,
    required this.bidan, required this.kader, required this.ibu,
    required this.kehamilan, required this.pemeriksaanKehamilan, required this.evaluasiKesehatanIbu,
    required this.pemeriksaanDokterTrimester1, required this.pemeriksaanDokterTrimester3, required this.pemeriksaanLanjutanTrimester3,
    required this.catatanPelayananTrimester1, required this.catatanPelayananTrimester2, required this.catatanPelayananTrimester3,
    required this.skriningPreeklampsia, required this.grafikEvaluasiKehamilan, required this.grafikPeningkatanBb,
    required this.penjelasanHasilGrafik, required this.rencanaPersalinan, required this.ringkasanPelayananPersalinan,
    required this.riwayatProsesMelahirkan, required this.keteranganLahir, required this.pelayananIbuNifas,
    required this.catatanPelayananNifas, required this.checklistPemantauanIbuNifas, required this.riwayatKehamilanLalu,
    required this.rujukan, required this.logTtdMms, required this.anak,
    required this.keluhanAnak, required this.periksaGigi, required this.pengukuranLila,
    required this.catatanPertumbuhan, required this.jadwalLayanan, required this.jadwalImunisasiAnak,
    required this.requestPerubahanImunisasi,
  });

  // Getter untuk memeriksa apakah ada data offline baru di salah satu tabel dinamis
  bool get isEmpty =>
      desa.isEmpty && puskesmas.isEmpty && posyandu.isEmpty && kartuKeluarga.isEmpty &&
      penduduk.isEmpty && pengguna.isEmpty && bidan.isEmpty && kader.isEmpty &&
      ibu.isEmpty && kehamilan.isEmpty && pemeriksaanKehamilan.isEmpty && evaluasiKesehatanIbu.isEmpty &&
      pemeriksaanDokterTrimester1.isEmpty && pemeriksaanDokterTrimester3.isEmpty && pemeriksaanLanjutanTrimester3.isEmpty &&
      catatanPelayananTrimester1.isEmpty && catatanPelayananTrimester2.isEmpty && catatanPelayananTrimester3.isEmpty &&
      skriningPreeklampsia.isEmpty && grafikEvaluasiKehamilan.isEmpty && grafikPeningkatanBb.isEmpty &&
      penjelasanHasilGrafik.isEmpty && rencanaPersalinan.isEmpty && ringkasanPelayananPersalinan.isEmpty &&
      riwayatProsesMelahirkan.isEmpty && keteranganLahir.isEmpty && pelayananIbuNifas.isEmpty &&
      catatanPelayananNifas.isEmpty && checklistPemantauanIbuNifas.isEmpty && riwayatKehamilanLalu.isEmpty &&
      rujukan.isEmpty && logTtdMms.isEmpty && anak.isEmpty && keluhanAnak.isEmpty &&
      periksaGigi.isEmpty && pengukuranLila.isEmpty && catatanPertumbuhan.isEmpty &&
      jadwalLayanan.isEmpty && jadwalImunisasiAnak.isEmpty && requestPerubahanImunisasi.isEmpty;

  // Bungkus seluruh list data kotor menjadi satu Map JSON besar
  Map<String, dynamic> toJson() {
    return {
      'desa': desa, 'puskesmas': puskesmas, 'posyandu': posyandu,
      'kartu_keluarga': kartuKeluarga, 'penduduk': penduduk, 'pengguna': pengguna,
      'bidan': bidan, 'kader': kader, 'ibu': ibu, 'kehamilan': kehamilan,
      'pemeriksaan_kehamilan': pemeriksaanKehamilan, 'evaluasi_kesehatan_ibu': evaluasiKesehatanIbu,
      'pemeriksaan_dokter_trimester_1': pemeriksaanDokterTrimester1, 'pemeriksaan_dokter_trimester_3': pemeriksaanDokterTrimester3,
      'pemeriksaan_lanjutan_trimester_3': pemeriksaanLanjutanTrimester3, 'catatan_pelayanan_trimester_1': catatanPelayananTrimester1,
      'catatan_pelayanan_trimester_2': catatanPelayananTrimester2, 'catatan_pelayanan_trimester_3': catatanPelayananTrimester3,
      'skrining_preeklampsia': skriningPreeklampsia, 'grafik_evaluasi_kehamilan': grafikEvaluasiKehamilan,
      'grafik_peningkatan_bb': grafikPeningkatanBb, 'penjelasan_hasil_grafik': penjelasanHasilGrafik,
      'rencana_persalinan': rencanaPersalinan, 'ringkasan_pelayanan_persalinan': ringkasanPelayananPersalinan,
      'riwayat_proses_melahirkan': riwayatProsesMelahirkan, 'keterangan_lahir': keteranganLahir,
      'pelayanan_ibu_nifas': pelayananIbuNifas, 'catatan_pelayanan_nifas': catatanPelayananNifas,
      'checklist_pemantauan_ibu_nifas': checklistPemantauanIbuNifas, 'riwayat_kehamilan_lalu': riwayatKehamilanLalu,
      'rujukan': rujukan, 'log_ttd_mms': logTtdMms, 'anak': anak, 'keluhan_anak': keluhanAnak,
      'periksa_gigi': periksaGigi, 'pengukuran_lila': pengukuranLila, 'catatan_pertumbuhan': catatanPertumbuhan,
      'jadwal_layanan': jadwalLayanan, 'jadwal_imunisasi_anak': jadwalImunisasiAnak, 'request_perubahan_imunisasi': requestPerubahanImunisasi,
    };
  }
}