import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/models/warna_tinja_model.dart';

class WarnaTinjaApiService {
  final http.Client _client;

  WarnaTinjaApiService({http.Client? client})
      : _client = client ?? http.Client();

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

  Future<List<WarnaTinjaModel>> getByAnakId(int anakId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ibuWarnaTinja}?anak_id=$anakId',
    );

    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawData = decoded['data'];
    if (rawData is! List) return const [];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(WarnaTinjaModel.fromJson)
        .toList();
  }

  Future<void> save({
    required int anakId,
    required String periodeKey,
    required String tanggalCatat,
    required int nomorWarna,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ibuWarnaTinja}');

    final payload = {
      'anak_id': anakId,
      'periode_key': periodeKey,
      'tanggal_catat': tanggalCatat,
      'nomor_warna': nomorWarna,
    };

    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }
  }

  void dispose() {
    _client.close();
  }
}
