class EdukasiASIModel {
  final int id;
  final String judul;
  final String isi;
  final String manfaatASI;
  final String cara;
  final String masalah;
  final String solusi;
  final String gambarUrl;

  EdukasiASIModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.manfaatASI,
    required this.cara,
    required this.masalah,
    required this.solusi,
    required this.gambarUrl,
  });

  factory EdukasiASIModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EdukasiASIModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      manfaatASI: json['manfaat_asi'] ?? '',
      cara: json['cara'] ?? '',
      masalah: json['masalah'] ?? '',
      solusi: json['solusi'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'manfaat_asi': manfaatASI,
      'cara': cara,
      'masalah': masalah,
      'solusi': solusi,
      'gambar_url': gambarUrl,
    };
  }
}