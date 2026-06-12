// Models untuk Perawatan
class PerawatanModel {
  final int id;
  final int anakId;
  final int kategoriCapaianId;
  final bool? jawaban;
  final DateTime? tanggalPeriksa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PerawatanModel({
    required this.id,
    required this.anakId,
    required this.kategoriCapaianId,
    this.jawaban,
    this.tanggalPeriksa,
    this.createdAt,
    this.updatedAt,
  });

  factory PerawatanModel.fromJson(Map<String, dynamic> json) {
    return PerawatanModel(
      id: json['id'] ?? 0,
      anakId: json['anak_id'] ?? 0,
      kategoriCapaianId: json['kategori_capaian_id'] ?? 0,
      jawaban: json['jawaban'],
      tanggalPeriksa: json['tanggal_periksa'] != null
          ? DateTime.tryParse(json['tanggal_periksa'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'anak_id': anakId,
    'kategori_capaian_id': kategoriCapaianId,
    'jawaban': jawaban,
    'tanggal_periksa': tanggalPeriksa?.toIso8601String(),
  };
}

class KategoriCapaianModel {
  final int id;
  final String rentangUsia;
  final String pertanyaanCeklist;
  final String aspek;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KategoriCapaianModel({
    required this.id,
    required this.rentangUsia,
    required this.pertanyaanCeklist,
    required this.aspek,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriCapaianModel.fromJson(Map<String, dynamic> json) {
    return KategoriCapaianModel(
      id: json['id'] ?? 0,
      rentangUsia: json['rentang_usia'] ?? '',
      pertanyaanCeklist: json['pertanyaan_ceklist'] ?? '',
      aspek: json['aspek'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'rentang_usia': rentangUsia,
    'pertanyaan_ceklist': pertanyaanCeklist,
    'aspek': aspek,
  };
}

class CreatePerawatanRequest {
  final int anakId;
  final int kategoriCapaianId;
  final bool? jawaban;
  final DateTime? tanggalPeriksa;

  CreatePerawatanRequest({
    required this.anakId,
    required this.kategoriCapaianId,
    this.jawaban,
    this.tanggalPeriksa,
  });

  Map<String, dynamic> toJson() => {
    'anak_id': anakId,
    'kategori_capaian_id': kategoriCapaianId,
    'jawaban': jawaban,
    'tanggal_periksa': tanggalPeriksa?.toIso8601String(),
  };
}

class UpdatePerawatanRequest {
  final bool? jawaban;
  final DateTime? tanggalPeriksa;

  UpdatePerawatanRequest({
    this.jawaban,
    this.tanggalPeriksa,
  });

  Map<String, dynamic> toJson() => {
    'jawaban': jawaban,
    'tanggal_periksa': tanggalPeriksa?.toIso8601String(),
  };
}
