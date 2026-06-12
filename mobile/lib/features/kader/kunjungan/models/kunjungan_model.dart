import 'package:flutter/material.dart';

class KunjunganImunisasiModel {
  final int kunjunganId;
  final DateTime? tanggalKunjungan;
  final String statusKunjungan;
  final String namaAnak;

  KunjunganImunisasiModel({
    required this.kunjunganId,
    required this.tanggalKunjungan,
    required this.statusKunjungan,
    required this.namaAnak,
  });

  factory KunjunganImunisasiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return KunjunganImunisasiModel(
      kunjunganId: (json['kunjungan_id'] as num?)?.toInt() ?? 0,
      tanggalKunjungan: json['tanggal_kunjungan'] != null
          ? DateTime.parse(
              json['tanggal_kunjungan'],
            )
          : null,
      statusKunjungan: json['status_kunjungan'] ?? '',
      namaAnak: json['nama_anak'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kunjungan_id': kunjunganId,
      'tanggal_kunjungan': tanggalKunjungan?.toIso8601String(),
      'status_kunjungan': statusKunjungan,
      'nama_anak': namaAnak,
    };
  }
}

class DetailKunjunganImunisasiModel {
  final int kunjunganId;
  final DateTime? tanggalKunjungan;
  final String statusKunjungan;

  final String namaAnak;
  final DateTime? tanggalLahir;

  final String namaIbu;
  final String nomorTeleponIbu;

  final String namaAyah;
  final String nomorTeleponAyah;
  final String dusun;

  final String namaVaksin;
  final String namaDosis;

  final DateTime? jadwalImunisasi;

  DetailKunjunganImunisasiModel({
    required this.kunjunganId,
    required this.tanggalKunjungan,
    required this.statusKunjungan,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.namaIbu,
    required this.nomorTeleponIbu,
    required this.namaAyah,
    required this.nomorTeleponAyah,
    required this.dusun,
    required this.namaVaksin,
    required this.namaDosis,
    required this.jadwalImunisasi,
  });

  factory DetailKunjunganImunisasiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DetailKunjunganImunisasiModel(
      kunjunganId: (json['kunjungan_id'] as num?)?.toInt() ?? 0,
      tanggalKunjungan: _parseDate(
        json['tanggal_kunjungan'],
      ),
      statusKunjungan: json['status_kunjungan'] ?? '',
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: _parseDate(
        json['tanggal_lahir'],
      ),
      namaIbu: json['nama_ibu'] ?? '',
      nomorTeleponIbu: json['nomor_telepon_ibu'] ?? '',
      namaAyah: json['nama_ayah'] ?? '',
      nomorTeleponAyah: json['nomor_telepon_ayah'] ?? '',
      dusun: json['dusun'] ?? '',
      namaVaksin: json['nama_vaksin'] ?? '',
      namaDosis: json['nama_dosis'] ?? '',
      jadwalImunisasi: _parseDate(
        json['jadwal_imunisasi'],
      ),
    );
  }

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) return null;

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

class UpdateStatusKunjunganRequest {
  final int statusKunjunganId;

  UpdateStatusKunjunganRequest({
    required this.statusKunjunganId,
  });

  Map<String, dynamic> toJson() {
    return {
      "status_kunjungan_id": statusKunjunganId,
    };
  }
}

class UpdateTanggalKunjunganRequest {
  final String tanggalKunjungan;

  UpdateTanggalKunjunganRequest({
    required this.tanggalKunjungan,
  });

  Map<String, dynamic> toJson() {
    return {
      "tanggal_kunjungan": tanggalKunjungan,
    };
  }
}

class StatusKunjunganCountModel {
  final int statusId;
  final String statusKunjungan;
  final int jumlahKunjungan;

  StatusKunjunganCountModel({
    required this.statusId,
    required this.statusKunjungan,
    required this.jumlahKunjungan,
  });

  factory StatusKunjunganCountModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StatusKunjunganCountModel(
      statusId: (json['status_id'] as num?)?.toInt() ?? 0,
      statusKunjungan: json['status_kunjungan'] ?? '',
      jumlahKunjungan: (json['jumlah_kunjungan'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_id': statusId,
      'status_kunjungan': statusKunjungan,
      'jumlah_kunjungan': jumlahKunjungan,
    };
  }
}
