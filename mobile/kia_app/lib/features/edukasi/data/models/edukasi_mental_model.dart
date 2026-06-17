class EdukasiKesehatanMentalModel {
  final int id;
  final String judul;
  final String isi;
  final String tandaGejala;
  final String solusi;
  final String gambarUrl;

  EdukasiKesehatanMentalModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tandaGejala,
    required this.solusi,
    required this.gambarUrl,
  });

  factory EdukasiKesehatanMentalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EdukasiKesehatanMentalModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      tandaGejala: json['tanda_gejala'] ?? '',
      solusi: json['solusi'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'tanda_gejala': tandaGejala,
      'solusi': solusi,
      'gambar_url': gambarUrl,
    };
  }
}