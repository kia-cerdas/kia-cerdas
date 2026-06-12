import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/catatan/data/models/bbl_model.dart';

class BblKaderApiService {
  final http.Client _client = http.Client();

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
    return 'Request gagal ($statusCode)';
  }

  Future<List<BblModel>> getAllBbl() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/kader/bbl');
    final resp = await _client.get(uri, headers: _headers());
    
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(_extractErrorMessage(resp.body, resp.statusCode));
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final raw = decoded['data'] as List?;
    if (raw == null) return [];
    
    return raw.map((e) => BblModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> verifyBbl(int anakId, int kaderId, String periodeWaktu, String status) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/kader/bbl/anak/$anakId/verifikasi');
    final resp = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'kader_id': kaderId,
        'periode_waktu': periodeWaktu,
        'status': status,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(_extractErrorMessage(resp.body, resp.statusCode));
    }
  }

  void dispose() {
    _client.close();
  }
}
