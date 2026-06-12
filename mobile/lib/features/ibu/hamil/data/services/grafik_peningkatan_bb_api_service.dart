import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/grafik_peningkatan_bb_model.dart';

class GrafikPeningkatanBBApiService {
  final http.Client _client;

  GrafikPeningkatanBBApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<GrafikBBResponseModel> getGrafikBBV2() async {
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

  void dispose() {
    _client.close();
  }
}