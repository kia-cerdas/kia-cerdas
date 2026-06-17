import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/log_ttd_mms_model.dart';
import 'rekap_ttd_mms_model.dart';

class TtdMmsKaderApiService {
  final http.Client _client;

  TtdMmsKaderApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

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

  /// Ambil rekap kepatuhan TTD/MMS semua ibu hamil di wilayah kader.
  /// Endpoint: GET /kader/log-ttd-mms/rekap
  Future<List<RekapTTDMMSModel>> getRekap() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/kader/log-ttd-mms/rekap');
    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => RekapTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    throw Exception(body['message'] ?? 'Gagal mengambil data rekap TTD/MMS');
  }

  /// Ambil log TTD/MMS harian detail milik satu ibu (read-only untuk kader).
  /// Endpoint: GET /kader/log-ttd-mms/:kehamilan_id
  Future<List<LogTTDMMSModel>> getDetailLog(int kehamilanId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/log-ttd-mms/$kehamilanId',
    );
    final response = await _client.get(uri, headers: _headers);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => LogTTDMMSModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    throw Exception(body['message'] ?? 'Gagal mengambil detail log TTD/MMS');
  }

  void dispose() => _client.close();
}