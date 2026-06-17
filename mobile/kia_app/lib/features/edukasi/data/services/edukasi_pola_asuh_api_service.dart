import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_pola_asuh_model.dart';

class EdukasiPolaAsuhApiService {
  final http.Client _client;

  EdukasiPolaAsuhApiService({http.Client? client})
      : _client = client ?? AppHttpClient();

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic message = decoded['message'];
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        // Also check 'error' field
        final dynamic error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {}
    return 'Request gagal ($statusCode)';
  }

  List<Map<String, dynamic>> _extractListItems(dynamic rawData) {
    if (rawData is List) {
      return rawData.whereType<Map<String, dynamic>>().toList();
    }

    if (rawData is Map<String, dynamic>) {
      final dynamic nestedData = rawData['data'];
      if (nestedData is List) {
        return nestedData.whereType<Map<String, dynamic>>().toList();
      }
      if (rawData.containsKey('id') && rawData.containsKey('judul')) {
        return <Map<String, dynamic>>[rawData];
      }
    }

    return const [];
  }

  Future<List<EdukasiPolaAsuhModel>> listPolaAsuh() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiPolaAsuh}',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          _extractErrorMessage(response.body, response.statusCode));
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic rawData =
        decoded is Map<String, dynamic> ? decoded['data'] ?? decoded : decoded;

    final items = _extractListItems(rawData);
    return items.map(EdukasiPolaAsuhModel.fromJson).toList();
  }

  Future<EdukasiPolaAsuhModel?> getPolaAsuhById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiPolaAsuhById(id)}',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          _extractErrorMessage(response.body, response.statusCode));
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic rawData =
        decoded is Map<String, dynamic> ? decoded['data'] ?? decoded : decoded;

    if (rawData is Map<String, dynamic>) {
      return EdukasiPolaAsuhModel.fromJson(rawData);
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
