class AbsensiKelasIbuHamilModel {
  final int? id;
  final int kehamilanId;
  final int pertemuanKe;
  final String tanggal;
  final String namaKader;
  final String tanggalParaf;
  final String namaIbu;

  const AbsensiKelasIbuHamilModel({
    this.id,
    required this.kehamilanId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.namaKader,
    required this.tanggalParaf,
    this.namaIbu = '',
  });

  factory AbsensiKelasIbuHamilModel.fromJson(Map<String, dynamic> json) {
    String namaIbu = '';
    final kehamilan = json['kehamilan'];
    if (kehamilan != null) {
      final ibu = kehamilan['ibu'];
      if (ibu != null) {
        final kpd = ibu['kependudukan'];
        if (kpd != null) {
          namaIbu = kpd['nama_lengkap']?.toString() ??
              kpd['nama_anggota_keluarga']?.toString() ??
              kpd['nama']?.toString() ??
              '';
        }
      }
    }

    return AbsensiKelasIbuHamilModel(
      id: json['id'],
      kehamilanId: json['kehamilan_id'] ?? 0,
      pertemuanKe: json['pertemuan_ke'] ?? 0,
      tanggal: _readDate(json['tanggal']),
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalParaf: _readDate(json['tanggal_paraf']),
      namaIbu: namaIbu,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kehamilan_id': kehamilanId,
      'pertemuan_ke': pertemuanKe,
      'tanggal': tanggal,
      'nama_kader': namaKader,
      'tanggal_paraf': tanggalParaf,
    };
  }
}

String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}