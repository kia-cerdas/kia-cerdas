// import '../models/catatan_pelayanan_kehamilan_model.dart';
// import '../services/catatan_pelayanan_kehamilan_service.dart';

// class CatatanPelayananKehamilanRepository {
//   final CatatanPelayananKehamilanService service;

//   CatatanPelayananKehamilanRepository(this.service);

//   /// Ambil catatan milik ibu yang login.
//   /// [trimester] opsional: 1/2/3. Null = semua trimester.
//   Future<List<CatatanPelayananKehamilanModel>> getMine({int? trimester}) async {
//     final result = await service.getMine(trimester: trimester);
//     return result
//         .map((e) => CatatanPelayananKehamilanModel.fromJson(e))
//         .toList();
//   }
// }


import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';

import '../models/catatan_pelayanan_kehamilan_model.dart';
import '../services/catatan_pelayanan_kehamilan_service.dart';

class CatatanPelayananKehamilanRepository {
  final CatatanPelayananKehamilanService service;
  final KehamilanApiService _kehamilanService = KehamilanApiService();

  CatatanPelayananKehamilanRepository(this.service);

  /// Ambil catatan pelayanan milik ibu yang login.
  ///
  /// [trimester] WAJIB 1 atau 3. Sumber data sekarang diambil langsung dari
  /// tabel "pemeriksaan_dokter_trimester_1" / "pemeriksaan_dokter_trimester_3"
  /// (field tanggal_periksa_stamp_paraf, keluhan_pemeriksaan_tindakan_saran,
  /// tanggal_kembali sudah tergabung di tabel itu), BUKAN lagi dari tabel
  /// catatan_pelayanan_kehamilan. Tidak ada perubahan backend yang diperlukan.
  ///
  /// Trimester 2 tidak lagi didukung (tidak ada tabel pemeriksaan dokter
  /// untuk trimester 2), sehingga akan selalu mengembalikan list kosong.
  Future<List<CatatanPelayananKehamilanModel>> getMine({int? trimester}) async {
    // ✅ FIX: Tambahkan pengecekan null
    if (trimester == null || (trimester != 1 && trimester != 3)) {
      return [];
    }

    final rawList = await service.getFromPemeriksaanDokter(trimester);

    // Batasi hanya ke kehamilan yang sedang aktif, supaya tidak tercampur
    // dengan riwayat kehamilan sebelumnya (endpoint "/all" mengambil semua
    // milik user, bukan per kehamilan_id).
    int? kehamilanAktifId;
    try {
      final kehamilanAktif = await _kehamilanService.getKehamilanAktif();
      kehamilanAktifId = kehamilanAktif.id;
    } catch (_) {
      // Jika gagal ambil kehamilan aktif (mis. data belum ada), tampilkan
      // semua saja sebagai fallback agar fitur tetap jalan.
      kehamilanAktifId = null;
    }

    final filtered = kehamilanAktifId == null
        ? rawList
        : rawList.where((e) {
            final map = e as Map<String, dynamic>;
            // return map['kehamilan_id'] == kehamilanAktifId;
            return map['kehamilan_id'].toString() == kehamilanAktifId.toString();
          }).toList();

    return filtered.map((e) {
      // final map = Map<String, dynamic>.from(e as Map);
      final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
      // Field "trimester" tidak ada di tabel pemeriksaan dokter, jadi kita
      // sisipkan manual sesuai parameter yang diminta.
      map['trimester'] = trimester;
      // Tabel pemeriksaan dokter memakai key "id", bukan "id_catatan".
      map['id_catatan'] = map['id_catatan'] ?? map['id'];
      return CatatanPelayananKehamilanModel.fromJson(map);
    }).toList();
  }
}