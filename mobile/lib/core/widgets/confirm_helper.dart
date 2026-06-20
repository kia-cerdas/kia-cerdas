// import 'package:flutter/material.dart';

// extension ConfirmHelper on BuildContext {
//   /// Menampilkan dialog konfirmasi
//   /// Return true jika user konfirmasi, false jika batal
//   Future<bool> showConfirm({
//     String? title,
//     required String message,
//     String confirmText = 'Ya, Simpan',
//     String cancelText = 'Periksa Lagi',
//     Color? primaryColor,
//   }) async {
//     final color = primaryColor ?? Theme.of(this).primaryColor;

//     final result = await showDialog<bool>(
//       context: this,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.assignment_turned_in_outlined, color: color),
//             SizedBox(width: 10),
//             Text(
//               title ?? 'Konfirmasi',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(cancelText, style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: color,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text(confirmText, style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     return result ?? false;
//   }
// }


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
        // 1. Tambahin insetPadding biar dialog gak terlalu mepet pinggir layar
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: color),
            const SizedBox(width: 10),
            // 2. Bungkus title dengan Expanded biar gak overflow kalau judulnya panjang
            Expanded(
              child: Text(
                title ?? 'Konfirmasi',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // 3. Bungkus content dengan SingleChildScrollView (jaga-jaga kalau pesannya super panjang)
        content: SingleChildScrollView(
          child: Text(message),
        ),
        // 4. Bungkus actions dalam Row dan Expanded biar tombolnya responsif & gak ketabrak
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    cancelText,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    confirmText,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );

    return result ?? false;
  }
}