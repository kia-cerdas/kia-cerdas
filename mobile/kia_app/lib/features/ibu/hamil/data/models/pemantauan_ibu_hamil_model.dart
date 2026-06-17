// class PemantauanIbuHamilModel {
//   final int? id;
//   final int mingguKehamilan;
//   final bool demamLebih2Hari;
//   final bool sakitKepala;
//   final bool cemasBerlebih;
//   final bool resikoTB;
//   final bool gerakanBayiKurang;
//   final bool nyeriPerut;
//   final bool cairanJalanLahir;
//   final bool masalahKemaluan;
//   final bool diareBerulang;

//   const PemantauanIbuHamilModel({
//     this.id,
//     required this.mingguKehamilan,
//     required this.demamLebih2Hari,
//     required this.sakitKepala,
//     required this.cemasBerlebih,
//     required this.resikoTB,
//     required this.gerakanBayiKurang,
//     required this.nyeriPerut,
//     required this.cairanJalanLahir,
//     required this.masalahKemaluan,
//     required this.diareBerulang,
//   });

//   factory PemantauanIbuHamilModel.fromJson(Map<String, dynamic> json) {
//     return PemantauanIbuHamilModel(
//       id: json['id'],
//       mingguKehamilan: json['minggu_kehamilan'] ?? 0,
//       demamLebih2Hari: json['demam_lebih_2_hari'] ?? false,
//       sakitKepala: json['sakit_kepala'] ?? false,
//       cemasBerlebih: json['cemas_berlebih'] ?? false,
//       resikoTB: json['resiko_tb'] ?? false,
//       gerakanBayiKurang: json['gerakan_bayi_kurang'] ?? false,
//       nyeriPerut: json['nyeri_perut'] ?? false,
//       cairanJalanLahir: json['cairan_jalan_lahir'] ?? false,
//       masalahKemaluan: json['masalah_kemaluan'] ?? false,
//       diareBerulang: json['diare_berulang'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'minggu_kehamilan': mingguKehamilan,
//       'demam_lebih_2_hari': demamLebih2Hari,
//       'sakit_kepala': sakitKepala,
//       'cemas_berlebih': cemasBerlebih,
//       'resiko_tb': resikoTB,
//       'gerakan_bayi_kurang': gerakanBayiKurang,
//       'nyeri_perut': nyeriPerut,
//       'cairan_jalan_lahir': cairanJalanLahir,
//       'masalah_kemaluan': masalahKemaluan,
//       'diare_berulang': diareBerulang,
//     };
//   }
// }

// class PemantauanIbuHamilModel {
//   final int? id;
//   final int mingguKehamilan;
//   final bool demamLebih2Hari;
//   final bool sakitKepala;
//   final bool cemasBerlebih;
//   final bool resikoTB;
//   final bool gerakanBayiKurang;
//   final bool nyeriPerut;
//   final bool cairanJalanLahir;
//   final bool masalahKemaluan;
//   final bool diareBerulang;

//   /// Tanggal pertama kali data ini dibuat, dipakai untuk validasi
//   /// apakah masih boleh diedit (hanya hari ini & kemarin).
//   final DateTime? createdAt;

//   const PemantauanIbuHamilModel({
//     this.id,
//     required this.mingguKehamilan,
//     required this.demamLebih2Hari,
//     required this.sakitKepala,
//     required this.cemasBerlebih,
//     required this.resikoTB,
//     required this.gerakanBayiKurang,
//     required this.nyeriPerut,
//     required this.cairanJalanLahir,
//     required this.masalahKemaluan,
//     required this.diareBerulang,
//     this.createdAt,
//   });

//   factory PemantauanIbuHamilModel.fromJson(Map<String, dynamic> json) {
//     return PemantauanIbuHamilModel(
//       id: json['id'],
//       mingguKehamilan: json['minggu_kehamilan'] ?? 0,
//       demamLebih2Hari: json['demam_lebih_2_hari'] ?? false,
//       sakitKepala: json['sakit_kepala'] ?? false,
//       cemasBerlebih: json['cemas_berlebih'] ?? false,
//       resikoTB: json['resiko_tb'] ?? false,
//       gerakanBayiKurang: json['gerakan_bayi_kurang'] ?? false,
//       nyeriPerut: json['nyeri_perut'] ?? false,
//       cairanJalanLahir: json['cairan_jalan_lahir'] ?? false,
//       masalahKemaluan: json['masalah_kemaluan'] ?? false,
//       diareBerulang: json['diare_berulang'] ?? false,
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'].toString())
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'minggu_kehamilan': mingguKehamilan,
//       'demam_lebih_2_hari': demamLebih2Hari,
//       'sakit_kepala': sakitKepala,
//       'cemas_berlebih': cemasBerlebih,
//       'resiko_tb': resikoTB,
//       'gerakan_bayi_kurang': gerakanBayiKurang,
//       'nyeri_perut': nyeriPerut,
//       'cairan_jalan_lahir': cairanJalanLahir,
//       'masalah_kemaluan': masalahKemaluan,
//       'diare_berulang': diareBerulang,
//     };
//   }

//   /// Apakah data ini masih boleh diedit?
//   /// Aturan: hanya boleh jika belum pernah diisi (createdAt null),
//   /// atau jika createdAt adalah hari ini atau kemarin.
//   bool get isEditable {
//     if (createdAt == null) return true;
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final recordDay = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
//     return !recordDay.isBefore(yesterday);
//   }
// }

// ignore_for_file: unused_element

// ──────────────────────────────────────────────────────────────────────────────
// [VERSI LAMA — di-comment, jangan hapus]
// class PemantauanIbuHamilModel { ... }
// ──────────────────────────────────────────────────────────────────────────────

class PemantauanIbuHamilModel {
  final int? id;
  final int mingguKehamilan;
  final bool demamLebih2Hari;
  final bool sakitKepala;
  final bool cemasBerlebih;
  final bool resikoTB;
  final bool gerakanBayiKurang;
  final bool nyeriPerut;
  final bool cairanJalanLahir;
  final bool masalahKemaluan;
  final bool diareBerulang;

  /// Tanggal pertama kali data ini dibuat, dipakai untuk validasi
  /// apakah masih boleh diedit (hanya hari ini & kemarin).
  final DateTime? createdAt;

  /// Nama kader yang memverifikasi (kosong jika belum diverifikasi).
  final String namaKader;

  /// Tanggal kader memverifikasi (kosong jika belum diverifikasi).
  final String tanggalVerifikasi;

  const PemantauanIbuHamilModel({
    this.id,
    required this.mingguKehamilan,
    required this.demamLebih2Hari,
    required this.sakitKepala,
    required this.cemasBerlebih,
    required this.resikoTB,
    required this.gerakanBayiKurang,
    required this.nyeriPerut,
    required this.cairanJalanLahir,
    required this.masalahKemaluan,
    required this.diareBerulang,
    this.createdAt,
    this.namaKader = '',
    this.tanggalVerifikasi = '',
  });

  /// Apakah sudah diverifikasi oleh kader.
  bool get sudahDiverifikasi =>
      namaKader.isNotEmpty && tanggalVerifikasi.isNotEmpty;

  factory PemantauanIbuHamilModel.fromJson(Map<String, dynamic> json) {
    return PemantauanIbuHamilModel(
      id: json['id'],
      mingguKehamilan: json['minggu_kehamilan'] ?? 0,
      demamLebih2Hari: json['demam_lebih_2_hari'] ?? false,
      sakitKepala: json['sakit_kepala'] ?? false,
      cemasBerlebih: json['cemas_berlebih'] ?? false,
      resikoTB: json['resiko_tb'] ?? false,
      gerakanBayiKurang: json['gerakan_bayi_kurang'] ?? false,
      nyeriPerut: json['nyeri_perut'] ?? false,
      cairanJalanLahir: json['cairan_jalan_lahir'] ?? false,
      masalahKemaluan: json['masalah_kemaluan'] ?? false,
      diareBerulang: json['diare_berulang'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalVerifikasi: _readDate(json['tanggal_verifikasi']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minggu_kehamilan': mingguKehamilan,
      'demam_lebih_2_hari': demamLebih2Hari,
      'sakit_kepala': sakitKepala,
      'cemas_berlebih': cemasBerlebih,
      'resiko_tb': resikoTB,
      'gerakan_bayi_kurang': gerakanBayiKurang,
      'nyeri_perut': nyeriPerut,
      'cairan_jalan_lahir': cairanJalanLahir,
      'masalah_kemaluan': masalahKemaluan,
      'diare_berulang': diareBerulang,
    };
  }

  /// Apakah data ini masih boleh diedit?
  /// Aturan: hanya boleh jika belum pernah diisi (createdAt null),
  /// atau jika createdAt adalah hari ini atau kemarin.
  bool get isEditable {
    if (createdAt == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDay =
        DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    return !recordDay.isBefore(yesterday);
  }
}

String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}