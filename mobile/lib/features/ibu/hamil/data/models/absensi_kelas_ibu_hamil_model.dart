// class AbsensiKelasIbuHamilModel {
//   final int? id;
//   final int pertemuanKe;
//   final String tanggal;
//   final String namaKader;
//   final String tanggalParaf;

//   const AbsensiKelasIbuHamilModel({
//     this.id,
//     required this.pertemuanKe,
//     required this.tanggal,
//     required this.namaKader,
//     required this.tanggalParaf,
//   });

//   factory AbsensiKelasIbuHamilModel.fromJson(Map<String, dynamic> json) {
//     return AbsensiKelasIbuHamilModel(
//       id: json['id'],
//       pertemuanKe: json['pertemuan_ke'] ?? 0,
//       tanggal: _readDate(json['tanggal']),
//       namaKader: json['nama_kader']?.toString() ?? '',
//       tanggalParaf: _readDate(json['tanggal_paraf']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'pertemuan_ke': pertemuanKe,
//       'tanggal': tanggal,
//       'nama_kader': namaKader,
//       'tanggal_paraf': tanggalParaf,
//     };
//   }
// }

// String _readDate(dynamic value) {
//   if (value == null) return '';
//   final text = value.toString();
//   if (text.length >= 10) return text.substring(0, 10);
//   return text;
// }

class AbsensiKelasIbuHamilModel {
  final int? id;
  final int pertemuanKe;
  final String tanggal;
  final String namaKader;
  final String tanggalParaf;
  final String status;

  const AbsensiKelasIbuHamilModel({
    this.id,
    required this.pertemuanKe,
    required this.tanggal,
    required this.namaKader,
    required this.tanggalParaf,
    this.status = 'Menunggu Verifikasi',
  });

  factory AbsensiKelasIbuHamilModel.fromJson(Map<String, dynamic> json) {
    return AbsensiKelasIbuHamilModel(
      id: json['id'],
      pertemuanKe: json['pertemuan_ke'] ?? 0,
      tanggal: _readDate(json['tanggal']),
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalParaf: _readDate(json['tanggal_paraf']),
      status: json['status']?.toString() ?? 'Menunggu Verifikasi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pertemuan_ke': pertemuanKe,
      'tanggal': tanggal,
      'nama_kader': namaKader,
      'tanggal_paraf': tanggalParaf,
    };
  }
}

String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}