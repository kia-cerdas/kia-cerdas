import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class AppLocalDataSource {
  // Instance Tunggal Koneksi Database
  final AppDatabase _dbInstance = AppDatabase.instance;

  // Generic Helper untuk mempermudah operasi INSERT/UPDATE (UPSERT) tabel dinamis
  Future<void> _upsertLocal(String tableName, Map<String, dynamic> data, {String idColumn = 'id'}) async {
    final db = await _dbInstance.database;
    final localData = Map<String, dynamic>.from(data);
    
    // Semua data transaksional lokal wajib ditandai belum sync (0)
    localData['is_synced'] = 0;

    await db.insert(
      tableName,
      localData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Generic Helper untuk mengambil semua data dari suatu tabel
  Future<List<Map<String, dynamic>>> _getAll(String tableName) async {
    final db = await _dbInstance.database;
    return await db.query(tableName);
  }

  // ====================================================================
  // 1. MANAJEMEN WILAYAH, PENDUDUK & AKUN (DINAMIS)
  // ====================================================================

  Future<void> insertOrUpdateDesa(Map<String, dynamic> data) => _upsertLocal('desa', data);
  Future<List<Map<String, dynamic>>> getAllDesa() => _getAll('desa');

  Future<void> insertOrUpdatePuskesmas(Map<String, dynamic> data) => _upsertLocal('puskesmas', data);
  Future<List<Map<String, dynamic>>> getAllPuskesmas() => _getAll('puskesmas');

  Future<void> insertOrUpdatePosyandu(Map<String, dynamic> data) => _upsertLocal('posyandu', data);
  Future<List<Map<String, dynamic>>> getAllPosyandu() => _getAll('posyandu');

  Future<void> insertOrUpdateKartuKeluarga(Map<String, dynamic> data) => _upsertLocal('kartu_keluarga', data);
  Future<List<Map<String, dynamic>>> getAllKartuKeluarga() => _getAll('kartu_keluarga');

  Future<void> insertOrUpdatePenduduk(Map<String, dynamic> data) => _upsertLocal('penduduk', data);
  Future<List<Map<String, dynamic>>> getAllPenduduk() => _getAll('penduduk');

  Future<void> insertOrUpdatePengguna(Map<String, dynamic> data) => _upsertLocal('pengguna', data);
  Future<List<Map<String, dynamic>>> getAllPengguna() => _getAll('pengguna');

  Future<void> insertOrUpdateBidan(Map<String, dynamic> data) => _upsertLocal('bidan', data);
  Future<List<Map<String, dynamic>>> getAllBidan() => _getAll('bidan');

  Future<void> insertOrUpdateKader(Map<String, dynamic> data) => _upsertLocal('kader', data);
  Future<List<Map<String, dynamic>>> getAllKader() => _getAll('kader');


  // ====================================================================
  // 2. MANAJEMEN DATA LAYANAN KESEHATAN IBU & KEHAMILAN (DINAMIS)
  // ====================================================================

  Future<void> insertOrUpdateIbu(Map<String, dynamic> data) => _upsertLocal('ibu', data);
  Future<List<Map<String, dynamic>>> getAllIbu() => _getAll('ibu');

  Future<void> insertOrUpdateKehamilan(Map<String, dynamic> data) => _upsertLocal('kehamilan', data);
  Future<List<Map<String, dynamic>>> getAllKehamilan() => _getAll('kehamilan');

  Future<void> insertOrUpdatePemeriksaanKehamilan(Map<String, dynamic> data) => 
      _upsertLocal('pemeriksaan_kehamilan', data, idColumn: 'id_periksa');
  Future<List<Map<String, dynamic>>> getAllPemeriksaanKehamilan() => _getAll('pemeriksaan_kehamilan');

  Future<void> insertOrUpdateEvaluasiKesehatanIbu(Map<String, dynamic> data) => _upsertLocal('evaluasi_kesehatan_ibu', data);
  Future<List<Map<String, dynamic>>> getAllEvaluasiKesehatanIbu() => _getAll('evaluasi_kesehatan_ibu');

  Future<void> insertPemeriksaanDokterTrimester1(Map<String, dynamic> data) => 
      _upsertLocal('pemeriksaan_dokter_trimester_1', data, idColumn: 'id_trimester1');
  Future<List<Map<String, dynamic>>> getAllPemeriksaanDokterTrimester1() => _getAll('pemeriksaan_dokter_trimester_1');

  Future<void> insertPemeriksaanDokterTrimester3(Map<String, dynamic> data) => 
      _upsertLocal('pemeriksaan_dokter_trimester_3', data, idColumn: 'id_trimester3');
  Future<List<Map<String, dynamic>>> getAllPemeriksaanDokterTrimester3() => _getAll('pemeriksaan_dokter_trimester_3');

  Future<void> insertPemeriksaanLanjutanTrimester3(Map<String, dynamic> data) => 
      _upsertLocal('pemeriksaan_lanjutan_trimester_3', data, idColumn: 'id_lanjutan_t3');
  Future<List<Map<String, dynamic>>> getAllPemeriksaanLanjutanTrimester3() => _getAll('pemeriksaan_lanjutan_trimester_3');

  Future<void> insertCatatanPelayananTrimester1(Map<String, dynamic> data) => 
      _upsertLocal('catatan_pelayanan_trimester_1', data, idColumn: 'id_catatan');
  Future<void> insertCatatanPelayananTrimester2(Map<String, dynamic> data) => 
      _upsertLocal('catatan_pelayanan_trimester_2', data, idColumn: 'id_catatan_t2');
  Future<void> insertCatatanPelayananTrimester3(Map<String, dynamic> data) => 
      _upsertLocal('catatan_pelayanan_trimester_3', data, idColumn: 'id_catatan_t3');

  Future<void> insertSkriningPreeklampsia(Map<String, dynamic> data) => _upsertLocal('skrining_preeklampsia', data);
  Future<void> insertGrafikEvaluasiKehamilan(Map<String, dynamic> data) => _upsertLocal('grafik_evaluasi_kehamilan', data);
  Future<void> insertGrafikPeningkatanBb(Map<String, dynamic> data) => _upsertLocal('grafik_peningkatan_bb', data);
  
  Future<void> insertPenjelasanHasilGrafik(Map<String, dynamic> data) => 
      _upsertLocal('penjelasan_hasil_grafik', data, idColumn: 'id_penjelasan');

  Future<void> insertRencanaPersalinan(Map<String, dynamic> data) => 
      _upsertLocal('rencana_persalinan', data, idColumn: 'id_rencana_persalinan');

  Future<void> insertRingkasanPelayananPersalinan(Map<String, dynamic> data) => _upsertLocal('ringkasan_pelayanan_persalinan', data);
  Future<void> insertRiwayatProsesMelahirkan(Map<String, dynamic> data) => _upsertLocal('riwayat_proses_melahirkan', data);
  Future<void> insertKeteranganLahir(Map<String, dynamic> data) => _upsertLocal('keterangan_lahir', data);
  
  Future<void> insertPelayananIbuNifas(Map<String, dynamic> data) => _upsertLocal('pelayanan_ibu_nifas', data);
  
  Future<void> insertCatatanPelayananNifas(Map<String, dynamic> data) => 
      _upsertLocal('catatan_pelayanan_nifas', data, idColumn: 'id_catatan_nifas');

  Future<void> insertChecklistPemantauanIbuNifas(Map<String, dynamic> data) => _upsertLocal('checklist_pemantauan_ibu_nifas', data);
  
  Future<void> insertRiwayatKehamilanLalu(Map<String, dynamic> data) => 
      _upsertLocal('riwayat_kehamilan_lalu', data, idColumn: 'id_riwayat');

  Future<void> insertRujukan(Map<String, dynamic> data) => _upsertLocal('rujukan', data);
  Future<void> insertLogTtdMms(Map<String, dynamic> data) => _upsertLocal('log_ttd_mms', data);


  // ====================================================================
  // 3. MANAJEMEN DATA ANAK, PERTUMBUHAN & IMUNISASI (DINAMIS)
  // ====================================================================

  Future<void> insertOrUpdateAnak(Map<String, dynamic> data) => _upsertLocal('anak', data);
  Future<List<Map<String, dynamic>>> getAllAnak() => _getAll('anak');

  Future<void> insertKeluhanAnak(Map<String, dynamic> data) => _upsertLocal('keluhan_anak', data);
  Future<void> insertPeriksaGigi(Map<String, dynamic> data) => _upsertLocal('periksa_gigi', data);
  Future<void> insertPengukuranLila(Map<String, dynamic> data) => _upsertLocal('pengukuran_lila', data);
  
  Future<void> insertCatatanPertumbuhan(Map<String, dynamic> data) => _upsertLocal('catatan_pertumbuhan', data);
  Future<List<Map<String, dynamic>>> getAllCatatanPertumbuhan() => _getAll('catatan_pertumbuhan');

  Future<void> insertJadwalLayanan(Map<String, dynamic> data) => _upsertLocal('jadwal_layanan', data);
  Future<List<Map<String, dynamic>>> getAllJadwalLayanan() => _getAll('jadwal_layanan');

  Future<void> insertJadwalImunisasiAnak(Map<String, dynamic> data) => _upsertLocal('jadwal_imunisasi_anak', data);
  Future<List<Map<String, dynamic>>> getAllJadwalImunisasiAnak() => _getAll('jadwal_imunisasi_anak');

  Future<void> insertRequestPerubahanImunisasi(Map<String, dynamic> data) => _upsertLocal('request_perubahan_imunisasi', data);
  Future<List<Map<String, dynamic>>> getAllRequestPerubahanImunisasi() => _getAll('request_perubahan_imunisasi');


  // ====================================================================
  // 4. KUMPULAN TABEL MASTER & EDUKASI (READ-ONLY UTK UI)
  // ====================================================================

  Future<List<Map<String, dynamic>>> getRoles() => _getAll('roles');
  Future<List<Map<String, dynamic>>> getStatusJadwal() => _getAll('status_jadwal');
  Future<List<Map<String, dynamic>>> getStatusRequest() => _getAll('status_request');
  Future<List<Map<String, dynamic>>> getVaksin() => _getAll('vaksin');
  Future<List<Map<String, dynamic>>> getDosisVaksin() => _getAll('dosis_vaksin');
  Future<List<Map<String, dynamic>>> getMasterStandarAntropometri() => _getAll('master_standar_antropometri');
  Future<List<Map<String, dynamic>>> getEdukasiInformasiUmum() => _getAll('edukasi_informasi_umum');
  Future<List<Map<String, dynamic>>> getEdukasiMenyusuiAsi() => _getAll('edukasi_menyusui_asi');
  Future<List<Map<String, dynamic>>> getEdukasiSetelahMelahirkan() => _getAll('edukasi_setelah_melahirkan');
  Future<List<Map<String, dynamic>>> getEdukasiTandaMelahirkan() => _getAll('edukasi_tanda_melahirkan');
  Future<List<Map<String, dynamic>>> getEdukasiTrimester() => _getAll('edukasi_trimester');
  Future<List<Map<String, dynamic>>> getAturanPorsiMpasi() => _getAll(' aturan_porsi_mpasi');
  Future<List<Map<String, dynamic>>> getMateriMpasi() => _getAll('materi_mpasi');
  Future<List<Map<String, dynamic>>> getJadwalHarianMpasi() => _getAll('jadwal_harian_mpasi');
  Future<List<Map<String, dynamic>>> getResepMpasi() => _getAll('resep_mpasi');
  Future<List<Map<String, dynamic>>> getEdukasiImd() => _getAll('edukasi_imd');
}