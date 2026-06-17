// class EdukasiNifasModel {
//   final int id;
//   final String judul;
//   final String isi;
//   final String perawatan;
//   final String tandaBahaya;
//   final String gambarUrl;

//   EdukasiNifasModel({
//     required this.id,
//     required this.judul,
//     required this.isi,
//     required this.perawatan,
//     required this.tandaBahaya,
//     required this.gambarUrl,
//   });

//   // factory EdukasiNifasModel.fromJson(
//   //   Map<String, dynamic> json,
//   // ) {
//   //   return EdukasiNifasModel(
//   //     // id: json['id'],
//   //     id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()),
//   //     judul: json['judul'] ?? '',
//   //     isi: json['isi'] ?? '',
//   //     perawatan: json['perawatan'] ?? '',
//   //     tandaBahaya: json['tanda_bahaya'] ?? '',
//   //     gambarUrl: json['gambar_url'] ?? '',
//   //   );
//   // }

//   factory EdukasiNifasModel.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return EdukasiNifasModel(
//       id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
//       judul: json['judul'] ?? '',
//       isi: json['isi'] ?? '',
//       perawatan: json['perawatan'] ?? '',
//       tandaBahaya: json['tanda_bahaya'] ?? '',
//       gambarUrl: json['gambar_url'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'judul': judul,
//       'isi': isi,
//       'perawatan': perawatan,
//       'tanda_bahaya': tandaBahaya,
//       'gambar_url': gambarUrl,
//     };
//   }
// }


class EdukasiNifasModel {
  final int id;
  final String judul;
  final String isi;
  final String gambarUrl;

  EdukasiNifasModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.gambarUrl,
  });

  factory EdukasiNifasModel.fromJson(Map<String, dynamic> json) {
    return EdukasiNifasModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'gambar_url': gambarUrl,
    };
  }
}