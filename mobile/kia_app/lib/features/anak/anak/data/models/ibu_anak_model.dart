class IbuAnakModel {
  final int id;
  final String nama;
  final String tanggalLahir;
  final String jenisKelamin;
  final String usiaTeks;

  const IbuAnakModel({
    required this.id,
    required this.nama,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.usiaTeks,
  });

  factory IbuAnakModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return IbuAnakModel(
      id: toInt(json['id']),
      nama: (json['nama'] ?? json['nama_anak'] ?? '').toString(),
      tanggalLahir: (json['tanggal_lahir'] ?? '').toString(),
      jenisKelamin: (json['jenis_kelamin'] ?? '').toString(),
      usiaTeks: (json['usia_teks'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toChildMap() {
    return {
      'id': id,
      'nama': nama,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'usia_teks': usiaTeks,
    };
  }
}
