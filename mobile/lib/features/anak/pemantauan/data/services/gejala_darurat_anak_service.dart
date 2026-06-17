import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class GejalaDaruratAnakApiService {
  final http.Client _client;

  GejalaDaruratAnakApiService({http.Client? client}) : _client = client ?? AppHttpClient();

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

  Future<Map<String, dynamic>> submitDeteksi({
    required int anakId,
    required String tanggalPeriksa,
    required List<Map<String, dynamic>> daftarGejala,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/gejala-darurat/deteksi');

    final response = await _client.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'anak_id': anakId,
        'tanggal_periksa': tanggalPeriksa,
        'daftar_gejala': daftarGejala,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['data'] as Map<String, dynamic>;
    } else {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }
  }

  Future<List<dynamic>> getRiwayat(int anakId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/gejala-darurat/riwayat/$anakId');

    final response = await _client.get(
      url,
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rawData = decoded['data'];
      if (rawData is List) {
        return rawData;
      }
      return [];
    } else {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }
  }
}