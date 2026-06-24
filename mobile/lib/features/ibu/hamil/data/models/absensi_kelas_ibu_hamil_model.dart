// =============================================================
// MODEL: Absensi Kelas Ibu Hamil
// -------------------------------------------------------------
// Model = "cetakan/wadah data". Ibarat formulir kosong yang
// punya kolom-kolom tertentu (id, tanggal, status, dst).
// Tugasnya: menerjemahkan data JSON dari backend Go menjadi
// objek Dart yang rapi, dan sebaliknya.
// =============================================================

class AbsensiKelasIbuHamilModel {
  final int? id;
  final int pertemuanKe;
  final String tanggal;
  final String namaKader;
  final String tanggalParaf;
  final String status;

  const AbsensiKelasIbuHamilModel({
    this.id,
    required this.pertemuanKe,
    required this.tanggal,
    required this.namaKader,
    required this.tanggalParaf,
    this.status = 'Menunggu Verifikasi',
  });

  // fromJson = menerjemahkan "bahasa backend" (JSON) -> objek Dart.
  // Dipakai saat kita MENERIMA data dari server.
  factory AbsensiKelasIbuHamilModel.fromJson(Map<String, dynamic> json) {
    return AbsensiKelasIbuHamilModel(
      id: json['id'],
      pertemuanKe: json['pertemuan_ke'] ?? 0,
      tanggal: _readDate(json['tanggal']),
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalParaf: _readDate(json['tanggal_paraf']),
      status: json['status']?.toString() ?? 'Menunggu Verifikasi',
    );
  }

  // toJson = menerjemahkan objek Dart -> "bahasa backend" (JSON).
  // Dipakai saat kita MENGIRIM data ke server.
  Map<String, dynamic> toJson() {
    return {
      'pertemuan_ke': pertemuanKe,
      'tanggal': tanggal,
      'nama_kader': namaKader,
      'tanggal_paraf': tanggalParaf,
    };
  }
}

// Helper kecil: backend kadang mengirim tanggal lengkap dengan jam
// (contoh: "2025-06-16T00:00:00Z"). Kita cukup ambil 10 karakter
// pertama saja -> "2025-06-16". Ibarat memotong tanggal dari struk.
String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}