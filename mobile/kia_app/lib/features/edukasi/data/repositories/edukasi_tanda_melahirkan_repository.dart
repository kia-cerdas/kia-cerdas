import '../models/edukasi_tanda_melahirkan_model.dart';
import '../services/edukasi_tanda_melahirkan_service.dart';

class EdukasiTandaMelahirkanRepository {
  final EdukasiTandaMelahirkanService service;

  EdukasiTandaMelahirkanRepository(
    this.service,
  );

  Future<
          List<
              EdukasiTandaMelahirkanModel>>
      getAllEdukasiTandaMelahirkan() async {
    final result = await service
        .getEdukasiTandaMelahirkan();

    return result
        .map<EdukasiTandaMelahirkanModel>(
          (json) =>
              EdukasiTandaMelahirkanModel
                  .fromJson(json),
        )
        .toList();
  }
}