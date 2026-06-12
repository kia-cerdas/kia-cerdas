class LogTTDMMSModel {
  final int? id;
  final int bulanKe;
  final int hariKe;
  final bool sudahDiminum;

  const LogTTDMMSModel({
    this.id,
    required this.bulanKe,
    required this.hariKe,
    required this.sudahDiminum,
  });

  factory LogTTDMMSModel.fromJson(Map<String, dynamic> json) {
    return LogTTDMMSModel(
      id: json['id'],
      bulanKe: json['bulan_ke'] ?? 0,
      hariKe: json['hari_ke'] ?? 0,
      sudahDiminum: json['sudah_diminum'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bulan_ke': bulanKe,
      'hari_ke': hariKe,
      'sudah_diminum': sudahDiminum,
    };
  }
}
