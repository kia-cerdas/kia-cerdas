import 'package:flutter/material.dart';

// --- IMPOR WARNA MENGGUNAKAN RELATIVE PATH (AMAN DARI SEGALA MACAM PERUBAHAN BRANCH) ---
import '../../../../core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class EdukasiCard extends StatelessWidget {
  final String title;
  final IconData icon; 
  final String category;
  final VoidCallback onTap;

  const EdukasiCard({
    super.key,
    required this.title,
    required this.icon,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 44,
                  color: AppColors.primary, 
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}