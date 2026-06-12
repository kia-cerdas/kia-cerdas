class AbsensiKelasIbuBalitaModel {
  final int? id;
  final int pertemuanKe;
  final String tanggal;
  final String namaKader;
  final String tanggalParaf;
  final String namaIbu;
  final String status;

  const AbsensiKelasIbuBalitaModel({
    this.id,
    required this.pertemuanKe,
    required this.tanggal,
    required this.namaKader,
    required this.tanggalParaf,
    this.namaIbu = '',
    this.status = 'Menunggu Verifikasi',
  });

  factory AbsensiKelasIbuBalitaModel.fromJson(Map<String, dynamic> json) {
    String namaIbu = '';
    if (json['ibu'] != null && json['ibu']['kependudukan'] != null) {
      namaIbu = json['ibu']['kependudukan']['nama']?.toString() ?? '';
    }

    return AbsensiKelasIbuBalitaModel(
      id: json['id'],
      pertemuanKe: json['pertemuan_ke'] ?? 0,
      tanggal: _readDate(json['tanggal']),
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalParaf: _readDate(json['tanggal_paraf']),
      namaIbu: namaIbu,
      status: json['status']?.toString() ?? 'Menunggu Verifikasi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
