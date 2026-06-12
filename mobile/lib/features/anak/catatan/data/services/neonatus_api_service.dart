import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import '../models/neonatus_model.dart';

class NeonatusApiService {
  final http.Client _client;

  NeonatusApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers() {
    final token = AuthSession.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}
    return 'Request gagal ( $statusCode)';
  }

  Future<List<NeonatusModel>> getByAnakId(int anakId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/modul-ibu/neonatus/anak/$anakId');
    final resp = await _client.get(uri, headers: _headers());
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(_extractErrorMessage(resp.body, resp.statusCode));
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! List) return const [];

    return decoded.whereType<Map<String, dynamic>>().map(NeonatusModel.fromJson).toList();
  }

  void dispose() {
    _client.close();
  }
}
