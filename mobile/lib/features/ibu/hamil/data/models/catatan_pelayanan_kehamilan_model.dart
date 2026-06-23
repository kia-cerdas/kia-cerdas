// class CatatanPelayananKehamilanModel {
//   final int idCatatan;
//   final int kehamilanId;
//   final int trimester; // 1, 2, atau 3
//   final DateTime? tanggalPeriksa;
//   final String keluhan;
//   final DateTime? tanggalKembali;

//   CatatanPelayananKehamilanModel({
//     required this.idCatatan,
//     required this.kehamilanId,
//     required this.trimester,
//     required this.tanggalPeriksa,
//     required this.keluhan,
//     required this.tanggalKembali,
//   });

//   factory CatatanPelayananKehamilanModel.fromJson(Map<String, dynamic> json) {
//     return CatatanPelayananKehamilanModel(
//       idCatatan: json['id_catatan'] ?? 0,
//       kehamilanId: json['kehamilan_id'] ?? 0,
//       trimester: json['trimester'] ?? 0,
//       tanggalPeriksa: json['tanggal_periksa_stamp_paraf'] != null
//           ? DateTime.tryParse(json['tanggal_periksa_stamp_paraf'])
//           : null,
//       keluhan: json['keluhan_pemeriksaan_tindakan_saran'] ?? '',
//       tanggalKembali: json['tanggal_kembali'] != null
//           ? DateTime.tryParse(json['tanggal_kembali'])
//           : null,
//     );
//   }
// }


class CatatanPelayananKehamilanModel {
  final int idCatatan;
  final int kehamilanId;
  final int trimester;
  final DateTime? tanggalPeriksa;
  final String keluhan;
  final String penjelasan;
  final DateTime? tanggalKembali;

  CatatanPelayananKehamilanModel({
    required this.idCatatan,
    required this.kehamilanId,
    required this.trimester,
    required this.tanggalPeriksa,
    required this.keluhan,
    required this.penjelasan,
    required this.tanggalKembali,
  });

  // Tambahkan helper ini agar parsing tanggal aman dari berbagai format
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      // tryParse aman untuk format "2024-10-25" atau "2024-10-25T00:00:00Z"
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory CatatanPelayananKehamilanModel.fromJson(Map<String, dynamic> json) {
    return CatatanPelayananKehamilanModel(
      idCatatan: json['id_catatan'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      trimester: json['trimester'] ?? 0,
      
      // ⬇️ LOGIC BARU: Fallback ke tanggal_periksa jika stamp_paraf kosong
      tanggalPeriksa: _parseDate(json['tanggal_periksa_stamp_paraf']) ?? 
                       _parseDate(json['tanggal_periksa']),
                       
      keluhan: json['keluhan_pemeriksaan_tindakan_saran'] ?? '',
      penjelasan: json['penjelasan'] ?? '-',
      
      // ⬇️ LOGIC BARU: Juga pakai helper agar aman
      tanggalKembali: _parseDate(json['tanggal_kembali']),
    );
  }
}