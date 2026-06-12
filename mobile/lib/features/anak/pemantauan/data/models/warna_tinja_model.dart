class WarnaTinjaModel {
  final int id;
  final int anakId;
  final String periodeKey;
  final String periodeLabel;
  final String tanggalCatat;
  final int nomorWarna;

  const WarnaTinjaModel({
    required this.id,
    required this.anakId,
    required this.periodeKey,
    required this.periodeLabel,
    required this.tanggalCatat,
    required this.nomorWarna,
  });

  factory WarnaTinjaModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return WarnaTinjaModel(
      id: parseInt(json['id']),
      anakId: parseInt(json['anak_id']),
      periodeKey: (json['periode_key'] ?? '').toString(),
      periodeLabel: (json['periode_label'] ?? '').toString(),
      tanggalCatat: (json['tanggal_catat'] ?? '').toString(),
      nomorWarna: parseInt(json['nomor_warna']),
    );
  }
}
