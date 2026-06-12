class ChecklistProsesMelahirkanModel {
  final int? id;
  final int? kehamilanId;
  final bool tandaPersalinan;
  final bool prosesMelahirkan;
  final bool hakIbuPendamping;
  final bool hakIbuPosisiMelahirkan;
  final bool mulas;
  final bool teknikMengurangiNyeri;
  final bool imdKontakKulit;

  const ChecklistProsesMelahirkanModel({
    this.id,
    this.kehamilanId,
    required this.tandaPersalinan,
    required this.prosesMelahirkan,
    required this.hakIbuPendamping,
    required this.hakIbuPosisiMelahirkan,
    required this.mulas,
    required this.teknikMengurangiNyeri,
    required this.imdKontakKulit,
  });

  factory ChecklistProsesMelahirkanModel.empty() =>
      const ChecklistProsesMelahirkanModel(
        tandaPersalinan: false,
        prosesMelahirkan: false,
        hakIbuPendamping: false,
        hakIbuPosisiMelahirkan: false,
        mulas: false,
        teknikMengurangiNyeri: false,
        imdKontakKulit: false,
      );

  factory ChecklistProsesMelahirkanModel.fromJson(Map<String, dynamic> json) {
    return ChecklistProsesMelahirkanModel(
      id: json['id'] as int?,
      kehamilanId: json['kehamilan_id'] as int?,
      tandaPersalinan: _readBool(json, 'tanda_persalinan'),
      prosesMelahirkan: _readBool(json, 'proses_melahirkan'),
      hakIbuPendamping: _readBool(json, 'hak_ibu_pendamping'),
      hakIbuPosisiMelahirkan: _readBool(json, 'hak_ibu_posisi_melahirkan'),
      mulas: _readBool(json, 'mulas'),
      teknikMengurangiNyeri: _readBool(json, 'teknik_mengurangi_nyeri'),
      imdKontakKulit: _readBool(json, 'imd_kontak_kulit'),
    );
  }

  Map<String, dynamic> toJson() => {
        'tanda_persalinan': tandaPersalinan,
        'proses_melahirkan': prosesMelahirkan,
        'hak_ibu_pendamping': hakIbuPendamping,
        'hak_ibu_posisi_melahirkan': hakIbuPosisiMelahirkan,
        'mulas': mulas,
        'teknik_mengurangi_nyeri': teknikMengurangiNyeri,
        'imd_kontak_kulit': imdKontakKulit,
      };

  ChecklistProsesMelahirkanModel copyWith({
    int? id,
    int? kehamilanId,
    bool? tandaPersalinan,
    bool? prosesMelahirkan,
    bool? hakIbuPendamping,
    bool? hakIbuPosisiMelahirkan,
    bool? mulas,
    bool? teknikMengurangiNyeri,
    bool? imdKontakKulit,
  }) =>
      ChecklistProsesMelahirkanModel(
        id: id ?? this.id,
        kehamilanId: kehamilanId ?? this.kehamilanId,
        tandaPersalinan: tandaPersalinan ?? this.tandaPersalinan,
        prosesMelahirkan: prosesMelahirkan ?? this.prosesMelahirkan,
        hakIbuPendamping: hakIbuPendamping ?? this.hakIbuPendamping,
        hakIbuPosisiMelahirkan:
            hakIbuPosisiMelahirkan ?? this.hakIbuPosisiMelahirkan,
        mulas: mulas ?? this.mulas,
        teknikMengurangiNyeri:
            teknikMengurangiNyeri ?? this.teknikMengurangiNyeri,
        imdKontakKulit: imdKontakKulit ?? this.imdKontakKulit,
      );

  int get totalChecked => [
        tandaPersalinan,
        prosesMelahirkan,
        hakIbuPendamping,
        hakIbuPosisiMelahirkan,
        mulas,
        teknikMengurangiNyeri,
        imdKontakKulit,
      ].where((v) => v).length;

  static const int totalItems = 7;
}

bool _readBool(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}
