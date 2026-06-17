// // import 'dart:convert';

// // import 'package:http/http.dart' as http;
// // import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// // import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// // import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';

// // class LogTTDMMSApiService {
// //   final http.Client _client;

// //   LogTTDMMSApiService({http.Client? client})
// //       : _client = client ?? http.Client();

// //   Map<String, String> get _headers {
// //     final token = AuthSession.token;

// //     if (token == null || token.isEmpty) {
// //       throw Exception('Token tidak ditemukan. Silakan login ulang.');
// //     }

// //     return {
// //       'Authorization': 'Bearer $token',
// //       'Content-Type': 'application/json',
// //     };
// //   }

// //   Future<List<LogTTDMMSModel>> getMine() async {
// //     final uri = Uri.parse(
// //       '${ApiConstants.baseUrl}/modul-ibu/log-ttd-mms/me',
// //     );

// //     final response = await _client.get(uri, headers: _headers);
// //     final body = jsonDecode(response.body) as Map<String, dynamic>;

// //     if (response.statusCode == 404) {
// //       return [];
// //     }

// //     if (response.statusCode < 200 || response.statusCode >= 300) {
// //       throw Exception(body['message'] ?? 'Gagal mengambil log TTD/MMS');
// //     }

// //     final data = body['data'];

// //     if (data is List) {
// //       return data
// //           .map(
// //             (item) => LogTTDMMSModel.fromJson(
// //               Map<String, dynamic>.from(item),
// //             ),
// //           )
// //           .toList();
// //     }

// //     return [];
// //   }

// //   Future<LogTTDMMSModel> save(LogTTDMMSModel data) async {
// //     final uri = Uri.parse(
// //       '${ApiConstants.baseUrl}/modul-ibu/log-ttd-mms',
// //     );

// //     final response = await _client.post(
// //       uri,
// //       headers: _headers,
// //       body: jsonEncode(data.toJson()),
// //     );

// //     final body = jsonDecode(response.body) as Map<String, dynamic>;

// //     if (response.statusCode < 200 || response.statusCode >= 300) {
// //       throw Exception(body['message'] ?? 'Gagal menyimpan log TTD/MMS');
// //     }

// //     return LogTTDMMSModel.fromJson(
// //       Map<String, dynamic>.from(body['data']),
// //     );
// //   }

// //   void dispose() {
// //     _client.close();
// //   }
// // }


// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';

// /// Service log TTD/MMS dengan mekanisme offline-first.
// ///
// /// Alur READ (getMine):
// ///   1. Coba fetch dari API
// ///   2. Jika berhasil → simpan ke cache → return data
// ///   3. Jika gagal (offline / error) → baca cache terakhir → return data
// ///   4. Jika tidak ada cache → throw error seperti biasa
// ///
// /// Alur WRITE (save):
// ///   1. Simpan dulu ke pending queue lokal (optimistic update)
// ///   2. Coba kirim ke API
// ///   3. Jika berhasil → hapus dari pending queue
// ///   4. Jika gagal (offline) → biarkan di pending queue, akan di-flush nanti
// ///
// /// Flush pending queue (flushPendingQueue):
// ///   - Dipanggil dari screen saat koneksi kembali (pull-to-refresh / init)
// ///   - Kirim satu per satu, skip duplikat (409 / pesan duplicate)
// class LogTTDMMSApiService {
//   static const String _cacheKey = 'cache_log_ttd_mms';
//   static const String _cacheTsKey = 'cache_log_ttd_mms_timestamp';
//   static const String _pendingKey = 'pending_log_ttd_mms';

//   final http.Client _client;

//   LogTTDMMSApiService({http.Client? client})
//       : _client = client ?? http.Client();

//   Map<String, String> get _headers {
//     final token = AuthSession.token;
//     if (token == null || token.isEmpty) {
//       throw Exception('Token tidak ditemukan. Silakan login ulang.');
//     }
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: apakah ada cache?
//   // ────────────────────────────────────────────────────────────────────────
//   static Future<bool> hasCachedData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey(_cacheKey);
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: kapan cache terakhir diperbarui?
//   // ────────────────────────────────────────────────────────────────────────
//   static Future<DateTime?> getCacheTimestamp() async {
//     final prefs = await SharedPreferences.getInstance();
//     final ts = prefs.getString(_cacheTsKey);
//     if (ts == null) return null;
//     return DateTime.tryParse(ts);
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: berapa item masih di pending queue?
//   // ────────────────────────────────────────────────────────────────────────
//   static Future<int> pendingCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_pendingKey);
//     if (raw == null) return 0;
//     try {
//       final list = jsonDecode(raw) as List<dynamic>;
//       return list.length;
//     } catch (_) {
//       return 0;
//     }
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: getMine — online-first, fallback ke cache
//   // ────────────────────────────────────────────────────────────────────────
//   Future<List<LogTTDMMSModel>> getMine() async {
//     try {
//       final data = await _fetchFromApi();
//       await _saveCache(data);
//       return data;
//     } catch (_) {
//       final cached = await _loadCache();
//       if (cached != null) return cached;
//       rethrow;
//     }
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: save — optimistic local, lalu coba API
//   //   Return: model yang sudah tersimpan (dari server atau dari queue)
//   //   Throws: hanya jika terjadi error SELAIN offline (misal: validasi server)
//   // ────────────────────────────────────────────────────────────────────────
//   Future<({LogTTDMMSModel model, bool isPending})> save(
//       LogTTDMMSModel data) async {
//     // Optimistic: tambah ke cache lokal dulu agar UI langsung update
//     await _addToLocalCache(data);

//     // Coba kirim ke server
//     try {
//       final saved = await _sendToApi(data);
//       // Berhasil: hapus dari pending queue jika ada
//       await _removeFromPending(data.bulanKe, data.hariKe);
//       // Update cache dengan data dari server (ada id-nya)
//       await _updateCacheItem(saved);
//       return (model: saved, isPending: false);
//     } catch (e) {
//       // Offline atau server error sementara → masuk pending queue
//       if (_isOfflineError(e)) {
//         await _addToPending(data);
//         return (model: data, isPending: true);
//       }
//       // Error lain (validasi, duplikat, dll) → rollback cache lokal
//       await _removeFromLocalCache(data.bulanKe, data.hariKe);
//       rethrow;
//     }
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: flushPendingQueue — kirim semua pending ke server
//   //   Dipanggil dari screen saat koneksi kembali
//   //   Return: jumlah item yang berhasil dikirim
//   // ────────────────────────────────────────────────────────────────────────
//   Future<int> flushPendingQueue() async {
//     final pending = await _loadPending();
//     if (pending.isEmpty) return 0;

//     int flushed = 0;
//     final stillPending = <LogTTDMMSModel>[];

//     for (final item in pending) {
//       try {
//         final saved = await _sendToApi(item);
//         await _updateCacheItem(saved);
//         flushed++;
//       } catch (e) {
//         if (_isDuplicateError(e)) {
//           // Sudah ada di server (misal dari device lain) → anggap sukses
//           flushed++;
//         } else if (_isOfflineError(e)) {
//           // Masih offline, simpan untuk percobaan berikutnya
//           stillPending.add(item);
//         } else {
//           // Error lain (validasi) → drop, tidak perlu retry
//         }
//       }
//     }

//     await _savePending(stillPending);
//     return flushed;
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PUBLIC: clearCache (untuk kebutuhan reset / logout)
//   // ────────────────────────────────────────────────────────────────────────
//   static Future<void> clearCache() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_cacheKey);
//     await prefs.remove(_cacheTsKey);
//     await prefs.remove(_pendingKey);
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: fetch dari API
//   // ────────────────────────────────────────────────────────────────────────
//   Future<List<LogTTDMMSModel>> _fetchFromApi() async {
//     final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logTTDMMS}');
//     final response = await _client.get(uri, headers: _headers);
//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (response.statusCode == 404) return [];
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(body['message'] ?? 'Gagal mengambil log TTD/MMS');
//     }

//     final data = body['data'];
//     if (data is List) {
//       return data
//           .map((item) =>
//               LogTTDMMSModel.fromJson(Map<String, dynamic>.from(item)))
//           .toList();
//     }
//     return [];
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: kirim satu item ke API
//   // ────────────────────────────────────────────────────────────────────────
//   Future<LogTTDMMSModel> _sendToApi(LogTTDMMSModel data) async {
//     final uri =
//         Uri.parse('${ApiConstants.baseUrl}${ApiConstants.saveLogTTDMMS}');
//     final response = await _client.post(
//       uri,
//       headers: _headers,
//       body: jsonEncode(data.toJson()),
//     );

//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(body['message'] ?? 'Gagal menyimpan log TTD/MMS');
//     }

//     return LogTTDMMSModel.fromJson(
//         Map<String, dynamic>.from(body['data']));
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: cache helpers
//   // ────────────────────────────────────────────────────────────────────────
//   Future<void> _saveCache(List<LogTTDMMSModel> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonStr = jsonEncode(data.map((e) => _modelToJson(e)).toList());
//     await prefs.setString(_cacheKey, jsonStr);
//     await prefs.setString(_cacheTsKey, DateTime.now().toIso8601String());
//   }

//   Future<List<LogTTDMMSModel>?> _loadCache() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_cacheKey);
//     if (raw == null) return null;
//     try {
//       final list = jsonDecode(raw) as List<dynamic>;
//       return list
//           .map((e) => LogTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     } catch (_) {
//       return null;
//     }
//   }

//   /// Tambah item ke cache lokal (tanpa fetch ulang dari server)
//   Future<void> _addToLocalCache(LogTTDMMSModel item) async {
//     final current = await _loadCache() ?? [];
//     final exists = current.any(
//         (e) => e.bulanKe == item.bulanKe && e.hariKe == item.hariKe);
//     if (!exists) {
//       current.add(item);
//       await _saveCache(current);
//     }
//   }

//   /// Update item di cache dengan data dari server (ada id-nya)
//   Future<void> _updateCacheItem(LogTTDMMSModel updated) async {
//     final current = await _loadCache() ?? [];
//     final idx = current.indexWhere(
//         (e) => e.bulanKe == updated.bulanKe && e.hariKe == updated.hariKe);
//     if (idx >= 0) {
//       current[idx] = updated;
//     } else {
//       current.add(updated);
//     }
//     await _saveCache(current);
//   }

//   /// Hapus item dari cache lokal (rollback)
//   Future<void> _removeFromLocalCache(int bulanKe, int hariKe) async {
//     final current = await _loadCache() ?? [];
//     current.removeWhere(
//         (e) => e.bulanKe == bulanKe && e.hariKe == hariKe);
//     await _saveCache(current);
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: pending queue helpers
//   // ────────────────────────────────────────────────────────────────────────
//   Future<List<LogTTDMMSModel>> _loadPending() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_pendingKey);
//     if (raw == null) return [];
//     try {
//       final list = jsonDecode(raw) as List<dynamic>;
//       return list
//           .map((e) => LogTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   Future<void> _savePending(List<LogTTDMMSModel> items) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (items.isEmpty) {
//       await prefs.remove(_pendingKey);
//     } else {
//       await prefs.setString(
//           _pendingKey, jsonEncode(items.map((e) => _modelToJson(e)).toList()));
//     }
//   }

//   Future<void> _addToPending(LogTTDMMSModel item) async {
//     final current = await _loadPending();
//     final exists = current.any(
//         (e) => e.bulanKe == item.bulanKe && e.hariKe == item.hariKe);
//     if (!exists) {
//       current.add(item);
//       await _savePending(current);
//     }
//   }

//   Future<void> _removeFromPending(int bulanKe, int hariKe) async {
//     final current = await _loadPending();
//     current.removeWhere(
//         (e) => e.bulanKe == bulanKe && e.hariKe == hariKe);
//     await _savePending(current);
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: helper serialisasi
//   // ────────────────────────────────────────────────────────────────────────
//   Map<String, dynamic> _modelToJson(LogTTDMMSModel m) {
//     return {
//       if (m.id != null) 'id': m.id,
//       'bulan_ke': m.bulanKe,
//       'hari_ke': m.hariKe,
//       'sudah_diminum': m.sudahDiminum,
//     };
//   }

//   // ────────────────────────────────────────────────────────────────────────
//   // PRIVATE: deteksi error
//   // ────────────────────────────────────────────────────────────────────────
//   bool _isOfflineError(Object e) {
//     final msg = e.toString().toLowerCase();
//     return msg.contains('socket') ||
//         msg.contains('connection') ||
//         msg.contains('network') ||
//         msg.contains('failed host lookup') ||
//         msg.contains('errno = 7') ||
//         msg.contains('os error');
//   }

//   bool _isDuplicateError(Object e) {
//     final msg = e.toString().toLowerCase();
//     return msg.contains('duplicate') ||
//         msg.contains('sudah ada') ||
//         msg.contains('already') ||
//         msg.contains('unique');
//   }

//   void dispose() {
//     _client.close();
//   }
// }

// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';

// class LogTTDMMSApiService {
//   final http.Client _client;

//   LogTTDMMSApiService({http.Client? client})
//       : _client = client ?? http.Client();

//   Map<String, String> get _headers {
//     final token = AuthSession.token;

//     if (token == null || token.isEmpty) {
//       throw Exception('Token tidak ditemukan. Silakan login ulang.');
//     }

//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }

//   Future<List<LogTTDMMSModel>> getMine() async {
//     final uri = Uri.parse(
//       '${ApiConstants.baseUrl}/modul-ibu/log-ttd-mms/me',
//     );

//     final response = await _client.get(uri, headers: _headers);
//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (response.statusCode == 404) {
//       return [];
//     }

//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(body['message'] ?? 'Gagal mengambil log TTD/MMS');
//     }

//     final data = body['data'];

//     if (data is List) {
//       return data
//           .map(
//             (item) => LogTTDMMSModel.fromJson(
//               Map<String, dynamic>.from(item),
//             ),
//           )
//           .toList();
//     }

//     return [];
//   }

//   Future<LogTTDMMSModel> save(LogTTDMMSModel data) async {
//     final uri = Uri.parse(
//       '${ApiConstants.baseUrl}/modul-ibu/log-ttd-mms',
//     );

//     final response = await _client.post(
//       uri,
//       headers: _headers,
//       body: jsonEncode(data.toJson()),
//     );

//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(body['message'] ?? 'Gagal menyimpan log TTD/MMS');
//     }

//     return LogTTDMMSModel.fromJson(
//       Map<String, dynamic>.from(body['data']),
//     );
//   }

//   void dispose() {
//     _client.close();
//   }
// }


import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/services/api_response_handler.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';

/// Service log TTD/MMS dengan mekanisme offline-first.
///
/// Alur READ (getMine):
///   1. Coba fetch dari API
///   2. Jika berhasil → simpan ke cache → return data
///   3. Jika gagal (offline / error) → baca cache terakhir → return data
///   4. Jika tidak ada cache → throw error seperti biasa
///
/// Alur WRITE (save):
///   1. Simpan dulu ke pending queue lokal (optimistic update)
///   2. Coba kirim ke API
///   3. Jika berhasil → hapus dari pending queue
///   4. Jika gagal (offline) → biarkan di pending queue, akan di-flush nanti
///
/// Flush pending queue (flushPendingQueue):
///   - Dipanggil dari screen saat koneksi kembali (pull-to-refresh / init)
///   - Kirim satu per satu, skip duplikat (409 / pesan duplicate)
class LogTTDMMSApiService {
  static const String _cacheKey = 'cache_log_ttd_mms';
  static const String _cacheTsKey = 'cache_log_ttd_mms_timestamp';
  static const String _pendingKey = 'pending_log_ttd_mms';

  final http.Client _client;

  LogTTDMMSApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  Map<String, String> get _headers {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: apakah ada cache?
  // ────────────────────────────────────────────────────────────────────────
  static Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: kapan cache terakhir diperbarui?
  // ────────────────────────────────────────────────────────────────────────
  static Future<DateTime?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_cacheTsKey);
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: berapa item masih di pending queue?
  // ────────────────────────────────────────────────────────────────────────
  static Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return 0;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.length;
    } catch (_) {
      return 0;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: getMine — online-first, fallback ke cache
  // ────────────────────────────────────────────────────────────────────────
  Future<List<LogTTDMMSModel>> getMine() async {
    try {
      final data = await _fetchFromApi();
      await _saveCache(data);
      return data;
    } catch (_) {
      final cached = await _loadCache();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: save — optimistic local, lalu coba API
  //   Return: model yang sudah tersimpan (dari server atau dari queue)
  //   Throws: hanya jika terjadi error SELAIN offline (misal: validasi server)
  // ────────────────────────────────────────────────────────────────────────
  Future<({LogTTDMMSModel model, bool isPending})> save(
      LogTTDMMSModel data) async {
    // Optimistic: tambah ke cache lokal dulu agar UI langsung update
    await _addToLocalCache(data);

    // Coba kirim ke server
    try {
      final saved = await _sendToApi(data);
      // Berhasil: hapus dari pending queue jika ada
      await _removeFromPending(data.bulanKe, data.hariKe);
      // Update cache dengan data dari server (ada id-nya)
      await _updateCacheItem(saved);
      return (model: saved, isPending: false);
    } catch (e) {
      // Offline atau server error sementara → masuk pending queue
      if (_isOfflineError(e)) {
        await _addToPending(data);
        return (model: data, isPending: true);
      }
      // Error lain (validasi, duplikat, dll) → rollback cache lokal
      await _removeFromLocalCache(data.bulanKe, data.hariKe);
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: flushPendingQueue — kirim semua pending ke server
  //   Dipanggil dari screen saat koneksi kembali
  //   Return: jumlah item yang berhasil dikirim
  // ────────────────────────────────────────────────────────────────────────
  Future<int> flushPendingQueue() async {
    final pending = await _loadPending();
    if (pending.isEmpty) return 0;

    int flushed = 0;
    final stillPending = <LogTTDMMSModel>[];

    for (final item in pending) {
      try {
        final saved = await _sendToApi(item);
        await _updateCacheItem(saved);
        flushed++;
      } catch (e) {
        if (_isDuplicateError(e)) {
          // Sudah ada di server (misal dari device lain) → anggap sukses
          flushed++;
        } else if (_isOfflineError(e)) {
          // Masih offline, simpan untuk percobaan berikutnya
          stillPending.add(item);
        } else {
          // Error lain (validasi) → drop, tidak perlu retry
        }
      }
    }

    await _savePending(stillPending);
    return flushed;
  }

  // ────────────────────────────────────────────────────────────────────────
  // PUBLIC: clearCache (untuk kebutuhan reset / logout)
  // ────────────────────────────────────────────────────────────────────────
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTsKey);
    await prefs.remove(_pendingKey);
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: fetch dari API
  // ────────────────────────────────────────────────────────────────────────
  Future<List<LogTTDMMSModel>> _fetchFromApi() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logTTDMMS}');
    final response = await _client.get(uri, headers: _headers);
    await ApiResponseHandler.check(response); // cek sesi/401
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) return [];
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil log TTD/MMS');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((item) =>
              LogTTDMMSModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: kirim satu item ke API
  // ────────────────────────────────────────────────────────────────────────
  Future<LogTTDMMSModel> _sendToApi(LogTTDMMSModel data) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.saveLogTTDMMS}');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );

    await ApiResponseHandler.check(response); // cek sesi/401
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal menyimpan log TTD/MMS');
    }

    return LogTTDMMSModel.fromJson(
        Map<String, dynamic>.from(body['data']));
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: cache helpers
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _saveCache(List<LogTTDMMSModel> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(data.map((e) => _modelToJson(e)).toList());
    await prefs.setString(_cacheKey, jsonStr);
    await prefs.setString(_cacheTsKey, DateTime.now().toIso8601String());
  }

  Future<List<LogTTDMMSModel>?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LogTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Tambah item ke cache lokal (tanpa fetch ulang dari server)
  Future<void> _addToLocalCache(LogTTDMMSModel item) async {
    final current = await _loadCache() ?? [];
    final exists = current.any(
        (e) => e.bulanKe == item.bulanKe && e.hariKe == item.hariKe);
    if (!exists) {
      current.add(item);
      await _saveCache(current);
    }
  }

  /// Update item di cache dengan data dari server (ada id-nya)
  Future<void> _updateCacheItem(LogTTDMMSModel updated) async {
    final current = await _loadCache() ?? [];
    final idx = current.indexWhere(
        (e) => e.bulanKe == updated.bulanKe && e.hariKe == updated.hariKe);
    if (idx >= 0) {
      current[idx] = updated;
    } else {
      current.add(updated);
    }
    await _saveCache(current);
  }

  /// Hapus item dari cache lokal (rollback)
  Future<void> _removeFromLocalCache(int bulanKe, int hariKe) async {
    final current = await _loadCache() ?? [];
    current.removeWhere(
        (e) => e.bulanKe == bulanKe && e.hariKe == hariKe);
    await _saveCache(current);
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: pending queue helpers
  // ────────────────────────────────────────────────────────────────────────
  Future<List<LogTTDMMSModel>> _loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LogTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePending(List<LogTTDMMSModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    if (items.isEmpty) {
      await prefs.remove(_pendingKey);
    } else {
      await prefs.setString(
          _pendingKey, jsonEncode(items.map((e) => _modelToJson(e)).toList()));
    }
  }

  Future<void> _addToPending(LogTTDMMSModel item) async {
    final current = await _loadPending();
    final exists = current.any(
        (e) => e.bulanKe == item.bulanKe && e.hariKe == item.hariKe);
    if (!exists) {
      current.add(item);
      await _savePending(current);
    }
  }

  Future<void> _removeFromPending(int bulanKe, int hariKe) async {
    final current = await _loadPending();
    current.removeWhere(
        (e) => e.bulanKe == bulanKe && e.hariKe == hariKe);
    await _savePending(current);
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: helper serialisasi
  // ────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _modelToJson(LogTTDMMSModel m) {
    return {
      if (m.id != null) 'id': m.id,
      'bulan_ke': m.bulanKe,
      'hari_ke': m.hariKe,
      'sudah_diminum': m.sudahDiminum,
    };
  }

  // ────────────────────────────────────────────────────────────────────────
  // PRIVATE: deteksi error
  // ────────────────────────────────────────────────────────────────────────
  bool _isOfflineError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('errno = 7') ||
        msg.contains('os error');
  }

  bool _isDuplicateError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('duplicate') ||
        msg.contains('sudah ada') ||
        msg.contains('already') ||
        msg.contains('unique');
  }

  void dispose() {
    _client.close();
  }
}