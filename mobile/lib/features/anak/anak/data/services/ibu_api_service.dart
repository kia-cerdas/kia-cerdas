import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/ibu_anak_model.dart';

class IbuApiService {
  final http.Client _client;

  IbuApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers() {
    final token = AuthSession.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic message = decoded['message'];
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to generic text when response body is not JSON.
    }
    return 'Request gagal ($statusCode)';
  }

  Future<List<IbuAnakModel>> getAnakSaya() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ibuAnak}');
    final response = await _client.get(uri, headers: _headers());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic rawData = decoded['data'];

    if (rawData is List) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(IbuAnakModel.fromJson)
          .toList();
    }

    return const [];
  }

  void dispose() {
    _client.close();
  }
}
