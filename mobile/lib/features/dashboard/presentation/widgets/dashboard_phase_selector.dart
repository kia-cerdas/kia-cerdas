import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/data/dashboard_menu_data.dart';

class DashboardPhaseSelector extends StatelessWidget {
  final String selectedPhase;
  final ValueChanged<String> onPhaseSelected;

  const DashboardPhaseSelector({
    super.key,
    required this.selectedPhase,
    required this.onPhaseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TAHAP SAAT INI",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: DashboardMenuData.phases.map((p) {
            final bool isActive = selectedPhase == p['label'];
            return GestureDetector(
              onTap: () => onPhaseSelected(p['label'] as String),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isActive
                          ? Border.all(
                              color: TrimesterTheme.t1Primary,
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      p['icon'] as IconData,
                      color:
                          isActive ? TrimesterTheme.t1Primary : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isActive ? TrimesterTheme.t1Primary : Colors.grey,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
