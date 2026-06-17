class GrafikTFUPointModel {
  final int usia;
  final double? tfu;
  final double normal;
  final double upper;
  final double lower;
  final String tanggalPeriksa;
  final String tekananDarah;
  final double? hemoglobin;
  final String urinProtein;
  final int? tabletTambahDarah;
  final String? gerakanBayi;   // "normal" | "kurang" | null
  final String statusTFU;      // "normal" | "tinggi" | "rendah" | "tidak_ada_data"

  GrafikTFUPointModel({
    required this.usia,
    this.tfu,
    required this.normal,
    required this.upper,
    required this.lower,
    required this.tanggalPeriksa,
    required this.tekananDarah,
    this.hemoglobin,
    required this.urinProtein,
    this.tabletTambahDarah,
    this.gerakanBayi,
    required this.statusTFU,
  });

  factory GrafikTFUPointModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return GrafikTFUPointModel(
      usia: json['usia'] ?? 0,
      tfu: toDouble(json['tfu']),
      normal: (json['normal'] ?? 0).toDouble(),
      upper: (json['upper'] ?? 0).toDouble(),
      lower: (json['lower'] ?? 0).toDouble(),
      tanggalPeriksa: json['tanggal_periksa']?.toString() ?? '',
      tekananDarah: json['tekanan_darah']?.toString() ?? '-',
      hemoglobin: toDouble(json['hemoglobin']),
      urinProtein: json['urin_protein']?.toString() ?? '-',
      tabletTambahDarah: toInt(json['tablet_tambah_darah']),
      gerakanBayi: json['gerakan_bayi']?.toString(),
      statusTFU: json['status_tfu']?.toString() ?? 'tidak_ada_data',
    );
  }
}

class GrafikDJJPointModel {
  final int usia;
  final int djj;
  final int upper;
  final int lower;
  final String tanggalPeriksa;
  final String statusDJJ; // "normal" | "bradikardia" | "takikardia"

  GrafikDJJPointModel({
    required this.usia,
    required this.djj,
    required this.upper,
    required this.lower,
    required this.tanggalPeriksa,
    required this.statusDJJ,
  });

  factory GrafikDJJPointModel.fromJson(Map<String, dynamic> json) {
    return GrafikDJJPointModel(
      usia: json['usia'] ?? 0,
      djj: json['djj'] ?? 0,
      upper: json['upper'] ?? 160,
      lower: json['lower'] ?? 110,
      tanggalPeriksa: json['tanggal_periksa']?.toString() ?? '',
      statusDJJ: json['status_djj']?.toString() ?? 'normal',
    );
  }
}

class GrafikEvaluasiKehamilanResponseModel {
  final List<GrafikTFUPointModel> grafikTfu;
  final List<GrafikDJJPointModel> grafikDjj;
  final String? penjelasanHasilGrafik;

  GrafikEvaluasiKehamilanResponseModel({
    required this.grafikTfu,
    required this.grafikDjj,
    this.penjelasanHasilGrafik,
  });

  factory GrafikEvaluasiKehamilanResponseModel.fromJson(Map<String, dynamic> json) {
    return GrafikEvaluasiKehamilanResponseModel(
      grafikTfu: (json['grafik_tfu'] as List?)
              ?.map((e) => GrafikTFUPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      grafikDjj: (json['grafik_djj'] as List?)
              ?.map((e) => GrafikDJJPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      penjelasanHasilGrafik: json['penjelasan_hasil_grafik']?.toString(),
    );
  }
}
