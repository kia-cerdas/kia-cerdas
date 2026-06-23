class PemantauanIbuHamilKaderModel {
  final int? id;
  final int kehamilanId;
  final int mingguKehamilan;
  final bool demamLebih2Hari;
  final bool sakitKepala;
  final bool cemasBerlebih;
  final bool resikoTB;
  final bool gerakanBayiKurang;
  final bool nyeriPerut;
  final bool cairanJalanLahir;
  final bool masalahKemaluan;
  final bool diareBerulang;
  final String namaKader;
  final String tanggalVerifikasi;
  final String namaIbu;
  final String createdAt;

  const PemantauanIbuHamilKaderModel({
    this.id,
    required this.kehamilanId,
    required this.mingguKehamilan,
    required this.demamLebih2Hari,
    required this.sakitKepala,
    required this.cemasBerlebih,
    required this.resikoTB,
    required this.gerakanBayiKurang,
    required this.nyeriPerut,
    required this.cairanJalanLahir,
    required this.masalahKemaluan,
    required this.diareBerulang,
    this.namaKader = '',
    this.tanggalVerifikasi = '',
    this.namaIbu = '',
    this.createdAt = '',
  });

  bool get sudahDitinjau => namaKader.isNotEmpty && tanggalVerifikasi.isNotEmpty;

  /// Jumlah keluhan yang aktif (true)
  int get jumlahKeluhan => [
        demamLebih2Hari,
        sakitKepala,
        cemasBerlebih,
        resikoTB,
        gerakanBayiKurang,
        nyeriPerut,
        cairanJalanLahir,
        masalahKemaluan,
        diareBerulang,
      ].where((e) => e).length;

  factory PemantauanIbuHamilKaderModel.fromJson(Map<String, dynamic> json) {
    String namaIbu = '';
    final kehamilan = json['kehamilan'];
    if (kehamilan != null) {
      final ibu = kehamilan['ibu'];
      if (ibu != null) {
        final kpd = ibu['kependudukan'];
        if (kpd != null) {
          namaIbu = kpd['nama_lengkap']?.toString() ??
              kpd['nama_anggota_keluarga']?.toString() ??
              kpd['nama']?.toString() ??
              '';
        }
      }
    }

    return PemantauanIbuHamilKaderModel(
      id: json['id'],
      kehamilanId: json['kehamilan_id'] ?? 0,
      mingguKehamilan: json['minggu_kehamilan'] ?? 0,
      demamLebih2Hari: json['demam_lebih_2_hari'] ?? false,
      sakitKepala: json['sakit_kepala'] ?? false,
      cemasBerlebih: json['cemas_berlebih'] ?? false,
      resikoTB: json['resiko_tb'] ?? false,
      gerakanBayiKurang: json['gerakan_bayi_kurang'] ?? false,
      nyeriPerut: json['nyeri_perut'] ?? false,
      cairanJalanLahir: json['cairan_jalan_lahir'] ?? false,
      masalahKemaluan: json['masalah_kemaluan'] ?? false,
      diareBerulang: json['diare_berulang'] ?? false,
      namaKader: json['nama_kader']?.toString() ?? '',
      tanggalVerifikasi: _readDate(json['tanggal_verifikasi']),
      namaIbu: namaIbu,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

String _readDate(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}
