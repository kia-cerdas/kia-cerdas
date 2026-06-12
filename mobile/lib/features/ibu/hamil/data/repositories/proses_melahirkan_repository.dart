import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/models/proses_melahirkan_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/proses_melahirkan_api_service.dart';

class ProsesMelahirkanRepository {
  final ProsesMelahirkanApiService _apiService;

  ProsesMelahirkanRepository({ProsesMelahirkanApiService? apiService})
      : _apiService = apiService ?? ProsesMelahirkanApiService();

  Future<ProsesMelahirkanModel> getMine() => _apiService.getMine();

  void dispose() => _apiService.dispose();
}