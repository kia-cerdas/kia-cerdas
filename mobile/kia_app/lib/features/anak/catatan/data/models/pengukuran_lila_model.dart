class PengukuranLilaModel {
  final int id;
  final int anakId;
  final int bulan;
  final DateTime tanggal;
  final double hasilLila;
  final String kategoriRisiko;

  PengukuranLilaModel({
    required this.id,
    required this.anakId,
    required this.bulan,
    required this.tanggal,
    required this.hasilLila,
    required this.kategoriRisiko,
  });

  factory PengukuranLilaModel.fromJson(Map<String, dynamic> json) {
    return PengukuranLilaModel(
      id: json['id'] ?? 0,
      anakId: json['anak_id'] ?? 0,
      bulan: json['bulan'] ?? 0,
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      hasilLila: (json['hasil_lila'] ?? 0).toDouble(),
      kategoriRisiko: json['kategori_risiko'] ?? '',
    );
  }
}
