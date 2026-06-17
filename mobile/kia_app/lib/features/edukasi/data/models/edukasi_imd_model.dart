class EdukasiIMDModel {
  final int id;
  final String judul;
  final String isi;
  final String manfaat;
  final String langkah;
  final String gambarUrl;

  EdukasiIMDModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.manfaat,
    required this.langkah,
    required this.gambarUrl,
  });

  factory EdukasiIMDModel.fromJson(Map<String, dynamic> json) {
    return EdukasiIMDModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      manfaat: json['manfaat'] ?? '',
      langkah: json['langkah'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'manfaat': manfaat,
      'langkah': langkah,
      'gambar_url': gambarUrl,
    };
  }
}