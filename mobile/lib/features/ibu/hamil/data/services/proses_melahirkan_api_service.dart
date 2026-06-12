import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/proses_melahirkan_model.dart';

class ProsesMelahirkanApiService {
  final http.Client _client;

  ProsesMelahirkanApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<ProsesMelahirkanModel> getMine() async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.prosesMelahirkan}');
    final response = await _client.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      return ProsesMelahirkanModel.empty();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['message'] ??
          'Gagal mengambil data proses melahirkan (${response.statusCode})');
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return ProsesMelahirkanModel.fromJson(data);
    }
    if (data is Map) {
      return ProsesMelahirkanModel.fromJson(Map<String, dynamic>.from(data));
    }
    return ProsesMelahirkanModel.empty();
  }

  void dispose() => _client.close();
}