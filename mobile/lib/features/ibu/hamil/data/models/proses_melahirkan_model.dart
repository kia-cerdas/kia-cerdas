// class ProsesMelahirkanModel {
//   final String? id;
//   final RingkasanPelayananMelahirkanModel ringkasan;
//   final RiwayatProsesMelahirkanModel riwayat;
//   final KeteranganLahirModel keteranganLahir;

//   const ProsesMelahirkanModel({
//     this.id,
//     required this.ringkasan,
//     required this.riwayat,
//     required this.keteranganLahir,
//   });

//   factory ProsesMelahirkanModel.empty() => ProsesMelahirkanModel(
//         ringkasan: RingkasanPelayananMelahirkanModel.empty(),
//         riwayat: RiwayatProsesMelahirkanModel.empty(),
//         keteranganLahir: KeteranganLahirModel.empty(),
//       );

//   factory ProsesMelahirkanModel.fromJson(Map<String, dynamic> json) {
//     return ProsesMelahirkanModel(
//       id: _readString(json, ['id', '_id', 'uuid']),
//       ringkasan: RingkasanPelayananMelahirkanModel.fromJson(_readMap(json, [
//         'ringkasan',
//         'ringkasan_pelayanan',
//         'ringkasanPelayanan',
//       ], fallback: json)),
//       riwayat: RiwayatProsesMelahirkanModel.fromJson(_readMap(json, [
//         'riwayat',
//         'riwayat_proses_melahirkan',
//         'riwayatProsesMelahirkan',
//       ], fallback: json)),
//       keteranganLahir: KeteranganLahirModel.fromJson(_readMap(json, [
//         'keterangan_lahir',
//         'keteranganLahir',
//         'keterangan',
//       ], fallback: json)),
//     );
//   }
// }

// class RingkasanPelayananMelahirkanModel {
//   final String tanggalMelahirkan, pukul, umurKehamilan;
//   final String penolongProsesMelahirkan, caraMelahirkan, keadaanIbu;
//   final String kbPascaMelahirkan, keteranganTambahan, anakKe;
//   final String beratLahir, panjangBadan, lingkarKepala, jenisKelamin;
//   final List<String> kondisiBayiSaatLahir, asuhanBayiBaruLahir;

//   const RingkasanPelayananMelahirkanModel({
//     required this.tanggalMelahirkan, required this.pukul,
//     required this.umurKehamilan, required this.penolongProsesMelahirkan,
//     required this.caraMelahirkan, required this.keadaanIbu,
//     required this.kbPascaMelahirkan, required this.keteranganTambahan,
//     required this.anakKe, required this.beratLahir,
//     required this.panjangBadan, required this.lingkarKepala,
//     required this.jenisKelamin, required this.kondisiBayiSaatLahir,
//     required this.asuhanBayiBaruLahir,
//   });

//   factory RingkasanPelayananMelahirkanModel.empty() =>
//       const RingkasanPelayananMelahirkanModel(
//         tanggalMelahirkan: '', pukul: '', umurKehamilan: '',
//         penolongProsesMelahirkan: '', caraMelahirkan: '', keadaanIbu: '',
//         kbPascaMelahirkan: '', keteranganTambahan: '', anakKe: '',
//         beratLahir: '', panjangBadan: '', lingkarKepala: '', jenisKelamin: '',
//         kondisiBayiSaatLahir: [], asuhanBayiBaruLahir: [],
//       );

//   factory RingkasanPelayananMelahirkanModel.fromJson(Map<String, dynamic> json) =>
//       RingkasanPelayananMelahirkanModel(
//         tanggalMelahirkan: _readString(json, ['tanggal_melahirkan', 'tanggalMelahirkan', 'tanggal_lahir']),
//         pukul: _readString(json, ['pukul', 'jam_lahir', 'jamLahir']),
//         umurKehamilan: _readString(json, ['umur_kehamilan', 'umurKehamilan']),
//         penolongProsesMelahirkan: _readString(json, ['penolong_proses_melahirkan', 'penolongProsesMelahirkan', 'penolong_kelahiran']),
//         caraMelahirkan: _readString(json, ['cara_melahirkan', 'caraMelahirkan']),
//         keadaanIbu: _readString(json, ['keadaan_ibu', 'keadaanIbu']),
//         kbPascaMelahirkan: _readString(json, ['kb_pasca_melahirkan', 'kbPascaMelahirkan']),
//         keteranganTambahan: _readString(json, ['keterangan_tambahan', 'keteranganTambahan']),
//         anakKe: _readString(json, ['anak_ke', 'anakKe']),
//         beratLahir: _readString(json, ['berat_lahir', 'beratLahir']),
//         panjangBadan: _readString(json, ['panjang_badan', 'panjangBadan']),
//         lingkarKepala: _readString(json, ['lingkar_kepala', 'lingkarKepala']),
//         jenisKelamin: _readString(json, ['jenis_kelamin', 'jenisKelamin']),
//         kondisiBayiSaatLahir: _readStringList(json, ['kondisi_bayi_saat_lahir', 'kondisiBayiSaatLahir']),
//         asuhanBayiBaruLahir: _readStringList(json, ['asuhan_bayi_baru_lahir', 'asuhanBayiBaruLahir']),
//       );
// }

// class RiwayatProsesMelahirkanModel {
//   final String gravida, para, abortus, hari, tanggal, pukul;
//   final List<String> caraMelahirkan, tindakan, penolongKelahiran;
//   final String taksiranMelahirkan, fasyankes, rujukan, inisiasiMenyusuDini;

//   const RiwayatProsesMelahirkanModel({
//     required this.gravida, required this.para, required this.abortus,
//     required this.hari, required this.tanggal, required this.pukul,
//     required this.caraMelahirkan, required this.tindakan,
//     required this.penolongKelahiran, required this.taksiranMelahirkan,
//     required this.fasyankes, required this.rujukan,
//     required this.inisiasiMenyusuDini,
//   });

//   factory RiwayatProsesMelahirkanModel.empty() =>
//       const RiwayatProsesMelahirkanModel(
//         gravida: '', para: '', abortus: '', hari: '', tanggal: '', pukul: '',
//         caraMelahirkan: [], tindakan: [], penolongKelahiran: [],
//         taksiranMelahirkan: '', fasyankes: '', rujukan: '', inisiasiMenyusuDini: '',
//       );

//   factory RiwayatProsesMelahirkanModel.fromJson(Map<String, dynamic> json) =>
//       RiwayatProsesMelahirkanModel(
//         gravida: _readString(json, ['g', 'gravida']),
//         para: _readString(json, ['p', 'para']),
//         abortus: _readString(json, ['a', 'abortus']),
//         hari: _readString(json, ['hari', 'pada_hari']),
//         tanggal: _readString(json, ['tanggal', 'tanggal_melahirkan']),
//         pukul: _readString(json, ['pukul']),
//         caraMelahirkan: _readStringList(json, ['cara_melahirkan', 'caraMelahirkan']),
//         tindakan: _readStringList(json, ['tindakan', 'dengan_tindakan']),
//         penolongKelahiran: _readStringList(json, ['penolong_kelahiran', 'penolongKelahiran']),
//         taksiranMelahirkan: _readString(json, ['taksiran_melahirkan', 'taksiranMelahirkan']),
//         fasyankes: _readString(json, ['fasyankes']),
//         rujukan: _readString(json, ['rujukan']),
//         inisiasiMenyusuDini: _readString(json, ['inisiasi_menyusu_dini', 'inisiasiMenyusuDini']),
//       );
// }

// class KeteranganLahirModel {
//   final String nomor, hari, tanggal, pukul, jenisKelamin, jenisKelahiran;
//   final String anakKe, beratLahir, panjangBadan, lingkarKepala;
//   final String tempatLahir, alamatTempatLahir;
//   final String namaIbu, umurIbu, nikIbu, namaAyah, nikAyah;
//   final String pekerjaan, alamat, rtRw, kecamatan, kabKota;
//   final String saksi1, saksi2, penolongKelahiran;

//   const KeteranganLahirModel({
//     required this.nomor, required this.hari, required this.tanggal,
//     required this.pukul, required this.jenisKelamin, required this.jenisKelahiran,
//     required this.anakKe, required this.beratLahir, required this.panjangBadan,
//     required this.lingkarKepala, required this.tempatLahir,
//     required this.alamatTempatLahir, required this.namaIbu, required this.umurIbu,
//     required this.nikIbu, required this.namaAyah, required this.nikAyah,
//     required this.pekerjaan, required this.alamat, required this.rtRw,
//     required this.kecamatan, required this.kabKota,
//     required this.saksi1, required this.saksi2, required this.penolongKelahiran,
//   });

//   factory KeteranganLahirModel.empty() => const KeteranganLahirModel(
//         nomor: '', hari: '', tanggal: '', pukul: '', jenisKelamin: '',
//         jenisKelahiran: '', anakKe: '', beratLahir: '', panjangBadan: '',
//         lingkarKepala: '', tempatLahir: '', alamatTempatLahir: '',
//         namaIbu: '', umurIbu: '', nikIbu: '', namaAyah: '', nikAyah: '',
//         pekerjaan: '', alamat: '', rtRw: '', kecamatan: '', kabKota: '',
//         saksi1: '', saksi2: '', penolongKelahiran: '',
//       );

//   factory KeteranganLahirModel.fromJson(Map<String, dynamic> json) =>
//       KeteranganLahirModel(
//         nomor: _readString(json, ['nomor', 'no_surat']),
//         hari: _readString(json, ['hari', 'pada_hari']),
//         tanggal: _readString(json, ['tanggal']),
//         pukul: _readString(json, ['pukul']),
//         jenisKelamin: _readString(json, ['jenis_kelamin', 'jenisKelamin']),
//         jenisKelahiran: _readString(json, ['jenis_kelahiran', 'jenisKelahiran']),
//         anakKe: _readString(json, ['anak_ke', 'anakKe']),
//         beratLahir: _readString(json, ['berat_lahir', 'beratLahir']),
//         panjangBadan: _readString(json, ['panjang_badan', 'panjangBadan']),
//         lingkarKepala: _readString(json, ['lingkar_kepala', 'lingkarKepala']),
//         tempatLahir: _readString(json, ['tempat_lahir', 'tempatLahir']),
//         alamatTempatLahir: _readString(json, ['alamat_tempat_lahir', 'alamatTempatLahir']),
//         namaIbu: _readString(json, ['nama_ibu', 'namaIbu']),
//         umurIbu: _readString(json, ['umur_ibu', 'umurIbu']),
//         nikIbu: _readString(json, ['nik_ibu', 'nikIbu']),
//         namaAyah: _readString(json, ['nama_ayah', 'namaAyah']),
//         nikAyah: _readString(json, ['nik_ayah', 'nikAyah']),
//         pekerjaan: _readString(json, ['pekerjaan']),
//         alamat: _readString(json, ['alamat']),
//         rtRw: _readString(json, ['rt_rw', 'rtRw']),
//         kecamatan: _readString(json, ['kecamatan']),
//         kabKota: _readString(json, ['kab_kota', 'kabKota']),
//         saksi1: _readString(json, ['saksi_1', 'saksi1']),
//         saksi2: _readString(json, ['saksi_2', 'saksi2']),
//         penolongKelahiran: _readString(json, ['penolong_kelahiran', 'penolongKelahiran']),
//       );
// }

// // ─── Helper functions (private, hanya dipakai di file ini) ───────────────────

// Map<String, dynamic> _readMap(
//   Map<String, dynamic> json,
//   List<String> keys, {
//   Map<String, dynamic>? fallback,
// }) {
//   for (final key in keys) {
//     final value = json[key];
//     if (value is Map<String, dynamic>) return value;
//     if (value is Map) return Map<String, dynamic>.from(value);
//   }
//   return fallback ?? <String, dynamic>{};
// }

// String _readString(Map<String, dynamic> json, List<String> keys) {
//   for (final key in keys) {
//     final value = json[key];
//     if (value == null) continue;
//     if (value is String) return value;
//     return value.toString();
//   }
//   return '';
// }

// List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
//   for (final key in keys) {
//     final value = json[key];
//     if (value is List) {
//       return value.where((e) => e != null).map((e) => e.toString()).toList();
//     }
//     if (value is String && value.trim().isNotEmpty) {
//       return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//     }
//   }
//   return const [];
// }

class ProsesMelahirkanModel {
  final String? id;
  final RingkasanPelayananMelahirkanModel ringkasan;
  final RiwayatProsesMelahirkanModel riwayat;
  final KeteranganLahirModel keteranganLahir;

  const ProsesMelahirkanModel({
    this.id,
    required this.ringkasan,
    required this.riwayat,
    required this.keteranganLahir,
  });

  factory ProsesMelahirkanModel.empty() => ProsesMelahirkanModel(
        ringkasan: RingkasanPelayananMelahirkanModel.empty(),
        riwayat: RiwayatProsesMelahirkanModel.empty(),
        keteranganLahir: KeteranganLahirModel.empty(),
      );

  factory ProsesMelahirkanModel.fromJson(Map<String, dynamic> json) {
    return ProsesMelahirkanModel(
      id: _readString(json, ['id', '_id', 'uuid']),
      ringkasan: RingkasanPelayananMelahirkanModel.fromJson(_readMap(json, [
        'ringkasan',
        'ringkasan_pelayanan',
        'ringkasanPelayanan',
      ], fallback: json)),
      riwayat: RiwayatProsesMelahirkanModel.fromJson(_readMap(json, [
        'riwayat',
        'riwayat_proses_melahirkan',
        'riwayatProsesMelahirkan',
      ], fallback: json)),
      keteranganLahir: KeteranganLahirModel.fromJson(_readMap(json, [
        'keterangan_lahir',
        'keteranganLahir',
        'keterangan',
      ], fallback: json)),
    );
  }
}

class RingkasanPelayananMelahirkanModel {
  final String tanggalMelahirkan, pukul, umurKehamilan;
  final String penolongProsesMelahirkan, caraMelahirkan, keadaanIbu;
  final String kbPascaMelahirkan, keteranganTambahan, anakKe;
  final String beratLahir, panjangBadan, lingkarKepala, jenisKelamin;
  final List<String> kondisiBayiSaatLahir, asuhanBayiBaruLahir;

  const RingkasanPelayananMelahirkanModel({
    required this.tanggalMelahirkan, required this.pukul,
    required this.umurKehamilan, required this.penolongProsesMelahirkan,
    required this.caraMelahirkan, required this.keadaanIbu,
    required this.kbPascaMelahirkan, required this.keteranganTambahan,
    required this.anakKe, required this.beratLahir,
    required this.panjangBadan, required this.lingkarKepala,
    required this.jenisKelamin, required this.kondisiBayiSaatLahir,
    required this.asuhanBayiBaruLahir,
  });

  factory RingkasanPelayananMelahirkanModel.empty() =>
      const RingkasanPelayananMelahirkanModel(
        tanggalMelahirkan: '', pukul: '', umurKehamilan: '',
        penolongProsesMelahirkan: '', caraMelahirkan: '', keadaanIbu: '',
        kbPascaMelahirkan: '', keteranganTambahan: '', anakKe: '',
        beratLahir: '', panjangBadan: '', lingkarKepala: '', jenisKelamin: '',
        kondisiBayiSaatLahir: [], asuhanBayiBaruLahir: [],
      );

  factory RingkasanPelayananMelahirkanModel.fromJson(Map<String, dynamic> json) =>
      RingkasanPelayananMelahirkanModel(
        tanggalMelahirkan: _readString(json, ['tanggal_melahirkan', 'tanggalMelahirkan', 'tanggal_lahir']),
        pukul: _readString(json, ['pukul', 'jam_lahir', 'jamLahir']),
        umurKehamilan: _readString(json, ['umur_kehamilan', 'umurKehamilan']),
        penolongProsesMelahirkan: _readString(json, ['penolong_proses_melahirkan', 'penolongProsesMelahirkan', 'penolong_kelahiran']),
        caraMelahirkan: _readString(json, ['cara_melahirkan', 'caraMelahirkan']),
        keadaanIbu: _readString(json, ['keadaan_ibu', 'keadaanIbu']),
        kbPascaMelahirkan: _readString(json, ['kb_pasca_melahirkan', 'kbPascaMelahirkan']),
        keteranganTambahan: _readString(json, ['keterangan_tambahan', 'keteranganTambahan']),
        anakKe: _readString(json, ['anak_ke', 'anakKe']),
        beratLahir: _readString(json, ['berat_lahir', 'beratLahir']),
        panjangBadan: _readString(json, ['panjang_badan', 'panjangBadan']),
        lingkarKepala: _readString(json, ['lingkar_kepala', 'lingkarKepala']),
        jenisKelamin: _readString(json, ['jenis_kelamin', 'jenisKelamin']),
        kondisiBayiSaatLahir: _readStringList(json, ['kondisi_bayi_saat_lahir', 'kondisiBayiSaatLahir']),
        asuhanBayiBaruLahir: _readStringList(json, ['asuhan_bayi_baru_lahir', 'asuhanBayiBaruLahir']),
      );
}

class RiwayatProsesMelahirkanModel {
  final String gravida, para, abortus, hari, tanggal, pukul;
  final List<String> caraMelahirkan, tindakan, penolongKelahiran;
  final String taksiranMelahirkan, fasyankes, rujukan, inisiasiMenyusuDini;

  const RiwayatProsesMelahirkanModel({
    required this.gravida, required this.para, required this.abortus,
    required this.hari, required this.tanggal, required this.pukul,
    required this.caraMelahirkan, required this.tindakan,
    required this.penolongKelahiran, required this.taksiranMelahirkan,
    required this.fasyankes, required this.rujukan,
    required this.inisiasiMenyusuDini,
  });

  factory RiwayatProsesMelahirkanModel.empty() =>
      const RiwayatProsesMelahirkanModel(
        gravida: '', para: '', abortus: '', hari: '', tanggal: '', pukul: '',
        caraMelahirkan: [], tindakan: [], penolongKelahiran: [],
        taksiranMelahirkan: '', fasyankes: '', rujukan: '', inisiasiMenyusuDini: '',
      );

  factory RiwayatProsesMelahirkanModel.fromJson(Map<String, dynamic> json) =>
      RiwayatProsesMelahirkanModel(
        gravida: _readString(json, ['g', 'gravida']),
        para: _readString(json, ['p', 'para']),
        abortus: _readString(json, ['a', 'abortus']),
        hari: _readString(json, ['hari', 'pada_hari']),
        tanggal: _readString(json, ['tanggal', 'tanggal_melahirkan']),
        pukul: _readString(json, ['pukul']),
        caraMelahirkan: _readStringList(json, ['cara_melahirkan', 'caraMelahirkan']),
        tindakan: _readStringList(json, ['tindakan', 'dengan_tindakan']),
        penolongKelahiran: _readStringList(json, ['penolong_kelahiran', 'penolongKelahiran']),
        taksiranMelahirkan: _readString(json, ['taksiran_melahirkan', 'taksiranMelahirkan']),
        fasyankes: _readString(json, ['fasyankes']),
        rujukan: _readString(json, ['rujukan']),
        inisiasiMenyusuDini: _readString(json, ['inisiasi_menyusu_dini', 'inisiasiMenyusuDini']),
      );
}

// ─── KeteranganLahirModel — sesuai Go struct KeteranganLahir ─────────────────
//
// Go fields (json tags):
//   id, id_ibu_relasi, nomor_surat,
//   hari_lahir, tanggal_lahir, pukul_lahir,
//   jenis_kelamin, jenis_kelahiran, anak_ke,
//   usia_gestasi_minggu, berat_lahir_gram, panjang_badan_cm, lingkar_kepala_cm,
//   lokasi_persalinan, alamat_lokasi_persalinan, nama_bayi_diberi_nama,
//   nama_ibu, umur_ibu, nik_ibu, nama_ayah, nik_ayah,
//   pekerjaan_orang_tua, alamat_orang_tua, rw_rt_orang_tua,
//   kecamatan_orang_tua, kab_kota_orang_tua,
//   tanggal_surat, nama_saksi_1, nama_saksi_2, nama_penolong_kelahiran

class KeteranganLahirModel {
  // Identitas Surat
  final String nomorSurat;
  final String tanggalSurat; // date string dari API

  // Data Lahir
  final String hariLahir;
  final String tanggalLahir;
  final String pukulLahir;

  // Data Bayi
  final String jenisKelamin;
  final String jenisKelahiran;
  final String anakKe;           // int di DB → ditampilkan sebagai string
  final String usiaGestasiMinggu; // int di DB
  final String beratLahirGram;   // int di DB
  final String panjangBadanCm;   // int di DB
  final String lingkarKepalaCm;  // int di DB
  final String namaBayiDiberiNama;

  // Lokasi
  final String lokasiPersalinan;
  final String alamatLokasiPersalinan;

  // Data Orang Tua
  final String namaIbu;
  final String umurIbu;          // int di DB
  final String nikIbu;
  final String namaAyah;
  final String nikAyah;
  final String pekerjaanOrangTua;
  final String alamatOrangTua;
  final String rwRtOrangTua;
  final String kecamatanOrangTua;
  final String kabKotaOrangTua;

  // Tanda Tangan
  final String namaSaksi1;
  final String namaSaksi2;
  final String namaPenolongKelahiran;

  const KeteranganLahirModel({
    required this.nomorSurat,
    required this.tanggalSurat,
    required this.hariLahir,
    required this.tanggalLahir,
    required this.pukulLahir,
    required this.jenisKelamin,
    required this.jenisKelahiran,
    required this.anakKe,
    required this.usiaGestasiMinggu,
    required this.beratLahirGram,
    required this.panjangBadanCm,
    required this.lingkarKepalaCm,
    required this.namaBayiDiberiNama,
    required this.lokasiPersalinan,
    required this.alamatLokasiPersalinan,
    required this.namaIbu,
    required this.umurIbu,
    required this.nikIbu,
    required this.namaAyah,
    required this.nikAyah,
    required this.pekerjaanOrangTua,
    required this.alamatOrangTua,
    required this.rwRtOrangTua,
    required this.kecamatanOrangTua,
    required this.kabKotaOrangTua,
    required this.namaSaksi1,
    required this.namaSaksi2,
    required this.namaPenolongKelahiran,
  });

  factory KeteranganLahirModel.empty() => const KeteranganLahirModel(
        nomorSurat: '',
        tanggalSurat: '',
        hariLahir: '',
        tanggalLahir: '',
        pukulLahir: '',
        jenisKelamin: '',
        jenisKelahiran: '',
        anakKe: '',
        usiaGestasiMinggu: '',
        beratLahirGram: '',
        panjangBadanCm: '',
        lingkarKepalaCm: '',
        namaBayiDiberiNama: '',
        lokasiPersalinan: '',
        alamatLokasiPersalinan: '',
        namaIbu: '',
        umurIbu: '',
        nikIbu: '',
        namaAyah: '',
        nikAyah: '',
        pekerjaanOrangTua: '',
        alamatOrangTua: '',
        rwRtOrangTua: '',
        kecamatanOrangTua: '',
        kabKotaOrangTua: '',
        namaSaksi1: '',
        namaSaksi2: '',
        namaPenolongKelahiran: '',
      );

  factory KeteranganLahirModel.fromJson(Map<String, dynamic> json) =>
      KeteranganLahirModel(
        nomorSurat: _readString(json, ['nomor_surat', 'nomorSurat', 'nomor', 'no_surat']),
        tanggalSurat: _readString(json, ['tanggal_surat', 'tanggalSurat']),
        hariLahir: _readString(json, ['hari_lahir', 'hariLahir', 'hari']),
        tanggalLahir: _readString(json, ['tanggal_lahir', 'tanggalLahir', 'tanggal']),
        pukulLahir: _readString(json, ['pukul_lahir', 'pukulLahir', 'pukul']),
        jenisKelamin: _readString(json, ['jenis_kelamin', 'jenisKelamin']),
        jenisKelahiran: _readString(json, ['jenis_kelahiran', 'jenisKelahiran']),
        anakKe: _readIntAsString(json, ['anak_ke', 'anakKe']),
        usiaGestasiMinggu: _readIntAsString(json, ['usia_gestasi_minggu', 'usiaGestasiMinggu']),
        beratLahirGram: _readIntAsString(json, ['berat_lahir_gram', 'beratLahirGram', 'berat_lahir']),
        panjangBadanCm: _readIntAsString(json, ['panjang_badan_cm', 'panjangBadanCm', 'panjang_badan']),
        lingkarKepalaCm: _readIntAsString(json, ['lingkar_kepala_cm', 'lingkarKepalaCm', 'lingkar_kepala']),
        namaBayiDiberiNama: _readString(json, ['nama_bayi_diberi_nama', 'namaBayiDiberiNama']),
        lokasiPersalinan: _readString(json, ['lokasi_persalinan', 'lokasiPersalinan', 'tempat_lahir']),
        alamatLokasiPersalinan: _readString(json, ['alamat_lokasi_persalinan', 'alamatLokasiPersalinan', 'alamat_tempat_lahir']),
        namaIbu: _readString(json, ['nama_ibu', 'namaIbu']),
        umurIbu: _readIntAsString(json, ['umur_ibu', 'umurIbu']),
        nikIbu: _readString(json, ['nik_ibu', 'nikIbu']),
        namaAyah: _readString(json, ['nama_ayah', 'namaAyah']),
        nikAyah: _readString(json, ['nik_ayah', 'nikAyah']),
        pekerjaanOrangTua: _readString(json, ['pekerjaan_orang_tua', 'pekerjaanOrangTua', 'pekerjaan']),
        alamatOrangTua: _readString(json, ['alamat_orang_tua', 'alamatOrangTua', 'alamat']),
        rwRtOrangTua: _readString(json, ['rw_rt_orang_tua', 'rwRtOrangTua', 'rt_rw', 'rtRw']),
        kecamatanOrangTua: _readString(json, ['kecamatan_orang_tua', 'kecamatanOrangTua', 'kecamatan']),
        kabKotaOrangTua: _readString(json, ['kab_kota_orang_tua', 'kabKotaOrangTua', 'kab_kota']),
        namaSaksi1: _readString(json, ['nama_saksi_1', 'namaSaksi1', 'saksi_1', 'saksi1']),
        namaSaksi2: _readString(json, ['nama_saksi_2', 'namaSaksi2', 'saksi_2', 'saksi2']),
        namaPenolongKelahiran: _readString(json, ['nama_penolong_kelahiran', 'namaPenolongKelahiran', 'penolong_kelahiran']),
      );
}

// ─── Helper functions (private, hanya dipakai di file ini) ───────────────────

Map<String, dynamic> _readMap(
  Map<String, dynamic> json,
  List<String> keys, {
  Map<String, dynamic>? fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return fallback ?? <String, dynamic>{};
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is String) return value;
    return value.toString();
  }
  return '';
}

/// Membaca nilai int dari JSON dan mengembalikannya sebagai String.
/// Jika nilainya 0, dikembalikan string kosong supaya UI menampilkan "Belum diisi".
String _readIntAsString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value == 0 ? '' : value.toString();
    if (value is double) return value == 0 ? '' : value.toStringAsFixed(0);
    if (value is String) return value;
    return value.toString();
  }
  return '';
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.where((e) => e != null).map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
  }
  return const [];
}