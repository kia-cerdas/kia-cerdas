import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/evaluasi_kesehatan_ibu_model.dart';

class EvaluasiKesehatanIbuApiService {
  final http.Client _client;

  EvaluasiKesehatanIbuApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<EvaluasiKesehatanIbuModel> getMine() async {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.evaluasiKesehatanIbu}',
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
      throw Exception(body['message'] ?? 'Data evaluasi belum tersedia');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengambil data evaluasi (${response.statusCode})');
    }

    final data = body['data'] as Map<String, dynamic>;
    return EvaluasiKesehatanIbuModel.fromJson(data);
  }

  void dispose() {
    _client.close();
  }
}