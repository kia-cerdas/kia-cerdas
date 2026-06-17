import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class EdukasiVideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final VoidCallback onTap;

  const EdukasiVideoCard({
    super.key,
    required this.title,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            Container(
              height: 140,

              decoration: const BoxDecoration(
                color: Color(0xFFDDEEFF),

                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),

              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      title,

                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Row(
                    children: [

                      const Icon(
                        Icons.access_time,
                        size: 15,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        duration,

                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}