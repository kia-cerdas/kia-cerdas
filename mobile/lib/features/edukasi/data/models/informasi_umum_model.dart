class InformasiUmumModel {
  final int id;
  final String tipe;
  final String judul;
  final String umurTarget;
  final String durasiBaca;
  final String ringkasan;
  final String konten;
  final String yangPerluDiingat;
  final String thumbnailUrl;
  final bool isActive;

  const InformasiUmumModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.umurTarget,
    required this.durasiBaca,
    required this.ringkasan,
    required this.konten,
    required this.yangPerluDiingat,
    required this.thumbnailUrl,
    required this.isActive,
  });

  factory InformasiUmumModel.fromJson(Map<String, dynamic> json) {
    return InformasiUmumModel(
      id: _asInt(json['id']),
      tipe: _asString(json['tipe']),
      judul: _asString(json['judul']),
      umurTarget: _asString(json['umur_target']),
      durasiBaca: _asString(json['durasi_baca']),
      ringkasan: _asString(json['ringkasan']),
      konten: _asString(json['konten']),
      yangPerluDiingat: _asString(json['yang_perlu_diingat']),
      thumbnailUrl: _asString(json['thumbnail_url']),
      isActive: _asBool(json['is_active'], fallback: true),
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

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  bool get isVideo => tipe.toUpperCase() == 'VIDEO';
  bool get isArticle => !isVideo;

  String get displayAgeText =>
      umurTarget.trim().isNotEmpty ? umurTarget.trim() : 'Semua Umur';

  String get displayDurationText =>
      durasiBaca.trim().isNotEmpty ? durasiBaca.trim() : '5 Menit Baca';
}
