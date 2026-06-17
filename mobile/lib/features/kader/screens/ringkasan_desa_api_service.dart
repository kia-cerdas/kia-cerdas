import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/ringkasan_desa_model.dart';

class RingkasanDesaApiService {
  final http.Client _client;

  RingkasanDesaApiService({
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

  Future<RingkasanDesaModel> getRingkasanDesa() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/ringkasan-desa',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        return RingkasanDesaModel.empty();
      }

      final body = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil ringkasan desa');

        throw Exception(
          errorText,
        );
      }

      final data = body['data'];

      if (data is Map) {
        return RingkasanDesaModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      return RingkasanDesaModel.empty();
    } catch (e) {
      debugPrint(
        'Error getRingkasanDesa: $e',
      );

      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
