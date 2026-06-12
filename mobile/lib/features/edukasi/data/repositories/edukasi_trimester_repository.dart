// import '../models/edukasi_trimester_model.dart';
// import '../services/edukasi_trimester_service.dart';

// class EdukasiTrimesterRepository {
//   final EdukasiTrimesterService service;

//   EdukasiTrimesterRepository(
//     this.service,
//   );

//   Future<List<EdukasiTrimesterModel>>
//       getByTrimester(
//     String trimester,
//   ) async {
//     final result =
//         await service.getByTrimester(
//       trimester,
//     );

//     return result
//         .map<EdukasiTrimesterModel>(
//           (json) =>
//               EdukasiTrimesterModel
//                   .fromJson(json),
//         )
//         .toList();
//   }

//   Future<List<EdukasiTrimesterModel>>
//       getByKategori(
//     String trimester,
//     String kategori,
//   ) async {
//     final result =
//         await service.getByKategori(
//       trimester,
//       kategori,
//     );

//     return result
//         .map<EdukasiTrimesterModel>(
//           (json) =>
//               EdukasiTrimesterModel
//                   .fromJson(json),
//         )
//         .toList();
//   }
// }

import '../models/edukasi_trimester_model.dart';
import '../services/edukasi_trimester_service.dart';

class EdukasiTrimesterRepository {
  final EdukasiTrimesterService service;

  EdukasiTrimesterRepository(this.service);

  Future<List<EdukasiTrimesterModel>> getAll() async {
    final result = await service.getAll();
    return result
        .map<EdukasiTrimesterModel>(
          (json) => EdukasiTrimesterModel.fromJson(json),
        )
        .toList();
  }
}