// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
// import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemantauan_ibu_hamil_model.dart';

// class PemantauanIbuHamilApiService {
//   final _client = http.Client();

//   void dispose() => _client.close();

//   Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${AuthSession.token ?? ''}',
//       };

//   Future<List<PemantauanIbuHamilModel>> getMine() async {
//     final response = await _client.get(
//       Uri.parse(
//         '${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil/me',
//       ),
//       headers: _headers,
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode >= 200 &&
//         response.statusCode < 300) {
//       final List data = body['data'] ?? [];

//       return data
//           .map(
//             (e) => PemantauanIbuHamilModel.fromJson(e),
//           )
//           .toList();
//     }

//     throw Exception(
//       body['message']?.toString() ??
//           'Gagal memuat data pemantauan',
//     );
//   }

//   Future<void> save(
//     PemantauanIbuHamilModel model,
//   ) async {
//     final response = await _client.post(
//       Uri.parse(
//         '${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil',
//       ),

//       // Uri.parse('${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil/me'),
//       // Uri.parse('${ApiConstants.baseUrl}${ApiConstants.savePemantauanIbuHamil}'),
//       headers: _headers,
//       body: jsonEncode(model.toJson()),
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode < 200 ||
//         response.statusCode >= 300) {
//       throw Exception(
//         body['message']?.toString() ??
//             'Gagal menyimpan pemantauan',
//       );
//     }
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/services/api_response_handler.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/pemantauan_ibu_hamil_model.dart';

class PemantauanIbuHamilApiService {
  final _client = AppHttpClient();

  void dispose() => _client.close();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthSession.token ?? ''}',
      };

  Future<List<PemantauanIbuHamilModel>> getMine() async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil/me',
      ),
      headers: _headers,
    );

    await ApiResponseHandler.check(response); // cek sesi/401
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final List data = body['data'] ?? [];

      return data
          .map(
            (e) => PemantauanIbuHamilModel.fromJson(e),
          )
          .toList();
    }

    throw Exception(
      body['message']?.toString() ??
          'Gagal memuat data pemantauan',
    );
  }

  Future<void> save(
    PemantauanIbuHamilModel model,
  ) async {
    final response = await _client.post(
      Uri.parse(
        '${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil',
      ),

      // Uri.parse('${ApiConstants.baseUrl}/modul-ibu/pemantauan-ibu-hamil/me'),
      // Uri.parse('${ApiConstants.baseUrl}${ApiConstants.savePemantauanIbuHamil}'),
      headers: _headers,
      body: jsonEncode(model.toJson()),
    );

    await ApiResponseHandler.check(response); // cek sesi/401
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ??
            'Gagal menyimpan pemantauan',
      );
    }
  }
}