// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_evaluasi_kehamilan_model.dart';

// class GrafikEvaluasiKehamilanApiService {
//   final http.Client _client;

//   GrafikEvaluasiKehamilanApiService({http.Client? client})
//       : _client = client ?? http.Client();

//   Future<GrafikEvaluasiKehamilanResponseModel> getGrafikV2() async {
//     final token = AuthSession.token;

//     if (token == null || token.isEmpty) {
//       throw Exception('Token tidak ditemukan. Silakan login ulang.');
//     }

//     final uri = Uri.parse(
//       '${ApiConstants.baseUrl}${ApiConstants.grafikEvaluasiKehamilanV2}',
//     );

//     final response = await _client.get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     final body = jsonDecode(response.body) as Map<String, dynamic>;

//     if (response.statusCode == 404) {
//       throw Exception(body['message'] ?? 'Data grafik belum tersedia');
//     }

//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(
//         'Gagal mengambil data grafik evaluasi kehamilan (${response.statusCode})',
//       );
//     }

//     final data = body['data'];

//     if (data is Map<String, dynamic>) {
//       return GrafikEvaluasiKehamilanResponseModel.fromJson(data);
//     }

//     throw Exception('Format response tidak valid');
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
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_evaluasi_kehamilan_model.dart';

/// Service grafik DJJ & TFU dengan mekanisme offline cache.
///
/// Alur:
///   1. Coba fetch dari API
///   2. Jika berhasil → simpan ke SharedPreferences → return data
///   3. Jika gagal (offline/error) → baca cache terakhir → return data
///   4. Jika tidak ada cache → throw error seperti biasa
class GrafikEvaluasiKehamilanApiService {
  static const String _cacheKey = 'cache_grafik_evaluasi_kehamilan_v2';
  static const String _cacheTsKey = 'cache_grafik_evaluasi_kehamilan_v2_timestamp';

  final http.Client _client;

  GrafikEvaluasiKehamilanApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  // ─── PUBLIC: online-first, fallback ke cache ───────────────────────────────
  Future<GrafikEvaluasiKehamilanResponseModel> getGrafikV2() async {
    try {
      final data = await _fetchFromApi();
      await _saveCache(data);
      return data;
    } catch (e) {
      final cached = await _loadCache();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ─── PUBLIC: utilitas cache ────────────────────────────────────────────────
  static Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }

  static Future<DateTime?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_cacheTsKey);
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  static Future<String?> getRawCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKey);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTsKey);
  }

  // ─── PRIVATE: fetch dari API ───────────────────────────────────────────────
  Future<GrafikEvaluasiKehamilanResponseModel> _fetchFromApi() async {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.grafikEvaluasiKehamilanV2}',
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      throw Exception(body['message'] ?? 'Data grafik belum tersedia');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengambil data grafik evaluasi kehamilan (${response.statusCode})',
      );
    }

    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return GrafikEvaluasiKehamilanResponseModel.fromJson(data);
    }

    throw Exception('Format response tidak valid');
  }

  // ─── PRIVATE: simpan ke SharedPreferences ─────────────────────────────────
  Future<void> _saveCache(GrafikEvaluasiKehamilanResponseModel data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_modelToJson(data));
    await prefs.setString(_cacheKey, jsonStr);
    await prefs.setString(_cacheTsKey, DateTime.now().toIso8601String());
  }

  // ─── PRIVATE: baca dari SharedPreferences ─────────────────────────────────
  Future<GrafikEvaluasiKehamilanResponseModel?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GrafikEvaluasiKehamilanResponseModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ─── HELPER: model → Map JSON ─────────────────────────────────────────────
  Map<String, dynamic> _modelToJson(GrafikEvaluasiKehamilanResponseModel m) {
    return {
      'penjelasan_hasil_grafik': m.penjelasanHasilGrafik,
      'grafik_tfu': m.grafikTfu
          .map((p) => {
                'usia': p.usia,
                'tfu': p.tfu,
                'normal': p.normal,
                'upper': p.upper,
                'lower': p.lower,
                'tanggal_periksa': p.tanggalPeriksa,
                'tekanan_darah': p.tekananDarah,
                'hemoglobin': p.hemoglobin,
                'urin_protein': p.urinProtein,
                'tablet_tambah_darah': p.tabletTambahDarah,
                'gerakan_bayi': p.gerakanBayi,
                'status_tfu': p.statusTFU,
              })
          .toList(),
      'grafik_djj': m.grafikDjj
          .map((p) => {
                'usia': p.usia,
                'djj': p.djj,
                'upper': p.upper,
                'lower': p.lower,
                'tanggal_periksa': p.tanggalPeriksa,
                'status_djj': p.statusDJJ,
              })
          .toList(),
    };
  }

  void dispose() {
    _client.close();
  }
}