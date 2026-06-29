import 'package:flutter/foundation.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';
import 'app_database.dart';

/// Membaca data imunisasi dari SQLite lokal.
/// Digunakan sebagai fallback saat offline, atau sebagai sumber data utama
/// setelah pull pertama berhasil.
class ImunisasiLocalDatasource {
  final _db = AppDatabase.instance;

  // ── Anak ────────────────────────────────────────────────────────────────────

  /// Mengembalikan daftar [ImunisasiModel] untuk semua anak milik ibu (userID).
  /// Join: pengguna → penduduk → ibu → kehamilan → anak + penduduk anak
  Future<List<ImunisasiModel>> getJadwalImunisasiByUser(int userID) async {
    final db = await _db.database;

    // 1. Ambil anak-anak milik ibu ini
    final anakRows = await db.rawQuery('''
      SELECT a.id         AS anak_id,
             p.nama_anggota_keluarga AS nama_anak,
             p.tanggal_lahir
      FROM pengguna u
      JOIN penduduk pu  ON pu.id = u.penduduk_id
      JOIN ibu i        ON i.penduduk_id = pu.id
      JOIN kehamilan k  ON k.ibu_id = i.id
      JOIN anak a       ON a.kehamilan_id = k.id
      JOIN penduduk p   ON p.id = a.penduduk_id
      WHERE u.id = ?
        AND (a.deleted_at IS NULL OR a.deleted_at = '')
    ''', [userID]);

    if (anakRows.isEmpty) return [];

    final result = <ImunisasiModel>[];
    for (final anak in anakRows) {
      final anakId = _toInt(anak['anak_id']);
      final jadwal = await _getJadwalByAnak(db, anakId);
      final terlewat = jadwal.where((j) => _isTerlewat(j.statusId)).length;

      result.add(ImunisasiModel(
        anakId: anakId,
        namaAnak: anak['nama_anak']?.toString() ?? '',
        tanggalLahir: _parseDate(anak['tanggal_lahir']),
        jumlahTerlewat: terlewat,
        jadwal: jadwal,
      ));
    }
    return result;
  }

  /// Mengembalikan [ImunisasiModel] untuk satu anak.
  Future<List<ImunisasiModel>> getJadwalImunisasiByAnakId(int anakId) async {
    final db = await _db.database;

    final anakRow = await db.rawQuery('''
      SELECT a.id AS anak_id,
             p.nama_anggota_keluarga AS nama_anak,
             p.tanggal_lahir
      FROM anak a
      JOIN penduduk p ON p.id = a.penduduk_id
      WHERE a.id = ?
        AND (a.deleted_at IS NULL OR a.deleted_at = '')
      LIMIT 1
    ''', [anakId]);

    if (anakRow.isEmpty) return [];

    final jadwal = await _getJadwalByAnak(db, anakId);
    final terlewat = jadwal.where((j) => _isTerlewat(j.statusId)).length;

    return [
      ImunisasiModel(
        anakId: anakId,
        namaAnak: anakRow.first['nama_anak']?.toString() ?? '',
        tanggalLahir: _parseDate(anakRow.first['tanggal_lahir']),
        jumlahTerlewat: terlewat,
        jadwal: jadwal,
      )
    ];
  }

  /// Mengembalikan detail satu jadwal imunisasi (join dosis_vaksin + vaksin + status_jadwal).
  Future<ImunisasiDetailModel?> getJadwalById(int jadwalId) async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT j.id            AS jadwal_id,
             j.id_anak,
             j.id_status_jadwal,
             j.tanggal_estimasi,
             dv.nama_dosis,
             v.deskripsi,
             v.efek_samping,
             sj.nama_status  AS status,
             p.nama_anggota_keluarga AS nama_anak,
             p.tanggal_lahir
      FROM jadwal_imunisasi_anak j
      LEFT JOIN dosis_vaksin dv ON dv.id = j.id_dosis_vaksin
      LEFT JOIN vaksin v        ON v.id  = dv.id_vaksin
      LEFT JOIN status_jadwal sj ON sj.id = j.id_status_jadwal
      JOIN anak a               ON a.id  = j.id_anak
      JOIN penduduk p           ON p.id  = a.penduduk_id
      WHERE j.id = ?
      LIMIT 1
    ''', [jadwalId]);

    if (rows.isEmpty) return null;
    final r = rows.first;

    return ImunisasiDetailModel(
      anakId: _toInt(r['id_anak']),
      namaAnak: r['nama_anak']?.toString() ?? '',
      tanggalLahir: _parseDate(r['tanggal_lahir']),
      jumlahTerlewat: 0,
      jadwal: [
        JadwalImunisasiModel(
          jadwalId: _toInt(r['jadwal_id']),
          namaDosis: r['nama_dosis']?.toString() ?? '',
          tanggalEstimasi: _parseDate(r['tanggal_estimasi']),
          statusId: _toInt(r['id_status_jadwal']),
          status: r['status']?.toString() ?? '',
          deskripsi: r['deskripsi']?.toString() ?? '',
          efekSamping: r['efek_samping']?.toString() ?? '',
        )
      ],
    );
  }

  // ── Request perubahan jadwal (offline queue) ─────────────────────────────

  /// Simpan request perubahan jadwal ke antrian lokal (is_synced = 0).
  Future<void> queueRequestPerubahan({
    required int jadwalId,
    required String tanggalBaru,
    required String alasan,
  }) async {
    final db = await _db.database;
    await db.insert('request_perubahan_imunisasi', {
      'id_jadwal_imunisasi': jadwalId,
      'tanggal_baru': tanggalBaru,
      'alasan': alasan,
      'id_status_request': 1, // pending
      'created_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
    debugPrint('[ImunisasiLocal] request perubahan disimpan ke antrian offline.');
  }

  /// Flush semua request belum disinkron (dipanggil saat kembali online).
  Future<List<Map<String, dynamic>>> getUnsyncedRequests() async {
    final db = await _db.database;
    return db.query('request_perubahan_imunisasi',
        where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<void> markRequestSynced(int localId) async {
    final db = await _db.database;
    await db.update('request_perubahan_imunisasi', {'is_synced': 1},
        where: 'id = ?', whereArgs: [localId]);
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  Future<List<JadwalImunisasiModel>> _getJadwalByAnak(dynamic db, int anakId) async {
    final rows = await db.rawQuery('''
      SELECT j.id            AS jadwal_id,
             j.id_status_jadwal,
             j.tanggal_estimasi,
             dv.nama_dosis,
             v.deskripsi,
             v.efek_samping,
             sj.nama_status  AS status
      FROM jadwal_imunisasi_anak j
      LEFT JOIN dosis_vaksin dv  ON dv.id = j.id_dosis_vaksin
      LEFT JOIN vaksin v         ON v.id  = dv.id_vaksin
      LEFT JOIN status_jadwal sj ON sj.id = j.id_status_jadwal
      WHERE j.id_anak = ?
        AND (j.deleted_at IS NULL OR j.deleted_at = '')
      ORDER BY j.tanggal_estimasi ASC
    ''', [anakId]);

    return rows
        .map<JadwalImunisasiModel>((r) => JadwalImunisasiModel(
              jadwalId: _toInt(r['jadwal_id']),
              namaDosis: r['nama_dosis']?.toString() ?? '',
              tanggalEstimasi: _parseDate(r['tanggal_estimasi']),
              statusId: _toInt(r['id_status_jadwal']),
              status: r['status']?.toString() ?? '',
              deskripsi: r['deskripsi']?.toString() ?? '',
              efekSamping: r['efek_samping']?.toString() ?? '',
            ))
        .toList();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  /// Status terlewat: 3=mendekati-kritis, 4=sangat-terlambat, 5=krisis
  static bool _isTerlewat(int statusId) => statusId >= 3 && statusId <= 5;
}
