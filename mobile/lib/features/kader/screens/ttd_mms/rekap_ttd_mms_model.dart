// class RekapTTDMMSModel {
//   final int ibuId;
//   final int kehamilanId;
//   final String namaIbu;
//   final int bulanKe;
//   final int totalHari;
//   final int totalDiminum;
//   final int totalTerlewat;
//   /// HPHT digunakan oleh detail screen untuk menghitung status tiap hari
//   /// (sudah lewat / belum / future). Null jika backend belum kirim field ini.
//   final DateTime? hpht;

//   const RekapTTDMMSModel({
//     required this.ibuId,
//     required this.kehamilanId,
//     required this.namaIbu,
//     required this.bulanKe,
//     required this.totalHari,
//     required this.totalDiminum,
//     required this.totalTerlewat,
//     this.hpht,
//   });

//   factory RekapTTDMMSModel.fromJson(Map<String, dynamic> json) {
//     DateTime? parsedHpht;
//     if (json['hpht'] != null) {
//       try {
//         parsedHpht = DateTime.parse(json['hpht'].toString());
//       } catch (_) {
//         parsedHpht = null;
//       }
//     }

//     return RekapTTDMMSModel(
//       ibuId: json['ibu_id'] ?? 0,
//       kehamilanId: json['kehamilan_id'] ?? 0,
//       namaIbu: json['nama_ibu'] ?? '',
//       bulanKe: json['bulan_ke'] ?? 0,
//       totalHari: json['total_hari'] ?? 0,
//       totalDiminum: json['total_diminum'] ?? 0,
//       totalTerlewat: json['total_terlewat'] ?? 0,
//       hpht: parsedHpht,
//     );
//   }

//   /// Persentase kepatuhan keseluruhan (0.0 – 1.0)
//   double get persentase {
//     if (totalHari == 0) return 0;
//     return totalDiminum / totalHari;
//   }

//   /// Label status berdasarkan persentase
//   StatusKepatuhan get status {
//     final p = persentase;
//     if (p >= 0.8) return StatusKepatuhan.patuh;
//     if (p >= 0.5) return StatusKepatuhan.perluPantau;
//     return StatusKepatuhan.tidakPatuh;
//   }
// }

// enum StatusKepatuhan { patuh, perluPantau, tidakPatuh }

class RekapTTDMMSModel {
  final int ibuId;
  final int kehamilanId;
  final String namaIbu;
  final int bulanKe;
  final int totalHari;
  final int totalDiminum;
  final int totalTerlewat;
  final DateTime? hpht;
  final String statusKehamilan;

  const RekapTTDMMSModel({
    required this.ibuId,
    required this.kehamilanId,
    required this.namaIbu,
    required this.bulanKe,
    required this.totalHari,
    required this.totalDiminum,
    required this.totalTerlewat,
    required this.statusKehamilan,
    this.hpht,
  });

  bool get isNifas => statusKehamilan == 'NIFAS';

  factory RekapTTDMMSModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedHpht;
    if (json['hpht'] != null) {
      try {
        parsedHpht = DateTime.parse(json['hpht'].toString());
      } catch (_) {
        parsedHpht = null;
      }
    }

    return RekapTTDMMSModel(
      ibuId: json['ibu_id'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      namaIbu: json['nama_ibu'] ?? '',
      bulanKe: json['bulan_ke'] ?? 0,
      totalHari: json['total_hari'] ?? 0,
      totalDiminum: json['total_diminum'] ?? 0,
      totalTerlewat: json['total_terlewat'] ?? 0,
      statusKehamilan: json['status_kehamilan'] ?? '',
      hpht: parsedHpht,
    );
  }

  /// Persentase kepatuhan keseluruhan (0.0 – 1.0)
  double get persentase {
    if (totalHari == 0) return 0;
    return totalDiminum / totalHari;
  }

  /// Label status berdasarkan persentase
  StatusKepatuhan get status {
    final p = persentase;
    if (p >= 0.8) return StatusKepatuhan.patuh;
    if (p >= 0.5) return StatusKepatuhan.perluPantau;
    return StatusKepatuhan.tidakPatuh;
  }
}

enum StatusKepatuhan { patuh, perluPantau, tidakPatuh }