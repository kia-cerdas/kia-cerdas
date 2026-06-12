import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'absensi_kelas_ibu_hamil_model.dart'; // <-- import model

class AbsensiKelasIbuHamilKaderApiService {
  final http.Client _client;

  AbsensiKelasIbuHamilKaderApiService({http.Client? client})
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

  /// GET /kader/absensi-kelas-ibu-hamil
  Future<List<AbsensiKelasIbuHamilModel>> getAll() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/absensi-kelas-ibu-hamil',
    );
    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) return [];
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil data absensi');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((item) => AbsensiKelasIbuHamilModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    }
    return [];
  }

  /// PUT /kader/absensi-kelas-ibu-hamil/:id/verifikasi
  Future<void> verify(int id, String namaKader, String tanggalParaf) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/absensi-kelas-ibu-hamil/$id/verifikasi',
    );
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'nama_kader': namaKader,
        'tanggal_paraf': tanggalParaf,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Gagal memverifikasi absensi');
    }
  }

  void dispose() => _client.close();
}