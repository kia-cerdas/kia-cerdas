class AbsensiKelasIbuBalitaModel {
  final int? id;
  final int pertemuanKe;
  final String tanggal;
  final String namaKader;
  final String tanggalParaf;
  final String namaIbu;
  final String namaAnak;
  final String status;

  const AbsensiKelasIbuBalitaModel({
    this.id,
    required this.pertemuanKe,
    required this.tanggal,
    required this.namaKader,
    required this.tanggalParaf,
    this.namaIbu = '',
    this.namaAnak = '',
    this.status = 'Menunggu Verifikasi',
  });

  factory AbsensiKelasIbuBalitaModel.fromJson(Map<String, dynamic> json) {
    String namaIbu = '';
    String namaAnak = '';

    if (json['ibu'] != null) {
      if (json['ibu']['kependudukan'] != null) {
        namaIbu = json['ibu']['kependudukan']['nama_lengkap']?.toString() ??
            json['ibu']['kependudukan']['nama_anggota_keluarga']?.toString() ??
            json['ibu']['kependudukan']['nama']?.toString() ?? '';
      }
      
      if (json['ibu']['anak'] is List) {
        final anakList = json['ibu']['anak'] as List;
        final List<String> names = [];
        for (var anakItem in anakList) {
          if (anakItem['penduduk'] != null && anakItem['penduduk']['nama_lengkap'] != null) {
            names.add(anakItem['penduduk']['nama_lengkap'].toString());
          } else if (anakItem['penduduk'] != null && anakItem['penduduk']['nama_anggota_keluarga'] != null) {
            names.add(anakItem['penduduk']['nama_anggota_keluarga'].toString());
          } else if (anakItem['penduduk'] != null && anakItem['penduduk']['nama'] != null) {
            names.add(anakItem['penduduk']['nama'].toString());
          } else if (anakItem['nama_anak'] != null) {
            names.add(anakItem['nama_anak'].toString());
          } else if (anakItem['nama'] != null) {
            names.add(anakItem['nama'].toString());
          }
        }
        namaAnak = names.join(', ');
      }
    }

    return AbsensiKelasIbuBalitaModel(
      id: json['id'],
      pertemuanKe: json['pertemuan_ke'] ?? 0,
      tanggal: _readDate(json['tanggal']),
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalParaf: _readDate(json['tanggal_paraf']),
      namaIbu: namaIbu,
      namaAnak: namaAnak,
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
