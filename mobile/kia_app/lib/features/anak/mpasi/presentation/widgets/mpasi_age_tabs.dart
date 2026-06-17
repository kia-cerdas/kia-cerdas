import 'package:flutter/material.dart';

class MpasiAgeTabs extends StatelessWidget {
  final int selectedBulan;
  final Function(int) onTabChanged;

  const MpasiAgeTabs({
    Key? key,
    required this.selectedBulan,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'label': '6 Bulan', 'value': 6},
      {'label': '7-8 Bulan', 'value': 7},
      {'label': '9-11 Bulan', 'value': 9},
      {'label': '12-24 Bulan', 'value': 12},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedBulan == tab['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTabChanged(tab['value'] as int),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1565C0) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blueGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
