class CatatanPelayananNifasModel {
  final int idCatatanNifas;
  final int kehamilanId;
  final DateTime? tanggalPeriksa;
  final String keluhan;
  final DateTime? tanggalKembali;

  CatatanPelayananNifasModel({
    required this.idCatatanNifas,
    required this.kehamilanId,
    required this.tanggalPeriksa,
    required this.keluhan,
    required this.tanggalKembali,
  });

  factory CatatanPelayananNifasModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CatatanPelayananNifasModel(
      idCatatanNifas:
          json['id_catatan_nifas'] ?? 0,

      kehamilanId:
          json['kehamilan_id'] ?? 0,

      tanggalPeriksa:
          json['tanggal_periksa_stamp_paraf'] !=
                  null
              ? DateTime.parse(
                  json[
                      'tanggal_periksa_stamp_paraf'],
                )
              : null,

      keluhan:
          json[
                  'keluhan_pemeriksaan_tindakan_saran'] ??
              '',

      tanggalKembali:
          json['tanggal_kembali'] != null
              ? DateTime.parse(
                  json['tanggal_kembali'],
                )
              : null,
    );
  }
}