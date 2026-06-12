class EdukasiPolaAsuhModel {
  final int id;
  final String judul;
  final String gambarUrl;
  final String isi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EdukasiPolaAsuhModel({
    required this.id,
    required this.judul,
    required this.gambarUrl,
    required this.isi,
    this.createdAt,
    this.updatedAt,
  });

  factory EdukasiPolaAsuhModel.fromJson(Map<String, dynamic> json) {
    return EdukasiPolaAsuhModel(
      id: _asInt(json['id']),
      judul: _asString(json['judul']),
      gambarUrl: _asString(json['gambar_url']),
      isi: _asString(json['isi']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
