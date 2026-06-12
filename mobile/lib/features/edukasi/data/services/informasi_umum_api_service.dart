import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/informasi_umum_model.dart';

class InformasiUmumApiService {
  final http.Client _client;

  InformasiUmumApiService({http.Client? client})
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
      }
    } catch (_) {
      // Fall back to a generic error below.
    }
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

      if (_looksLikeItem(rawData)) {
        return <Map<String, dynamic>>[rawData];
      }
    }

    return const [];
  }

  bool _looksLikeItem(Map<String, dynamic> value) {
    return value.containsKey('id') &&
        (value.containsKey('judul') || value.containsKey('konten'));
  }

  Future<List<InformasiUmumModel>> listInformasiUmum() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiInformasiUmum}',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic rawData = decoded is Map<String, dynamic>
        ? decoded['data'] ?? decoded
        : decoded;

    final items = _extractListItems(rawData);
    if (items.isNotEmpty) {
      return items
          .map(InformasiUmumModel.fromJson)
          .where((item) => item.isActive)
          .toList();
    }

    return const [];
  }

  Future<InformasiUmumModel?> getInformasiUmumById(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.edukasiInformasiUmumById(id)}',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body, response.statusCode));
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic rawData = decoded is Map<String, dynamic>
        ? decoded['data'] ?? decoded
        : decoded;

    if (rawData is Map<String, dynamic>) {
      return InformasiUmumModel.fromJson(rawData);
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
