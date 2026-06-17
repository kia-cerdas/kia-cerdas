// import 'dart:convert';

// import 'package:http/http.dart'as http;

// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

// class EdukasiNifasService {

//   Future<List<dynamic>>
//       getEdukasiNifas() async {

//     final response = await http.get(
//       Uri.parse(
//         ApiConstants.edukasiNifas,
//       ),
//     );

//     if (response.statusCode == 200) {

//       final result = jsonDecode(
//         response.body,
//       );

//       return result['data'];
//     }

//     throw Exception(
//       'Gagal mengambil data edukasi nifas',
//     );
//   }
// }


import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class EdukasiNifasService {

  Future<List<dynamic>> getEdukasiNifas() async {

    final response = await http.get(
      Uri.parse(
        ApiConstants.edukasiNifas,
      ),
    );

    if (response.statusCode == 200) {

      // Backend baru (edukasi_setelah_melahirkan) mengembalikan array langsung
      // bukan wrapped dalam { "data": [...] }
      return jsonDecode(response.body);
    }

    throw Exception(
      'Gagal mengambil data edukasi setelah melahirkan',
    );
  }
}