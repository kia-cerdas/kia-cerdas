import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/dashboard/data/dashboard_menu_data.dart';

/// Widget pemilih fase di dashboard ibu.
///
/// [enabledPhases] — set label fase yang boleh diklik.
/// Jika null, SEMUA tab bisa diklik (perilaku bebas / loading).
/// Tab yang tidak ada di dalam set ditampilkan dimmed dan tidak bisa ditekan.
///
/// Aturan bisnis fase ibu (dikontrol dari _DashboardScreenState):
///   - Status HAMIL  → enabledPhases = {'Hamil', 'Menyusui', 'Tumbuh'}
///   - Status NIFAS  → enabledPhases = {'Nifas', 'Menyusui', 'Tumbuh'}
///   - Belum diketahui (loading) → enabledPhases = null (semua bebas)
class DashboardPhaseSelector extends StatelessWidget {
  final String selectedPhase;
  final ValueChanged<String> onPhaseSelected;

  /// Set fase yang boleh diklik. null = semua fase bebas.
  // [SCOPE: modul-ibu] Hanya memengaruhi tab pada dashboard ibu.
  final Set<String>? enabledPhases;

  // --- backward-compat shim ---
  // Parameter lama [lockedPhase] (String?) masih diterima agar tidak
  // merusak pemanggil lain yang belum diperbarui.
  // Jika lockedPhase diisi, enabledPhases diisi dengan {lockedPhase} saja.
  // Prioritas: enabledPhases > lockedPhase.
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
    // Resolusi enabledPhases efektif:
    //   1. Pakai enabledPhases jika diisi.
    //   2. Fallback ke {lockedPhase} jika lockedPhase diisi.
    //   3. null = semua tab bebas.
    // [SCOPE: modul-ibu] Logika ini tidak memengaruhi modul lain.
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

            // Tab aktif jika tidak ada kunci, atau label ada di set yang diizinkan.
            // [SCOPE: modul-ibu] isEnabled hanya mengontrol interaktivitas tab ini.
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