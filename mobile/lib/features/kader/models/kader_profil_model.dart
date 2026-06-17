// class KaderProfilModel {
//   final int id;
//   final int pendudukId;
//   final String namaLengkap;
//   final String nik;
//   final String telepon;
//   final String dusun;
//   final String kecamatan;
//   final String desa;
//   final int? posyanduId;
//   final String posyanduNama;
//   final String status;
//   final DateTime createdAt;

//   const KaderProfilModel({
//     required this.id,
//     required this.pendudukId,
//     required this.namaLengkap,
//     required this.nik,
//     required this.telepon,
//     required this.dusun,
//     required this.kecamatan,
//     required this.desa,
//     this.posyanduId,
//     required this.posyanduNama,
//     required this.status,
//     required this.createdAt,
//   });

//   factory KaderProfilModel.fromJson(Map<String, dynamic> json) {
//     return KaderProfilModel(
//       id: json['id'] ?? 0,
//       pendudukId: json['penduduk_id'] ?? 0,
//       namaLengkap: json['nama_lengkap'] ?? '',
//       nik: json['nik'] ?? '',
//       telepon: json['telepon'] ?? '',
//       dusun: json['dusun'] ?? '',
//       kecamatan: json['kecamatan'] ?? '',
//       desa: json['desa'] ?? '',
//       posyanduId: json['posyandu_id'],
//       posyanduNama: json['posyandu_nama'] ?? '-',
//       status: json['status'] ?? '-',
//       createdAt: json['created_at'] != null 
//           ? DateTime.parse(json['created_at'].toString()) 
//           : DateTime.now(),
//     );
//   }
// }



class KaderProfilModel {
  final int id;
  final int pendudukId;
  final String namaLengkap;
  final String nik;
  final String telepon;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String golonganDarah;
  final String agama;
  final String pendidikanTerakhir;
  final String pekerjaan;
  final String dusun;
  final String kecamatan;
  final String desa;
  final int? posyanduId;
  final String posyanduNama;
  final String status;
  final DateTime createdAt;

  const KaderProfilModel({
    required this.id,
    required this.pendudukId,
    required this.namaLengkap,
    required this.nik,
    required this.telepon,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.golonganDarah,
    required this.agama,
    required this.pendidikanTerakhir,
    required this.pekerjaan,
    required this.dusun,
    required this.kecamatan,
    required this.desa,
    this.posyanduId,
    required this.posyanduNama,
    required this.status,
    required this.createdAt,
  });

  factory KaderProfilModel.fromJson(Map<String, dynamic> json) {
    return KaderProfilModel(
      id: json['id'] ?? 0,
      pendudukId: json['penduduk_id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      nik: json['nik'] ?? '',
      telepon: json['telepon'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '-',
      tempatLahir: json['tempat_lahir'] ?? '',
      tanggalLahir: _readDate(json['tanggal_lahir']),
      golonganDarah: json['golongan_darah'] ?? '-',
      agama: json['agama'] ?? '-',
      pendidikanTerakhir: json['pendidikan_terakhir'] ?? '-',
      pekerjaan: json['pekerjaan'] ?? '-',
      dusun: json['dusun'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      desa: json['desa'] ?? '',
      posyanduId: json['posyandu_id'],
      posyanduNama: json['posyandu_nama'] ?? '-',
      status: json['status'] ?? '-',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }
}

// Helper untuk amankan parse tanggal dari JSON
String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}