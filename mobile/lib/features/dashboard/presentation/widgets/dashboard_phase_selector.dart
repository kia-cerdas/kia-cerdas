import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/data/dashboard_menu_data.dart';


/// [enabledPhases] 
class DashboardPhaseSelector extends StatelessWidget {
  final String selectedPhase;
  final ValueChanged<String> onPhaseSelected;

  final Set<String>? enabledPhases;

  final String? lockedPhase;

  const DashboardPhaseSelector({
    super.key,
    required this.selectedPhase,
    required this.onPhaseSelected,
    this.enabledPhases,
    @Deprecated('Gunakan enabledPhases. lockedPhase hanya mengizinkan 1 tab.')
    this.lockedPhase,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String>? effective =
        enabledPhases ?? (lockedPhase != null ? {lockedPhase!} : null);

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
            final label = p['label'] as String;
            final bool isActive = selectedPhase == label;

            final bool isEnabled =
                effective == null || effective.contains(label);

            return GestureDetector(
              onTap: isEnabled ? () => onPhaseSelected(label) : null,
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.35,
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
                        color: isActive
                            ? TrimesterTheme.t1Primary
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? TrimesterTheme.t1Primary
                            : Colors.grey,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}