import '../models/edukasi_asi_model.dart';
import '../services/edukasi_asi_service.dart';

class EdukasiASIRepository {
  final EdukasiASIService service;

  EdukasiASIRepository(this.service);

  Future<List<EdukasiASIModel>>
      getAllEdukasiASI() async {
    final result =
        await service.getEdukasiASI();

    return result
        .map<EdukasiASIModel>(
          (json) =>
              EdukasiASIModel.fromJson(
            json,
          ),
        )
        .toList();
  }
}