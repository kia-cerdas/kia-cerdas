class DetailPelayananNeonatusModel {
  final int id;
  final int neonatusId;
  final int jenisPelayananId;
  final String namaPelayanan;
  final String nilai;
  final String keterangan;

  DetailPelayananNeonatusModel({
    required this.id,
    required this.neonatusId,
    required this.jenisPelayananId,
    required this.namaPelayanan,
    required this.nilai,
    required this.keterangan,
  });

  factory DetailPelayananNeonatusModel.fromJson(Map<String, dynamic> json) {
    String nama = '';
    if (json['jenis_pelayanan'] != null && json['jenis_pelayanan']['nama'] != null) {
      nama = json['jenis_pelayanan']['nama'];
    }

    return DetailPelayananNeonatusModel(
      id: json['id'] ?? 0,
      neonatusId: json['neonatus_id'] ?? 0,
      jenisPelayananId: json['jenis_pelayanan_id'] ?? 0,
      namaPelayanan: nama,
      nilai: json['nilai'] ?? '',
      keterangan: json['keterangan'] ?? '',
    );
  }
}

class NeonatusModel {
  final int id;
  final int anakId;
  final int periodeId;
  final int kategoriUmurId;
  final DateTime tanggal;
  final int tenagaKesehatanId;
  final List<DetailPelayananNeonatusModel> detailPelayanan;

  NeonatusModel({
    required this.id,
    required this.anakId,
    required this.periodeId,
    required this.kategoriUmurId,
    required this.tanggal,
    required this.tenagaKesehatanId,
    required this.detailPelayanan,
  });

  factory NeonatusModel.fromJson(Map<String, dynamic> json) {
    return NeonatusModel(
      id: json['id'] ?? 0,
      anakId: json['anak_id'] ?? 0,
      periodeId: json['periode_id'] ?? 0,
      kategoriUmurId: json['kategori_umur_id'] ?? 0,
      tanggal: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : DateTime.now(),
      tenagaKesehatanId: json['tenaga_kesehatan_id'] ?? 0,
      detailPelayanan: json['detail_pelayanan'] != null
          ? (json['detail_pelayanan'] as List).map((i) => DetailPelayananNeonatusModel.fromJson(i)).toList()
          : [],
    );
  }
}
