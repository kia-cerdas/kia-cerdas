import '../models/edukasi_nifas_model.dart';
import '../services/edukasi_nifas_service.dart';

class EdukasiNifasRepository {
  final EdukasiNifasService service;

  EdukasiNifasRepository(this.service);

  Future<List<EdukasiNifasModel>>
      getAllEdukasiNifas() async {
    final result =
        await service.getEdukasiNifas();

    return result
        .map<EdukasiNifasModel>(
          (json) =>
              EdukasiNifasModel.fromJson(
            json,
          ),
        )
        .toList();
  }
}