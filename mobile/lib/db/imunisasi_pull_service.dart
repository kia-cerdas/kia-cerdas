import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'app_database.dart';


/// Menarik semua data yang dibutuhkan fitur imunisasi ibu dari backend
/// lalu menyimpannya ke SQLite lokal (offline-first).
///
/// Dipanggil sekali setelah login berhasil (role = ibu) saat online.
class ImunisasiPullService {
  static String get _endpoint => '${ApiConstants.baseUrl}/ibu/imunisasi/sync';

  // Pemetaan key JSON dari backend → nama tabel SQLite lokal
  static const _tableMap = {
    'ibu': 'ibu',
    'penduduk': 'penduduk',
    'kehamilan': 'kehamilan',
    'anak': 'anak',
    'posyandu': 'posyandu',
    'jadwal_imunisasi_anak': 'jadwal_imunisasi_anak',
    'request_perubahan_imunisasi': 'request_perubahan_imunisasi',
    'status_jadwal': 'status_jadwal',
    'status_request': 'status_request',
    'vaksin': 'vaksin',
    'dosis_vaksin': 'dosis_vaksin',
  };

  /// Tarik data dari server dan simpan ke SQLite.
  /// Aman dipanggil berulang kali (pakai REPLACE ON CONFLICT).
  Future<void> pull(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[ImunisasiPull] server ${response.statusCode} — skip');
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        debugPrint('[ImunisasiPull] format data tidak dikenali — skip');
        return;
      }

      final db = await AppDatabase.instance.database;
      final batch = db.batch();

      for (final entry in _tableMap.entries) {
        final jsonKey = entry.key;
        final tableName = entry.value;
        final rows = data[jsonKey];
        if (rows is! List) continue;

        for (final raw in rows) {
          if (raw is! Map) continue;
          final row = Map<String, dynamic>.from(raw);
          // Tandai is_synced = 1 agar tidak dikirim balik ke server saat push
          row['is_synced'] = 1;
          batch.insert(tableName, row,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      await batch.commit(noResult: true);
      debugPrint('[ImunisasiPull] selesai — data imunisasi tersimpan lokal.');
    } on SocketException {
      debugPrint('[ImunisasiPull] offline — pull ditunda.');
    } on TimeoutException {
      debugPrint('[ImunisasiPull] timeout — pull ditunda.');
    } catch (e) {
      debugPrint('[ImunisasiPull] error: $e');
    }
  }
}
