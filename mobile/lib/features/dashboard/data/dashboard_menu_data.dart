import 'package:flutter/material.dart';
import 'dashboard_menu_item.dart';

class DashboardMenuData {
  static List<Map<String, dynamic>> hamilMenuItems = [
    {
      'title': 'Kehamilan Trimester 1–3',
      'subtitle': 'Pantau perkembangan kehamilan',
      'icon': Icons.favorite_outline,
      'color': Colors.pink,
    },
    {
      'title': 'Persalinan',
      'subtitle': 'Persiapan & proses persalinan',
      'icon': Icons.child_care_outlined,
      'color': Colors.blue,
    },
  ];

  // Quick menu Hamil — 6 item, grid 3 kolom (sesuai desain lib_desain)
  static List<Map<String, dynamic>> hamilQuickMenuItems = [
    {
      'label': 'Grafik Berat Badan Ibu',
      'icon': Icons.show_chart,
      'color': Colors.blue,
      'key': 'bb_ibu',
    },
    {
      'label': 'Grafik Evaluasi kehamilan',
      'icon': Icons.monitor_heart_outlined,
      'color': Colors.purple,
      'key': 'djj_tfu',
    },
    {
      'label': 'Catatan',
      'icon': Icons.assignment_outlined,
      'color': Colors.indigo,
      'key': 'catatan',
    },
    {
      'label': 'Log Minum TTD/MMS',
      'icon': Icons.medication_outlined,
      'color': Colors.red,
      'key': 'log_ttd',
    },
    {
      'label': 'Rujukan',
      'icon': Icons.description_outlined,
      'color': Colors.orange,
      'key': 'rujukan',
    },
    {
      'label': 'Pemantauan Ibu Hamil',
      'icon': Icons.health_and_safety_outlined,
      'color': Colors.teal,
      'key': 'pemantauan',
    },
  ];

  static List<Map<String, dynamic>> tumbuhQuickMenuItems = [
    {
      'label': 'Pertumbuhan',
      'desc': 'Pantau berat dan tinggi',
      'icon': Icons.trending_up_rounded,
      'color': Colors.deepOrange,
      'key': 'pertumbuhan',
    },
    {
      'label': 'Perkembangan',
      'desc': 'Skrining tanda bahaya',
      'icon': Icons.fact_check_outlined,
      'color': Colors.amber,
      'key': 'pemantauan',
    },
    {
      'label': 'MPASI',
      'desc': 'Menu makan bayi',
      'icon': Icons.restaurant_menu,
      'color': Colors.blue,
      'key': 'mpasi',
    },
    {
      'label': 'Catatan',
      'desc': 'Lihat riwayat anak',
      'icon': Icons.description_outlined,
      'color': Colors.red,
      'key': 'catatan',
    },
  ];

  // Fase — hanya 3 fase (Menyusui dihapus sesuai desain lib_desain)
  static List<Map<String, dynamic>> phases = [
    {'label': 'Hamil', 'icon': Icons.favorite_border},
    {'label': 'Nifas', 'icon': Icons.person_outline},
    {'label': 'Menyusui','icon': Icons.child_care_outlined,},
    {'label': 'Tumbuh', 'icon': Icons.emoji_emotions_outlined},
  ];
}