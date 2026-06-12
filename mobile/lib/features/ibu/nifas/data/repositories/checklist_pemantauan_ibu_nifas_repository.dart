import '../models/checklist_pemantauan_ibu_nifas_model.dart';
import '../services/checklist_pemantauan_ibu_nifas_service.dart';

class ChecklistPemantauanIbuNifasRepository {

  final ChecklistPemantauanIbuNifasService service;

  ChecklistPemantauanIbuNifasRepository(this.service);

  Future<void> createChecklist({
    required String token,
    required ChecklistPemantauanIbuNifasModel model,
  }) async {

    final response = await service.createChecklist(
      token: token,
      body: model.toJson(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception('Gagal menyimpan checklist');
    }
  }
}