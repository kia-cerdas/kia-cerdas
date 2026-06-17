// Sebagai Input field angka untuk form input pertumbuhan 

import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String? suffix;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}