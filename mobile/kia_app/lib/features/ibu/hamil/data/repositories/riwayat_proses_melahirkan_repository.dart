import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/riwayat_proses_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/riwayat_proses_melahirkan_api_service.dart';

class RiwayatProsesMelahirkanRepository {
  final RiwayatProsesMelahirkanApiService _apiService;

  RiwayatProsesMelahirkanRepository(
      {RiwayatProsesMelahirkanApiService? apiService})
      : _apiService =
            apiService ?? RiwayatProsesMelahirkanApiService();

  Future<RiwayatProsesMelahirkanModel> getMine() => _apiService.getMine();

  void dispose() => _apiService.dispose();
}