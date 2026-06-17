import 'dart:convert';
import 'dart:io'; // Digunakan untuk menangkap SocketException ketika offline
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class PullService {
  final AppDatabase _dbInstance = AppDatabase.instance;
  
  // PERBAIKAN: Ditambahkan port :8080 sesuai dengan konfigurasi endpoint Echo Golang kamu
  final String _baseUrl = 'http://10.77.214.125:8080/ibu';

  // Fungsi Utama untuk Menarik Seluruh Data Transaksional Terbaru dari Cloud Server
  Future<void> executeBulkPull(String tokenJwt) async {
    try {
      print("Sistem Pull: Menghubungi cloud server untuk menarik data terbaru...");

      // 1. Eksekusi HTTP GET request ke endpoint Echo Golang dengan batas waktu timeout
      final response = await http.get(
        Uri.parse('$_baseUrl/sync/pull'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJwt', // Menyertakan JWT token akses Ibu
        },
      ).timeout(const Duration(seconds: 5)); // PERBAIKAN: Proteksi timeout 5 detik agar tidak macet saat offline

      // 2. Jika server merespon sukses (200 OK)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Ekstrak objek map dari wrapper 'data' sesuai struktur JSON Echo Controller
        if (responseData['status'] != 'success' || responseData['data'] == null) {
          print("❌ PULL FAILED: Struktur response data dari server tidak valid.");
          return;
        }
        
        Map<String, dynamic> cloudData = responseData['data'];

        final db = await _dbInstance.database;
        final batch = db.batch();

        // Helper lokal untuk memasukkan data server ke dalam Batch secara otomatis
        void addTableToBatch(String jsonKey, String tableName, String idColumn) {
          if (cloudData[jsonKey] != null && cloudData[jsonKey] is List) {
            final List<dynamic> rows = cloudData[jsonKey];
            for (var row in rows) {
              if (row is Map<String, dynamic>) {
                final Map<String, dynamic> localRow = Map.from(row);
                
                // KUNCI UTAMA: Karena data ini murni berasal dari server, 
                // kita set flag is_synced = 1 agar tidak dikirim balik ke server saat proses Push.
                localRow['is_synced'] = 1; 

                batch.insert(
                  tableName,
                  localRow,
                  conflictAlgorithm: ConflictAlgorithm.replace, // Timpa jika ada pembaruan data terbaru
                );
              }
            }
          }
        }

        // ====================================================================
        // PROSES PEMETAAN BATCH INSERT KE SQLITE LOKAL
        // ====================================================================

        // 1. KELOMPOK WILAYAH, PENDUDUK & AKUN
        addTableToBatch('desa', 'desa', 'id');
        addTableToBatch('puskesmas', 'puskesmas', 'id');
        addTableToBatch('posyandu', 'posyandu', 'id');
        addTableToBatch('kartu_keluarga', 'kartu_keluarga', 'id');
        addTableToBatch('penduduk', 'penduduk', 'id');
        addTableToBatch('pengguna', 'pengguna', 'id');
        addTableToBatch('bidan', 'bidan', 'id');
        addTableToBatch('kader', 'kader', 'id');

        // 2. KELOMPOK LAYANAN KESEHATAN IBU & KEHAMILAN
        addTableToBatch('ibu', 'ibu', 'id');
        addTableToBatch('kehamilan', 'kehamilan', 'id');
        addTableToBatch('pemeriksaan_kehamilan', 'pemeriksaan_kehamilan', 'id_periksa');
        addTableToBatch('evaluasi_kesehatan_ibu', 'evaluasi_kesehatan_ibu', 'id');
        addTableToBatch('pemeriksaan_dokter_trimester_1', 'pemeriksaan_dokter_trimester_1', 'id_trimester1');
        addTableToBatch('pemeriksaan_dokter_trimester_3', 'pemeriksaan_dokter_trimester_3', 'id_trimester3');
        addTableToBatch('pemeriksaan_lanjutan_trimester_3', 'pemeriksaan_lanjutan_trimester_3', 'id_lanjutan_t3');
        addTableToBatch('catatan_pelayanan_trimester_1', 'catatan_pelayanan_trimester_1', 'id_catatan');
        addTableToBatch('catatan_pelayanan_trimester_2', 'catatan_pelayanan_trimester_2', 'id_catatan_t2');
        addTableToBatch('catatan_pelayanan_trimester_3', 'catatan_pelayanan_trimester_3', 'id_catatan_t3');
        addTableToBatch('skrining_preeklampsia', 'skrining_preeklampsia', 'id');
        addTableToBatch('grafik_evaluasi_kehamilan', 'grafik_evaluasi_kehamilan', 'id');
        addTableToBatch('grafik_peningkatan_bb', 'grafik_peningkatan_bb', 'id');
        addTableToBatch('penjelasan_hasil_grafik', 'penjelasan_hasil_grafik', 'id_penjelasan');
        addTableToBatch('rencana_persalinan', 'rencana_persalinan', 'id_rencana_persalinan');
        addTableToBatch('ringkasan_pelayanan_persalinan', 'ringkasan_pelayanan_persalinan', 'id');
        addTableToBatch('riwayat_proses_melahirkan', 'riwayat_proses_melahirkan', 'id');
        addTableToBatch('keterangan_lahir', 'keterangan_lahir', 'id');
        addTableToBatch('pelayanan_ibu_nifas', 'pelayanan_ibu_nifas', 'id');
        addTableToBatch('catatan_pelayanan_nifas', 'catatan_pelayanan_nifas', 'id_catatan_nifas');
        addTableToBatch('checklist_pemantauan_ibu_nifas', 'checklist_pemantauan_ibu_nifas', 'id');
        addTableToBatch('riwayat_kehamilan_lalu', 'riwayat_kehamilan_lalu', 'id_riwayat');
        addTableToBatch('rujukan', 'rujukan', 'id');
        addTableToBatch('log_ttd_mms', 'log_ttd_mms', 'id');

        // 3. KELOMPOK LAYANAN ANAK, PETUMBUHAN & IMUNISASI
        addTableToBatch('anak', 'anak', 'id');
        addTableToBatch('keluhan_anak', 'keluhan_anak', 'id');
        addTableToBatch('periksaGigi', 'periksa_gigi', 'id');
        addTableToBatch('pengukuran_lila', 'pengukuran_lila', 'id');
        addTableToBatch('catatan_pertumbuhan', 'catatan_pertumbuhan', 'id');
        addTableToBatch('jadwal_layanan', 'jadwal_layanan', 'id');
        addTableToBatch('jadwal_imunisasi_anak', 'jadwal_imunisasi_anak', 'id');
        addTableToBatch('request_perubahan_imunisasi', 'request_perubahan_imunisasi', 'id');

        // Eksekusi seluruh tumpukan insert data cloud ke SQLite secara atomik sekaligus
        await batch.commit(noResult: true);
        print("🎉 PULL SUCCESS: Seluruh data cloud terbaru dari seluruh tabel berhasil disinkronkan ke SQLite lokal!");
      } else {
        print("❌ PULL FAILED: Server merespon dengan HTTP status code ${response.statusCode}");
      }
    } on SocketException {
      // PERBAIKAN: Cegah timeout crash di perangkat fisik saat internet mati total
      print("📡 info: Perangkat sedang offline atau server tidak terjangkau. Sinkronisasi pull ditunda.");
    } on http.ClientException {
      print("📡 info: Masalah koneksi klien sewaktu pull data. Ditunda.");
    } catch (e) {
      print("📡 info: Gagal memproses data masuk dari server (Ditunda/Error): $e");
    }
  }
}