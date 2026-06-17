import 'package:flutter/material.dart';

// ============================================================
// ENUMS
// ============================================================

/// Kelompok usia anak sesuai Buku KIA 2024
enum AgeGroup {
  newborn0to28days,
  infant29daysto3months,
  infant3to6months,
  infant6to12months,
  toddler12to24months,
  child2to6years,
}

extension AgeGroupExt on AgeGroup {
  String get label {
    switch (this) {
      case AgeGroup.newborn0to28days:
        return 'Bayi 0–28 Hari';
      case AgeGroup.infant29daysto3months:
        return 'Bayi 29 Hari – 3 Bulan';
      case AgeGroup.infant3to6months:
        return 'Bayi 3–6 Bulan';
      case AgeGroup.infant6to12months:
        return 'Bayi 6–12 Bulan';
      case AgeGroup.toddler12to24months:
        return 'Anak 12–24 Bulan';
      case AgeGroup.child2to6years:
        return 'Anak 2–6 Tahun';
    }
  }

  String get shortLabel {
    switch (this) {
      case AgeGroup.newborn0to28days:
        return '0–28\nHari';
      case AgeGroup.infant29daysto3months:
        return '29hr–\n3 Bln';
      case AgeGroup.infant3to6months:
        return '3–6\nBulan';
      case AgeGroup.infant6to12months:
        return '6–12\nBulan';
      case AgeGroup.toddler12to24months:
        return '1–2\nTahun';
      case AgeGroup.child2to6years:
        return '2–6\nTahun';
    }
  }

  String get periodLabel {
    switch (this) {
      case AgeGroup.newborn0to28days:
        return 'Hari ke-';
      case AgeGroup.infant29daysto3months:
        return 'Minggu ke-';
      default:
        return 'Bulan ke-';
    }
  }

  int get maxPeriods {
    switch (this) {
      case AgeGroup.newborn0to28days:
        return 28;
      case AgeGroup.infant29daysto3months:
        return 9;
      case AgeGroup.infant3to6months:
        return 3;
      case AgeGroup.infant6to12months:
        return 6;
      case AgeGroup.toddler12to24months:
        return 12;
      case AgeGroup.child2to6years:
        return 48;
    }
  }

  IconData get icon {
    switch (this) {
      case AgeGroup.newborn0to28days:
        return Icons.child_care_rounded;
      case AgeGroup.infant29daysto3months:
        return Icons.baby_changing_station_rounded;
      case AgeGroup.infant3to6months:
        return Icons.directions_walk_rounded;
      case AgeGroup.infant6to12months:
        return Icons.sports_handball_rounded;
      case AgeGroup.toddler12to24months:
        return Icons.directions_run_rounded;
      case AgeGroup.child2to6years:
        return Icons.school_rounded;
    }
  }
}

// ============================================================
// DATA CLASSES
// ============================================================

class DangerSignItem {
  final String id;
  final String label;
  final String? description;
  final IconData icon;
  bool isChecked;

  DangerSignItem({
    required this.id,
    required this.label,
    this.description,
    required this.icon,
    this.isChecked = false,
  });

  DangerSignItem copyWith({bool? isChecked}) => DangerSignItem(
        id: id,
        label: label,
        description: description,
        icon: icon,
        isChecked: isChecked ?? this.isChecked,
      );
}

class DangerSignCategory {
  final String title;
  final Color color;
  final IconData categoryIcon;
  final List<DangerSignItem> items;

  DangerSignCategory({
    required this.title,
    required this.color,
    required this.categoryIcon,
    required this.items,
  });
}

class PemantauanEntry {
  final int periodNumber;
  final DateTime savedAt;
  final Map<String, bool> checkedItems;

  PemantauanEntry({
    required this.periodNumber,
    required this.savedAt,
    required this.checkedItems,
  });

  int get dangerCount => checkedItems.values.where((v) => v).length;
  bool get isAman => dangerCount == 0;
}

// ============================================================
// DATA SOURCE — Tanda Bahaya dari Buku KIA 2024
// ============================================================

class KIADangerSigns {
  // Tanda bahaya bayi 0–28 hari & 29 hari–3 bulan (hal. 40–43)
  static List<DangerSignCategory> getNewbornSigns() => [
        DangerSignCategory(
          title: 'Pernapasan & Suhu',
          color: const Color(0xFFEF5350),
          categoryIcon: Icons.air_rounded,
          items: [
            DangerSignItem(
              id: 'sesak_napas',
              label: 'Sesak napas / napas cepat',
              description:
                  'Dada tertarik ke dalam. Napas < 40x/menit atau > 60x/menit.',
              icon: Icons.air,
            ),
            DangerSignItem(
              id: 'suhu_abnormal',
              label: 'Suhu tubuh abnormal',
              description:
                  'Panas > 38,5°C atau dingin (suhu normal 36,5–37,5°C).',
              icon: Icons.thermostat,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Aktivitas & Kesadaran',
          color: const Color(0xFFFF7043),
          categoryIcon: Icons.accessibility_new_rounded,
          items: [
            DangerSignItem(
              id: 'lemah',
              label: 'Lemah / tampak tidak bergerak',
              description:
                  'Aktivitas tampak lemah, tidak menangis atau merintih.',
              icon: Icons.person_outline,
            ),
            DangerSignItem(
              id: 'kejang',
              label: 'Kejang',
              description:
                  'Mata mendelik, tangan menari, mulut mencucu, menangis melengking.',
              icon: Icons.warning_amber,
            ),
            DangerSignItem(
              id: 'hisapan_lemah',
              label: 'Hisapan bayi lemah / tidak menyusu',
              description: 'Bayi tidak mau menyusu sama sekali.',
              icon: Icons.no_food,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Kulit & Warna',
          color: const Color(0xFFFFB300),
          categoryIcon: Icons.color_lens_rounded,
          items: [
            DangerSignItem(
              id: 'kulit_kuning',
              label: 'Kulit dan mata kuning',
              description:
                  'Bila mata masih kuning setelah 2 minggu, segera ke dokter.',
              icon: Icons.circle,
            ),
            DangerSignItem(
              id: 'kulit_biru',
              label: 'Warna kulit tampak biru / sianosis',
              description: 'Memar di sekitar mulut, tangan, atau kaki.',
              icon: Icons.circle_outlined,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Pencernaan & BAB / BAK',
          color: const Color(0xFF66BB6A),
          categoryIcon: Icons.water_drop_rounded,
          items: [
            DangerSignItem(
              id: 'muntah',
              label: 'Muntah-muntah',
              description: 'Muntah susu atau cairan hijau berulang.',
              icon: Icons.sick,
            ),
            DangerSignItem(
              id: 'diare',
              label: 'Diare',
              description: 'BAB lebih sering dan lebih encer dari biasanya.',
              icon: Icons.water,
            ),
            DangerSignItem(
              id: 'kencing_kurang',
              label: 'Kencing < 6x/hari',
              description: 'Warna kencing kurang pekat atau gelap.',
              icon: Icons.opacity,
            ),
            DangerSignItem(
              id: 'tinja_pucat',
              label: 'Tinja berwarna pucat',
              description:
                  'Kemungkinan sumbatan kandung empedu (Atresia Bilier).',
              icon: Icons.report_problem,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Tali Pusat & Kulit',
          color: const Color(0xFF26C6DA),
          categoryIcon: Icons.healing_rounded,
          items: [
            DangerSignItem(
              id: 'tali_pusat',
              label: 'Tali pusat kemerahan / bernanah',
              description:
                  'Kemerahan sampai dinding perut, berbau, atau bernanah.',
              icon: Icons.medical_services,
            ),
            DangerSignItem(
              id: 'mata_merah',
              label: 'Mata merah / bernanah',
              description: 'Ada kotoran atau nanah pada mata bayi.',
              icon: Icons.remove_red_eye,
            ),
            DangerSignItem(
              id: 'bintil_kulit',
              label: 'Kulit bintil-bintil berisi air / nanah',
              description: 'Lesi atau bintil pada permukaan kulit bayi.',
              icon: Icons.bubble_chart,
            ),
          ],
        ),
      ];

  // Tanda bahaya balita 29 hari–5 tahun (hal. 50–51)
  static List<DangerSignCategory> getToddlerSigns() => [
        DangerSignCategory(
          title: 'Pernapasan & Jantung',
          color: const Color(0xFFEF5350),
          categoryIcon: Icons.air_rounded,
          items: [
            DangerSignItem(
              id: 'sesak_napas_bal',
              label: 'Sesak napas / cuping hidung kembang-kempis',
              description: 'Dada tertarik ke dalam saat bernapas.',
              icon: Icons.air,
            ),
            DangerSignItem(
              id: 'tampak_biru',
              label: 'Tampak biru (sianosis)',
              description: 'Bibir, kuku, atau kulit berwarna kebiruan.',
              icon: Icons.circle,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Demam & Pendarahan',
          color: const Color(0xFFFF7043),
          categoryIcon: Icons.thermostat_rounded,
          items: [
            DangerSignItem(
              id: 'demam_bal',
              label: 'Demam / panas tinggi',
              description: 'Suhu > 38,5°C, terutama bila disertai kejang.',
              icon: Icons.thermostat,
            ),
            DangerSignItem(
              id: 'kejang_bal',
              label: 'Kejang',
              description: 'Tubuh kaku atau kontraksi otot berulang.',
              icon: Icons.warning_amber,
            ),
            DangerSignItem(
              id: 'pendarahan',
              label: 'Pendarahan di hidung / kulit / BAB',
              description: 'Tanda dengue atau penyakit serius lainnya.',
              icon: Icons.bloodtype,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Pencernaan',
          color: const Color(0xFF66BB6A),
          categoryIcon: Icons.restaurant_rounded,
          items: [
            DangerSignItem(
              id: 'diare_bal',
              label: 'Diare',
              description:
                  'BAB lebih sering / encer, mata cekung, haus berlebih.',
              icon: Icons.water,
            ),
            DangerSignItem(
              id: 'muntah_bal',
              label: 'Muntah-muntah',
              description: 'Tidak bisa menahan makanan atau minuman.',
              icon: Icons.sick,
            ),
            DangerSignItem(
              id: 'tidak_minum',
              label: 'Tidak bisa minum',
              description: 'Anak menolak minum atau tidak mampu menelan.',
              icon: Icons.no_drinks,
            ),
          ],
        ),
        DangerSignCategory(
          title: 'Kelenjar & Lainnya',
          color: const Color(0xFF26C6DA),
          categoryIcon: Icons.healing_rounded,
          items: [
            DangerSignItem(
              id: 'pembengkakan_telinga',
              label: 'Pembengkakan nyeri di belakang telinga',
              description: 'Tanda mastoiditis atau infeksi serius.',
              icon: Icons.hearing,
            ),
          ],
        ),
      ];

  static List<DangerSignCategory> getCategoriesForGroup(AgeGroup group) {
    if (group == AgeGroup.newborn0to28days ||
        group == AgeGroup.infant29daysto3months) {
      return getNewbornSigns();
    }
    return getToddlerSigns();
  }
}
