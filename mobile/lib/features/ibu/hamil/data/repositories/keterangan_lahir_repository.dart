import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/proses_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/keterangan_lahir_api_service.dart';

class KeteranganLahirRepository {
  final KeteranganLahirApiService _apiService;

  KeteranganLahirRepository({KeteranganLahirApiService? apiService})
      : _apiService = apiService ?? KeteranganLahirApiService();

  Future<KeteranganLahirModel> getMe() => _apiService.getMe();

  void dispose() => _apiService.dispose();
}