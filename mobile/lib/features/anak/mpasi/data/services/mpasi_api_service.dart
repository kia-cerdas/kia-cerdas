import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/anak/mpasi/data/models/mpasi_models.dart';

class MpasiApiService {
  final http.Client _client;

  MpasiApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MateriMpasi>> getMateriByBulan(int bulan) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/edukasi-mpasi/materi/$bulan');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengambil materi MPASI');
    }

    final body = jsonDecode(response.body);
    final List data = (body is Map && body.containsKey('data')) ? body['data'] : body;
    return data.map((e) => MateriMpasi.fromJson(e)).toList();
  }

  Future<PorsiJadwalResponse> getPorsiJadwalByBulan(int bulan) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/edukasi-mpasi/porsi-jadwal/$bulan');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil porsi dan jadwal MPASI');
    }

    final data = body['data'] ?? body;
    return PorsiJadwalResponse.fromJson(data);
  }

  Future<List<ResepMpasi>> getResepByBulan(int bulan) async {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/edukasi-mpasi/resep/$bulan');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengambil resep MPASI');
    }

    final body = jsonDecode(response.body);
    final List data = (body is Map && body.containsKey('data')) ? body['data'] : body;
    return data.map((e) => ResepMpasi.fromJson(e)).toList();
  }

  void dispose() {
    _client.close();
  }
}
