class ChecklistPemantauanIbuNifasModel {
  final int kehamilanId;
  final int hariNifas;

  final bool pemeriksaanNifas;
  final bool konsumsiVitaminA;
  final bool pemenuhanGizi;
  final bool demamLebih38;
  final bool sakitKepala;
  final bool pandanganKabur;
  final bool nyeriUluHati;
  final bool masalahKesehatanJiwa;

  final bool jantungBerdebar;
  final bool cairanJalanLahir;
  final bool napasPendek;
  final bool payudaraBermasalah;
  final bool gangguanBak;
  final bool kelaminBermasalah;
  final bool darahNifasBerbau;
  final bool pendarahanBerat;
  final bool keputihan;

  final String keluhan;

  ChecklistPemantauanIbuNifasModel({
    required this.kehamilanId,
    required this.hariNifas,
    required this.pemeriksaanNifas,
    required this.konsumsiVitaminA,
    required this.pemenuhanGizi,
    required this.demamLebih38,
    required this.sakitKepala,
    required this.pandanganKabur,
    required this.nyeriUluHati,
    required this.masalahKesehatanJiwa,
    required this.jantungBerdebar,
    required this.cairanJalanLahir,
    required this.napasPendek,
    required this.payudaraBermasalah,
    required this.gangguanBak,
    required this.kelaminBermasalah,
    required this.darahNifasBerbau,
    required this.pendarahanBerat,
    required this.keputihan,

    required this.keluhan,
  });

  Map<String, dynamic> toJson() {
    return {
      'kehamilan_id': kehamilanId,
      'hari_nifas': hariNifas,
      'pemeriksaan_nifas': pemeriksaanNifas,
      'konsumsi_vitamin_a': konsumsiVitaminA,
      'pemenuhan_gizi': pemenuhanGizi,
      'demam_lebih_38': demamLebih38,
      'sakit_kepala': sakitKepala,
      'pandangan_kabur': pandanganKabur,
      'nyeri_ulu_hati': nyeriUluHati,
      'masalah_kesehatan_jiwa': masalahKesehatanJiwa,
      'jantung_berdebar': jantungBerdebar,
      'cairan_jalan_lahir': cairanJalanLahir,
      'napas_pendek': napasPendek,
      'payudara_bermasalah': payudaraBermasalah,
      'gangguan_bak': gangguanBak,
      'kelamin_bermasalah': kelaminBermasalah,
      'darah_nifas_berbau': darahNifasBerbau,
      'pendarahan_berat': pendarahanBerat,
      'keputihan': keputihan,

      'keluhan': keluhan,
    };
  }
}