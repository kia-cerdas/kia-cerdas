import 'dart:convert';

import 'package:http/http.dart'
    as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class EdukasiTandaMelahirkanService {

  Future<List<dynamic>>
      getEdukasiTandaMelahirkan() async {

    final response = await http.get(
      Uri.parse(
        ApiConstants
            .edukasiTandaMelahirkan,
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Gagal mengambil data edukasi tanda melahirkan',
    );
  }
}