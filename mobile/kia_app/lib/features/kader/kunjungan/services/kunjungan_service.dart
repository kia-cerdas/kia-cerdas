import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';

class KunjunganImunisasiService {
  final http.Client _client;

  KunjunganImunisasiService({
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

  Future<List<KunjunganImunisasiModel>> getAllKunjunganImunisasi() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        return [];
      }

      final body = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil data kunjungan imunisasi');

        throw Exception(
          errorText,
        );
      }

      final data = body['data'];

      if (data is List) {
        return data.map((
          item,
        ) {
          final itemMap = Map<String, dynamic>.from(
            item as Map,
          );

          return KunjunganImunisasiModel.fromJson(
            itemMap,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint(
        'Error getAllKunjunganImunisasi: $e',
      );

      rethrow;
    }
  }

  Future<DetailKunjunganImunisasiModel> getKunjunganById(
    int id,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi/$id',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        throw Exception(
          'Data kunjungan tidak ditemukan',
        );
      }

      final body = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil detail kunjungan');

        throw Exception(
          errorText,
        );
      }

      return DetailKunjunganImunisasiModel.fromJson(
        body['data'],
      );
    } catch (e) {
      debugPrint(
        'Error getKunjunganById: $e',
      );

      rethrow;
    }
  }

  Future<void> updateStatusKunjungan(
    int id,
    int statusId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi/$id/status',
    );

    try {
      final body = jsonEncode({
        "status_kunjungan_id": statusId,
      });

      final response = await _client.put(
        uri,
        headers: _headers,
        body: body,
      );

      final decoded = jsonDecode(
        response.body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decoded['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal update status kunjungan');

        throw Exception(
          errorText,
        );
      }
    } catch (e) {
      debugPrint(
        'Error updateStatusKunjungan: $e',
      );

      rethrow;
    }
  }

  Future<void> updateTanggalKunjungan(
    int id,
    String tanggalKunjungan,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi/$id/tanggal-kunjungan',
    );

    try {
      final body = jsonEncode({
        "tanggal_kunjungan": tanggalKunjungan,
      });

      final response = await _client.put(
        uri,
        headers: _headers,
        body: body,
      );

      final decoded = jsonDecode(
        response.body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decoded['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal update tanggal kunjungan');

        throw Exception(
          errorText,
        );
      }
    } catch (e) {
      debugPrint(
        'Error updateTanggalKunjungan: $e',
      );

      rethrow;
    }
  }

  Future<List<StatusKunjunganCountModel>> getJumlahKunjunganByStatus() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/status-kunjungan/count',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        return [];
      }

      final body = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil jumlah kunjungan berdasarkan status');

        throw Exception(
          errorText,
        );
      }

      final data = body['data'];

      if (data is List) {
        return data.map((
          item,
        ) {
          final itemMap = Map<String, dynamic>.from(
            item as Map,
          );

          return StatusKunjunganCountModel.fromJson(
            itemMap,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint(
        'Error getJumlahKunjunganByStatus: $e',
      );

      rethrow;
    }
  }

  Future<List<KunjunganImunisasiModel>> getKunjunganImunisasiByStatus(
    int statusId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi/status/$statusId',
    );

    try {
      final response = await _client.get(
        uri,
        headers: _headers,
      );

      if (response.statusCode == 404) {
        return [];
      }

      final body = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal mengambil kunjungan berdasarkan status');

        throw Exception(
          errorText,
        );
      }

      final data = body['data'];

      if (data is List) {
        return data.map((
          item,
        ) {
          final itemMap = Map<String, dynamic>.from(
            item as Map,
          );

          return KunjunganImunisasiModel.fromJson(
            itemMap,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint(
        'Error getKunjunganImunisasiByStatus: $e',
      );

      rethrow;
    }
  }

Future<List<JadwalImunisasiTerlewatModel>>
    getAllJadwalImunisasiTerlewat() async {

  final uri = Uri.parse(
    '${ApiConstants.baseUrl}/kader/imunisasi-terlewat',
  );

  try {
    final response = await _client.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 404) {
      return [];
    }

    final body = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {

      final msg = body['message'];

      final errorText = (msg is List)
          ? msg.join(', ')
          : (msg ??
              'Gagal mengambil jadwal imunisasi terlewat');

      throw Exception(errorText);
    }

    final data = body['data'];

    if (data is List) {
      return data.map((item) {
        return JadwalImunisasiTerlewatModel.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        );
      }).toList();
    }

    return [];
  } catch (e) {
    debugPrint(
      'Error getAllJadwalImunisasiTerlewat: $e',
    );

    rethrow;
  }
}

Future<DetailJadwalImunisasiTerlewatModel>
    getJadwalImunisasiTerlewatById(
  int jadwalId,
) async {
  final uri = Uri.parse(
    '${ApiConstants.baseUrl}/kader/imunisasi-terlewat/$jadwalId',
  );

  try {
    final response = await _client.get(
      uri,
      headers: _headers,
    );

    if (response.statusCode == 404) {
      throw Exception(
        'Data imunisasi terlewat tidak ditemukan',
      );
    }

    final body = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final msg = body['message'];

      final errorText = (msg is List)
          ? msg.join(', ')
          : (msg ??
              'Gagal mengambil detail imunisasi terlewat');

      throw Exception(
        errorText,
      );
    }

    return DetailJadwalImunisasiTerlewatModel.fromJson(
      body['data'],
    );
  } catch (e) {
    debugPrint(
      'Error getJadwalImunisasiTerlewatById: $e',
    );

    rethrow;
  }
}

  Future<void> postKunjunganImunisasi(
    PostKunjunganImunisasiRequest request,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/kader/kunjungan-imunisasi',
    );

    try {
      final body = jsonEncode(
        request.toJson(),
      );

      final response = await _client.post(
        uri,
        headers: _headers,
        body: body,
      );

      final decoded = jsonDecode(
        response.body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decoded['message'];

        final errorText = (msg is List)
            ? msg.join(', ')
            : (msg ?? 'Gagal membuat kunjungan imunisasi');

        throw Exception(
          errorText,
        );
      }
    } catch (e) {
      debugPrint(
        'Error postKunjunganImunisasi: $e',
      );

      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
