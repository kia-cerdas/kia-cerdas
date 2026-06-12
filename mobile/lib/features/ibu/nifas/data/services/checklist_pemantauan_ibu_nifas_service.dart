import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';

class ChecklistPemantauanIbuNifasService {

  Future<http.Response> createChecklist({
    required String token,
    required Map<String, dynamic> body,
  }) async {

    return await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.checklistPemantauanIbuNifas}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}