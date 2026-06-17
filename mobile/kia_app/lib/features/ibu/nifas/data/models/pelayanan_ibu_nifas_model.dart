class PelayananIbuNifasModel {
  final int id;
  final int kehamilanId;
  final String kunjunganKe;
  final DateTime? tanggalPeriksa;
  final String tandaVitalTekananDarah;
  final double? tandaVitalSuhuTubuh;
  final String pelayananInvolusiUteri;
  final String pelayananCairanPervaginam;
  final String pelayananPeriksaJalanLahir;
  final String pelayananPeriksaPayudara;
  final String pelayananAsiEksklusif;
  final bool pemberianKapsulVitaminA;
  final int? pemberianTabletTambahDarahJumlah;
  final String pelayananSkriningDepresiNifas;
  final String pelayananKontrasepsiPascaPersalinan;
  final String pelayananPenangananRisikoMalaria;
  final String komplikasiNifas;
  final String tindakanSaran;
  final String namaPemeriksaParaf;
  final DateTime? tanggalKembali;

  PelayananIbuNifasModel({
    required this.id,
    required this.kehamilanId,
    required this.kunjunganKe,
    this.tanggalPeriksa,
    required this.tandaVitalTekananDarah,
    this.tandaVitalSuhuTubuh,
    required this.pelayananInvolusiUteri,
    required this.pelayananCairanPervaginam,
    required this.pelayananPeriksaJalanLahir,
    required this.pelayananPeriksaPayudara,
    required this.pelayananAsiEksklusif,
    required this.pemberianKapsulVitaminA,
    this.pemberianTabletTambahDarahJumlah,
    required this.pelayananSkriningDepresiNifas,
    required this.pelayananKontrasepsiPascaPersalinan,
    required this.pelayananPenangananRisikoMalaria,
    required this.komplikasiNifas,
    required this.tindakanSaran,
    required this.namaPemeriksaParaf,
    this.tanggalKembali,
  });

  factory PelayananIbuNifasModel.fromJson(Map<String, dynamic> json) {
    return PelayananIbuNifasModel(
      id: json['id'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      kunjunganKe: json['kunjungan_ke'] ?? '',
      tanggalPeriksa: json['tanggal_periksa'] != null
          ? DateTime.tryParse(json['tanggal_periksa'])
          : null,
      tandaVitalTekananDarah:
          json['tanda_vital_tekanan_darah'] ?? '',
      tandaVitalSuhuTubuh:
          (json['tanda_vital_suhu_tubuh'] as num?)?.toDouble(),
      pelayananInvolusiUteri:
          json['pelayanan_involusi_uteri'] ?? '',
      pelayananCairanPervaginam:
          json['pelayanan_cairan_pervaginam'] ?? '',
      pelayananPeriksaJalanLahir:
          json['pelayanan_periksa_jalan_lahir'] ?? '',
      pelayananPeriksaPayudara:
          json['pelayanan_periksa_payudara'] ?? '',
      pelayananAsiEksklusif:
          json['pelayanan_asi_eksklusif'] ?? '',
      pemberianKapsulVitaminA:
          json['pemberian_kapsul_vitamin_a'] ?? false,
      pemberianTabletTambahDarahJumlah:
          json['pemberian_tablet_tambah_darah_jumlah'],
      pelayananSkriningDepresiNifas:
          json['pelayanan_skrining_depresi_nifas'] ?? '',
      pelayananKontrasepsiPascaPersalinan:
          json['pelayanan_kontrasepsi_pasca_persalinan'] ?? '',
      pelayananPenangananRisikoMalaria:
          json['pelayanan_penanganan_risiko_malaria'] ?? '',
      komplikasiNifas:
          json['komplikasi_nifas'] ?? '',
      tindakanSaran:
          json['tindakan_saran'] ?? '',
      namaPemeriksaParaf:
          json['nama_pemeriksa_paraf'] ?? '',
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.tryParse(json['tanggal_kembali'])
          : null,
    );
  }
}