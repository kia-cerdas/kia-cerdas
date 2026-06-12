import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int overdueCount;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: TrimesterTheme.t1Primary,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Beranda',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.event_available_outlined),
          label: 'Absensi',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          label: 'Edukasi',
        ),

        // Pure UI: hanya render berdasarkan overdueCount
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon berubah warna jika ada imunisasi terlewat
              Icon(
                Icons.vaccines,
                color: overdueCount > 0 ? Colors.red : null,
              ),

              // Badge notifikasi
              if (overdueCount > 0)
                Positioned(
                  right: -8,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.15,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      overdueCount > 99 ? '99+' : overdueCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label: overdueCount > 0 ? 'Imunisasi' : 'Imunisasi',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
