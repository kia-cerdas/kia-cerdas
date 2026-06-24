import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';

class PertumbuhanApiService {
  final http.Client _client;

  PertumbuhanApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  Map<String, String> _headers() {
    final token = AuthSession.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic message = decoded['message'];
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}
    return 'Request gagal ($statusCode)';
  }

  Future<List<AnakSearchModel>> searchAnak({
    String namaAnak = '',
    String namaIbu = '',
    String noKk = '',
  }) async {
    final trimmedNamaAnak = namaAnak.trim();
    final trimmedNamaIbu = namaIbu.trim();
    final trimmedNoKk = noKk.trim();

    if (trimmedNamaAnak.isEmpty &&
        trimmedNamaIbu.isEmpty &&
        trimmedNoKk.isEmpty) {
      throw Exception(
        'Isi minimal satu parameter pencarian: nama anak, nama ibu, atau nomor KK.',
      );
    }

    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.anakSearch}').replace(
      queryParameters: {
        if (trimmedNamaAnak.isNotEmpty) 'nama': trimmedNamaAnak,
        if (trimmedNamaIbu.isNotEmpty) 'nama_ibu': trimmedNamaIbu,
        if (trimmedNoKk.isNotEmpty) 'no_kk': trimmedNoKk,
      },
    );

    final response = await _client.get(uri, headers: _headers());

    // Debug log untuk membantu penelusuran ketika backend menolak akses
    // (akan tampil di console saat menjalankan `flutter run`)
    // Jangan hapus logging ini saat debugging.
    // Contoh: 403 -> "Anda tidak memiliki akses ke anak ini"
    // atau 401 -> token expired
    // NOTE: logging ini hanya untuk pengembangan.
    // ignore: avoid_print
    print('GET $uri -> ${response.statusCode}');
    // ignore: avoid_print
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Berikan pesan khusus untuk status 401/403 agar UI bisa menampilkan instruksi
      if (response.statusCode == 401) {
        throw Exception('Unauthorized (401): Silakan login ulang.');
      }
      if (response.statusCode == 403) {
        throw Exception(
            'Forbidden (403): Anda tidak memiliki akses ke data ini.');
      }
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic rawData = decoded['data'];

    if (rawData is List) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(AnakSearchModel.fromJson)
          .toList();
    }

    return const [];
  }

  Future<List<PertumbuhanModel>> getRiwayatPertumbuhanByAnakId(
    int anakId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.riwayatPertumbuhanByAnakId(anakId)}',
    );
    final response = await _client.get(uri, headers: _headers());

    // Debug logging
    // ignore: avoid_print
    print('GET $uri -> ${response.statusCode}');
    // ignore: avoid_print
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        throw Exception('Unauthorized (401): Silakan login ulang.');
      }
      if (response.statusCode == 403) {
        throw Exception(
            'Forbidden (403): Anda tidak memiliki akses ke data ini.');
      }
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic rawData = decoded['data'];

    if (rawData is List) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(PertumbuhanModel.fromJson)
          .toList();
    }

    if (rawData is Map<String, dynamic>) {
      final dynamic items =
          rawData['items'] ?? rawData['riwayat'] ?? rawData['catatan'];
      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(PertumbuhanModel.fromJson)
            .toList();
      }
    }

    return [];
  }

  static final Map<String, List<MasterStandarModel>> _masterCache = {};

  Future<List<MasterStandarModel>> getMasterStandar({
    required String parameter,
    required String jenisKelamin,
  }) async {
    final cacheKey = '${parameter}_$jenisKelamin';
    if (_masterCache.containsKey(cacheKey)) {
      return _masterCache[cacheKey]!;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.masterStandar}',
    ).replace(
      queryParameters: {
        'parameter': parameter,
        'jenis_kelamin': jenisKelamin,
      },
    );

    final response = await _client.get(uri, headers: _headers());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic rawData = decoded['data'];

    if (rawData is List) {
      final list = rawData
          .whereType<Map<String, dynamic>>()
          .map(MasterStandarModel.fromJson)
          .toList();
      _masterCache[cacheKey] = list;
      return list;
    }

    return const [];
  }

  Future<void> createCatatanPertumbuhan(
    CreatePertumbuhanRequest payload,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pertumbuhan}');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }
  }

  void dispose() {
    _client.close();
  }
}
