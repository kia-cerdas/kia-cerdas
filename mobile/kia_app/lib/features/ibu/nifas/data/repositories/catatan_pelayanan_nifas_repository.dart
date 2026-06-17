import '../models/catatan_pelayanan_nifas_model.dart';
import '../services/catatan_pelayanan_nifas_service.dart';

class CatatanPelayananNifasRepository {

  final CatatanPelayananNifasService service;

  CatatanPelayananNifasRepository(
    this.service,
  );

  Future<List<CatatanPelayananNifasModel>>
      getMine() async {

    final result =
        await service.getMine();

    return result
        .map(
          (e) =>
              CatatanPelayananNifasModel
                  .fromJson(e),
        )
        .toList();
  }
}