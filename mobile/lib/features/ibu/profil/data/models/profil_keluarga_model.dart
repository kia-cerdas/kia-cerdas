// lib/features/ibu/profil/data/models/profil_keluarga_model.dart

class AnggotaKeluargaModel {
  final int id;
  final String nama;
  final String nik;
  final String hubungan;
  final String jenisKelamin;
  final String tempatLahir;
  final String tanggalLahir;
  final String pendidikan;
  final String pekerjaan;

  const AnggotaKeluargaModel({
    required this.id,
    required this.nama,
    required this.nik,
    required this.hubungan,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.pekerjaan,
  });

  factory AnggotaKeluargaModel.fromJson(Map<String, dynamic> json) {
    return AnggotaKeluargaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      hubungan: json['hubungan']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      tanggalLahir: json['tanggal_lahir']?.toString() ?? '',
      pendidikan: json['pendidikan']?.toString() ?? '',
      pekerjaan: json['pekerjaan']?.toString() ?? '',
    );
  }
}