import '../models/catatan_pelayanan_kehamilan_model.dart';
import '../services/catatan_pelayanan_kehamilan_service.dart';

class CatatanPelayananKehamilanRepository {
  final CatatanPelayananKehamilanService service;

  CatatanPelayananKehamilanRepository(this.service);

  /// Ambil catatan milik ibu yang login.
  /// [trimester] opsional: 1/2/3. Null = semua trimester.
  Future<List<CatatanPelayananKehamilanModel>> getMine({int? trimester}) async {
    final result = await service.getMine(trimester: trimester);
    return result
        .map((e) => CatatanPelayananKehamilanModel.fromJson(e))
        .toList();
  }
}
