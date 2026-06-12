// class KehamilanAktifModel {
//   final int id;
//   final int ibuId;
//   final int gravida;
//   final int paritas;
//   final int abortus;
//   final DateTime? hpht;
//   final DateTime? taksiranPersalinan;
//   final int ukKehamilanSaatIni;
//   final int jarakKehamilanSebelumnya;
//   final String statusKehamilan;
//   final double bbAwal;
//   final double tb;
//   final double imtAwal;

//   KehamilanAktifModel({
//     required this.id,
//     required this.ibuId,
//     required this.gravida,
//     required this.paritas,
//     required this.abortus,
//     this.hpht,
//     this.taksiranPersalinan,
//     required this.ukKehamilanSaatIni,
//     required this.jarakKehamilanSebelumnya,
//     required this.statusKehamilan,
//     this.bbAwal = 0.0,
//     this.tb = 0.0,
//     this.imtAwal = 0.0,
//   });

//   factory KehamilanAktifModel.fromJson(Map<String, dynamic> json) {
//     double toDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is num) return v.toDouble();
//       return double.tryParse(v.toString()) ?? 0.0;
//     }

//     return KehamilanAktifModel(
//       id: json['id'] ?? 0,
//       ibuId: json['ibu_id'] ?? 0,
//       gravida: json['gravida'] ?? 0,
//       paritas: json['paritas'] ?? 0,
//       abortus: json['abortus'] ?? 0,
//       hpht: json['hpht'] != null ? DateTime.tryParse(json['hpht']) : null,
//       taksiranPersalinan: json['taksiran_persalinan'] != null
//           ? DateTime.tryParse(json['taksiran_persalinan'])
//           : null,
//       ukKehamilanSaatIni: json['uk_kehamilan_saat_ini'] ?? 0,
//       jarakKehamilanSebelumnya: json['jarak_kehamilan_sebelumnya'] ?? 0,
//       statusKehamilan: json['status_kehamilan'] ?? '',
//       bbAwal: toDouble(json['bb_awal']),
//       tb: toDouble(json['tb']),
//       imtAwal: toDouble(json['imt_awal']),
//     );
//   }
// }


class KehamilanAktifModel {
  final int id;
  final int ibuId;
  final int gravida;
  final int paritas;
  final int abortus;
  final DateTime? hpht;
  final DateTime? taksiranPersalinan;
  final int ukKehamilanSaatIni;
  final int jarakKehamilanSebelumnya;
  final String statusKehamilan;
  final double bbAwal;
  final double tb;
  final double imtAwal;

  KehamilanAktifModel({
    required this.id,
    required this.ibuId,
    required this.gravida,
    required this.paritas,
    required this.abortus,
    this.hpht,
    this.taksiranPersalinan,
    required this.ukKehamilanSaatIni,
    required this.jarakKehamilanSebelumnya,
    required this.statusKehamilan,
    this.bbAwal = 0.0,
    this.tb = 0.0,
    this.imtAwal = 0.0,
  });

  factory KehamilanAktifModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final hpht =
        json['hpht'] != null ? DateTime.tryParse(json['hpht']) : null;

    // UK dari backend (sudah dihitung dinamis dari HPHT di backend).
    // Sebagai fallback: jika backend mengirim 0 atau null tapi HPHT ada,
    // hitung sendiri di Flutter agar UI tidak pernah menampilkan 0.
    int ukFromBackend = json['uk_kehamilan_saat_ini'] ?? 0;
    if (ukFromBackend == 0 && hpht != null) {
      ukFromBackend = _hitungUKDariHPHT(hpht);
    }

    return KehamilanAktifModel(
      id: json['id'] ?? 0,
      ibuId: json['ibu_id'] ?? 0,
      gravida: json['gravida'] ?? 0,
      paritas: json['paritas'] ?? 0,
      abortus: json['abortus'] ?? 0,
      hpht: hpht,
      taksiranPersalinan: json['taksiran_persalinan'] != null
          ? DateTime.tryParse(json['taksiran_persalinan'])
          : null,
      ukKehamilanSaatIni: ukFromBackend,
      jarakKehamilanSebelumnya: json['jarak_kehamilan_sebelumnya'] ?? 0,
      statusKehamilan: json['status_kehamilan'] ?? '',
      bbAwal: toDouble(json['bb_awal']),
      tb: toDouble(json['tb']),
      imtAwal: toDouble(json['imt_awal']),
    );
  }

  /// Hitung usia kehamilan dalam minggu dari HPHT hingga hari ini.
  /// Dipakai sebagai fallback jika backend mengirim 0.
  static int _hitungUKDariHPHT(DateTime hpht) {
    final now = DateTime.now();
    if (hpht.isAfter(now)) return 0;
    final days = now.difference(hpht).inDays;
    final weeks = days ~/ 7;
    return weeks.clamp(0, 42);
  }

  /// Getter: usia kehamilan dalam minggu dihitung real-time dari HPHT.
  /// Gunakan ini di UI agar selalu akurat meski data model sudah lama di memori.
  int get usiaKehamilanMinggu {
    if (hpht == null) return ukKehamilanSaatIni;
    return _hitungUKDariHPHT(hpht!);
  }

  /// Getter: usia kehamilan dalam hari (sisa hari setelah minggu penuh).
  int get usiaKehamilanHari {
    if (hpht == null) return 0;
    final now = DateTime.now();
    if (hpht!.isAfter(now)) return 0;
    final totalDays = now.difference(hpht!).inDays;
    return totalDays % 7;
  }

  /// Getter: label trimester berdasarkan UK saat ini.
  String get trimesterLabel {
    final minggu = usiaKehamilanMinggu;
    if (minggu <= 12) return 'Trimester I';
    if (minggu <= 27) return 'Trimester II';
    return 'Trimester III';
  }
}