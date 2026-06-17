class GrafikBBPointModel {
  final int mingguKehamilan;
  final double beratBadan;
  final double kenaikanDariAwal;
  final double batasMin;
  final double batasMax;
  final String status; // "kurang" | "normal" | "lebih"

  GrafikBBPointModel({
    required this.mingguKehamilan,
    required this.beratBadan,
    required this.kenaikanDariAwal,
    required this.batasMin,
    required this.batasMax,
    required this.status,
  });

  factory GrafikBBPointModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return GrafikBBPointModel(
      mingguKehamilan: json['minggu_kehamilan'] ?? 0,
      beratBadan: toDouble(json['berat_badan']),
      kenaikanDariAwal: toDouble(json['kenaikan_dari_awal']),
      batasMin: toDouble(json['batas_min']),
      batasMax: toDouble(json['batas_max']),
      status: json['status']?.toString() ?? 'normal',
    );
  }
}

class GrafikBBResponseModel {
  final double bbAwal;
  final String imtKategori;
  final double targetMin;
  final double targetMax;
  final List<GrafikBBPointModel> grafikBb;
  final String penjelasanHasilGrafik;

  GrafikBBResponseModel({
    required this.bbAwal,
    required this.imtKategori,
    required this.targetMin,
    required this.targetMax,
    required this.grafikBb,
    required this.penjelasanHasilGrafik,
  });

  factory GrafikBBResponseModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return GrafikBBResponseModel(
      bbAwal: toDouble(json['bb_awal']),
      imtKategori: json['imt_kategori']?.toString() ?? '-',
      targetMin: toDouble(json['target_kenaikan_min']),
      targetMax: toDouble(json['target_kenaikan_max']),
      grafikBb: (json['grafik_bb'] as List?)
              ?.map((e) => GrafikBBPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      penjelasanHasilGrafik: json['penjelasan_hasil_grafik']?.toString() ?? '',
    );
  }
}