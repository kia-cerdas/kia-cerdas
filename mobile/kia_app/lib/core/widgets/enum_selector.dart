// Sebagai selector pilihan berbentuk chip

import 'package:flutter/material.dart';

class EnumSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final Function(String) onChanged;
  final Color activeColor;

  const EnumSelector({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            bool isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              selectedColor: activeColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}