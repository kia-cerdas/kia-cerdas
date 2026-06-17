class KeluhanAnakModel {
  final int id;
  final int anakId;
  final DateTime tanggal;
  final DateTime? tanggalKembali;
  final String keluhan;
  final String? tindakan;
  final String? pemeriksa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KeluhanAnakModel({
    required this.id,
    required this.anakId,
    required this.tanggal,
    this.tanggalKembali,
    required this.keluhan,
    this.tindakan,
    this.pemeriksa,
    this.createdAt,
    this.updatedAt,
  });

  factory KeluhanAnakModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullableDate(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return KeluhanAnakModel(
      id: (json['id'] ?? 0) as int,
      anakId: (json['anak_id'] ?? 0) as int,
      tanggal: DateTime.parse(json['tanggal'].toString()),
      tanggalKembali: parseNullableDate(json['tanggal_kembali']?.toString()),
      keluhan: (json['keluhan'] ?? '') as String,
      tindakan: json['tindakan'] as String?,
      pemeriksa: json['pemeriksa'] as String?,
      createdAt: parseNullableDate(json['created_at']?.toString()),
      updatedAt: parseNullableDate(json['updated_at']?.toString()),
    );
  }
}
