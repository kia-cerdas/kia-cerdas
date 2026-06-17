class PersiapanMelahirkanModel {
  final int? id;
  final int? kehamilanId;
  final bool perkiraanPersalinan;
  final bool pendampingPersalinan;
  final bool danaPersalinan;
  final bool statusJkn;
  final bool faskesPersalinan;
  final bool pendonorDarah;
  final bool transportasi;
  final bool metodeKb;
  final bool programP4k;
  final bool dokumenPenting;

  const PersiapanMelahirkanModel({
    this.id,
    this.kehamilanId,
    required this.perkiraanPersalinan,
    required this.pendampingPersalinan,
    required this.danaPersalinan,
    required this.statusJkn,
    required this.faskesPersalinan,
    required this.pendonorDarah,
    required this.transportasi,
    required this.metodeKb,
    required this.programP4k,
    required this.dokumenPenting,
  });

  factory PersiapanMelahirkanModel.empty() => const PersiapanMelahirkanModel(
        perkiraanPersalinan: false,
        pendampingPersalinan: false,
        danaPersalinan: false,
        statusJkn: false,
        faskesPersalinan: false,
        pendonorDarah: false,
        transportasi: false,
        metodeKb: false,
        programP4k: false,
        dokumenPenting: false,
      );

  factory PersiapanMelahirkanModel.fromJson(Map<String, dynamic> json) {
    return PersiapanMelahirkanModel(
      id: json['id'] as int?,
      kehamilanId: json['kehamilan_id'] as int?,
      perkiraanPersalinan: _readBool(json, 'perkiraan_persalinan'),
      pendampingPersalinan: _readBool(json, 'pendamping_persalinan'),
      danaPersalinan: _readBool(json, 'dana_persalinan'),
      statusJkn: _readBool(json, 'status_jkn'),
      faskesPersalinan: _readBool(json, 'faskes_persalinan'),
      pendonorDarah: _readBool(json, 'pendonor_darah'),
      transportasi: _readBool(json, 'transportasi'),
      metodeKb: _readBool(json, 'metode_kb'),
      programP4k: _readBool(json, 'program_p4k'),
      dokumenPenting: _readBool(json, 'dokumen_penting'),
    );
  }

  Map<String, dynamic> toJson() => {
        'perkiraan_persalinan': perkiraanPersalinan,
        'pendamping_persalinan': pendampingPersalinan,
        'dana_persalinan': danaPersalinan,
        'status_jkn': statusJkn,
        'faskes_persalinan': faskesPersalinan,
        'pendonor_darah': pendonorDarah,
        'transportasi': transportasi,
        'metode_kb': metodeKb,
        'program_p4k': programP4k,
        'dokumen_penting': dokumenPenting,
      };

  PersiapanMelahirkanModel copyWith({
    int? id,
    int? kehamilanId,
    bool? perkiraanPersalinan,
    bool? pendampingPersalinan,
    bool? danaPersalinan,
    bool? statusJkn,
    bool? faskesPersalinan,
    bool? pendonorDarah,
    bool? transportasi,
    bool? metodeKb,
    bool? programP4k,
    bool? dokumenPenting,
  }) =>
      PersiapanMelahirkanModel(
        id: id ?? this.id,
        kehamilanId: kehamilanId ?? this.kehamilanId,
        perkiraanPersalinan: perkiraanPersalinan ?? this.perkiraanPersalinan,
        pendampingPersalinan: pendampingPersalinan ?? this.pendampingPersalinan,
        danaPersalinan: danaPersalinan ?? this.danaPersalinan,
        statusJkn: statusJkn ?? this.statusJkn,
        faskesPersalinan: faskesPersalinan ?? this.faskesPersalinan,
        pendonorDarah: pendonorDarah ?? this.pendonorDarah,
        transportasi: transportasi ?? this.transportasi,
        metodeKb: metodeKb ?? this.metodeKb,
        programP4k: programP4k ?? this.programP4k,
        dokumenPenting: dokumenPenting ?? this.dokumenPenting,
      );

  int get totalChecked => [
        perkiraanPersalinan,
        pendampingPersalinan,
        danaPersalinan,
        statusJkn,
        faskesPersalinan,
        pendonorDarah,
        transportasi,
        metodeKb,
        programP4k,
        dokumenPenting,
      ].where((v) => v).length;

  static const int totalItems = 10;
}

bool _readBool(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}
