import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/services/api_response_handler.dart';
import '../models/kader_profil_model.dart';

class KaderProfilApiService {
  final http.Client _client;

  KaderProfilApiService({http.Client? client})
      : _client = client ?? http.Client();

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

  Future<KaderProfilModel> getProfilSaya() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/kader/profil');
    
    final response = await _client.get(uri, headers: _headers);

    await ApiResponseHandler.check(response); // handle 401/token expired
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil profil kader');
    }

    return KaderProfilModel.fromJson(Map<String, dynamic>.from(body['data']));
  }

  void dispose() {
    _client.close();
  }
}