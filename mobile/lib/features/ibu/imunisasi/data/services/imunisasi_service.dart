import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/db/app_database.dart';
import 'package:ta_pa2_pa3_project/db/imunisasi_local_datasource.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';

/// Service imunisasi dengan pola offline-first:
///   1. Coba jaringan → simpan cache ke SQLite
///   2. Jika offline / timeout → baca SQLite lokal
///   3. requestPerubahanJadwal offline → masuk antrian SQLite (is_synced=0)
class ImunisasiService {
  final http.Client _client;
  final ImunisasiLocalDatasource _local = ImunisasiLocalDatasource();

  ImunisasiService({http.Client? client}) : _client = client ?? AppHttpClient();

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

  // ── 1. GET ALL JADWAL IMUNISASI ─────────────────────────────────────────

  Future<List<ImunisasiModel>> getJadwalImunisasi() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi');

    try {
      final response =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractMessage(body));
      }

      final data = body['data'];
      if (data is List) {
        return data
            .map((item) =>
                ImunisasiModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on SocketException {
      debugPrint('[ImunisasiService] offline — fallback lokal');
    } on TimeoutException {
      debugPrint('[ImunisasiService] timeout — fallback lokal');
    } catch (e) {
      debugPrint('[ImunisasiService] error: $e — fallback lokal');
    }

    return _local.getJadwalImunisasiByUser(AuthSession.userID ?? 0);
  }

  // ── 2. GET JADWAL BY ANAK ID ────────────────────────────────────────────

  Future<List<ImunisasiModel>> getJadwalImunisasiByAnakId(int anakId) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/anak/$anakId');

    try {
      final response =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) return [];

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) throw Exception('Response tidak valid');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractMessage(body));
      }

      final data = body['data'];
      if (data is List && data.isNotEmpty) {
        return [ImunisasiModel.fromJson(Map<String, dynamic>.from(data.first as Map))];
      }
      return [];
    } on SocketException {
      debugPrint('[ImunisasiService] offline — fallback lokal anak=$anakId');
    } on TimeoutException {
      debugPrint('[ImunisasiService] timeout — fallback lokal anak=$anakId');
    } catch (e) {
      debugPrint('[ImunisasiService] error: $e — fallback lokal anak=$anakId');
    }

    return _local.getJadwalImunisasiByAnakId(anakId);
  }

  // ── 3. GET DETAIL BY JADWAL ID ──────────────────────────────────────────

  Future<ImunisasiDetailModel> getJadwalImunisasiById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$id');

    try {
      final response =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) throw Exception('Data jadwal tidak ditemukan');

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractMessage(body));
      }

      return ImunisasiDetailModel.fromJson(body);
    } on SocketException {
      debugPrint('[ImunisasiService] offline — fallback detail id=$id');
    } on TimeoutException {
      debugPrint('[ImunisasiService] timeout — fallback detail id=$id');
    } catch (e) {
      debugPrint('[ImunisasiService] error detail: $e');
      rethrow;
    }

    final detail = await _local.getJadwalById(id);
    if (detail != null) return detail;
    throw Exception(
        'Koneksi terputus dan data tidak ditemukan di penyimpanan lokal.');
  }

  // ── 4. POST REQUEST PERUBAHAN JADWAL ────────────────────────────────────

  Future<void> requestPerubahanJadwal(
      int jadwalId, String tanggalBaru, String alasan) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/request-perubahan');
    final body = jsonEncode({"tanggal_baru": tanggalBaru, "alasan": alasan});

    try {
      final response = await _client
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractMessage(decoded));
      }
      return; // sukses online
    } on SocketException {
      debugPrint('[ImunisasiService] offline — queue request perubahan lokal');
    } on TimeoutException {
      debugPrint('[ImunisasiService] timeout — queue request perubahan lokal');
    }

    // Simpan ke antrian SQLite, akan di-push saat online kembali
    await _local.queueRequestPerubahan(
      jadwalId: jadwalId,
      tanggalBaru: tanggalBaru,
      alasan: alasan,
    );
  }

  // ── 5. PUT SET JADWAL SELESAI ────────────────────────────────────────────

  Future<void> setJadwalSelesai(int jadwalId) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/selesai');

    try {
      final response =
          await _client.put(uri, headers: _headers).timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractMessage(body));
      }
      return;
    } on SocketException {
      debugPrint('[ImunisasiService] offline — simpan status selesai lokal');
    } on TimeoutException {
      debugPrint('[ImunisasiService] timeout — simpan status selesai lokal');
    }

    // Simpan status selesai secara lokal (is_synced=0 agar di-push nanti)
    final db = await AppDatabase.instance.database;
    await db.update(
      'jadwal_imunisasi_anak',
      {'id_status_jadwal': 6, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [jadwalId],
    );
  }

  // ── 6. GET UPCOMING JADWAL LAYANAN ──────────────────────────────────────

  Future<List<JadwalLayananModel>> getJadwalLayananUpcoming() async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-layanan?upcoming=true');

    try {
      final response =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) return [];
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gagal mengambil jadwal layanan (${response.statusCode})');
      }

      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map((e) =>
                JadwalLayananModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ImunisasiService] getJadwalLayanan error: $e');
      return [];
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  String _extractMessage(dynamic body) {
    if (body is Map) {
      final msg = body['message'];
      return (msg is List) ? msg.join(', ') : (msg?.toString() ?? 'Gagal');
    }
    return 'Gagal';
  }

  void dispose() => _client.close();
}
