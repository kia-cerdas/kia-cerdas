class RingkasanIbuHamilModel {
  final int total;
  final int trimester1;
  final int trimester2;
  final int trimester3;

  const RingkasanIbuHamilModel({
    required this.total,
    required this.trimester1,
    required this.trimester2,
    required this.trimester3,
  });

  factory RingkasanIbuHamilModel.empty() => const RingkasanIbuHamilModel(
        total: 0,
        trimester1: 0,
        trimester2: 0,
        trimester3: 0,
      );

  factory RingkasanIbuHamilModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RingkasanIbuHamilModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      trimester1: (json['trimester_1'] as num?)?.toInt() ?? 0,
      trimester2: (json['trimester_2'] as num?)?.toInt() ?? 0,
      trimester3: (json['trimester_3'] as num?)?.toInt() ?? 0,
    );
  }
}

class RingkasanVerifikasiModel {
  final String key;
  final String label;
  final int total;
  final int sudahVerifikasi;
  final int belumVerifikasi;

  const RingkasanVerifikasiModel({
    required this.key,
    required this.label,
    required this.total,
    required this.sudahVerifikasi,
    required this.belumVerifikasi,
  });

  factory RingkasanVerifikasiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RingkasanVerifikasiModel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      sudahVerifikasi: (json['sudah_verifikasi'] as num?)?.toInt() ?? 0,
      belumVerifikasi: (json['belum_verifikasi'] as num?)?.toInt() ?? 0,
    );
  }
}

class RingkasanDesaModel {
  final int? desaId;
  final String? namaDesa;
  final RingkasanIbuHamilModel ibuHamil;
  final int jumlahAnak;
  final int perluTindakLanjut;
  final List<RingkasanVerifikasiModel> verifikasi;

  const RingkasanDesaModel({
    required this.desaId,
    required this.namaDesa,
    required this.ibuHamil,
    required this.jumlahAnak,
    required this.perluTindakLanjut,
    required this.verifikasi,
  });

  factory RingkasanDesaModel.empty() => RingkasanDesaModel(
        desaId: null,
        namaDesa: null,
        ibuHamil: RingkasanIbuHamilModel.empty(),
        jumlahAnak: 0,
        perluTindakLanjut: 0,
        verifikasi: const [],
      );

  /// Mencari ringkasan verifikasi berdasarkan key menu (mis. 'kelas_ibu_balita').
  /// Mengembalikan null jika belum ada datanya (mis. masih loading).
  RingkasanVerifikasiModel? verifikasiByKey(String key) {
    for (final item in verifikasi) {
      if (item.key == key) return item;
    }
    return null;
  }

  factory RingkasanDesaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final ibuHamilJson = json['ibu_hamil'];
    final verifikasiJson = json['verifikasi'];

    return RingkasanDesaModel(
      desaId: (json['desa_id'] as num?)?.toInt(),
      namaDesa: json['nama_desa'] as String?,
      ibuHamil: ibuHamilJson is Map
          ? RingkasanIbuHamilModel.fromJson(
              Map<String, dynamic>.from(ibuHamilJson),
            )
          : RingkasanIbuHamilModel.empty(),
      jumlahAnak: (json['jumlah_anak'] as num?)?.toInt() ?? 0,
      perluTindakLanjut: (json['perlu_tindak_lanjut'] as num?)?.toInt() ?? 0,
      verifikasi: verifikasiJson is List
          ? verifikasiJson
              .map(
                (item) => RingkasanVerifikasiModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
          : const [],
    );
  }
}
