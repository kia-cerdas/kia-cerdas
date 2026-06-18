import 'package:flutter/material.dart';

extension ConfirmHelper on BuildContext {
  /// Menampilkan dialog konfirmasi
  /// Return true jika user konfirmasi, false jika batal
  Future<bool> showConfirm({
    String? title,
    required String message,
    String confirmText = 'Ya, Simpan',
    String cancelText = 'Periksa Lagi',
    Color? primaryColor,
  }) async {
    final color = primaryColor ?? Theme.of(this).primaryColor;

    final result = await showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: color),
            SizedBox(width: 10),
            Text(
              title ?? 'Konfirmasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}