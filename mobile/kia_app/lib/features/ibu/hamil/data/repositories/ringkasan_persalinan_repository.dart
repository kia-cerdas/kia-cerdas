import '../models/ringkasan_persalinan_model.dart';
import '../services/ringkasan_persalinan_service.dart';

class RingkasanPersalinanRepository {
  final RingkasanPersalinanService service;

  RingkasanPersalinanRepository(
    this.service,
  );

  Future<List<RingkasanPersalinanModel>>
      getData(String token) async {

    final response =
        await service.getData(token);

    return response
        .map<RingkasanPersalinanModel>(
          (e) =>
              RingkasanPersalinanModel
                  .fromJson(e),
        )
        .toList();
  }
}