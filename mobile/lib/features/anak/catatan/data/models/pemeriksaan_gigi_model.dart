class PemeriksaanGigiModel {
  final int id;
  final int anakId;
  final int bulan;
  final DateTime tanggal;
  final int jumlahGigi;
  final int gigiBerlubang;
  final String statusPlak;
  final String resikoGigiBerlubang;

  PemeriksaanGigiModel({
    required this.id,
    required this.anakId,
    required this.bulan,
    required this.tanggal,
    required this.jumlahGigi,
    required this.gigiBerlubang,
    required this.statusPlak,
    required this.resikoGigiBerlubang,
  });

  factory PemeriksaanGigiModel.fromJson(Map<String, dynamic> json) {
    return PemeriksaanGigiModel(
      id: json['id'] ?? 0,
      anakId: json['anak_id'] ?? 0,
      bulan: json['bulan'] ?? 0,
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      jumlahGigi: json['jumlah_gigi'] ?? 0,
      gigiBerlubang: json['gigi_berlubang'] ?? 0,
      statusPlak: json['status_plak'] ?? '',
      resikoGigiBerlubang: json['resiko_gigi_berlubang'] ?? '',
    );
  }
}
