import 'dart:convert';

import 'package:flutter/material.dart'; // Ditambahkan untuk debugPrint jika diperlukan
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';

class ImunisasiService {
  final http.Client _client;

  ImunisasiService({
    http.Client? client,
  }) : _client = client ?? AppHttpClient();

  Map<String, String> get _headers {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token tidak ditemukan. Silakan login ulang.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<ImunisasiModel>> getJadwalImunisasi() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi');
    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 404) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal');
        throw Exception(errorText);
      }

      final data = body['data'];
      if (data is List) {
        return data.map((item) {
          final Map<String, dynamic> itemMap =
              Map<String, dynamic>.from(item as Map);
          return ImunisasiModel.fromJson(itemMap);
        }).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ImunisasiModel>> getJadwalImunisasiByAnakId(
    int anakId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/anak/$anakId',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil jadwal imunisasi anak');
        throw Exception(errorText);
      }

      final data = body['data'];

      if (data is List) {
        return data.map((item) {
          final Map<String, dynamic> itemMap =
              Map<String, dynamic>.from(item as Map);
          return ImunisasiModel.fromJson(itemMap);
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error di ImunisasiService (getJadwalImunisasiByAnakId): $e");
      rethrow;
    }
  }

  Future<ImunisasiDetailModel> getJadwalImunisasiById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$id',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        throw Exception('Data jadwal tidak ditemukan');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil detail jadwal');
        throw Exception(errorText);
      }

      // ✅ FIX UTAMA DI SINI
      return ImunisasiDetailModel.fromJson(body);
    } catch (e) {
      debugPrint("Error getJadwalImunisasiById: $e");
      rethrow;
    }
  }

Future<void> requestPerubahanJadwal(
  int jadwalId,
  int jadwalLayananId,
  String alasan,
) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/request-perubahan',
    );

    try {
final body = jsonEncode({
  "jadwal_layanan_id": jadwalLayananId,
  "alasan": alasan,
});

      final response = await _client.post(
        uri,
        headers: _headers,
        body: body,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decoded['message'];
        final errorText =
            (msg is List) ? msg.join(', ') : (msg ?? 'Gagal mengirim request');

        throw Exception(errorText);
      }
    } catch (e) {
      debugPrint("Error requestPerubahanJadwal: $e");
      rethrow;
    }
  }

  Future<void> setJadwalSelesai(int jadwalId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/selesai',
    );

    try {
      final response = await _client.put(
        uri,
        headers: _headers,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal menyelesaikan jadwal');

        throw Exception(errorText);
      }
    } catch (e) {
      debugPrint("Error setJadwalSelesai: $e");
      rethrow;
    }
  }

Future<List<JadwalLayananModel>>
    getJadwalLayananUpcoming() async {
  final uri = Uri.parse(
    '${ApiConstants.baseUrl}/ibu/jadwal-layanan?upcoming=true',
  );

  try {
    final response = await _client.get(
      uri,
      headers: _headers,
    );
debugPrint(response.body);
    if (response.statusCode == 404) {
      return [];
    }

    final data = jsonDecode(response.body);
    debugPrint("Jumlah jadwal: ${data.length}");

    if (data is List) {
      return data
          .map(
            (e) => JadwalLayananModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    return [];
  } catch (e) {
    debugPrint(
      'Error getJadwalLayananUpcoming: $e',
    );
    rethrow;
  }
  
}
  void dispose() {
    _client.close();
  }
}
