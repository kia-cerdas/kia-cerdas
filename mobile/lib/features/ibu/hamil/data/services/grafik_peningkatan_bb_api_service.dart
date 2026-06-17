// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_peningkatan_bb_model.dart';

// class GrafikPeningkatanBBApiService {
//   final http.Client _client;

//   GrafikPeningkatanBBApiService({http.Client? client})
//       : _client = client ?? http.Client();

//   Future<GrafikBBResponseModel> getGrafikBBV2() async {
//     final token = AuthSession.token;

//     if (token == null || token.isEmpty) {
//       throw Exception('Token tidak ditemukan. Silakan login ulang.');
//     }

//     final uri = Uri.parse(
//       '${ApiConstants.baseUrl}${ApiConstants.grafikPeningkatanBBV2}',
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
//       throw Exception(body['message'] ?? 'Data grafik BB belum tersedia');
//     }

//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception(
//         'Gagal mengambil data grafik berat badan (${response.statusCode})',
//       );
//     }

//     final data = body['data'];

//     if (data is Map<String, dynamic>) {
//       return GrafikBBResponseModel.fromJson(data);
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
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_peningkatan_bb_model.dart';

/// Service grafik BB dengan mekanisme offline cache.
///
/// Alur:
///   1. Coba fetch dari API
///   2. Jika berhasil → simpan ke SharedPreferences → return data
///   3. Jika gagal (offline / error) → baca cache terakhir → return data
///   4. Jika tidak ada cache → throw error seperti biasa
class GrafikPeningkatanBBApiService {
  static const String _cacheKey = 'cache_grafik_bb_v2';
  static const String _cacheTsKey = 'cache_grafik_bb_v2_timestamp';

  final http.Client _client;

  GrafikPeningkatanBBApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: getGrafikBBV2 — online-first, fallback ke cache
  // ──────────────────────────────────────────────────────────────────────────
  Future<GrafikBBResponseModel> getGrafikBBV2() async {
    try {
      final data = await _fetchFromApi();
      await _saveCache(data);
      return data;
    } catch (e) {
      // Coba ambil dari cache
      final cached = await _loadCache();
      if (cached != null) return cached;

      // Tidak ada cache sama sekali — teruskan error asli
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: apakah ada cache tersimpan?
  // ──────────────────────────────────────────────────────────────────────────
  static Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: kapan cache terakhir diperbarui?
  // ──────────────────────────────────────────────────────────────────────────
  static Future<DateTime?> getCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_cacheTsKey);
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: ambil raw JSON cache (untuk debug / lihat isi)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<String?> getRawCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKey);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PUBLIC: hapus cache
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTsKey);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE: fetch dari API
  // ──────────────────────────────────────────────────────────────────────────
  Future<GrafikBBResponseModel> _fetchFromApi() async {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.grafikPeningkatanBBV2}',
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
      throw Exception(body['message'] ?? 'Data grafik BB belum tersedia');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengambil data grafik berat badan (${response.statusCode})',
      );
    }

    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return GrafikBBResponseModel.fromJson(data);
    }

    throw Exception('Format response tidak valid');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE: simpan ke SharedPreferences
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _saveCache(GrafikBBResponseModel data) async {
    final prefs = await SharedPreferences.getInstance();

    // Konversi model → JSON string
    final jsonStr = jsonEncode(_modelToJson(data));
    await prefs.setString(_cacheKey, jsonStr);
    await prefs.setString(_cacheTsKey, DateTime.now().toIso8601String());
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE: baca dari SharedPreferences
  // ──────────────────────────────────────────────────────────────────────────
  Future<GrafikBBResponseModel?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GrafikBBResponseModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPER: GrafikBBResponseModel → Map (untuk disimpan sebagai JSON)
  // ──────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _modelToJson(GrafikBBResponseModel m) {
    return {
      'bb_awal': m.bbAwal,
      'imt_kategori': m.imtKategori,
      'target_kenaikan_min': m.targetMin,
      'target_kenaikan_max': m.targetMax,
      'penjelasan_hasil_grafik': m.penjelasanHasilGrafik,
      'grafik_bb': m.grafikBb
          .map((p) => {
                'minggu_kehamilan': p.mingguKehamilan,
                'berat_badan': p.beratBadan,
                'kenaikan_dari_awal': p.kenaikanDariAwal,
                'batas_min': p.batasMin,
                'batas_max': p.batasMax,
                'status': p.status,
              })
          .toList(),
    };
  }

  void dispose() {
    _client.close();
  }
}