class BblCheckModel {
  final int id;
  final int bblId;
  final String periodeWaktu;
  final bool statusPemeriksaan;
  final DateTime? tanggalSubmit;
  final bool isVerified;
  final String status;
  final DateTime? verifiedAt;
  final int? verifiedByKaderId;
  final String? namaKaderVerifikasi;

  BblCheckModel({
    required this.id,
    required this.bblId,
    required this.periodeWaktu,
    required this.statusPemeriksaan,
    this.tanggalSubmit,
    this.isVerified = false,
    this.status = 'Menunggu verifikasi',
    this.verifiedAt,
    this.verifiedByKaderId,
    this.namaKaderVerifikasi,
  });

  factory BblCheckModel.fromJson(Map<String, dynamic> json) {
    String? namaKader;
    if (json['verified_by_kader'] != null) {
      final kader = json['verified_by_kader'] as Map<String, dynamic>;
      if (kader['penduduk'] != null) {
        final penduduk = kader['penduduk'] as Map<String, dynamic>;
        namaKader = penduduk['nama_lengkap'] as String? ?? penduduk['nama_anggota_keluarga'] as String?;
      }
    }

    return BblCheckModel(
      id: (json['id'] ?? 0) as int,
      bblId: (json['bbl_id'] ?? 0) as int,
      periodeWaktu: (json['periode_waktu'] ?? '') as String,
      statusPemeriksaan: json['status_pemeriksaan'] == true,
      tanggalSubmit: json['tanggal_submit'] != null
          ? DateTime.parse(json['tanggal_submit'] as String)
          : null,
      isVerified: json['is_verified'] == true,
      status: (json['status'] ?? 'Menunggu verifikasi') as String,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verifiedByKaderId: json['verified_by_kader_id'] as int?,
      namaKaderVerifikasi: namaKader,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'periode_waktu': periodeWaktu,
      'status_pemeriksaan': statusPemeriksaan,
      'tanggal_submit': tanggalSubmit?.toUtc().toIso8601String(),
    };
  }
}

class BblModel {
  final int id;
  final int anakId;
  final List<BblCheckModel> checklist;
  final String? namaAnak;

  BblModel({
    required this.id,
    required this.anakId,
    required this.checklist,
    this.namaAnak,
  });

  factory BblModel.fromJson(Map<String, dynamic> json) {
    // Parse checklist
    List<BblCheckModel> checklistData = [];
    if (json['checklist'] != null && json['checklist'] is List) {
      checklistData = (json['checklist'] as List)
          .map((e) => BblCheckModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    String? namaAnakStr;
    if (json['anak'] != null) {
      final anak = json['anak'] as Map<String, dynamic>;
      if (anak['penduduk'] != null) {
        final pendudukAnak = anak['penduduk'] as Map<String, dynamic>;
        namaAnakStr = pendudukAnak['nama_lengkap'] as String? ?? pendudukAnak['nama_anggota_keluarga'] as String?;
      }
      if (namaAnakStr == null || namaAnakStr.isEmpty) {
        namaAnakStr = anak['nama_lengkap'] as String? ?? anak['nama'] as String?;
      }
    }

    return BblModel(
      id: (json['id'] ?? 0) as int,
      anakId: (json['anak_id'] ?? 0) as int,
      checklist: checklistData,
      namaAnak: namaAnakStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checklist': checklist.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper: get BblCheck by periode_waktu
  BblCheckModel? getCheckByPeriode(String periode) {
    try {
      return checklist.firstWhere((c) => c.periodeWaktu == periode);
    } catch (_) {
      return null;
    }
  }
}
