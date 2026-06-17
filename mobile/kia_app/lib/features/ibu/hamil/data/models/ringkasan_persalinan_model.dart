class RingkasanPersalinanModel {

  final int id;

  final int kehamilanId;

  final String tanggalMelahirkan;
  final String pukulMelahirkan;

  final int umurKehamilanMinggu;

  final String penolongProsesMelahirkan;
  final String caraMelahirkan;

  final String keadaanIbu;

  final String bayiJenisKelamin;

  final int bayiBeratLahirGram;
  final int bayiPanjangBadanCm;
  final int bayiLingkarKepalaCm;

  final bool asuhanImd1JamPertama;
  final bool asuhanSuntikanVitaminK1;
  final bool asuhanSalepMataAntibiotika;
  final bool asuhanImunisasiHb0;

  final String keteranganTambahanBayi;

  RingkasanPersalinanModel({
    required this.id,
    required this.kehamilanId,
    required this.tanggalMelahirkan,
    required this.pukulMelahirkan,
    required this.umurKehamilanMinggu,
    required this.penolongProsesMelahirkan,
    required this.caraMelahirkan,
    required this.keadaanIbu,
    required this.bayiJenisKelamin,
    required this.bayiBeratLahirGram,
    required this.bayiPanjangBadanCm,
    required this.bayiLingkarKepalaCm,
    required this.asuhanImd1JamPertama,
    required this.asuhanSuntikanVitaminK1,
    required this.asuhanSalepMataAntibiotika,
    required this.asuhanImunisasiHb0,
    required this.keteranganTambahanBayi,
  });

  factory RingkasanPersalinanModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return RingkasanPersalinanModel(

      id: json['id'] ?? 0,

      kehamilanId:
          json['kehamilan_id'] ?? 0,

      tanggalMelahirkan:
          json['tanggal_melahirkan'] ?? '',

      pukulMelahirkan:
          json['pukul_melahirkan'] ?? '',

      umurKehamilanMinggu:
          json['umur_kehamilan_minggu'] ?? 0,

      penolongProsesMelahirkan:
          json['penolong_proses_melahirkan'] ?? '',

      caraMelahirkan:
          json['cara_melahirkan'] ?? '',

      keadaanIbu:
          json['keadaan_ibu'] ?? '',

      bayiJenisKelamin:
          json['bayi_jenis_kelamin'] ?? '',

      bayiBeratLahirGram:
          json['bayi_berat_lahir_gram'] ?? 0,

      bayiPanjangBadanCm:
          json['bayi_panjang_badan_cm'] ?? 0,

      bayiLingkarKepalaCm:
          json['bayi_lingkar_kepala_cm'] ?? 0,

      asuhanImd1JamPertama:
          json['asuhan_imd_1_jam_pertama'] ?? false,

      asuhanSuntikanVitaminK1:
          json['asuhan_suntikan_vitamin_k1'] ?? false,

      asuhanSalepMataAntibiotika:
          json['asuhan_salep_mata_antibiotika'] ?? false,

      asuhanImunisasiHb0:
          json['asuhan_imunisasi_hb0'] ?? false,

      keteranganTambahanBayi:
          json['keterangan_tambahan_bayi'] ?? '',
    );
  }
}