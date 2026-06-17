class PemeriksaanKehamilanModel {
  final int idPeriksa;
  final int kehamilanId;
  final String trimester;
  final int kunjunganKe;
  final String? tanggalPeriksa;
  final String tempatPeriksa;

  final double? beratBadan;
  final double? tinggiBadan;
  final double? lingkarLenganAtas;
  final String tekananDarah;
  final double? tinggiRahim;
  final String letakDenyutJantungBayi;

  final String statusImunisasiTetanus;
  final String konseling;
  final String skriningDokter;
  final int? tabletTambahDarah;

  final double? tesLabHb;
  final String tesGolonganDarah;
  final String tesLabProteinUrine;
  final int? tesLabGulaDarah;

  final String usg;
  final String tripelEliminasi;
  final String tataLaksanaKasus;

  PemeriksaanKehamilanModel({
    required this.idPeriksa,
    required this.kehamilanId,
    required this.trimester,
    required this.kunjunganKe,
    required this.tanggalPeriksa,
    required this.tempatPeriksa,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.lingkarLenganAtas,
    required this.tekananDarah,
    required this.tinggiRahim,
    required this.letakDenyutJantungBayi,
    required this.statusImunisasiTetanus,
    required this.konseling,
    required this.skriningDokter,
    required this.tabletTambahDarah,
    required this.tesLabHb,
    required this.tesGolonganDarah,
    required this.tesLabProteinUrine,
    required this.tesLabGulaDarah,
    required this.usg,
    required this.tripelEliminasi,
    required this.tataLaksanaKasus,
  });

  factory PemeriksaanKehamilanModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    String str(dynamic value) => value?.toString() ?? '';

    return PemeriksaanKehamilanModel(
      idPeriksa: json['id_periksa'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      trimester: str(json['trimester']),
      kunjunganKe: json['kunjungan_ke'] ?? 0,
      tanggalPeriksa: json['tanggal_periksa']?.toString(),
      tempatPeriksa: str(json['tempat_periksa']),
      beratBadan: toDouble(json['berat_badan']),
      tinggiBadan: toDouble(json['tinggi_badan']),
      lingkarLenganAtas: toDouble(json['lingkar_lengan_atas']),
      tekananDarah: str(json['tekanan_darah']),
      tinggiRahim: toDouble(json['tinggi_rahim']),
      letakDenyutJantungBayi: str(json['letak_denyut_jantung_bayi']),
      statusImunisasiTetanus: str(json['status_imunisasi_tetanus']),
      konseling: str(json['konseling']),
      skriningDokter: str(json['skrining_dokter']),
      tabletTambahDarah: toInt(json['tablet_tambah_darah']),
      tesLabHb: toDouble(json['tes_lab_hb']),
      tesGolonganDarah: str(json['tes_golongan_darah']),
      tesLabProteinUrine: str(json['tes_lab_protein_urine']),
      tesLabGulaDarah: toInt(json['tes_lab_gula_darah']),
      usg: str(json['usg']),
      tripelEliminasi: str(json['tripel_eliminasi']),
      tataLaksanaKasus: str(json['tata_laksana_kasus']),
    );
  }
}