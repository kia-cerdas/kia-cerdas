import '../models/edukasi_mental_model.dart';
import '../services/edukasi_mental_service.dart';

class EdukasiKesehatanMentalRepository {
  final EdukasiKesehatanMentalService service;

  EdukasiKesehatanMentalRepository(this.service);

  Future<List<EdukasiKesehatanMentalModel>>
      getAllEdukasiKesehatanMental() async {
    final result =
        await service.getEdukasiKesehatanMental();

    return result
        .map<EdukasiKesehatanMentalModel>(
          (json) =>
              EdukasiKesehatanMentalModel.fromJson(
            json,
          ),
        )
        .toList();
  }
}