class PertumbuhanModel {
  final int id;
  final int anakId;
  final String tglUkur;
  final int usiaUkurBulan;
  final double beratBadan;
  final double tinggiBadan;
  final double lingkarKepala;
  final double imt;
  final String statusBBU;
  final String statusTBU;
  final String statusIMTU;
  final String statusBBTB;
  final String statusLKU;
  final String statusKMSNaik;
  final String statusKMSBGM;
  final String statusKMSInfo;
  final String catatanNakes;
  final double zScoreBBU;
  final double zScoreTBU;
  final double zScoreIMTU;
  final double zScoreBBTB;
  final double zScoreLKU;

  const PertumbuhanModel({
    required this.id,
    required this.anakId,
    required this.tglUkur,
    required this.usiaUkurBulan,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.lingkarKepala,
    required this.imt,
    required this.statusBBU,
    required this.statusTBU,
    required this.statusIMTU,
    required this.statusBBTB,
    required this.statusLKU,
    required this.statusKMSNaik,
    required this.statusKMSBGM,
    required this.statusKMSInfo,
    required this.catatanNakes,
    this.zScoreBBU = 0,
    this.zScoreTBU = 0,
    this.zScoreIMTU = 0,
    this.zScoreBBTB = 0,
    this.zScoreLKU = 0,
  });

  factory PertumbuhanModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return PertumbuhanModel(
      id: toInt(json['id']),
      anakId: toInt(json['anak_id']),
      tglUkur: (json['tgl_ukur'] ?? '').toString(),
      usiaUkurBulan: toInt(json['usia_ukur_bulan']),
      beratBadan: toDouble(json['berat_badan']),
      tinggiBadan: toDouble(json['tinggi_badan']),
      lingkarKepala: toDouble(json['lingkar_kepala']),
      imt: toDouble(json['imt']),
      statusBBU: (json['status_bb_u'] ?? '-').toString(),
      statusTBU: (json['status_tb_u'] ?? '-').toString(),
      statusIMTU: (json['status_imt_u'] ?? '-').toString(),
      statusBBTB: (json['status_bb_tb'] ?? '-').toString(),
      statusLKU: (json['status_lk_u'] ?? '-').toString(),
      statusKMSNaik: (json['status_kms_naik'] ?? '-').toString(),
      statusKMSBGM: (json['status_kms_bgm'] ?? '-').toString(),
      statusKMSInfo: (json['status_kms_info'] ?? '-').toString(),
      catatanNakes: (json['catatan_nakes'] ?? '').toString(),
      zScoreBBU: toDouble(json['z_score_bb_u']),
      zScoreTBU: toDouble(json['z_score_tb_u']),
      zScoreIMTU: toDouble(json['z_score_imt_u']),
      zScoreBBTB: toDouble(json['z_score_bb_tb']),
      zScoreLKU: toDouble(json['z_score_lk_u']),
    );
  }
}

class CreatePertumbuhanRequest {
  final int anakId;
  final String tglUkur;
  final double beratBadan;
  final double tinggiBadan;
  final double? lingkarKepala;
  final String? catatanNakes;

  const CreatePertumbuhanRequest({
    required this.anakId,
    required this.tglUkur,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
    this.catatanNakes,
  });

  Map<String, dynamic> toJson() {
    return {
      'anak_id': anakId,
      'tgl_ukur': tglUkur,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      if (lingkarKepala != null) 'lingkar_kepala': lingkarKepala,
      if (catatanNakes != null && catatanNakes!.isNotEmpty) 'catatan_nakes': catatanNakes,
    };
  }
}
