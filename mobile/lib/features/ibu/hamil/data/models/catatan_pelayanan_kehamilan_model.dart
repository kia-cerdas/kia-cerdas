class CatatanPelayananKehamilanModel {
  final int idCatatan;
  final int kehamilanId;
  final int trimester; // 1, 2, atau 3
  final DateTime? tanggalPeriksa;
  final String keluhan;
  final DateTime? tanggalKembali;

  CatatanPelayananKehamilanModel({
    required this.idCatatan,
    required this.kehamilanId,
    required this.trimester,
    required this.tanggalPeriksa,
    required this.keluhan,
    required this.tanggalKembali,
  });

  factory CatatanPelayananKehamilanModel.fromJson(Map<String, dynamic> json) {
    return CatatanPelayananKehamilanModel(
      idCatatan: json['id_catatan'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      trimester: json['trimester'] ?? 0,
      tanggalPeriksa: json['tanggal_periksa_stamp_paraf'] != null
          ? DateTime.tryParse(json['tanggal_periksa_stamp_paraf'])
          : null,
      keluhan: json['keluhan_pemeriksaan_tindakan_saran'] ?? '',
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.tryParse(json['tanggal_kembali'])
          : null,
    );
  }
}
