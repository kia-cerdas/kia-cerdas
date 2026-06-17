import 'dart:convert';

import 'package:http/http.dart'
    as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class RingkasanPersalinanService {

  Future<List<dynamic>> getData(
    String token,
  ) async {

    final response = await http.get(
      Uri.parse(
        ApiConstants
            .ringkasanPersalinan,
      ),

      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    final body = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {

      return body['data'];
    }

    throw Exception(
      body['message'],
    );
  }
}