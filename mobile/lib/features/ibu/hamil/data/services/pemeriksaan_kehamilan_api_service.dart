import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemeriksaan_kehamilan_model.dart';

class PemeriksaanKehamilanApiService {
  final http.Client _client;

  PemeriksaanKehamilanApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<PemeriksaanKehamilanModel>> getMine() async {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.pemeriksaanKehamilan}',
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
      throw Exception(body['message'] ?? 'Data pemeriksaan belum tersedia');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengambil data pemeriksaan kehamilan (${response.statusCode})',
      );
    }

    final data = body['data'];

    if (data is List) {
      return data
          .map((item) =>
              PemeriksaanKehamilanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  void dispose() {
    _client.close();
  }
}