import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class EdukasiKesehatanMentalService {

  Future<List<dynamic>>
      getEdukasiKesehatanMental() async {

    final response = await http.get(
      Uri.parse(
        ApiConstants
            .edukasiKesehatanMental,
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      'Gagal mengambil data edukasi kesehatan mental',
    );
  }
}