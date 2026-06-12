class EvaluasiKesehatanIbuModel {
  final int idEvaluasi;
  final int kehamilanId;
  final String namaDokter;
  final String? tanggalPeriksa;
  final String fasilitasKesehatan;
  final double? tbCm;
  final double? bbKg;
  final String imtKategori;
  final double? lilaCm;

  final bool statusTT1;
  final bool statusTT2;
  final bool statusTT3;
  final bool statusTT4;
  final bool statusTT5;
  final String imunisasiLainnyaCovid19;

  final bool riwayatAlergi;
  final bool riwayatAsma;
  final bool riwayatAutoimun;
  final bool riwayatDiabetes;
  final bool riwayatHepatitisB;
  final bool riwayatHipertensi;
  final bool riwayatJantung;
  final bool riwayatJiwa;
  final bool riwayatSifilis;
  final bool riwayatTb;
  final String riwayatKesehatanLainnya;

  final bool perilakuAktivitasFisikKurang;
  final bool perilakuAlkohol;
  final bool perilakuKosmetikBerbahaya;
  final bool perilakuMerokok;
  final bool perilakuObatTeratogenik;
  final bool perilakuPolaMakanBerisiko;
  final String perilakuLainnya;

  final bool keluargaAlergi;
  final bool keluargaAsma;
  final bool keluargaAutoimun;
  final bool keluargaDiabetes;
  final bool keluargaHepatitisB;
  final bool keluargaHipertensi;
  final bool keluargaJantung;
  final bool keluargaJiwa;
  final bool keluargaSifilis;
  final bool keluargaTb;
  final String keluargaLainnya;

  final String inspeksiPorsio;
  final String inspeksiUretra;
  final String inspeksiVagina;
  final String inspeksiVulva;
  final String inspeksiFluksus;
  final String inspeksiFluor;

  EvaluasiKesehatanIbuModel({
    required this.idEvaluasi,
    required this.kehamilanId,
    required this.namaDokter,
    required this.tanggalPeriksa,
    required this.fasilitasKesehatan,
    required this.tbCm,
    required this.bbKg,
    required this.imtKategori,
    required this.lilaCm,
    required this.statusTT1,
    required this.statusTT2,
    required this.statusTT3,
    required this.statusTT4,
    required this.statusTT5,
    required this.imunisasiLainnyaCovid19,
    required this.riwayatAlergi,
    required this.riwayatAsma,
    required this.riwayatAutoimun,
    required this.riwayatDiabetes,
    required this.riwayatHepatitisB,
    required this.riwayatHipertensi,
    required this.riwayatJantung,
    required this.riwayatJiwa,
    required this.riwayatSifilis,
    required this.riwayatTb,
    required this.riwayatKesehatanLainnya,
    required this.perilakuAktivitasFisikKurang,
    required this.perilakuAlkohol,
    required this.perilakuKosmetikBerbahaya,
    required this.perilakuMerokok,
    required this.perilakuObatTeratogenik,
    required this.perilakuPolaMakanBerisiko,
    required this.perilakuLainnya,
    required this.keluargaAlergi,
    required this.keluargaAsma,
    required this.keluargaAutoimun,
    required this.keluargaDiabetes,
    required this.keluargaHepatitisB,
    required this.keluargaHipertensi,
    required this.keluargaJantung,
    required this.keluargaJiwa,
    required this.keluargaSifilis,
    required this.keluargaTb,
    required this.keluargaLainnya,
    required this.inspeksiPorsio,
    required this.inspeksiUretra,
    required this.inspeksiVagina,
    required this.inspeksiVulva,
    required this.inspeksiFluksus,
    required this.inspeksiFluor,
  });

  factory EvaluasiKesehatanIbuModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    bool toBool(dynamic value) => value == true;

    String str(dynamic value) => value?.toString() ?? '';

    return EvaluasiKesehatanIbuModel(
      idEvaluasi: json['id_evaluasi'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      namaDokter: str(json['nama_dokter']),
      tanggalPeriksa: json['tanggal_periksa']?.toString(),
      fasilitasKesehatan: str(json['fasilitas_kesehatan']),
      tbCm: toDouble(json['tb_cm']),
      bbKg: toDouble(json['bb_kg']),
      imtKategori: str(json['imt_kategori']),
      lilaCm: toDouble(json['lila_cm']),

      statusTT1: toBool(json['status_tt_1']),
      statusTT2: toBool(json['status_tt_2']),
      statusTT3: toBool(json['status_tt_3']),
      statusTT4: toBool(json['status_tt_4']),
      statusTT5: toBool(json['status_tt_5']),
      imunisasiLainnyaCovid19: str(json['imunisasi_lainnya_covid19']),

      riwayatAlergi: toBool(json['riwayat_alergi']),
      riwayatAsma: toBool(json['riwayat_asma']),
      riwayatAutoimun: toBool(json['riwayat_autoimun']),
      riwayatDiabetes: toBool(json['riwayat_diabetes']),
      riwayatHepatitisB: toBool(json['riwayat_hepatitis_b']),
      riwayatHipertensi: toBool(json['riwayat_hipertensi']),
      riwayatJantung: toBool(json['riwayat_jantung']),
      riwayatJiwa: toBool(json['riwayat_jiwa']),
      riwayatSifilis: toBool(json['riwayat_sifilis']),
      riwayatTb: toBool(json['riwayat_tb']),
      riwayatKesehatanLainnya: str(json['riwayat_kesehatan_lainnya']),

      perilakuAktivitasFisikKurang:
          toBool(json['perilaku_aktivitas_fisik_kurang']),
      perilakuAlkohol: toBool(json['perilaku_alkohol']),
      perilakuKosmetikBerbahaya:
          toBool(json['perilaku_kosmetik_berbahaya']),
      perilakuMerokok: toBool(json['perilaku_merokok']),
      perilakuObatTeratogenik:
          toBool(json['perilaku_obat_teratogenik']),
      perilakuPolaMakanBerisiko:
          toBool(json['perilaku_pola_makan_berisiko']),
      perilakuLainnya: str(json['perilaku_lainnya']),

      keluargaAlergi: toBool(json['keluarga_alergi']),
      keluargaAsma: toBool(json['keluarga_asma']),
      keluargaAutoimun: toBool(json['keluarga_autoimun']),
      keluargaDiabetes: toBool(json['keluarga_diabetes']),
      keluargaHepatitisB: toBool(json['keluarga_hepatitis_b']),
      keluargaHipertensi: toBool(json['keluarga_hipertensi']),
      keluargaJantung: toBool(json['keluarga_jantung']),
      keluargaJiwa: toBool(json['keluarga_jiwa']),
      keluargaSifilis: toBool(json['keluarga_sifilis']),
      keluargaTb: toBool(json['keluarga_tb']),
      keluargaLainnya: str(json['keluarga_lainnya']),

      inspeksiPorsio: str(json['inspeksi_porsio']),
      inspeksiUretra: str(json['inspeksi_uretra']),
      inspeksiVagina: str(json['inspeksi_vagina']),
      inspeksiVulva: str(json['inspeksi_vulva']),
      inspeksiFluksus: str(json['inspeksi_fluksus']),
      inspeksiFluor: str(json['inspeksi_fluor']),
    );
  }

  String get statusTTText {
    final items = <String>[];
    if (statusTT1) items.add('TT1');
    if (statusTT2) items.add('TT2');
    if (statusTT3) items.add('TT3');
    if (statusTT4) items.add('TT4');
    if (statusTT5) items.add('TT5');
    return items.isEmpty ? 'Belum ada' : items.join(', ');
  }

  String get riwayatKesehatanText {
    final items = <String>[];
    if (riwayatAlergi) items.add('Alergi');
    if (riwayatAsma) items.add('Asma');
    if (riwayatAutoimun) items.add('Autoimun');
    if (riwayatDiabetes) items.add('Diabetes');
    if (riwayatHepatitisB) items.add('Hepatitis B');
    if (riwayatHipertensi) items.add('Hipertensi');
    if (riwayatJantung) items.add('Jantung');
    if (riwayatJiwa) items.add('Gangguan jiwa');
    if (riwayatSifilis) items.add('Sifilis');
    if (riwayatTb) items.add('TB');
    if (riwayatKesehatanLainnya.trim().isNotEmpty) {
      items.add(riwayatKesehatanLainnya);
    }
    return items.isEmpty ? 'Tidak ada' : items.join(', ');
  }

  String get perilakuBerisikoText {
    final items = <String>[];
    if (perilakuAktivitasFisikKurang) items.add('Aktivitas fisik kurang');
    if (perilakuAlkohol) items.add('Alkohol');
    if (perilakuKosmetikBerbahaya) items.add('Kosmetik berbahaya');
    if (perilakuMerokok) items.add('Merokok');
    if (perilakuObatTeratogenik) items.add('Obat teratogenik');
    if (perilakuPolaMakanBerisiko) items.add('Pola makan berisiko');
    if (perilakuLainnya.trim().isNotEmpty) items.add(perilakuLainnya);
    return items.isEmpty ? 'Tidak ada' : items.join(', ');
  }

  String get riwayatKeluargaText {
    final items = <String>[];
    if (keluargaAlergi) items.add('Alergi');
    if (keluargaAsma) items.add('Asma');
    if (keluargaAutoimun) items.add('Autoimun');
    if (keluargaDiabetes) items.add('Diabetes');
    if (keluargaHepatitisB) items.add('Hepatitis B');
    if (keluargaHipertensi) items.add('Hipertensi');
    if (keluargaJantung) items.add('Jantung');
    if (keluargaJiwa) items.add('Gangguan jiwa');
    if (keluargaSifilis) items.add('Sifilis');
    if (keluargaTb) items.add('TB');
    if (keluargaLainnya.trim().isNotEmpty) items.add(keluargaLainnya);
    return items.isEmpty ? 'Tidak ada' : items.join(', ');
  }
}