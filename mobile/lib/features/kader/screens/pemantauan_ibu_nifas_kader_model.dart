class PemantauanIbuNifasKaderModel {
  final int? id;
  final int kehamilanId;
  final int hariNifas;

  // NIFAS A
  final bool pemeriksaanNifas;
  final bool konsumsiVitaminA;
  final bool pemenuhanGizi;
  final bool demamLebih38;
  final bool sakitKepala;
  final bool pandanganKabur;
  final bool nyeriUluHati;
  final bool masalahKesehatanJiwa;

  // NIFAS B
  final bool jantungBerdebar;
  final bool cairanJalanLahir;
  final bool napasPendek;
  final bool payudaraBermasalah;
  final bool gangguanBak;
  final bool kelaminBermasalah;
  final bool darahNifasBerbau;
  final bool pendarahanBerat;
  final bool keputihan;

  final String keluhan;

  // Kader
  final String namaKader;
  final String tanggalVerifikasi;

  // Info ibu (dari relasi)
  final String namaIbu;
  final String createdAt;

  const PemantauanIbuNifasKaderModel({
    this.id,
    required this.kehamilanId,
    required this.hariNifas,
    required this.pemeriksaanNifas,
    required this.konsumsiVitaminA,
    required this.pemenuhanGizi,
    required this.demamLebih38,
    required this.sakitKepala,
    required this.pandanganKabur,
    required this.nyeriUluHati,
    required this.masalahKesehatanJiwa,
    required this.jantungBerdebar,
    required this.cairanJalanLahir,
    required this.napasPendek,
    required this.payudaraBermasalah,
    required this.gangguanBak,
    required this.kelaminBermasalah,
    required this.darahNifasBerbau,
    required this.pendarahanBerat,
    required this.keputihan,
    this.keluhan = '',
    this.namaKader = '',
    this.tanggalVerifikasi = '',
    this.namaIbu = '',
    this.createdAt = '',
  });

  /// Sudah ditinjau jika nama kader & tanggal verifikasi terisi
  bool get sudahDitinjau =>
      namaKader.isNotEmpty && tanggalVerifikasi.isNotEmpty;

  /// Keluhan yang aktif (tanda bahaya)
  List<String> get daftarKeluhan {
    final keluhan = <String>[];
    if (demamLebih38) keluhan.add('Demam > 38°C');
    if (sakitKepala) keluhan.add('Sakit kepala');
    if (pandanganKabur) keluhan.add('Pandangan kabur');
    if (nyeriUluHati) keluhan.add('Nyeri ulu hati');
    if (masalahKesehatanJiwa) keluhan.add('Masalah kesehatan jiwa');
    if (jantungBerdebar) keluhan.add('Jantung berdebar');
    if (cairanJalanLahir) keluhan.add('Cairan jalan lahir');
    if (napasPendek) keluhan.add('Napas pendek');
    if (payudaraBermasalah) keluhan.add('Payudara bermasalah');
    if (gangguanBak) keluhan.add('Gangguan BAK');
    if (kelaminBermasalah) keluhan.add('Kelamin bermasalah');
    if (darahNifasBerbau) keluhan.add('Darah nifas berbau');
    if (pendarahanBerat) keluhan.add('Pendarahan berat');
    if (keputihan) keluhan.add('Keputihan');
    return keluhan;
  }

  int get jumlahKeluhan => daftarKeluhan.length;

  factory PemantauanIbuNifasKaderModel.fromJson(Map<String, dynamic> json) {
    // Ambil nama ibu dari relasi kehamilan → ibu → kependudukan
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

    return PemantauanIbuNifasKaderModel(
      id: json['id'],
      kehamilanId: json['kehamilan_id'] ?? 0,
      hariNifas: json['hari_nifas'] ?? 0,
      pemeriksaanNifas: json['pemeriksaan_nifas'] ?? false,
      konsumsiVitaminA: json['konsumsi_vitamin_a'] ?? false,
      pemenuhanGizi: json['pemenuhan_gizi'] ?? false,
      demamLebih38: json['demam_lebih_38'] ?? false,
      sakitKepala: json['sakit_kepala'] ?? false,
      pandanganKabur: json['pandangan_kabur'] ?? false,
      nyeriUluHati: json['nyeri_ulu_hati'] ?? false,
      masalahKesehatanJiwa: json['masalah_kesehatan_jiwa'] ?? false,
      jantungBerdebar: json['jantung_berdebar'] ?? false,
      cairanJalanLahir: json['cairan_jalan_lahir'] ?? false,
      napasPendek: json['napas_pendek'] ?? false,
      payudaraBermasalah: json['payudara_bermasalah'] ?? false,
      gangguanBak: json['gangguan_bak'] ?? false,
      kelaminBermasalah: json['kelamin_bermasalah'] ?? false,
      darahNifasBerbau: json['darah_nifas_berbau'] ?? false,
      pendarahanBerat: json['pendarahan_berat'] ?? false,
      keputihan: json['keputihan'] ?? false,
      keluhan: json['keluhan']?.toString() ?? '',
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