import '../models/pelayanan_ibu_nifas_model.dart';
import '../services/pelayanan_ibu_nifas_service.dart';

class PelayananIbuNifasRepository {
  final PelayananIbuNifasService service;

  PelayananIbuNifasRepository(this.service);

  Future<List<PelayananIbuNifasModel>> getMine() async {
    final result = await service.getMine();

    return result
        .map((e) => PelayananIbuNifasModel.fromJson(e))
        .toList();
  }
}