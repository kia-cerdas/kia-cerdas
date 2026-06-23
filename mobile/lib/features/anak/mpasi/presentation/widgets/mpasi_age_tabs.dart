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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final tab = entry.value;
          final isSelected = selectedBulan == tab['value'];
          final isLast = entry.key == tabs.length - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: GestureDetector(
                onTap: () => onTabChanged(tab['value'] as int),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF185FA5)
                        : const Color(0xFF185FA5).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF185FA5),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
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