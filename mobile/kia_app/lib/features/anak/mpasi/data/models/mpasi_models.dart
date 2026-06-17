class MateriMpasi {
  final int id;
  final String judul;
  final String konten;
  final int? bulanMin;
  final int? bulanMax;

  MateriMpasi({
    required this.id,
    required this.judul,
    required this.konten,
    this.bulanMin,
    this.bulanMax,
  });

  factory MateriMpasi.fromJson(Map<String, dynamic> json) {
    return MateriMpasi(
      id: json['id'],
      judul: json['judul'],
      konten: json['konten'],
      bulanMin: json['bulan_min'],
      bulanMax: json['bulan_max'],
    );
  }
}

class AturanPorsiMpasi {
  final int id;
  final String tekstur;
  final String frekuensi;
  final String porsi;

  AturanPorsiMpasi({
    required this.id,
    required this.tekstur,
    required this.frekuensi,
    required this.porsi,
  });

  factory AturanPorsiMpasi.fromJson(Map<String, dynamic> json) {
    return AturanPorsiMpasi(
      id: json['id'],
      tekstur: json['tekstur'],
      frekuensi: json['frekuensi'],
      porsi: json['porsi'],
    );
  }
}

class JadwalHarianMpasi {
  final int id;
  final String waktu;
  final String aktivitas;

  JadwalHarianMpasi({
    required this.id,
    required this.waktu,
    required this.aktivitas,
  });

  factory JadwalHarianMpasi.fromJson(Map<String, dynamic> json) {
    return JadwalHarianMpasi(
      id: json['id'],
      waktu: json['waktu'],
      aktivitas: json['aktivitas'],
    );
  }
}

class PorsiJadwalResponse {
  final AturanPorsiMpasi? aturanPorsi;
  final List<JadwalHarianMpasi> jadwalHarian;

  PorsiJadwalResponse({
    this.aturanPorsi,
    required this.jadwalHarian,
  });

  factory PorsiJadwalResponse.fromJson(Map<String, dynamic> json) {
    var jadwalList = json['jadwal_harian'] as List? ?? [];
    return PorsiJadwalResponse(
      aturanPorsi: json['aturan_porsi'] != null
          ? AturanPorsiMpasi.fromJson(json['aturan_porsi'])
          : null,
      jadwalHarian: jadwalList.map((e) => JadwalHarianMpasi.fromJson(e)).toList(),
    );
  }
}

class ResepMpasi {
  final int id;
  final String judul;
  final String tipe;
  final String? gambarUrl;
  final int waktuPersiapan;
  final int kalori;
  final String porsi;
  final List<String> bahanBahan;
  final List<String> caraMembuat;
  final String? manfaat;
  final String? tips;

  ResepMpasi({
    required this.id,
    required this.judul,
    required this.tipe,
    this.gambarUrl,
    required this.waktuPersiapan,
    required this.kalori,
    required this.porsi,
    required this.bahanBahan,
    required this.caraMembuat,
    this.manfaat,
    this.tips,
  });

  factory ResepMpasi.fromJson(Map<String, dynamic> json) {
    return ResepMpasi(
      id: json['id'],
      judul: json['judul'],
      tipe: json['tipe'],
      gambarUrl: json['gambar_url'],
      waktuPersiapan: json['waktu_persiapan'],
      kalori: json['kalori'],
      porsi: json['porsi'],
      bahanBahan: List<String>.from(json['bahan_bahan'] ?? []),
      caraMembuat: List<String>.from(json['cara_membuat'] ?? []),
      manfaat: json['manfaat'],
      tips: json['tips'],
    );
  }
}
