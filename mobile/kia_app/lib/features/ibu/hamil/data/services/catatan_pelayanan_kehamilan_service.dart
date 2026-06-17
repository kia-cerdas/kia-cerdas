import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class CatatanPelayananKehamilanService {
  /// [trimester] opsional: 1, 2, atau 3. Null = ambil semua trimester.
  Future<List<dynamic>> getMine({int? trimester}) async {
    final token = AuthSession.token;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.catatanPelayananKehamilanMe}',
    ).replace(
      queryParameters: trimester != null
          ? {'trimester': trimester.toString()}
          : null,
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data catatan pelayanan',
    );
  }
}
