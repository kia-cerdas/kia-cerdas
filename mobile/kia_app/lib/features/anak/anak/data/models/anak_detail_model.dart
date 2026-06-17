class IbuModel {
  final int? id;
  final String namaIbu;

  const IbuModel({
    this.id,
    required this.namaIbu,
  });

  factory IbuModel.fromJson(Map<String, dynamic> json) {
    return IbuModel(
      id: json['id'] as int?,
      namaIbu: (json['nama_ibu'] ?? '').toString(),
    );
  }
}

class AnakDetailModel {
  final int id;
  final int noKartuKeluarga;
  final String namaAnak;
  final String jenisKelamin;
  final String tanggalLahir;
  final double beratLahir;
  final double tinggiLahir;
  final IbuModel? ibu;

  const AnakDetailModel({
    required this.id,
    required this.noKartuKeluarga,
    required this.namaAnak,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.beratLahir,
    required this.tinggiLahir,
    this.ibu,
  });

  factory AnakDetailModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return AnakDetailModel(
      id: toInt(json['id']),
      noKartuKeluarga: toInt(json['no_kartu_keluarga']),
      namaAnak: (json['nama_anak'] ?? '').toString(),
      jenisKelamin: (json['jenis_kelamin'] ?? '').toString(),
      tanggalLahir: (json['tanggal_lahir'] ?? '').toString(),
      beratLahir: toDouble(json['berat_lahir']),
      tinggiLahir: toDouble(json['tinggi_lahir']),
      ibu: json['ibu'] != null ? IbuModel.fromJson(json['ibu']) : null,
    );
  }
}
