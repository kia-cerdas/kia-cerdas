import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/models/lembar_pemantauan_dynamic_model.dart';

class LembarPemantauanApiService {
  final http.Client _client;

  LembarPemantauanApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

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

  Future<List<RentangUsiaModel>> getRentangUsia() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ibuLembarPemantauanRentangUsia}',
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
        .map(RentangUsiaModel.fromJson)
        .toList();
  }

  Future<List<KategoriTandaSakitModel>> getKategoriByRentangUsia(
    int rentangUsiaId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ibuLembarPemantauanKategori}'
      '?rentang_usia_id=$rentangUsiaId',
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
        .map(KategoriTandaSakitModel.fromJson)
        .toList();
  }

  Future<void> createLembarPemantauan({
    required int anakId,
    required int rentangUsiaId,
    required int periodeWaktu,
    required String tanggalPeriksa,
    required String namaPemeriksa,
    required List<Map<String, dynamic>> detailGejala,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ibuLembarPemantauan}');
    final payload = {
      'anak_id': anakId,
      'rentang_usia_id': rentangUsiaId,
      'periode_waktu': periodeWaktu,
      'tanggal_periksa': tanggalPeriksa,
      'nama_pemeriksa': namaPemeriksa,
      'detail_gejala': detailGejala,
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

  Future<List<LembarPemantauanModel>> getRiwayatPemantauan(int anakId) async {
    // Memanggil endpoint GET /ibu/lembar-pemantauan?anak_id=X
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ibuLembarPemantauan}?anak_id=$anakId',
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
        .map(LembarPemantauanModel.fromJson)
        .toList();
  }

  Future<List<LembarPemantauanModel>> getSemuaPemantauan() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/tenaga-kesehatan/lembar-pemantauan',
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
        .map(LembarPemantauanModel.fromJson)
        .toList();
  }

  Future<void> verifyLembarPemantauan({
    required int id,
    required String status,
    required String namaPemeriksa,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/tenaga-kesehatan/lembar-pemantauan/$id/verifikasi',
    );

    final response = await _client.patch(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'status': status,
        'nama_pemeriksa': namaPemeriksa,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }
  }

  void dispose() {
    _client.close();
  }
}
