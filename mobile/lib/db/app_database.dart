import 'dart:convert';
import 'package:flutter/services.dart'; // Untuk membaca rootBundle assets
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  // Constructor Singleton
  AppDatabase._init();
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kia_app_production.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Fungsi utama saat basis data pertama kali dibuat
  Future _onCreate(Database db, int version) async {
    // 1. Membuat seluruh tabel aplikasi
    await _createTables(db);

    // 2. Mengisi data master bawaan secara otomatis dari JSON
    await _seedMasterData(db);
  }

  Future<void> _createTables(Database db) async {
    // ---- 1. TABEL KONSTANTA & MASTER SISTEM ----
    await db.execute('''
      CREATE TABLE roles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_deleted TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 1]

    await db.execute('''
      CREATE TABLE status_jadwal (
        id TEXT PRIMARY KEY,
        nama_status TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 33]

    await db.execute('''
      CREATE TABLE status_request (
        id TEXT PRIMARY KEY,
        status_request TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 33]

    await db.execute('''
      CREATE TABLE vaksin (
        id TEXT PRIMARY KEY,
        nama TEXT,
        deskripsi TEXT,
        efek_samping TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 33]

    await db.execute('''
      CREATE TABLE dosis_vaksin (
        id TEXT PRIMARY KEY,
        id_vaksin TEXT,
        nama_dosis TEXT,
        jumlah_dosis TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 33, 34]

    await db.execute('''
      CREATE TABLE master_standar_antropometri (
        id TEXT PRIMARY KEY,
        parameter TEXT,
        jenis_kelamin TEXT,
        nilai_sumbu_x REAL,
        sd_3_neg REAL,
        sd_2_neg REAL,
        sd_1_neg REAL,
        median REAL,
        sd_1_pos REAL,
        sd_2_pos REAL,
        sd_3_pos REAL,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 31, 32]

    // ---- 2. TABEL WILAYAH, PENDUDUK & AKUN ----
    await db.execute('''
      CREATE TABLE desa (
        id TEXT PRIMARY KEY,
        kecamatan TEXT,
        kabupaten TEXT,
        provinsi TEXT,
        nama_desa TEXT NOT NULL,
        kode_desa TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        keterangan TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 1]

    await db.execute('''
      CREATE TABLE puskesmas (
        id TEXT PRIMARY KEY,
        nama TEXT,
        alamat TEXT,
        no_telepon TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 32, 33]

    await db.execute('''
      CREATE TABLE posyandu (
        id TEXT PRIMARY KEY,
        id_puskesmas TEXT NOT NULL,
        nama TEXT NOT NULL,
        alamat TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 3, 4]

    await db.execute('''
      CREATE TABLE kartu_keluarga (
        id TEXT PRIMARY KEY,
        no_kk TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        tanggal_terbit TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 2]

    await db.execute('''
      CREATE TABLE penduduk (
        id TEXT PRIMARY KEY,
        kartu_keluarga_id TEXT,
        nik TEXT,
        nama_lengkap TEXT NOT NULL,
        jenis_kelamin TEXT,
        tanggal_lahir TEXT,
        tempat_lahir TEXT,
        golongan_darah TEXT,
        agama TEXT,
        status_perkawinan TEXT,
        pendidikan_terakhir TEXT,
        pekerjaan TEXT,
        baca_huruf TEXT,
        kedudukan_keluarga TEXT,
        dusun TEXT,
        kecamatan TEXT,
        desa_id TEXT,
        tanggal_penambahan TEXT,
        asal_penduduk TEXT,
        tanggal_pengurangan TEXT,
        tujuan_pindah TEXT,
        tempat_meninggal TEXT,
        keterangan TEXT,
        is_non_ktp INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        telepon TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 2, 3]

    await db.execute('''
      CREATE TABLE pengguna (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        email TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        kata_sandi TEXT NOT NULL,
        role_id TEXT NOT NULL,
        penduduk_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        nomor_telepon TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 1, 2]

    await db.execute('''
      CREATE TABLE bidan (
        id TEXT PRIMARY KEY,
        penduduk_id TEXT NOT NULL,
        no_str TEXT,
        no_sipb TEXT,
        status TEXT DEFAULT 'aktif',
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        desa_id TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 3]

    await db.execute('''
      CREATE TABLE kader (
        id TEXT PRIMARY KEY,
        id_penduduk TEXT NOT NULL,
        id_posyandu TEXT,
        status TEXT DEFAULT 'aktif',
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 3, 4]

    // ---- 3. TABEL KEHAMILAN & DETAIL LAYANAN KESEHATAN IBU ----
    await db.execute('''
      CREATE TABLE ibu (
        id TEXT PRIMARY KEY,
        penduduk_id TEXT NOT NULL,
        suami_id TEXT,
        gravida INTEGER,
        paritas INTEGER,
        abortus INTEGER,
        created_at TEXT,
        updated_at TEXT,
        is_deleted TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 4]

    await db.execute('''
      CREATE TABLE kehamilan (
        id TEXT PRIMARY KEY,
        ibu_id TEXT NOT NULL,
        gravida INTEGER,
        paritas INTEGER,
        abortus INTEGER,
        hpht TEXT,
        taksiran_persalinan TEXT,
        uk_kehamilan_saat_ini INTEGER,
        jarak_kehamilan_sebelumnya INTEGER,
        status_kehamilan TEXT,
        bb_awal REAL,
        tb REAL,
        imt_awal REAL,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 4, 5]

    await db.execute('''
      CREATE TABLE pemeriksaan_kehamilan (
        id_periksa TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        trimester TEXT,
        kunjungan_ke INTEGER,
        minggu_kehamilan INTEGER,
        tanggal_periksa TEXT,
        tempat_periksa TEXT,
        berat_badan REAL,
        tinggi_badan REAL,
        lingkar_lengan_atas REAL,
        sistole INTEGER,
        diastole INTEGER,
        tinggi_rahim REAL,
        letak_denyut_jantung_bayi TEXT,
        denyut_jantung_janin INTEGER,
        status_imunisasi_tetanus TEXT,
        konseling TEXT,
        skrining_dokter TEXT,
        tablet_tambah_darah INTEGER,
        tes_lab_hb REAL,
        tes_golongan_darah TEXT,
        tes_lab_protein_urine TEXT,
        tes_lab_gula_darah INTEGER,
        usg TEXT,
        tripel_eliminasi TEXT,
        tata_laksana_kasus TEXT,
        skor_risiko INTEGER,
        status_risiko TEXT,
        detail_risiko TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 7, 8]

    await db.execute('''
      CREATE TABLE evaluasi_kesehatan_ibu (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        nama_dokter TEXT,
        tanggal_periksa TEXT,
        fasilitas_kesehatan TEXT,
        tb_cm REAL,
        bb_kg REAL,
        imt_kategori TEXT,
        lila_cm REAL,
        status_tt1 INTEGER,
        status_tt2 INTEGER,
        status_tt3 INTEGER,
        status_tt4 INTEGER,
        status_tt5 INTEGER,
        imunisasi_lainnya_covid19 TEXT,
        riwayat_alergi INTEGER,
        riwayat_asma INTEGER,
        riwayat_autoimun INTEGER,
        riwayat_diabetes INTEGER,
        riwayat_hepatitis_b INTEGER,
        riwayat_hipertensi INTEGER,
        riwayat_jantung INTEGER,
        riwayat_jiwa INTEGER,
        riwayat_sifilis INTEGER,
        riwayat_tb INTEGER,
        riwayat_kesehatan_lainnya TEXT,
        perilaku_aktivitas_fisik_kurang INTEGER,
        perilaku_alkohol INTEGER,
        perilaku_kosmetik_berbahaya INTEGER,
        perilaku_merokok INTEGER,
        perilaku_obat_teratogenik INTEGER,
        perilaku_pola_makan_berisiko INTEGER,
        perilaku_lainnya TEXT,
        keluarga_alergi INTEGER,
        keluarga_asma INTEGER,
        keluarga_autoimun INTEGER,
        keluarga_diabetes INTEGER,
        keluarga_hepatitis_b INTEGER,
        keluarga_hipertensi INTEGER,
        keluarga_jantung INTEGER,
        keluarga_jiwa INTEGER,
        keluarga_sifilis INTEGER,
        keluarga_tb INTEGER,
        keluarga_lainnya TEXT,
        inspeksi_porsio TEXT,
        inspeksi_uretra TEXT,
        inspeksi_vagina TEXT,
        inspeksi_vulva TEXT,
        inspeksi_fluksus TEXT,
        inspeksi_fluor TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 8, 9, 10]

    await db.execute('''
      CREATE TABLE pemeriksaan_dokter_trimester_1 (
        id_trimester1 TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        nama_dokter TEXT,
        tanggal_periksa TEXT,
        konsep_anamnesa_pemeriksaan TEXT,
        gambar_usg TEXT,
        fisik_konjungtiva TEXT,
        fisik_sklera TEXT,
        fisik_kulit TEXT,
        fisik_leher TEXT,
        fisik_gigi_mulut TEXT,
        fisik_tht TEXT,
        fisik_dada_jantung TEXT,
        fisik_dada_paru TEXT,
        fisik_perut TEXT,
        fisik_tungkai TEXT,
        hpht TEXT,
        keteraturan_haid TEXT,
        umur_hamil_hpht_minggu INTEGER,
        hpl_berdasarkan_hpht TEXT,
        umur_hamil_usg_minggu INTEGER,
        hpl_berdasarkan_usg TEXT,
        usg_jumlah_gs TEXT,
        usg_diameter_gs_cm REAL,
        usg_diameter_gs_minggu INTEGER,
        usg_diameter_gs_hari INTEGER,
        usg_jumlah_bayi TEXT,
        usgcrl_cm REAL,
        usgcrl_minggu INTEGER,
        usgcrl_hari INTEGER,
        usg_letak_produk_kehamilan TEXT,
        usg_pulsasi_jantung TEXT,
        usg_kecurigaan_temuan_abnormal TEXT,
        usg_keterangan_temuan_abnormal TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 10, 11]

    await db.execute('''
      CREATE TABLE pemeriksaan_dokter_trimester_3 (
        id_trimester3 TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        nama_dokter TEXT,
        tanggal_periksa TEXT,
        konsep_anamnesa_pemeriksaan TEXT,
        gambar_usg TEXT,
        fisik_konjungtiva TEXT,
        fisik_sklera TEXT,
        fisik_kulit TEXT,
        fisik_leher TEXT,
        fisik_gigi_mulut TEXT,
        fisik_tht TEXT,
        fisik_dada_jantung TEXT,
        fisik_dada_paru TEXT,
        fisik_perut TEXT,
        fisik_tungkai TEXT,
        usg_trimester3_dilakukan TEXT,
        uk_berdasarkan_usg_trimester1_minggu INTEGER,
        uk_berdasarkan_hpht_minggu INTEGER,
        uk_berdasarkan_biometri_usg_trimester3_minggu INTEGER,
        selisih_uk3_minggu_atau_lebih TEXT,
        usg_jumlah_bayi TEXT,
        usg_letak_bayi TEXT,
        usg_presentasi_bayi TEXT,
        usg_keadaan_bayi TEXT,
        usgdj_nilai INTEGER,
        usgdjj_status TEXT,
        usg_lokasi_plasenta TEXT,
        usg_cairan_ketuban_sdp_cm REAL,
        usg_cairan_ketuban_status TEXT,
        biometri_bpd_cm REAL,
        biometri_bpd_minggu INTEGER,
        biometri_hc_cm REAL,
        biometri_hc_minggu INTEGER,
        biometri_ac_cm REAL,
        biometri_ac_minggu INTEGER,
        biometri_fl_cm REAL,
        biometri_fl_minggu INTEGER,
        biometri_efwtbj_gram INTEGER,
        biometri_efwtbj_minggu INTEGER,
        usg_kecurigaan_temuan_abnormal TEXT,
        usg_keterangan_temuan_abnormal TEXT,
        hasil_usg_catatan TEXT,
        tanggal_lab TEXT,
        lab_hemoglobin_hasil REAL,
        lab_hemoglobin_rencana TEXT,
        lab_protein_urin_hasil INTEGER,
        lab_protein_urin_rencana TEXT,
        lab_urin_reduksi_hasil TEXT,
        lab_urin_reduksi_rencana TEXT,
        tanggal_skrining_jiwa TEXT,
        skrining_jiwa_hasil TEXT,
        skrining_jiwa_tindak_lanjut TEXT,
        skrining_jiwa_perlu_rujukan TEXT,
        rencana_konsultasi_gizi INTEGER,
        rencana_konsultasi_kebidanan INTEGER,
        rencana_konsultasi_anak INTEGER,
        rencana_konsultasi_penyakit_dalam INTEGER,
        rencana_konsultasi_neurologi INTEGER,
        rencana_konsultasi_tht INTEGER,
        rencana_konsultasi_psikiatri INTEGER,
        rencana_konsultasi_lain_lain TEXT,
        rencana_proses_melahirkan TEXT,
        rencana_kontrasepsi_akdr INTEGER,
        rencana_kontrasepsi_pil INTEGER,
        rencana_kontrasepsi_suntik INTEGER,
        rencana_kontrasepsi_steril INTEGER,
        rencana_kontrasepsi_mal INTEGER,
        rencana_kontrasepsi_implan INTEGER,
        rencana_kontrasepsi_belum_memilih INTEGER,
        kebutuhan_konseling TEXT,
        penjelasan TEXT,
        kesimpulan_rekomendasi_tempat_melahirkan TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 11, 12, 13]

    await db.execute('''
      CREATE TABLE pemeriksaan_lanjutan_trimester_3 (
        id_lanjutan_t3 TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        hasil_usg_catatan TEXT,
        tanggal_lab TEXT,
        lab_hemoglobin_hasil REAL,
        lab_hemoglobin_rencana TEXT,
        lab_protein_urin_hasil INTEGER,
        lab_protein_urin_rencana TEXT,
        lab_urin_reduksi_hasil TEXT,
        lab_urin_reduksi_rencana TEXT,
        tanggal_skrining_jiwa TEXT,
        skrining_jiwa_hasil TEXT,
        skrining_jiwa_tindak_lanjut TEXT,
        skrining_jiwa_perlu_rujukan TEXT,
        rencana_konsultasi_gizi INTEGER,
        rencana_konsultasi_kebidanan INTEGER,
        rencana_konsultasi_anak INTEGER,
        rencana_konsultasi_penyakit_dalam INTEGER,
        rencana_konsultasi_neurologi INTEGER,
        rencana_konsultasi_tht INTEGER,
        rencana_konsultasi_psikiatri INTEGER,
        rencana_konsultasi_lain_lain TEXT,
        rencana_proses_melahirkan TEXT,
        rencana_kontrasepsi_akdr INTEGER,
        rencana_kontrasepsi_pil INTEGER,
        rencana_kontrasepsi_suntik INTEGER,
        rencana_kontrasepsi_steril INTEGER,
        rencana_kontrasepsi_mal INTEGER,
        rencana_kontrasepsi_implan INTEGER,
        rencana_kontrasepsi_belum_memilih INTEGER,
        kebutuhan_konseling TEXT,
        penjelasan TEXT,
        kesimpulan_rekomendasi_tempat_melahirkan TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 13, 14]

    await db.execute('''
      CREATE TABLE catatan_pelayanan_trimester_1 (
        id_catatan TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        tanggal_periksa_stamp_paraf TEXT,
        keluhan_pemeriksaan_tindakan_saran TEXT,
        tanggal_kembali TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 14, 15]

    await db.execute('''
      CREATE TABLE catatan_pelayanan_trimester_2 (
        id_catatan_t2 TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        tanggal_periksa_stamp_paraf TEXT,
        keluhan_pemeriksaan_tindakan_saran TEXT,
        tanggal_kembali TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 15]

    await db.execute('''
      CREATE TABLE catatan_pelayanan_trimester_3 (
        id_catatan_t3 TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        tanggal_periksa_stamp_paraf TEXT,
        keluhan_pemeriksaan_tindakan_saran TEXT,
        tanggal_kembali TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 15]

    await db.execute('''
      CREATE TABLE skrining_preeklampsia (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        anamnesis_multipara_pasangan_baru_sedang INTEGER,
        anamnesis_teknologi_reproduksi_berbantu_sedang INTEGER,
        anamnesis_umur_diatas35_tahun_sedang INTEGER,
        anamnesis_nulipara_sedang INTEGER,
        anamnesis_jarak_kehamilan_diatas10_tahun_sedang INTEGER,
        anamnesis_riwayat_preeklampsia_keluarga_sedang INTEGER,
        anamnesis_obesitas_imt_diatas30_sedang INTEGER,
        anamnesis_riwayat_preeklampsia_sebelumnya_tinggi INTEGER,
        anamnesis_kehamilan_multipel_tinggi INTEGER,
        anamnesis_diabetes_dalam_kehamilan_tinggi INTEGER,
        anamnesis_hipertensi_kronik_tinggi INTEGER,
        anamnesis_penyakit_ginjal_tinggi INTEGER,
        anamnesis_penyakit_autoimun_sle_tinggi INTEGER,
        anamnesis_anti_phospholipid_syndrome_tinggi INTEGER,
        fisik_map_diatas90mm_hg INTEGER,
        fisik_proteinuria_urin_celup INTEGER,
        kesimpulan_skrining_preeklampsia TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 15, 16]

    await db.execute('''
      CREATE TABLE grafik_evaluasi_kehamilan (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        tanggal_bulan_tahun TEXT,
        usia_gestasi_minggu INTEGER,
        tinggi_fundus_uteri_cm REAL,
        denyut_jantung_bayi_x_menit INTEGER,
        tekanan_darah_sistole INTEGER,
        tekanan_darah_diastole INTEGER,
        nadi_per_menit INTEGER,
        gerakan_bayi TEXT,
        urin_protein TEXT,
        urin_reduksi TEXT,
        hemoglobin REAL,
        tablet_tambah_darah INTEGER,
        kalsium TEXT,
        aspirin TEXT,
        penjelasan_hasil_grafik TEXT,
        kategori_risiko TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 16]

    await db.execute('''
      CREATE TABLE grafik_peningkatan_bb (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        berat_badan REAL,
        minggu_kehamilan INTEGER,
        penjelasan_hasil_grafik TEXT,
        deviasi REAL,
        status TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 16, 17]

    await db.execute('''
      CREATE TABLE penjelasan_hasil_grafik (
        id_penjelasan TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        catatan_penjelasan_grafik TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 17]

    await db.execute('''
      CREATE TABLE rencana_persalinan (
        id_rencana_persalinan TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        nama_ibu_pernyataan TEXT,
        alamat_ibu_pernyataan TEXT,
        perkiraan_bulan_persalinan TEXT,
        perkiraan_tahun_persalinan INTEGER,
        fasyankes1_nama_tenaga TEXT,
        fasyankes1_nama_fasilitas TEXT,
        fasyankes2_nama_tenaga TEXT,
        fasyankes2_nama_fasilitas TEXT,
        sumber_dana_persalinan TEXT,
        kendaraan1_nama TEXT,
        kendaraan1_hp TEXT,
        kendaraan2_nama TEXT,
        kendaraan2_hp TEXT,
        kendaraan3_nama TEXT,
        kendaraan3_hp TEXT,
        metode_kontrasepsi_pilihan TEXT,
        donor_golongan_darah TEXT,
        donor_rhesus TEXT,
        donor1_nama TEXT,
        donor1_hp TEXT,
        donor2_nama TEXT,
        donor2_hp TEXT,
        donor3_nama TEXT,
        donor3_hp TEXT,
        donor4_nama TEXT,
        donor4_hp TEXT,
        tanggal_pernyataan TEXT,
        nama_suami_keluarga_ttd TEXT,
        namaibu_ttd TEXT,
        nama_bidan_dokter_ttd TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 17, 18]

    await db.execute('''
      CREATE TABLE ringkasan_pelayanan_persalinan (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        tanggal_melahirkan TEXT,
        pukul_melahirkan TEXT,
        umur_kehamilan_minggu INTEGER,
        penolong_proses_melahirkan TEXT,
        cara_melahirkan TEXT,
        keadaan_ibu TEXT,
        keadaan_ibu_detail_sakit TEXT,
        kb_pasca_melahirkan TEXT,
        keterangan_tambahan_ibu TEXT,
        bayi_anak_ke INTEGER,
        bayi_berat_lahir_gram REAL,
        bayi_panjang_badan_cm REAL,
        bayi_lingkar_kepala_cm REAL,
        bayi_jenis_kelamin TEXT,
        kondisi_bayi_segera_menangis INTEGER,
        kondisi_bayi_menangis_beberapa_saat INTEGER,
        kondisi_bayi_tidak_menangis INTEGER,
        kondisi_bayi_seluruh_tubuh_kemerahan INTEGER,
        kondisi_bayi_anggota_gerak_kebiruan INTEGER,
        kondisi_bayi_seluruh_tubuh_biru INTEGER,
        kondisi_bayi_kelainan_bawaan INTEGER,
        kondisi_bayi_kelainan_bawaan_detail TEXT,
        kondisi_bayi_meninggal INTEGER,
        asuhan_imd1_jam_pertama INTEGER,
        asuhan_suntikan_vitamin_k1 INTEGER,
        asuhan_salep_mata_antibiotika INTEGER,
        asuhan_imunisasi_hb0 INTEGER,
        keterangan_tambahan_bayi TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 18, 19]

    await db.execute('''
      CREATE TABLE riwayat_proses_melahirkan (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        hari_melahirkan TEXT,
        tanggal_melahirkan TEXT,
        pukul_melahirkan TEXT,
        cara_melahirkan_spontan INTEGER,
        cara_melahirkan_sungsang INTEGER,
        tindakan_ekstraksi_vakum INTEGER,
        tindakan_ekstraksi_forsep INTEGER,
        tindakan_sc INTEGER,
        penolong_dokter_spesialis INTEGER,
        penolong_dokter INTEGER,
        penolong_bidan INTEGER,
        taksiran_melahirkan TEXT,
        fasyankes_tempat_melahirkan TEXT,
        rujukan_keterangan TEXT,
        inisiasi_menyusu_dini_keterangan TEXT,
        cap_kaki_bayi_image_url TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 19]

    await db.execute('''
      CREATE TABLE keterangan_lahir (
        id TEXT PRIMARY KEY,
        id_ibu_relasi TEXT NOT NULL,
        nomor_surat TEXT,
        hari_lahir TEXT,
        tanggal_lahir TEXT,
        pukul_lahir TEXT,
        jenis_kelamin TEXT,
        jenis_kelahiran TEXT,
        anak_ke INTEGER,
        usia_gestasi_minggu INTEGER,
        berat_lahir_gram INTEGER,
        panjang_badan_cm INTEGER,
        lingkar_kepala_cm INTEGER,
        lokasi_persalinan TEXT,
        alamat_lokasi_persalinan TEXT,
        nama_bayi_diberi_nama TEXT,
        nama_ibu TEXT,
        umur_ibu INTEGER,
        nik_ibu TEXT,
        nama_ayah TEXT,
        nik_ayah TEXT,
        pekerjaan_orang_tua TEXT,
        alamat_orang_tua TEXT,
        rwrt_orang_tua TEXT,
        kecamatan_orang_tua TEXT,
        kab_kota_orang_tua TEXT,
        tanggal_surat TEXT,
        nama_saksi1 TEXT,
        nama_saksi2 TEXT,
        nama_penolong_kelahiran TEXT,
        created_at TEXT,
        ringkasan_pelayanan_persalinan_id TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 20, 21]

    await db.execute('''
      CREATE TABLE pelayanan_ibu_nifas (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        kunjungan_ke TEXT,
        tanggal_periksa TEXT,
        tanda_vital_tekanan_darah TEXT,
        tanda_vital_suhu_tubuh REAL,
        pelayanan_involusi_uteri TEXT,
        pelayanan_cairan_pervaginam TEXT,
        pelayanan_periksa_jalan_lahir TEXT,
        pelayanan_periksa_payudara TEXT,
        pelayanan_asi_ekslusif TEXT,
        pemberian_kapsul_vitamin_a INTEGER,
        pemberian_tablet_tambah_darah_jumlah INTEGER,
        pelayanan_skrining_depresi_nifas TEXT,
        pelayanan_kontrasepsi_pasca_persalinan TEXT,
        pelayanan_penanganan_risiko_malaria TEXT,
        komplikasi_nifas TEXT,
        tindakan_saran TEXT,
        nama_pemeriksa_paraf TEXT,
        tanggal_kembali TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 21]

    await db.execute('''
      CREATE TABLE catatan_pelayanan_nifas (
        id_catatan_nifas TEXT PRIMARY KEY,
        kehamilan_id TEXT,
        kunjungan_ke TEXT,
        tanggal_periksa_stamp_paraf TEXT,
        keluhan_pemeriksaan_tindakan_saran TEXT,
        tanggal_kembali TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 21]

    await db.execute('''
      CREATE TABLE checklist_pemantauan_ibu_nifas (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        hari_nifas INTEGER NOT NULL,
        pemeriksaan_nifas INTEGER DEFAULT 0,
        konsumsi_vitamin_a INTEGER DEFAULT 0,
        pemenuhan_gizi INTEGER DEFAULT 0,
        demam_lebih_38 INTEGER DEFAULT 0,
        sakit_kepala INTEGER DEFAULT 0,
        pandangan_kabur INTEGER DEFAULT 0,
        nyeri_ulu_hati INTEGER DEFAULT 0,
        masalah_kesehatan_jiwa INTEGER DEFAULT 0,
        jantung_berdebar INTEGER DEFAULT 0,
        cairan_jalan_lahir INTEGER DEFAULT 0,
        napas_pendek INTEGER DEFAULT 0,
        payudara_bermasalah INTEGER DEFAULT 0,
        gangguan_bak INTEGER DEFAULT 0,
        kelamin_bermasalah INTEGER DEFAULT 0,
        darah_nifas_berbau INTEGER DEFAULT 0,
        pendarahan_berat INTEGER DEFAULT 0,
        keputihan INTEGER DEFAULT 0,
        keluhan TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        nama_kader TEXT,
        tanggal_verifikasi TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 21, 22, 23]

    await db.execute('''
      CREATE TABLE riwayat_kehamilan_lalu (
        id_riwayat TEXT PRIMARY KEY,
        id_evaluasi TEXT NOT NULL,
        no_urut INTEGER,
        tahun INTEGER,
        bg_gram INTEGER,
        proses_melahirkan TEXT,
        penolong_proses_melahirkan TEXT,
        masalah TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 23]

    await db.execute('''
      CREATE TABLE rujukan (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        rujukan_resume_pemeriksaan_tatalaksana TEXT,
        rujukan_diagnosis_akhir TEXT,
        rujukan_alasan_dirujuk_ke_fkrtl TEXT,
        rujukan_balik_tanggal TEXT,
        rujukan_balik_diagnosis_akhir TEXT,
        rujukan_balik_resume_pemeriksaan_tatalaksana TEXT,
        anjuran_rekomendasi_tempat_melahirkan TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 23]

    await db.execute('''
      CREATE TABLE log_ttd_mms (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        bulan_ke INTEGER NOT NULL,
        hari_ke INTEGER NOT NULL,
        sudah_diminum INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 23, 24]

    // ---- 4. TABEL LAYANAN ANAK, PETUMBUHAN & IMUNISASI ----
    await db.execute('''
      CREATE TABLE anak (
        id TEXT PRIMARY KEY,
        kehamilan_id TEXT NOT NULL,
        penduduk_id TEXT NOT NULL,
        berat_lahir_kg REAL,
        tinggi_lahir_cm REAL,
        anak_ke INTEGER,
        lingkar_kepala_cm REAL,
        nama_ibu TEXT,
        nama_ayah TEXT,
        ibu_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 5]

    await db.execute('''
      CREATE TABLE keluhan_anak (
        id TEXT PRIMARY KEY,
        anak_id TEXT,
        tanggal TEXT,
        keluhan TEXT,
        tindakan TEXT,
        pemeriksa TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 24]

    await db.execute('''
      CREATE TABLE periksa_gigi (
        id TEXT PRIMARY KEY,
        anak_id TEXT,
        bulanke INTEGER,
        tanggal TEXT,
        jumlahgigi INTEGER,
        gigi_berlubang INTEGER,
        status_plak TEXT,
        resiko_gigi_berlubang TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 24, 25]

    await db.execute('''
      CREATE TABLE pengukuran_lila (
        id TEXT PRIMARY KEY,
        anak_id TEXT,
        bulanke INTEGER,
        tanggal TEXT,
        hasil_lila REAL,
        kategori_risiko TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 25, 26]

    await db.execute('''
      CREATE TABLE catatan_pertumbuhan (
        id TEXT PRIMARY KEY,
        anak_id TEXT,
        tgl_ukur TEXT,
        berat_badan REAL,
        tinggi_badan REAL,
        lingkar_kepala REAL,
        hasil_lila REAL,
        imt REAL,
        status_bb_u TEXT,
        status_tb_u TEXT,
        status_imt_u TEXT,
        status_bb_tb TEXT,
        status_lk_u TEXT,
        z_score_bb_u REAL,
        z_score_tb_u REAL,
        z_score_imt_u REAL,
        z_score_bb_tb REAL,
        z_score_lk_u REAL,
        usia_ukur_bulan INTEGER,
        catatan_nakes TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 30, 31]

    await db.execute('''
      CREATE TABLE jadwal_layanan (
        id TEXT PRIMARY KEY,
        posyandu_id TEXT,
        layanan TEXT,
        tanggal TEXT,
        waktu_mulai TEXT,
        waktu_selesai TEXT,
        keterangan TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 32, 33]

    await db.execute('''
      CREATE TABLE jadwal_imunisasi_anak (
        id TEXT PRIMARY KEY,
        id_dosis_vaksin TEXT,
        id_anak TEXT,
        id_status_jadwal TEXT,
        tanggal_estimasi TEXT,
        is_sent_h7 INTEGER DEFAULT 0,
        is_sent_h3 INTEGER DEFAULT 0,
        is_sent_h INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 34]

    await db.execute('''
      CREATE TABLE request_perubahan_imunisasi (
        id TEXT PRIMARY KEY,
        id_jadwal_imunisasi TEXT,
        id_status_request TEXT,
        alasan TEXT,
        tanggal_sebelum TEXT,
        tanggal_baru TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    '''); // [cite: 34]

    // ---- 5. TABEL MATERI KONTEN & EDUKASI (READ-ONLY) ----
    await db.execute('''
      CREATE TABLE edukasi_informasi_umum (
        id TEXT PRIMARY KEY,
        tipe TEXT,
        judul TEXT,
        umur_target TEXT,
        durasi_baca TEXT,
        ringkasan TEXT,
        konten TEXT,
        yang_perlu_diingat TEXT,
        thumbnail_url TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 26]

    await db.execute('''
      CREATE TABLE edukasi_menyusui_asi (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        isi TEXT,
        manfaat_asi TEXT,
        cara TEXT,
        masalah TEXT,
        solusi TEXT,
        gambar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 7]

    await db.execute('''
      CREATE TABLE edukasi_setelah_melahirkan (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        gambar_url TEXT,
        isi TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 7]

    await db.execute('''
      CREATE TABLE edukasi_tanda_melahirkan (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        isi TEXT,
        tanda TEXT,
        tindakan TEXT,
        gambar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 6]

    await db.execute('''
      CREATE TABLE edukasi_trimester (
        id TEXT PRIMARY KEY,
        trimester TEXT,
        kategori TEXT,
        judul TEXT,
        isi TEXT,
        gambar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 6]

    await db.execute('''
      CREATE TABLE aturan_porsi_mpasi (
        id TEXT PRIMARY KEY,
        bulan_min INTEGER,
        bulan_max INTEGER,
        tekstur TEXT,
        frekuensi TEXT,
        porsi TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 28]

    await db.execute('''
      CREATE TABLE materi_mpasi (
        id TEXT PRIMARY KEY,
        judul TEXT,
        konten TEXT,
        gambar_url TEXT,
        bulan_min INTEGER,
        bulan_max INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 28, 29]

    await db.execute('''
      CREATE TABLE jadwal_harian_mpasi (
        id TEXT PRIMARY KEY,
        bulan_min INTEGER,
        bulan_max INTEGER,
        waktu TEXT,
        aktivitas TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 29]

    await db.execute('''
      CREATE TABLE resep_mpasi (
        id TEXT PRIMARY KEY,
        bulan_min INTEGER,
        bulan_max INTEGER,
        judul TEXT,
        tipe TEXT,
        gambar_url TEXT,
        waktu_persiapan INTEGER,
        kalori INTEGER,
        porsi INTEGER,
        bahan_bahan TEXT,
        cara_membuat TEXT,
        manfaat TEXT,
        tips TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 29, 30]

    await db.execute('''
      CREATE TABLE edukasi_imd (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        isi TEXT,
        manfaat TEXT,
        langkah TEXT,
        gambar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    '''); // [cite: 6, 7]
  }

  // Seeding Otomatis Seluruh Data Master Sekaligus Menggunakan Batch
  Future<void> _seedMasterData(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString('lib/db/assets/master_data.json');
      final Map<String, dynamic> masterData = json.decode(jsonString);
      
      final batch = db.batch();

      // Daftar tabel master target penyuntikan data kotor
      final List<String> tableNames = [
        'roles',
        'status_jadwal',
        'status_request',
        'aturan_porsi_mpasi',
        'dosis_vaksin',
        'edukasi_informasi_umum',
        'edukasi_menyusui_asi',
        'edukasi_setelah_melahirkan',
        'edukasi_tanda_melahirkan',
        'edukasi_trimester',
        'jadwal_harian_mpasi',
        'master_standar_antropometri',
        'materi_mpasi',
        'resep_mpasi',
        'edukasi_imd'
      ];

      for (String table in tableNames) {
        if (masterData[table] != null) {
          for (var row in masterData[table]) {
            batch.insert(
              table, 
              row as Map<String, dynamic>, 
              conflictAlgorithm: ConflictAlgorithm.replace
            );
          }
        }
      }

      // Commit seluruh tumpukan insert kolektif dalam satu waktu
      await batch.commit(noResult: true);
      print("🎉 FIX SUCCESS: Seluruh data skema KIA dan 15 master tabel berhasil dimasukkan.");

    } catch (e) {
      print("❌ CRITICAL SEED ERROR: Gagal memproses JSON master data: $e");
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}