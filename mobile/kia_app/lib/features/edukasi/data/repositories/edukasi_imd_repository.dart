import '../models/edukasi_imd_model.dart';
import '../services/edukasi_imd_service.dart';

class EdukasiIMDRepository {
  final EdukasiIMDService service;

  EdukasiIMDRepository(this.service);

  Future<List<EdukasiIMDModel>> getAllEdukasiIMD() async {
    final data = await service.getEdukasiIMD();

    return data
        .map<EdukasiIMDModel>(
          (item) => EdukasiIMDModel.fromJson(item),
        )
        .toList();
  }
}