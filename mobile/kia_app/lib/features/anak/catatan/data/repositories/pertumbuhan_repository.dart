import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/services/pertumbuhan_api_service.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/master_standar_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';

class PertumbuhanRepository {
  final PertumbuhanApiService _apiService;

  PertumbuhanRepository({required PertumbuhanApiService apiService})
      : _apiService = apiService;

  /// Cari anak berdasarkan nama, nama ibu, atau nomor KK
  Future<List<AnakSearchModel>> searchAnak({
    String namaAnak = '',
    String namaIbu = '',
    String noKk = '',
  }) async {
    return _apiService.searchAnak(
      namaAnak: namaAnak,
      namaIbu: namaIbu,
      noKk: noKk,
    );
  }

  /// Dapatkan riwayat pertumbuhan untuk seorang anak
  Future<List<PertumbuhanModel>> getRiwayatPertumbuhanByAnakId(
    int anakId,
  ) async {
    return _apiService.getRiwayatPertumbuhanByAnakId(anakId);
  }

  /// Dapatkan master standar untuk grafik
  Future<List<MasterStandarModel>> getMasterStandar({
    required String parameter,
    required String jenisKelamin,
  }) async {
    return _apiService.getMasterStandar(
      parameter: parameter,
      jenisKelamin: jenisKelamin,
    );
  }

  /// Buat catatan pertumbuhan baru
  Future<void> createCatatanPertumbuhan(
    CreatePertumbuhanRequest payload,
  ) async {
    return _apiService.createCatatanPertumbuhan(payload);
  }
}
