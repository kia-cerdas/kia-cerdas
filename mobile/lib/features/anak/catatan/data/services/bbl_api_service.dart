import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import '../models/bbl_model.dart';

class BblApiService {
  final http.Client _client;

  BblApiService({http.Client? client}) : _client = client ?? http.Client();

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
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}
    return 'Request gagal ( $statusCode)';
  }

  Future<BblModel?> getByAnakId(int anakId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/bbl/anak/$anakId');
    final resp = await _client.get(uri, headers: _headers());
    if (resp.statusCode == 404) {
      return null;
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(_extractErrorMessage(resp.body, resp.statusCode));
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final raw = decoded['data'];
    if (raw == null || raw is! Map<String, dynamic>) return null;
    return BblModel.fromJson(raw);
  }

  Future<BblModel> upsert(int anakId, BblModel model) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/bbl/anak/$anakId');
    final resp = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(model.toJson()),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(_extractErrorMessage(resp.body, resp.statusCode));
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final raw = decoded['data'];
    return BblModel.fromJson(raw as Map<String, dynamic>);
  }

  void dispose() {
    _client.close();
  }
}
