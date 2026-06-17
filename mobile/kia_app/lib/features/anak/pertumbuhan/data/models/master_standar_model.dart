class MasterStandarModel {
  final int id;
  final String parameter;
  final String jenisKelamin;
  final double nilaiSumbuX;
  final double sd3Neg;
  final double sd2Neg;
  final double sd1Neg;
  final double median;
  final double sd1Pos;
  final double sd2Pos;
  final double sd3Pos;

  const MasterStandarModel({
    required this.id,
    required this.parameter,
    required this.jenisKelamin,
    required this.nilaiSumbuX,
    required this.sd3Neg,
    required this.sd2Neg,
    required this.sd1Neg,
    required this.median,
    required this.sd1Pos,
    required this.sd2Pos,
    required this.sd3Pos,
  });

  factory MasterStandarModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return MasterStandarModel(
      id: toInt(json['id']),
      parameter: (json['parameter'] ?? '').toString(),
      jenisKelamin: (json['jenis_kelamin'] ?? '').toString(),
      nilaiSumbuX: toDouble(json['nilai_sumbu_x']),
      sd3Neg: toDouble(json['sd_3_neg']),
      sd2Neg: toDouble(json['sd_2_neg']),
      sd1Neg: toDouble(json['sd_1_neg']),
      median: toDouble(json['median']),
      sd1Pos: toDouble(json['sd_1_pos']),
      sd2Pos: toDouble(json['sd_2_pos']),
      sd3Pos: toDouble(json['sd_3_pos']),
    );
  }
}
