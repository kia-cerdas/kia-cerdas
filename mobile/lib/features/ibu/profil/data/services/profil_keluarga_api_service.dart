// lib/features/ibu/profil/data/services/profil_keluarga_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/services/api_response_handler.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_keluarga_model.dart';

class ProfilKeluargaApiService {
  final http.Client _client;

  ProfilKeluargaApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  Future<List<AnggotaKeluargaModel>> getProfilKeluarga() async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.profilIbu}/keluarga',
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    await ApiResponseHandler.check(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message'] ?? 'Gagal mengambil data keluarga (${response.statusCode})',
      );
    }

    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => AnggotaKeluargaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}