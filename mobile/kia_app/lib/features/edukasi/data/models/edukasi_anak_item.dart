/// Unified model that normalizes items from all three edukasi anak sources
/// (Informasi Umum, Pola Asuh, Perawatan Anak) so they can be displayed
/// in a single list with consistent UI.
class EdukasiAnakItem {
  final int id;
  final String judul;
  final String kategori; // 'Informasi Umum', 'Pola Asuh', 'Perawatan'
  final String tipe; // 'ARTIKEL', 'VIDEO', 'Pedoman'
  final String ringkasan;
  final String konten;
  final String yangPerluDiingat;
  final String umurTarget;
  final String durasiBaca;
  final String thumbnailUrl;

  const EdukasiAnakItem({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.tipe,
    this.ringkasan = '',
    this.konten = '',
    this.yangPerluDiingat = '',
    this.umurTarget = '',
    this.durasiBaca = '',
    this.thumbnailUrl = '',
  });

  bool get isVideo => tipe.toUpperCase() == 'VIDEO';

  String get displayAgeText =>
      umurTarget.trim().isNotEmpty ? umurTarget.trim() : '';

  String get displayDurationText =>
      durasiBaca.trim().isNotEmpty ? durasiBaca.trim() : '5 Menit';

  String get displayTipe => tipe.isNotEmpty ? tipe.toUpperCase() : 'ARTIKEL';
}
