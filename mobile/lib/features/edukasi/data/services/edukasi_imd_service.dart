import 'dart:convert';

import 'package:http/http.dart'as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class EdukasiIMDService {

  Future<List<dynamic>>
      getEdukasiIMD() async {

    final response = await http.get(
      Uri.parse(
        ApiConstants.edukasiIMD,
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Gagal mengambil data edukasi IMD',
    );
  }
}