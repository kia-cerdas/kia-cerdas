// Model ini memetakan response dari endpoint:
//   GET /modul-ibu/riwayat-proses-melahirkan/me
//
// Sesuai Go struct models.RiwayatProsesMelahirkan dengan json tags:
//   id, kehamilan_id, g_gravida, p_partus, a_abortus,
//   hari_melahirkan, tanggal_melahirkan, pukul_melahirkan,
//   cara_melahirkan_spontan, cara_melahirkan_sungsang,
//   tindakan_ekstraksi_vakum, tindakan_ekstraksi_forsep, tindakan_sc,
//   penolong_dokter_spesialis, penolong_dokter, penolong_bidan,
//   taksiran_melahirkan, fasyankes_tempat_melahirkan,
//   rujukan_keterangan, inisiasi_menyusu_dini_keterangan,
//   cap_kaki_bayi_image_url, created_at

class RiwayatProsesMelahirkanModel {
  final int id;
  final int kehamilanId;

  // G/P/A
  final int gGravida;
  final int pPartus;
  final int aAbortus;

  // Waktu melahirkan
  final String hariMelahirkan;
  final String tanggalMelahirkan; // ISO date string: "2025-03-10T00:00:00Z"
  final String pukulMelahirkan;   // ISO datetime string, ambil jam:menit saja

  // Cara melahirkan
  final bool caraMelahirkanSpontan;
  final bool caraMelahirkanSungsang;

  // Tindakan
  final bool tindakanEkstraksiVakum;
  final bool tindakanEkstraksiForsep;
  final bool tindakanSC;

  // Penolong
  final bool penolongDokterSpesialis;
  final bool penolongDokter;
  final bool penolongBidan;

  // Catatan
  final String taksiranMelahirkan;
  final String fasyankesTempatMelahirkan;
  final String rujukanKeterangan;
  final String inisiasiMenyusuDiniKeterangan;

  // created_at untuk info tambahan
  final String createdAt;

  const RiwayatProsesMelahirkanModel({
    required this.id,
    required this.kehamilanId,
    required this.gGravida,
    required this.pPartus,
    required this.aAbortus,
    required this.hariMelahirkan,
    required this.tanggalMelahirkan,
    required this.pukulMelahirkan,
    required this.caraMelahirkanSpontan,
    required this.caraMelahirkanSungsang,
    required this.tindakanEkstraksiVakum,
    required this.tindakanEkstraksiForsep,
    required this.tindakanSC,
    required this.penolongDokterSpesialis,
    required this.penolongDokter,
    required this.penolongBidan,
    required this.taksiranMelahirkan,
    required this.fasyankesTempatMelahirkan,
    required this.rujukanKeterangan,
    required this.inisiasiMenyusuDiniKeterangan,
    required this.createdAt,
  });

  factory RiwayatProsesMelahirkanModel.empty() =>
      const RiwayatProsesMelahirkanModel(
        id: 0,
        kehamilanId: 0,
        gGravida: 0,
        pPartus: 0,
        aAbortus: 0,
        hariMelahirkan: '',
        tanggalMelahirkan: '',
        pukulMelahirkan: '',
        caraMelahirkanSpontan: false,
        caraMelahirkanSungsang: false,
        tindakanEkstraksiVakum: false,
        tindakanEkstraksiForsep: false,
        tindakanSC: false,
        penolongDokterSpesialis: false,
        penolongDokter: false,
        penolongBidan: false,
        taksiranMelahirkan: '',
        fasyankesTempatMelahirkan: '',
        rujukanKeterangan: '',
        inisiasiMenyusuDiniKeterangan: '',
        createdAt: '',
      );

  /// Apakah model ini benar-benar berisi data (bukan empty)?
  bool get hasData => id != 0;

  factory RiwayatProsesMelahirkanModel.fromJson(Map<String, dynamic> json) =>
      RiwayatProsesMelahirkanModel(
        id: _readInt(json, ['id']) ?? 0,
        kehamilanId: _readInt(json, ['kehamilan_id', 'kehamilanId']) ?? 0,
        gGravida: _readInt(json, ['g_gravida', 'gGravida']) ?? 0,
        pPartus: _readInt(json, ['p_partus', 'pPartus']) ?? 0,
        aAbortus: _readInt(json, ['a_abortus', 'aAbortus']) ?? 0,
        hariMelahirkan:
            _readString(json, ['hari_melahirkan', 'hariMelahirkan']),
        tanggalMelahirkan: _readDateString(
            json, ['tanggal_melahirkan', 'tanggalMelahirkan']),
        pukulMelahirkan: _readTimeString(
            json, ['pukul_melahirkan', 'pukulMelahirkan']),
        caraMelahirkanSpontan:
            _readBool(json, ['cara_melahirkan_spontan', 'caraMelahirkanSpontan']),
        caraMelahirkanSungsang: _readBool(
            json, ['cara_melahirkan_sungsang', 'caraMelahirkanSungsang']),
        tindakanEkstraksiVakum: _readBool(
            json, ['tindakan_ekstraksi_vakum', 'tindakanEkstraksiVakum']),
        tindakanEkstraksiForsep: _readBool(
            json, ['tindakan_ekstraksi_forsep', 'tindakanEkstraksiForsep']),
        tindakanSC: _readBool(json, ['tindakan_sc', 'tindakanSC']),
        penolongDokterSpesialis: _readBool(
            json, ['penolong_dokter_spesialis', 'penolongDokterSpesialis']),
        penolongDokter:
            _readBool(json, ['penolong_dokter', 'penolongDokter']),
        penolongBidan:
            _readBool(json, ['penolong_bidan', 'penolongBidan']),
        taksiranMelahirkan:
            _readString(json, ['taksiran_melahirkan', 'taksiranMelahirkan']),
        fasyankesTempatMelahirkan: _readString(
            json, ['fasyankes_tempat_melahirkan', 'fasyankesTempatMelahirkan']),
        rujukanKeterangan:
            _readString(json, ['rujukan_keterangan', 'rujukanKeterangan']),
        inisiasiMenyusuDiniKeterangan: _readString(json, [
          'inisiasi_menyusu_dini_keterangan',
          'inisiasiMenyusuDiniKeterangan'
        ]),
        createdAt: _readString(json, ['created_at', 'createdAt']),
      );

  // ── Helper: daftar cara melahirkan yang dipilih ──────────────────────────
  List<String> get caraMelahirkanList {
    final list = <String>[];
    if (caraMelahirkanSpontan) list.add('Spontan');
    if (caraMelahirkanSungsang) list.add('Sungsang');
    return list;
  }

  // ── Helper: daftar tindakan yang dipilih ────────────────────────────────
  List<String> get tindakanList {
    final list = <String>[];
    if (tindakanEkstraksiVakum) list.add('Ekstraksi Vakum');
    if (tindakanEkstraksiForsep) list.add('Ekstraksi Forsep');
    if (tindakanSC) list.add('SC');
    return list;
  }

  // ── Helper: daftar penolong yang dipilih ────────────────────────────────
  List<String> get penolongList {
    final list = <String>[];
    if (penolongDokterSpesialis) list.add('Dokter Spesialis');
    if (penolongDokter) list.add('Dokter');
    if (penolongBidan) list.add('Bidan');
    return list;
  }

  // ── Helper: format tanggal untuk tampil ─────────────────────────────────
  String get tanggalFormatted {
    if (tanggalMelahirkan.isEmpty) return '';
    try {
      final dt = DateTime.parse(tanggalMelahirkan);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return tanggalMelahirkan;
    }
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v == null) continue;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
  }
  return null;
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v == null) continue;
    if (v is String) return v;
    return v.toString();
  }
  return '';
}

bool _readBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v == null) continue;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) return v == 'true' || v == '1';
  }
  return false;
}

/// Ambil tanggal dari ISO datetime string, kembalikan date-only string (yyyy-MM-dd)
String _readDateString(Map<String, dynamic> json, List<String> keys) {
  final raw = _readString(json, keys);
  if (raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return dt.toIso8601String(); // simpan full; format UI di getter
  } catch (_) {
    return raw;
  }
}

/// Ambil jam dari ISO datetime string → format "HH:mm"
String _readTimeString(Map<String, dynamic> json, List<String> keys) {
  final raw = _readString(json, keys);
  if (raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } catch (_) {
    return raw;
  }
}