class RentangUsiaModel {
  final int id;
  final String namaRentang;
  final String satuanWaktu;
  final int maxPeriode;

  RentangUsiaModel({
    required this.id,
    required this.namaRentang,
    required this.satuanWaktu,
    required this.maxPeriode,
  });

  factory RentangUsiaModel.fromJson(Map<String, dynamic> json) {
    return RentangUsiaModel(
      id: json['id'] ?? 0,
      namaRentang: json['nama_rentang'] ?? '',
      satuanWaktu: json['satuan_waktu'] ?? '',
      maxPeriode: json['max_periode'] ?? 0,
    );
  }
}

class KategoriTandaSakitModel {
  final int id;
  final int rentangUsiaId;
  final String gejala;
  final String deskripsi;
  final bool isActive;

  KategoriTandaSakitModel({
    required this.id,
    required this.rentangUsiaId,
    required this.gejala,
    required this.deskripsi,
    required this.isActive,
  });

  factory KategoriTandaSakitModel.fromJson(Map<String, dynamic> json) {
    return KategoriTandaSakitModel(
      id: json['id'] ?? 0,
      rentangUsiaId: json['rentang_usia_id'] ?? 0,
      gejala: json['gejala'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class DetailPemantauanModel {
  final int id;
  final int kategoriTandaSakitId;
  final bool isTerjadi;
  final KategoriTandaSakitModel? kategoriTandaSakit;

  DetailPemantauanModel({
    required this.id,
    required this.kategoriTandaSakitId,
    required this.isTerjadi,
    this.kategoriTandaSakit,
  });

  factory DetailPemantauanModel.fromJson(Map<String, dynamic> json) {
    return DetailPemantauanModel(
      id: json['id'] ?? 0,
      kategoriTandaSakitId: json['kategori_tanda_sakit_id'] ?? 0,
      isTerjadi: json['is_terjadi'] ?? false,
      kategoriTandaSakit: json['kategori_tanda_sakit'] != null
          ? KategoriTandaSakitModel.fromJson(json['kategori_tanda_sakit'])
          : null,
    );
  }
}

class LembarPemantauanModel {
  final int id;
  final int anakId;
  final Map<String, dynamic>? anak;
  final int rentangUsiaId;
  final int periodeWaktu;
  final String tanggalPeriksa;
  final String namaPemeriksa;
  final String status; // Menunggu verifikasi, Diterima, Ditolak
  final String updatedAt;
  final List<DetailPemantauanModel> detailGejala;
  final RentangUsiaModel? rentangUsia;

  LembarPemantauanModel({
    required this.id,
    required this.anakId,
    this.anak,
    required this.rentangUsiaId,
    required this.periodeWaktu,
    required this.tanggalPeriksa,
    required this.namaPemeriksa,
    required this.status,
    required this.updatedAt,
    required this.detailGejala,
    this.rentangUsia,
  });

  factory LembarPemantauanModel.fromJson(Map<String, dynamic> json) {
    var listDetail = json['detail_gejala'] as List? ?? [];
    List<DetailPemantauanModel> detailList =
        listDetail.map((i) => DetailPemantauanModel.fromJson(i)).toList();

    return LembarPemantauanModel(
      id: json['id'] ?? 0,
      anakId: json['anak_id'] ?? 0,
      anak: json['anak'] is Map<String, dynamic>
          ? json['anak'] as Map<String, dynamic>
          : null,
      rentangUsiaId: json['rentang_usia_id'] ?? 0,
      periodeWaktu: json['periode_waktu'] ?? 0,
      tanggalPeriksa: json['tanggal_periksa'] != null
          ? json['tanggal_periksa'].toString().split('T')[0]
          : '',
      namaPemeriksa: json['nama_pemeriksa'] ?? '',
      status: json['status'] ?? 'Menunggu verifikasi',
      updatedAt: json['updated_at'] != null
          ? json['updated_at'].toString().split('T')[0]
          : '',
      detailGejala: detailList,
      rentangUsia: json['rentang_usia'] != null
          ? RentangUsiaModel.fromJson(json['rentang_usia'])
          : null,
    );
  }
}
