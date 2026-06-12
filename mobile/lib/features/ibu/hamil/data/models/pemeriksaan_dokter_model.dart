class PemeriksaanDokterTrimester1Model {
  final int id;
  final int kehamilanId;
  final String namaDokter;
  final String? tanggalPeriksa;
  final String konsepAnamnesaPemeriksaan;

  final String fisikKonjungtiva;
  final String fisikSklera;
  final String fisikKulit;
  final String fisikLeher;
  final String fisikGigiMulut;
  final String fisikTht;
  final String fisikDadaJantung;
  final String fisikDadaParu;
  final String fisikPerut;
  final String fisikTungkai;

  final String? hpht;
  final String keteraturanHaid;
  final int? umurHamilHphtMinggu;
  final String? hplBerdasarkanHpht;
  final int? umurHamilUsgMinggu;
  final String? hplBerdasarkanUsg;

  final String usgJumlahGs;
  final double? usgDiameterGsCm;
  final int? usgDiameterGsMinggu;
  final int? usgDiameterGsHari;
  final String usgJumlahBayi;
  final double? usgCrlCm;
  final int? usgCrlMinggu;
  final int? usgCrlHari;
  final String usgLetakProdukKehamilan;
  final String usgPulsasiJantung;
  final String usgKecurigaanTemuanAbnormal;
  final String usgKeteranganTemuanAbnormal;

  PemeriksaanDokterTrimester1Model({
    required this.id,
    required this.kehamilanId,
    required this.namaDokter,
    required this.tanggalPeriksa,
    required this.konsepAnamnesaPemeriksaan,
    required this.fisikKonjungtiva,
    required this.fisikSklera,
    required this.fisikKulit,
    required this.fisikLeher,
    required this.fisikGigiMulut,
    required this.fisikTht,
    required this.fisikDadaJantung,
    required this.fisikDadaParu,
    required this.fisikPerut,
    required this.fisikTungkai,
    required this.hpht,
    required this.keteraturanHaid,
    required this.umurHamilHphtMinggu,
    required this.hplBerdasarkanHpht,
    required this.umurHamilUsgMinggu,
    required this.hplBerdasarkanUsg,
    required this.usgJumlahGs,
    required this.usgDiameterGsCm,
    required this.usgDiameterGsMinggu,
    required this.usgDiameterGsHari,
    required this.usgJumlahBayi,
    required this.usgCrlCm,
    required this.usgCrlMinggu,
    required this.usgCrlHari,
    required this.usgLetakProdukKehamilan,
    required this.usgPulsasiJantung,
    required this.usgKecurigaanTemuanAbnormal,
    required this.usgKeteranganTemuanAbnormal,
  });

  factory PemeriksaanDokterTrimester1Model.fromJson(Map<String, dynamic> json) {
    String str(dynamic value) => value?.toString() ?? '';
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PemeriksaanDokterTrimester1Model(
      id: json['id_trimester_1'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      namaDokter: str(json['nama_dokter']),
      tanggalPeriksa: json['tanggal_periksa']?.toString(),
      konsepAnamnesaPemeriksaan: str(json['konsep_anamnesa_pemeriksaan']),
      fisikKonjungtiva: str(json['fisik_konjungtiva']),
      fisikSklera: str(json['fisik_sklera']),
      fisikKulit: str(json['fisik_kulit']),
      fisikLeher: str(json['fisik_leher']),
      fisikGigiMulut: str(json['fisik_gigi_mulut']),
      fisikTht: str(json['fisik_tht']),
      fisikDadaJantung: str(json['fisik_dada_jantung']),
      fisikDadaParu: str(json['fisik_dada_paru']),
      fisikPerut: str(json['fisik_perut']),
      fisikTungkai: str(json['fisik_tungkai']),
      hpht: json['hpht']?.toString(),
      keteraturanHaid: str(json['keteraturan_haid']),
      umurHamilHphtMinggu: toInt(json['umur_hamil_hpht_minggu']),
      hplBerdasarkanHpht: json['hpl_berdasarkan_hpht']?.toString(),
      umurHamilUsgMinggu: toInt(json['umur_hamil_usg_minggu']),
      hplBerdasarkanUsg: json['hpl_berdasarkan_usg']?.toString(),
      usgJumlahGs: str(json['usg_jumlah_gs']),
      usgDiameterGsCm: toDouble(json['usg_diameter_gs_cm']),
      usgDiameterGsMinggu: toInt(json['usg_diameter_gs_minggu']),
      usgDiameterGsHari: toInt(json['usg_diameter_gs_hari']),
      usgJumlahBayi: str(json['usg_jumlah_bayi']),
      usgCrlCm: toDouble(json['usg_crl_cm']),
      usgCrlMinggu: toInt(json['usg_crl_minggu']),
      usgCrlHari: toInt(json['usg_crl_hari']),
      usgLetakProdukKehamilan: str(json['usg_letak_produk_kehamilan']),
      usgPulsasiJantung: str(json['usg_pulsasi_jantung']),
      usgKecurigaanTemuanAbnormal:
          str(json['usg_kecurigaan_temuan_abnormal']),
      usgKeteranganTemuanAbnormal:
          str(json['usg_keterangan_temuan_abnormal']),
    );
  }
}

class PemeriksaanDokterTrimester3Model {
  final int id;
  final int kehamilanId;
  final String namaDokter;
  final String? tanggalPeriksa;
  final String konsepAnamnesaPemeriksaan;

  final String fisikKonjungtiva;
  final String fisikSklera;
  final String fisikKulit;
  final String fisikLeher;
  final String fisikGigiMulut;
  final String fisikTht;
  final String fisikDadaJantung;
  final String fisikDadaParu;
  final String fisikPerut;
  final String fisikTungkai;

  final String usgTrimester3Dilakukan;
  final int? ukBerdasarkanUsgTrimester1Minggu;
  final int? ukBerdasarkanHphtMinggu;
  final int? ukBerdasarkanBiometriUsgTrimester3Minggu;
  final String selisihUk3MingguAtauLebih;

  final String usgJumlahBayi;
  final String usgLetakBayi;
  final String usgPresentasiBayi;
  final String usgKeadaanBayi;
  final int? usgDjjNilai;
  final String usgDjjStatus;
  final String usgLokasiPlasenta;
  final double? usgCairanKetubanSdpCm;
  final String usgCairanKetubanStatus;

  final double? biometriBpdCm;
  final int? biometriBpdMinggu;
  final double? biometriHcCm;
  final int? biometriHcMinggu;
  final double? biometriAcCm;
  final int? biometriAcMinggu;
  final double? biometriFlCm;
  final int? biometriFlMinggu;
  final int? biometriEfwTbjGram;
  final int? biometriEfwTbjMinggu;

  final String usgKecurigaanTemuanAbnormal;
  final String usgKeteranganTemuanAbnormal;

  PemeriksaanDokterTrimester3Model({
    required this.id,
    required this.kehamilanId,
    required this.namaDokter,
    required this.tanggalPeriksa,
    required this.konsepAnamnesaPemeriksaan,
    required this.fisikKonjungtiva,
    required this.fisikSklera,
    required this.fisikKulit,
    required this.fisikLeher,
    required this.fisikGigiMulut,
    required this.fisikTht,
    required this.fisikDadaJantung,
    required this.fisikDadaParu,
    required this.fisikPerut,
    required this.fisikTungkai,
    required this.usgTrimester3Dilakukan,
    required this.ukBerdasarkanUsgTrimester1Minggu,
    required this.ukBerdasarkanHphtMinggu,
    required this.ukBerdasarkanBiometriUsgTrimester3Minggu,
    required this.selisihUk3MingguAtauLebih,
    required this.usgJumlahBayi,
    required this.usgLetakBayi,
    required this.usgPresentasiBayi,
    required this.usgKeadaanBayi,
    required this.usgDjjNilai,
    required this.usgDjjStatus,
    required this.usgLokasiPlasenta,
    required this.usgCairanKetubanSdpCm,
    required this.usgCairanKetubanStatus,
    required this.biometriBpdCm,
    required this.biometriBpdMinggu,
    required this.biometriHcCm,
    required this.biometriHcMinggu,
    required this.biometriAcCm,
    required this.biometriAcMinggu,
    required this.biometriFlCm,
    required this.biometriFlMinggu,
    required this.biometriEfwTbjGram,
    required this.biometriEfwTbjMinggu,
    required this.usgKecurigaanTemuanAbnormal,
    required this.usgKeteranganTemuanAbnormal,
  });

  factory PemeriksaanDokterTrimester3Model.fromJson(Map<String, dynamic> json) {
    String str(dynamic value) => value?.toString() ?? '';
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PemeriksaanDokterTrimester3Model(
      id: json['id_trimester_3'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      namaDokter: str(json['nama_dokter']),
      tanggalPeriksa: json['tanggal_periksa']?.toString(),
      konsepAnamnesaPemeriksaan: str(json['konsep_anamnesa_pemeriksaan']),
      fisikKonjungtiva: str(json['fisik_konjungtiva']),
      fisikSklera: str(json['fisik_sklera']),
      fisikKulit: str(json['fisik_kulit']),
      fisikLeher: str(json['fisik_leher']),
      fisikGigiMulut: str(json['fisik_gigi_mulut']),
      fisikTht: str(json['fisik_tht']),
      fisikDadaJantung: str(json['fisik_dada_jantung']),
      fisikDadaParu: str(json['fisik_dada_paru']),
      fisikPerut: str(json['fisik_perut']),
      fisikTungkai: str(json['fisik_tungkai']),
      usgTrimester3Dilakukan: str(json['usg_trimester_3_dilakukan']),
      ukBerdasarkanUsgTrimester1Minggu:
          toInt(json['uk_berdasarkan_usg_trimester_1_minggu']),
      ukBerdasarkanHphtMinggu: toInt(json['uk_berdasarkan_hpht_minggu']),
      ukBerdasarkanBiometriUsgTrimester3Minggu:
          toInt(json['uk_berdasarkan_biometri_usg_trimester_3_minggu']),
      selisihUk3MingguAtauLebih:
          str(json['selisih_uk_3_minggu_atau_lebih']),
      usgJumlahBayi: str(json['usg_jumlah_bayi']),
      usgLetakBayi: str(json['usg_letak_bayi']),
      usgPresentasiBayi: str(json['usg_presentasi_bayi']),
      usgKeadaanBayi: str(json['usg_keadaan_bayi']),
      usgDjjNilai: toInt(json['usg_djj_nilai']),
      usgDjjStatus: str(json['usg_djj_status']),
      usgLokasiPlasenta: str(json['usg_lokasi_plasenta']),
      usgCairanKetubanSdpCm: toDouble(json['usg_cairan_ketuban_sdp_cm']),
      usgCairanKetubanStatus: str(json['usg_cairan_ketuban_status']),
      biometriBpdCm: toDouble(json['biometri_bpd_cm']),
      biometriBpdMinggu: toInt(json['biometri_bpd_minggu']),
      biometriHcCm: toDouble(json['biometri_hc_cm']),
      biometriHcMinggu: toInt(json['biometri_hc_minggu']),
      biometriAcCm: toDouble(json['biometri_ac_cm']),
      biometriAcMinggu: toInt(json['biometri_ac_minggu']),
      biometriFlCm: toDouble(json['biometri_fl_cm']),
      biometriFlMinggu: toInt(json['biometri_fl_minggu']),
      biometriEfwTbjGram: toInt(json['biometri_efw_tbj_gram']),
      biometriEfwTbjMinggu: toInt(json['biometri_efw_tbj_minggu']),
      usgKecurigaanTemuanAbnormal:
          str(json['usg_kecurigaan_temuan_abnormal']),
      usgKeteranganTemuanAbnormal:
          str(json['usg_keterangan_temuan_abnormal']),
    );
  }
}