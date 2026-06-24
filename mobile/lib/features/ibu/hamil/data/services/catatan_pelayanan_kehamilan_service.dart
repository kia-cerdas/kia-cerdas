// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
// import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

// class CatatanPelayananKehamilanService {
//   /// [trimester] opsional: 1, 2, atau 3. Null = ambil semua trimester.
//   Future<List<dynamic>> getMine({int? trimester}) async {
//     final token = AuthSession.token;

//     final uri = Uri.parse(
//       '${ApiConstants.baseUrl}${ApiConstants.catatanPelayananKehamilanMe}',
//     ).replace(
//       queryParameters: trimester != null
//           ? {'trimester': trimester.toString()}
//           : null,
//     );

//     final response = await http.get(
//       uri,
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return body['data'] ?? [];
//     }

//     throw Exception(
//       body['message'] ?? 'Gagal mengambil data catatan pelayanan',
//     );
//   }
// }


import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class CatatanPelayananKehamilanService {
  /// [trimester] opsional: 1, 2, atau 3. Null = ambil semua trimester.
  /// DIPERTAHANKAN untuk kompatibilitas (tabel lama catatan_pelayanan_kehamilan),
  /// tapi SUDAH TIDAK DIPAKAI untuk Trimester 1 & 3 di menu Catatan Pelayanan.
  /// Lihat [getFromPemeriksaanDokter] di bawah.
  Future<List<dynamic>> getMine({int? trimester}) async {
    final token = AuthSession.token;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.catatanPelayananKehamilanMe}',
    ).replace(
      queryParameters: trimester != null
          ? {'trimester': trimester.toString()}
          : null,
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data catatan pelayanan',
    );
  }

  /// BARU: Ambil catatan pelayanan langsung dari tabel
  /// "pemeriksaan_dokter_trimester_1" atau "pemeriksaan_dokter_trimester_3".
  /// Field tanggal_periksa_stamp_paraf, keluhan_pemeriksaan_tindakan_saran,
  /// dan tanggal_kembali sudah tergabung di tabel tersebut (backend tidak
  /// perlu diubah).
  ///
  /// [trimester] hanya boleh 1 atau 3 (trimester 2 tidak memiliki tabel
  /// pemeriksaan dokter, sehingga tidak didukung).
  Future<List<dynamic>> getFromPemeriksaanDokter(int trimester) async {
    final token = AuthSession.token;

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final path = trimester == 1
        ? ApiConstants.pemeriksaanDokterTrimester1All
        : ApiConstants.pemeriksaanDokterTrimester3All;

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    }

    throw Exception(
      body['message'] ??
          'Gagal mengambil data pemeriksaan dokter trimester $trimester',
    );
  }
}