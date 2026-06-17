import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:ta_pa2_pa3_project/core/network/app_http_client.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';
import 'package:ta_pa2_pa3_project/db/app_database.dart';

class ImunisasiService {
  final http.Client _client;

  ImunisasiService({
    http.Client? client,
  }) : _client = client ?? AppHttpClient();

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

  // 1. GET ALL JADWAL IMUNISASI
  Future<List<ImunisasiModel>> getJadwalImunisasi() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi');
    final db = await AppDatabase.instance.database;

    try {
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal');
        throw Exception(errorText);
      }

      final data = body['data'];
      if (data is List) {
        final batch = db.batch();
        for (var anakGroup in data) {
          if (anakGroup is Map<String, dynamic>) {
            final int idAnak = (anakGroup['anak_id'] as num?)?.toInt() ?? 0;
            if (anakGroup['jadwal'] is List) {
              for (var item in anakGroup['jadwal']) {
                if (item is Map<String, dynamic>) {
                  batch.insert(
                    'jadwal_imunisasi_anak', 
                    {
                      'id': (item['jadwal_id'] as num?)?.toInt() ?? 0,
                      'id_dosis_vaksin': (item['dosis_vaksin_id'] as num?)?.toInt() ?? 0,
                      'id_anak': idAnak,
                      'id_status_jadwal': (item['status_id'] as num?)?.toInt() ?? 0,
                      'tanggal_estimasi': item['tanggal_estimasi']?.toString(),
                      'is_synced': 1,
                    },
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );
                }
              }
            }
          }
        }
        await batch.commit(noResult: true);
        return data.map((item) => ImunisasiModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      }
    } on SocketException {
      debugPrint("📡 ImunisasiService: Offline detected. Membaca dari SQLite...");
    } catch (e) {
      debugPrint("📡 ImunisasiService: Kendala network global ($e). Mengalihkan ke SQLite...");
    }

    // Fallback Offline Global: Ambil data lokal lalu bungkus sesuai format struktur ImunisasiModel
    final List<Map<String, dynamic>> localData = await db.query('jadwal_imunisasi_anak');
    if (localData.isEmpty) return [];
    
    return [
      ImunisasiModel(
        anakId: (localData.first['id_anak'] as num?)?.toInt() ?? 0,
        namaAnak: 'Data Offline',
        tanggalLahir: null,
        jumlahTerlewat: 0,
        jadwal: localData.map((e) => JadwalImunisasiModel.fromJson(e)).toList(),
      )
    ];
  }

// 2. GET JADWAL IMUNISASI BY ANAK ID (FIX: STERILISASI KOLOM SQLITE)
  Future<List<ImunisasiModel>> getJadwalImunisasiByAnakId(int anakId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/anak/$anakId');
    final db = await AppDatabase.instance.database;

    try {
      debugPrint("📡 ImunisasiService: Menghubungi server cloud ${uri.toString()}...");
      
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      debugPrint("📡 ImunisasiService: Server merespon dengan status code: ${response.statusCode}");

      if (response.statusCode == 404) return [];

      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! Map<String, dynamic>) {
        throw Exception('Response body bukan berbentuk Map JSON valid');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decodedBody['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal mengambil jadwal');
        throw Exception(errorText);
      }

      final responseData = decodedBody['data'];

      if (responseData is List && responseData.isNotEmpty) {
        final Map<String, dynamic> anakData = Map<String, dynamic>.from(responseData.first as Map);

        if (anakData['jadwal'] is List) {
          final List<dynamic> jadwalListFromServer = anakData['jadwal'];

          final batch = db.batch();
          for (var item in jadwalListFromServer) {
            if (item is Map<String, dynamic>) {
              final String rawJadwalId = (item['jadwal_id'] ?? item['id'] ?? '0').toString();
              final String rawDosisId = (item['dosis_vaksin_id'] ?? item['id_dosis_vaksin'] ?? '0').toString();
              final String rawStatusId = (item['status_id'] ?? item['id_status_jadwal'] ?? '0').toString();

              // KUNCI AMAN: Hanya insert kolom yang berhak masuk ke tabel SQLite aslimu
              batch.insert(
                'jadwal_imunisasi_anak', 
                {
                  'id': int.tryParse(rawJadwalId) ?? 0, 
                  'id_dosis_vaksin': int.tryParse(rawDosisId) ?? 0,
                  'id_anak': anakId, 
                  'id_status_jadwal': int.tryParse(rawStatusId) ?? 0,
                  'tanggal_estimasi': item['tanggal_estimasi']?.toString(),
                  'is_synced': 1, 
                }, 
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit(noResult: true);
          debugPrint("📡 ImunisasiService: Caching ke SQLite berhasil dilakukan.");
        }

        debugPrint("🎉 ImunisasiService: Menampilkan data langsung dari Cloud Server (Online Mode).");
        return [ImunisasiModel.fromJson(anakData)];
      }
      
    } on SocketException catch (e) {
      debugPrint("❌ Gagal Jangkau Server: HP Offline ($e)");
    } on http.ClientException catch (e) {
      debugPrint("❌ Gagal Jangkau Server: Masalah HTTP Client ($e)");
    } catch (e) {
      debugPrint("❌ Gagal Jangkau Server: Error parsing/logika -> $e");
    }

    // FALLBACK OFFLINE (Berjalan murni saat kuota mati / server mati tanpa crash)
    debugPrint("📦 ImunisasiService: Menarik data cadangan offline dari SQLite...");
    final List<Map<String, dynamic>> localData = await db.query(
      'jadwal_imunisasi_anak',
      where: 'id_anak = ?', 
      whereArgs: [anakId],
    );

    if (localData.isEmpty) return [];

    return [
      ImunisasiModel(
        anakId: anakId,
        namaAnak: 'Mode Offline',
        tanggalLahir: null,
        jumlahTerlewat: 0,
        jadwal: localData.map((e) => JadwalImunisasiModel.fromJson(e)).toList(),
      )
    ];
  }
  // 3. GET DETAIL BY ID
  Future<ImunisasiDetailModel> getJadwalImunisasiById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$id');
    final db = await AppDatabase.instance.database;

    try {
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) throw Exception('Data jadwal tidak ditemukan');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal mengambil detail jadwal');
        throw Exception(errorText);
      }

      return ImunisasiDetailModel.fromJson(body);
    } catch (e) {
      debugPrint("📡 ImunisasiService: Membaca detail offline dari SQLite: $e");
      
      final List<Map<String, dynamic>> localData = await db.query(
        'jadwal_imunisasi_anak',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (localData.isNotEmpty) {
        return ImunisasiDetailModel.fromJson({
          'anak_id': localData.first['id_anak'],
          'nama_anak': 'Mode Offline',
          'jadwal': [localData.first]
        });
      }
      throw Exception('Koneksi internet terputus dan data tidak ditemukan di penyimpanan lokal.');
    }
  }

  // 4. POST REQUEST PERUBAHAN JADWAL
  Future<void> requestPerubahanJadwal(int jadwalId, int jadwalLayananId, String alasan) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/request-perubahan');
    final body = jsonEncode({
      "jadwal_layanan_id": jadwalLayananId,
      "alasan": alasan,
    });

    try {
      final response = await _client.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 5));
      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = decoded['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal mengirim request');
        throw Exception(errorText);
      }
    } on SocketException {
      final db = await AppDatabase.instance.database;
      await db.insert('request_perubahan_imunisasi', {
        'id_jadwal_imunisasi_anak': jadwalId,
        'id_jadwal_layanan': jadwalLayananId,
        'alasan': alasan,
        'is_synced': 0, 
      });
      debugPrint("📡 Offline-First: Request perubahan jadwal disimpan ke antrean SQLite lokal.");
    } catch (e) {
      debugPrint("Error requestPerubahanJadwal: $e");
      rethrow;
    }
  }

  // 5. PUT SET JADWAL SELESAI
  Future<void> setJadwalSelesai(int jadwalId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-imunisasi/$jadwalId/selesai');

    try {
      final response = await _client.put(uri, headers: _headers).timeout(const Duration(seconds: 5));
      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = body['message'];
        final errorText = (msg is List) ? msg.join(', ') : (msg ?? 'Gagal menyelesaikan jadwal');
        throw Exception(errorText);
      }
    } on SocketException {
      final db = await AppDatabase.instance.database;
      await db.update(
        'jadwal_imunisasi_anak',
        {'id_status_jadwal': 2, 'is_synced': 0}, 
        where: 'id = ?',
        whereArgs: [jadwalId],
      );
      debugPrint("📡 Offline-First: Status jadwal selesai diamankan ke SQLite lokal.");
    } catch (e) {
      debugPrint("Error setJadwalSelesai: $e");
      rethrow;
    }
  }

  // 6. GET UPCOMING JADWAL LAYANAN
  Future<List<JadwalLayananModel>> getJadwalLayananUpcoming() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/ibu/jadwal-layanan?upcoming=true');
    final db = await AppDatabase.instance.database;

    try {
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) return [];

      final data = jsonDecode(response.body);
      if (data is List) {
        final batch = db.batch();
        for (var e in data) {
          final localRow = Map<String, dynamic>.from(e);
          localRow['is_synced'] = 1;
          batch.insert('jadwal_layanan', localRow, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);

        return data.map((e) => JadwalLayananModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } on SocketException {
      debugPrint("📡 ImunisasiService: Offline sewaktu mengambil jadwal layanan upcoming.");
    } catch (e) {
      debugPrint('Error getJadwalLayananUpcoming: $e');
    }

    final List<Map<String, dynamic>> localData = await db.query('jadwal_layanan');
    return localData.map((e) => JadwalLayananModel.fromJson(e)).toList();
  }

  void dispose() {
    _client.close();
  }
}