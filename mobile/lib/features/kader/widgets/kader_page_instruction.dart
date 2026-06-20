import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

/// Banner instruksi singkat untuk halaman kader.
///
/// Tujuannya: begitu kader buka sebuah halaman, dia langsung tahu --
/// dalam satu-dua kalimat, tanpa berbelit-belit -- halaman ini untuk apa
/// dan apa yang sebaiknya dia lakukan. Taruh di paling atas body, sebelum
/// konten utama (ringkasan/filter/list).
///
/// Contoh:
/// ```dart
/// const KaderPageInstruction(
///   text: 'Pantau kepatuhan minum TTD/MMS ibu hamil. Ibu berstatus '
///       '"Perlu Tindak Lanjut" sebaiknya dikunjungi atau diingatkan.',
/// )
/// ```
class KaderPageInstruction extends StatelessWidget {
  final String text;
  final IconData icon;

  const KaderPageInstruction({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.primary,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}