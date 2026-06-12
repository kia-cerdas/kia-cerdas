class ImunisasiModel {
  final int anakId;
  final String namaAnak;
  final DateTime? tanggalLahir;
  final List<JadwalImunisasiModel> jadwal;
  final int jumlahTerlewat;

  ImunisasiModel({
    required this.anakId,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jadwal,
    required this.jumlahTerlewat,
  });

  factory ImunisasiModel.fromJson(Map<String, dynamic> json) {
    return ImunisasiModel(
      anakId: json['anak_id'] ?? 0,
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'])
          : null,
      jadwal: (json['jadwal'] as List?)
              ?.map(
                (item) => JadwalImunisasiModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          [],
      jumlahTerlewat: (json['jumlah_terlewat'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anak_id': anakId,
      'nama_anak': namaAnak,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'jadwal': jadwal.map((e) => e.toJson()).toList(),
      'jumlah_terlewat': jumlahTerlewat,
    };
  }
}

class JadwalImunisasiModel {
  final int jadwalId;
  final String namaDosis;
  final DateTime? tanggalEstimasi;
  final int statusId;
  final String status;
  final String deskripsi;
  final String efekSamping;

  JadwalImunisasiModel({
    required this.jadwalId,
    required this.namaDosis,
    required this.tanggalEstimasi,
    required this.statusId,
    required this.status,
    required this.deskripsi,
    required this.efekSamping,
  });

  factory JadwalImunisasiModel.fromJson(Map<String, dynamic> json) {
    return JadwalImunisasiModel(
      jadwalId: (json['jadwal_id'] as num?)?.toInt() ?? 0,
      namaDosis: json['nama_dosis'] ?? '',
      tanggalEstimasi: json['tanggal_estimasi'] != null
          ? DateTime.parse(json['tanggal_estimasi'])
          : null,
      statusId: (json['status_id'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      efekSamping: json['efek_samping'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jadwal_id': jadwalId,
      'nama_dosis': namaDosis,
      'tanggal_estimasi': tanggalEstimasi?.toIso8601String(),
      'status_id': statusId,
      'status': status,
      'deskripsi': deskripsi,
      'efek_samping': efekSamping,
    };
  }
}

class ImunisasiDetailModel {
  final int anakId;
  final String namaAnak;
  final DateTime? tanggalLahir;
  final int jumlahTerlewat;
  final List<JadwalImunisasiModel> jadwal;

  ImunisasiDetailModel({
    required this.anakId,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jumlahTerlewat,
    required this.jadwal,
  });

  factory ImunisasiDetailModel.fromJson(Map<String, dynamic> json) {
    final rawJadwal = json['jadwal'];

    List<JadwalImunisasiModel> jadwalList = [];

    if (rawJadwal is List) {
      jadwalList = rawJadwal
          .whereType<Map>() // amanin tipe
          .map((e) => JadwalImunisasiModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return ImunisasiDetailModel(
      anakId: (json['anak_id'] as num?)?.toInt() ?? 0,
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: _parseDate(json['tanggal_lahir']),
      jumlahTerlewat: (json['jumlah_terlewat'] as num?)?.toInt() ?? 0,
      jadwal: jadwalList,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

class RequestPerubahanJadwalRequest {
  final String tanggalBaru;
  final String alasan;

  RequestPerubahanJadwalRequest({
    required this.tanggalBaru,
    required this.alasan,
  });

  Map<String, dynamic> toJson() {
    return {
      "tanggal_estimasi": tanggalBaru,
      "alasan": alasan,
    };
  }
}

class SetJadwalSelesaiRequest {
  final int jadwalId;

  SetJadwalSelesaiRequest({
    required this.jadwalId,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": jadwalId,
    };
  }
}
