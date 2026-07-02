import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'dart:io'; // Digunakan untuk menangkap SocketException
import 'sync_payload_dto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncService {
  final AppDatabase _dbInstance = AppDatabase.instance;

  // 1. Kumpulkan semua baris data dari database lokal yang is_synced = 0
  Future<SyncPayloadDto> prepareSyncPayload() async {
    final db = await _dbInstance.database;

    Future<List<Map<String, dynamic>>> getUnsynced(String tableName) {
      return db.query(tableName, where: 'is_synced = ?', whereArgs: [0]);
    }

    return SyncPayloadDto(
      desa: await getUnsynced('desa'),
      puskesmas: await getUnsynced('puskesmas'),
      posyandu: await getUnsynced('posyandu'),
      kartuKeluarga: await getUnsynced('kartu_keluarga'),
      penduduk: await getUnsynced('penduduk'),
      pengguna: await getUnsynced('pengguna'),
      bidan: await getUnsynced('bidan'),
      kader: await getUnsynced('kader'),
      ibu: await getUnsynced('ibu'),
      kehamilan: await getUnsynced('kehamilan'),
      pemeriksaanKehamilan: await getUnsynced('pemeriksaan_kehamilan'),
      evaluasiKesehatanIbu: await getUnsynced('evaluasi_kesehatan_ibu'),
      pemeriksaanDokterTrimester1: await getUnsynced('pemeriksaan_dokter_trimester_1'),
      pemeriksaanDokterTrimester3: await getUnsynced('pemeriksaan_dokter_trimester_3'),
      pemeriksaanLanjutanTrimester3: await getUnsynced('pemeriksaan_lanjutan_trimester_3'),
      catatanPelayananTrimester1: await getUnsynced('catatan_pelayanan_trimester_1'),
      catatanPelayananTrimester2: await getUnsynced('catatan_pelayanan_trimester_2'),
      catatanPelayananTrimester3: await getUnsynced('catatan_pelayanan_trimester_3'),
      skriningPreeklampsia: await getUnsynced('skrining_preeklampsia'),
      grafikEvaluasiKehamilan: await getUnsynced('grafik_evaluasi_kehamilan'),
      grafikPeningkatanBb: await getUnsynced('grafik_peningkatan_bb'),
      penjelasanHasilGrafik: await getUnsynced('penjelasan_hasil_grafik'),
      rencanaPersalinan: await getUnsynced('rencana_persalinan'),
      ringkasanPelayananPersalinan: await getUnsynced('ringkasan_pelayanan_persalinan'),
      riwayatProsesMelahirkan: await getUnsynced('riwayat_proses_melahirkan'),
      keteranganLahir: await getUnsynced('keterangan_lahir'),
      pelayananIbuNifas: await getUnsynced('pelayanan_ibu_nifas'),
      catatanPelayananNifas: await getUnsynced('catatan_pelayanan_nifas'),
      checklistPemantauanIbuNifas: await getUnsynced('checklist_pemantauan_ibu_nifas'),
      riwayatKehamilanLalu: await getUnsynced('riwayat_kehamilan_lalu'),
      rujukan: await getUnsynced('rujukan'),
      logTtdMms: await getUnsynced('log_ttd_mms'),
      anak: await getUnsynced('anak'),
      keluhanAnak: await getUnsynced('keluhan_anak'),
      periksaGigi: await getUnsynced('periksa_gigi'),
      pengukuranLila: await getUnsynced('pengukuran_lila'),
      catatanPertumbuhan: await getUnsynced('catatan_pertumbuhan'),
      jadwalLayanan: await getUnsynced('jadwal_layanan'),
      jadwalImunisasiAnak: await getUnsynced('jadwal_imunisasi_anak'),
      requestPerubahanImunisasi: await getUnsynced('request_perubahan_imunisasi'),
    );
  }

  // 2. Transaksi Massal: Ubah flag is_synced menjadi 1 untuk semua data yang sukses dikirim
  Future<void> _markPayloadAsSynced(SyncPayloadDto payload) async {
    final db = await _dbInstance.database;

    await db.transaction((txn) async {
      Future<void> commitTable(List<Map<String, dynamic>> items, String tableName, String idCol) async {
        for (var item in items) {
          await txn.update(tableName, {'is_synced': 1}, where: '$idCol = ?', whereArgs: [item[idCol]]);
        }
      }

      await commitTable(payload.desa, 'desa', 'id');
      await commitTable(payload.puskesmas, 'puskesmas', 'id');
      await commitTable(payload.posyandu, 'posyandu', 'id');
      await commitTable(payload.kartuKeluarga, 'kartu_keluarga', 'id');
      await commitTable(payload.penduduk, 'penduduk', 'id');
      await commitTable(payload.pengguna, 'pengguna', 'id');
      await commitTable(payload.bidan, 'bidan', 'id');
      await commitTable(payload.kader, 'kader', 'id');
      await commitTable(payload.ibu, 'ibu', 'id');
      await commitTable(payload.kehamilan, 'kehamilan', 'id');
      await commitTable(payload.pemeriksaanKehamilan, 'pemeriksaan_kehamilan', 'id_periksa');
      await commitTable(payload.evaluasiKesehatanIbu, 'evaluasi_kesehatan_ibu', 'id');
      await commitTable(payload.pemeriksaanDokterTrimester1, 'pemeriksaan_dokter_trimester_1', 'id_trimester1');
      await commitTable(payload.pemeriksaanDokterTrimester3, 'pemeriksaan_dokter_trimester_3', 'id_trimester3');
      await commitTable(payload.pemeriksaanLanjutanTrimester3, 'pemeriksaan_lanjutan_trimester_3', 'id_lanjutan_t3');
      await commitTable(payload.catatanPelayananTrimester1, 'catatan_pelayanan_trimester_1', 'id_catatan');
      await commitTable(payload.catatanPelayananTrimester2, 'catatan_pelayanan_trimester_2', 'id_catatan_t2');
      await commitTable(payload.catatanPelayananTrimester3, 'catatan_pelayanan_trimester_3', 'id_catatan_t3');
      await commitTable(payload.skriningPreeklampsia, 'skrining_preeklampsia', 'id');
      await commitTable(payload.grafikEvaluasiKehamilan, 'grafik_evaluasi_kehamilan', 'id');
      await commitTable(payload.grafikPeningkatanBb, 'grafik_peningkatan_bb', 'id');
      await commitTable(payload.penjelasanHasilGrafik, 'penjelasan_hasil_grafik', 'id_penjelasan');
      await commitTable(payload.rencanaPersalinan, 'rencana_persalinan', 'id_rencana_persalinan');
      await commitTable(payload.ringkasanPelayananPersalinan, 'ringkasan_pelayanan_persalinan', 'id');
      await commitTable(payload.riwayatProsesMelahirkan, 'riwayat_proses_melahirkan', 'id');
      await commitTable(payload.keteranganLahir, 'keterangan_lahir', 'id');
      await commitTable(payload.pelayananIbuNifas, 'pelayanan_ibu_nifas', 'id');
      await commitTable(payload.catatanPelayananNifas, 'catatan_pelayanan_nifas', 'id_catatan_nifas');
      await commitTable(payload.checklistPemantauanIbuNifas, 'checklist_pemantauan_ibu_nifas', 'id');
      await commitTable(payload.riwayatKehamilanLalu, 'riwayat_kehamilan_lalu', 'id_riwayat');
      await commitTable(payload.rujukan, 'rujukan', 'id');
      await commitTable(payload.logTtdMms, 'log_ttd_mms', 'id');
      await commitTable(payload.anak, 'anak', 'id');
      await commitTable(payload.keluhanAnak, 'keluhan_anak', 'id');
      await commitTable(payload.periksaGigi, 'periksa_gigi', 'id');
      await commitTable(payload.pengukuranLila, 'pengukuran_lila', 'id');
      await commitTable(payload.catatanPertumbuhan, 'catatan_pertumbuhan', 'id');
      await commitTable(payload.jadwalLayanan, 'jadwal_layanan', 'id');
      await commitTable(payload.jadwalImunisasiAnak, 'jadwal_imunisasi_anak', 'id');
      await commitTable(payload.requestPerubahanImunisasi, 'request_perubahan_imunisasi', 'id');
    });
  }

  // 3. Eksekusi Upload sinkronisasi global massal
  // Tambahan Port :8080 (sesuai setingan Echo Golang) pada IP WiFi Laptop kamu
  // final String _baseUrl = 'http://https://api.generasisehat.com/ibu'; 
  final String _baseUrl = 'http://10.77.214.125:8080/ibu'; 

  Future<void> executeBulkSync(String tokenjwt) async {
    try {
      final payload = await prepareSyncPayload();

      if (payload.isEmpty) {
        print("Sistem Sync: Semua tabel dinamis milik Ibu sudah sinkron.");
        return;
      }

      print("Memulai kirim batch data Ibu ke server Golang...");

      // PERBAIKAN: Ditambahkan .timeout() agar request tidak menggantung saat offline
      final response = await http.post(
        Uri.parse('$_baseUrl/sync/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenjwt',
        },
        body: json.encode(payload.toJson()),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await _markPayloadAsSynced(payload);
        print("🎉 SUCCESS: Sinkronisasi massal data Ibu selesai!");
      } else {
        print("Gagal Sync: Server merespon dengan kode ${response.statusCode}");
      }
    } on SocketException {
      // PERBAIKAN: Menangkap kondisi tanpa internet fisik secara anggun
      print("📡 info: Perangkat sedang offline atau server tidak terjangkau. Sinkronisasi push ditunda.");
    } on http.ClientException {
      print("📡 info: Masalah koneksi klien. Sinkronisasi push ditunda.");
    } catch (e) {
      print("📡 info: Sinkronisasi push ditunda sementara (Timeout/Error: $e)");
    }
  }
}