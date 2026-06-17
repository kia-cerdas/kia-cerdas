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
    if (!json.containsKey('jadwal') && (json.containsKey('id_anak') || json.containsKey('id'))) {
      return ImunisasiModel(
        anakId: json['id_anak'] is int ? json['id_anak'] : (int.tryParse(json['id_anak']?.toString() ?? '') ?? 0),
        namaAnak: json['nama_anak'] ?? '', 
        tanggalLahir: json['tanggal_lahir'] != null ? DateTime.tryParse(json['tanggal_lahir'].toString()) : null,
        jumlahTerlewat: 0,
        jadwal: [JadwalImunisasiModel.fromJson(json)],
      );
    }

    return ImunisasiModel(
      anakId: json['anak_id'] is int ? json['anak_id'] : (int.tryParse(json['anak_id']?.toString() ?? '') ?? 0),
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'].toString())
          : null,
      jadwal: (json['jadwal'] as List?)
              ?.map(
                (item) => JadwalImunisasiModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          [],
      // Mengamankan jumlah_terlewat dari String server
      jumlahTerlewat: json['jumlah_terlewat'] is int 
          ? json['jumlah_terlewat'] 
          : (int.tryParse(json['jumlah_terlewat']?.toString() ?? '') ?? 0),
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
    // 1. Ambil ID Jadwal dan ID Status secara aman
    final int idJadwal = json['jadwal_id'] is int 
        ? json['jadwal_id'] 
        : (int.tryParse(json['jadwal_id']?.toString() ?? json['id']?.toString() ?? '') ?? 0);

    final int idStatus = json['status_id'] is int 
        ? json['status_id'] 
        : (int.tryParse(json['status_id']?.toString() ?? json['id_status_jadwal']?.toString() ?? '') ?? 0);

    // 2. 🛠️ KUNCI UTAMA OFFLINE: Terjemahkan angka status ID dari SQLite menjadi teks yang dikenali oleh UI Screen
    String textStatus = json['status']?.toString() ?? '';
    if (textStatus.isEmpty) {
      switch (idStatus) {
        case 1:
          textStatus = 'Mendekati';
          break;
        case 5:
          textStatus = 'Krisis';
          break;
        case 6:
          textStatus = 'Selesai';
          break;
        default:
          textStatus = 'Mendekati'; // Fallback default aman
      }
    }

    // 3. 🛠️ TERJEMAHKAN NAMA DOSIS BERDASARKAN ID JADWAL/DOSIS SAAT OFFLINE
    String textDosis = json['nama_dosis']?.toString() ?? '';
    if (textDosis.isEmpty) {
      // Siasati rujukan nama dosis berdasarkan idJadwal agar UI tidak kosongan saat offline
      switch (idJadwal) {
        case 13: textDosis = 'HB-0'; break;
        case 14: textDosis = 'BCG'; break;
        case 15: textDosis = 'Polio OPV-1'; break;
        case 16: textDosis = 'DPT-HB-Hib-1'; break;
        case 17: textDosis = 'Polio OPV-2'; break;
        case 18: textDosis = 'DPT-HB-Hib-2'; break;
        case 19: textDosis = 'Polio OPV-3'; break;
        case 20: textDosis = 'DPT-HB-Hib-3'; break;
        case 21: textDosis = 'Polio OPV-4'; break;
        case 22: textDosis = 'IPV'; break;
        case 23: textDosis = 'DPT-HB-Hib Booster'; break;
        default:
          textDosis = 'Vaksin Imunisasi';
      }
    }

    return JadwalImunisasiModel(
      jadwalId: idJadwal,
      namaDosis: textDosis,
      tanggalEstimasi: json['tanggal_estimasi'] != null
          ? DateTime.tryParse(json['tanggal_estimasi'].toString())
          : null,
      statusId: idStatus,
      status: textStatus, // Sekarang teks status dijamin terisi dan dikenali oleh fungsi .where() di UI Screen!
      deskripsi: json['deskripsi'] ?? 'Membentuk antibodi anak.',
      efekSamping: json['efek_samping'] ?? 'Demam ringan.',
    );
  }

  Map<String, String> toJson() {
    return {
      'jadwal_id': jadwalId.toString(),
      'nama_dosis': namaDosis,
      'tanggal_estimasi': tanggalEstimasi?.toIso8601String() ?? '',
      'status_id': statusId.toString(),
      'status': status,
      'deskripsi': deskripsi,
      'efekSamping': efekSamping,
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
          .whereType<Map>()
          .map((e) => JadwalImunisasiModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return ImunisasiDetailModel(
      anakId: json['anak_id'] is int 
          ? json['anak_id'] 
          : (int.tryParse(json['anak_id']?.toString() ?? json['id_anak']?.toString() ?? '') ?? 0),
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: _parseDate(json['tanggal_lahir']),
      jumlahTerlewat: json['jumlah_terlewat'] is int 
          ? json['jumlah_terlewat'] 
          : (int.tryParse(json['jumlah_terlewat']?.toString() ?? '') ?? 0),
      jadwal: jadwalList,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}

class JadwalLayananModel {
  final int id;
  final String layanan;
  final DateTime tanggal;

  JadwalLayananModel({
    required this.id,
    required this.layanan,
    required this.tanggal,
  });

  factory JadwalLayananModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return JadwalLayananModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      layanan: json['layanan'] ?? '',
      tanggal: DateTime.parse(json['tanggal'].toString()),
    );
  }
}

class RequestPerubahanJadwalRequest {
  final int jadwalLayananId;
  final String alasan;

  RequestPerubahanJadwalRequest({
    required this.jadwalLayananId,
    required this.alasan,
  });

  Map<String, dynamic> toJson() {
    return {
      "jadwal_layanan_id": jadwalLayananId,
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