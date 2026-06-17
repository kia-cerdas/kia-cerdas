class EdukasiTrimesterModel {
  final int id;
  final String trimester;
  final String kategori;
  final String judul;
  final String isi;
  final String gambarUrl;

  EdukasiTrimesterModel({
    required this.id,
    required this.trimester,
    required this.kategori,
    required this.judul,
    required this.isi,
    required this.gambarUrl,
  });

  factory EdukasiTrimesterModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EdukasiTrimesterModel(
      id: int.parse(json['id'].toString()),
      trimester: json['trimester'] ?? '',
      kategori: json['kategori'] ?? '',
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trimester': trimester,
      'kategori': kategori,
      'judul': judul,
      'isi': isi,
      'gambar_url': gambarUrl,
    };
  }
}