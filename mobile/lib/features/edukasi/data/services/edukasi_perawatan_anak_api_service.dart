import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_perawatan_anak_model.dart';

class EdukasiPerawatanAnakApiService {
  final http.Client _client;

  EdukasiPerawatanAnakApiService({http.Client? client})
      : _client = client ?? http.Client();

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

  Future<List<EdukasiPerawatanAnakModel>> listPerawatanAnak() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiPerawatanAnak}',
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
    return items.map(EdukasiPerawatanAnakModel.fromJson).toList();
  }

  Future<EdukasiPerawatanAnakModel?> getPerawatanAnakById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiPerawatanAnakById(id)}',
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
      return EdukasiPerawatanAnakModel.fromJson(rawData);
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
