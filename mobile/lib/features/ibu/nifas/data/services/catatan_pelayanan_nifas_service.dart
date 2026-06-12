import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class CatatanPelayananNifasService {

  Future<List<dynamic>> getMine() async {

    final token = AuthSession.token;

    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/catatan-pelayanan-nifas/me',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    }

    throw Exception(
      body['message'] ??
          'Gagal mengambil data',
    );
  }
}