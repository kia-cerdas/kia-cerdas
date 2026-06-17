import 'package:flutter/material.dart';

class DashboardMenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardMenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
