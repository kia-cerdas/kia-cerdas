import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'pemantauan_ibu_nifas_kader_model.dart';

class PemantauanIbuNifasKaderApiService {
  final http.Client _client;

  PemantauanIbuNifasKaderApiService({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers {
    final token = AuthSession.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// GET /kader/checklist-pemantauan-ibu-nifas
  Future<List<PemantauanIbuNifasKaderModel>> getAll() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/checklist-pemantauan-ibu-nifas',
    );
    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) return [];
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          body['message'] ?? 'Gagal mengambil data pemantauan ibu nifas');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((item) => PemantauanIbuNifasKaderModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }
    return [];
  }

  /// PUT /kader/checklist-pemantauan-ibu-nifas/:id/verifikasi
  Future<void> verify(
      int id, String namaKader, String tanggalVerifikasi) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/checklist-pemantauan-ibu-nifas/$id/verifikasi',
    );
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'nama_kader': namaKader,
        'tanggal_verifikasi': tanggalVerifikasi,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
          body['message'] ?? 'Gagal memverifikasi pemantauan ibu nifas');
    }
  }

  void dispose() => _client.close();
}