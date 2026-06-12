class SkriningAnswerItem {
  final String label;
  final bool value;

  const SkriningAnswerItem({
    required this.label,
    required this.value,
  });
}

class SkriningPreeklampsiaModel {
  final int id;
  final int kehamilanId;
  final String kesimpulan;

  final List<SkriningAnswerItem> risikoSedangItems;
  final List<SkriningAnswerItem> risikoTinggiItems;
  final List<SkriningAnswerItem> pemeriksaanFisikItems;

  SkriningPreeklampsiaModel({
    required this.id,
    required this.kehamilanId,
    required this.kesimpulan,
    required this.risikoSedangItems,
    required this.risikoTinggiItems,
    required this.pemeriksaanFisikItems,
  });

  factory SkriningPreeklampsiaModel.fromJson(Map<String, dynamic> json) {
    bool yes(String key) => json[key] == true;

    return SkriningPreeklampsiaModel(
      id: json['id_skrining_preeklampsia'] ?? 0,
      kehamilanId: json['kehamilan_id'] ?? 0,
      kesimpulan:
          json['kesimpulan_skrining_preeklampsia']?.toString() ?? '',
      risikoSedangItems: [
        SkriningAnswerItem(
          label: 'Multipara dengan pasangan baru',
          value: yes('anamnesis_multipara_pasangan_baru_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Teknologi reproduksi berbantu',
          value: yes('anamnesis_teknologi_reproduksi_berbantu_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Umur di atas 35 tahun',
          value: yes('anamnesis_umur_diatas_35_tahun_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Nulipara',
          value: yes('anamnesis_nulipara_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Jarak kehamilan di atas 10 tahun',
          value: yes('anamnesis_jarak_kehamilan_diatas_10_tahun_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Riwayat preeklampsia keluarga',
          value: yes('anamnesis_riwayat_preeklampsia_keluarga_sedang'),
        ),
        SkriningAnswerItem(
          label: 'Obesitas IMT di atas 30',
          value: yes('anamnesis_obesitas_imt_diatas_30_sedang'),
        ),
      ],
      risikoTinggiItems: [
        SkriningAnswerItem(
          label: 'Riwayat preeklampsia sebelumnya',
          value: yes('anamnesis_riwayat_preeklampsia_sebelumnya_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Kehamilan multipel',
          value: yes('anamnesis_kehamilan_multipel_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Diabetes dalam kehamilan',
          value: yes('anamnesis_diabetes_dalam_kehamilan_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Hipertensi kronik',
          value: yes('anamnesis_hipertensi_kronik_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Penyakit ginjal',
          value: yes('anamnesis_penyakit_ginjal_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Penyakit autoimun SLE',
          value: yes('anamnesis_penyakit_autoimun_sle_tinggi'),
        ),
        SkriningAnswerItem(
          label: 'Anti phospholipid syndrome',
          value: yes('anamnesis_anti_phospholipid_syndrome_tinggi'),
        ),
      ],
      pemeriksaanFisikItems: [
        SkriningAnswerItem(
          label: 'MAP di atas 90 mmHg',
          value: yes('fisik_map_diatas_90_mmhg'),
        ),
        SkriningAnswerItem(
          label: 'Proteinuria urin celup',
          value: yes('fisik_proteinuria_urin_celup'),
        ),
      ],
    );
  }

  bool get hasRisikoSedang =>
      risikoSedangItems.any((item) => item.value == true);

  bool get hasRisikoTinggi =>
      risikoTinggiItems.any((item) => item.value == true);

  bool get hasPemeriksaanFisikBermasalah =>
      pemeriksaanFisikItems.any((item) => item.value == true);

  String get kesimpulanText {
    if (kesimpulan.trim().isNotEmpty) return kesimpulan;
    if (hasRisikoTinggi) return 'Risiko tinggi';
    if (hasRisikoSedang || hasPemeriksaanFisikBermasalah) {
      return 'Perlu pemantauan';
    }
    return 'Tidak ditemukan faktor risiko';
  }
}