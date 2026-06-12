import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/checklist_proses_melahirkan_model.dart';

class ChecklistProsesMelahirkanApiService {
  final http.Client _client;

  ChecklistProsesMelahirkanApiService({http.Client? client})
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

  Future<ChecklistProsesMelahirkanModel> getMine() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.checklistProsesMelahirkan}',
    );

    final response = await _client.get(uri, headers: _headers);
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      return ChecklistProsesMelahirkanModel.empty();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message'] ??
            'Gagal mengambil data checklist proses melahirkan (${response.statusCode})',
      );
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return ChecklistProsesMelahirkanModel.fromJson(data);
    }
    if (data is Map) {
      return ChecklistProsesMelahirkanModel.fromJson(
          Map<String, dynamic>.from(data));
    }
    return ChecklistProsesMelahirkanModel.empty();
  }

  Future<ChecklistProsesMelahirkanModel> save(
      ChecklistProsesMelahirkanModel data) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.saveChecklistProsesMelahirkan}',
    );

    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message'] ?? 'Gagal menyimpan checklist proses melahirkan',
      );
    }

    final saved = body['data'];
    if (saved is Map<String, dynamic>) {
      return ChecklistProsesMelahirkanModel.fromJson(saved);
    }
    if (saved is Map) {
      return ChecklistProsesMelahirkanModel.fromJson(
          Map<String, dynamic>.from(saved));
    }
    return data;
  }

  void dispose() => _client.close();
}
