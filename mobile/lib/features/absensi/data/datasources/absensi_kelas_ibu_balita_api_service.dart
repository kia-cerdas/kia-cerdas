import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/absensi/data/models/absensi_kelas_ibu_balita_model.dart';

class AbsensiKelasIbuBalitaApiService {
  final http.Client _client;

  AbsensiKelasIbuBalitaApiService({http.Client? client})
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

  Future<List<AbsensiKelasIbuBalitaModel>> getMine() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/modul-ibu/absensi-kelas-ibu-balita/me',
    );

    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil absensi');
    }

    final data = body['data'];

    if (data is List) {
      return data
          .map(
            (item) => AbsensiKelasIbuBalitaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<AbsensiKelasIbuBalitaModel> save(
    AbsensiKelasIbuBalitaModel data,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/modul-ibu/absensi-kelas-ibu-balita',
    );

    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal menyimpan absensi');
    }

    return AbsensiKelasIbuBalitaModel.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  Future<List<AbsensiKelasIbuBalitaModel>> getAllKader() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/absensi-kelas-ibu-balita',
    );

    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengambil absensi');
    }

    final data = body['data'];

    if (data is List) {
      return data
          .map(
            (item) => AbsensiKelasIbuBalitaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<void> verifyKader(int id, String namaKader, String tanggalParaf, String status) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/absensi-kelas-ibu-balita/$id/verifikasi',
    );

    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'nama_kader': namaKader,
        'tanggal_paraf': tanggalParaf,
        'status': status,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Gagal memverifikasi absensi');
    }
  }

  void dispose() {
    _client.close();
  }
}
