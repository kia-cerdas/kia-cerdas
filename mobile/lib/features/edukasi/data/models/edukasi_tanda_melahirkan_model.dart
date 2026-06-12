class EdukasiTandaMelahirkanModel {
  final int id;
  final String judul;
  final String isi;
  final String tanda;
  final String tindakan;
  final String gambarUrl;

  EdukasiTandaMelahirkanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanda,
    required this.tindakan,
    required this.gambarUrl,
  });

  factory EdukasiTandaMelahirkanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EdukasiTandaMelahirkanModel(
      id: int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      tanda: json['tanda'] ?? '',
      tindakan: json['tindakan'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'tanda': tanda,
      'tindakan': tindakan,
      'gambar_url': gambarUrl,
    };
  }
}