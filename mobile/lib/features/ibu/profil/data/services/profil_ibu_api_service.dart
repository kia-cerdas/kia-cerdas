// lib/features/ibu/profil/data/services/profil_ibu_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_ibu_model.dart';

class ProfilIbuApiService {
  final http.Client _client;

  ProfilIbuApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<ProfilIbuModel> getProfilSaya() async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // ✅ FIXED: pakai profilIbu bukan authMe
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.profilIbu}',
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message'] ?? 'Gagal mengambil data profil (${response.statusCode})',
      );
    }

    final data = body['data'] as Map<String, dynamic>;
    return ProfilIbuModel.fromJson(data);
  }

  void dispose() => _client.close();
}