import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/core/services/notification_prefs.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';

class DashboardHeader extends StatelessWidget {
  final List<ImunisasiModel> data;
  final VoidCallback onOpenImunisasi;
  final int overdueCount;

  // ── Kontrol pemeriksaan ──
  final bool hasKontrolAlert;
  final String kontrolAlertMessage;
  final VoidCallback? onOpenKontrol;

  // ── TTD / MMS ──
  final bool hasTTDAlert;
  final String ttdAlertMessage;
  final VoidCallback? onOpenTTD;

  const DashboardHeader({
    super.key,
    required this.data,
    required this.onOpenImunisasi,
    required this.overdueCount,
    this.hasKontrolAlert = false,
    this.kontrolAlertMessage = '',
    this.onOpenKontrol,
    // ── TTD default optional ──
    this.hasTTDAlert = false,
    this.ttdAlertMessage = '',
    this.onOpenTTD,
  });

  @override
  Widget build(BuildContext context) {
    final name = AuthSession.userName ?? 'Bunda';

    final totalAlert =
        overdueCount + (hasKontrolAlert ? 1 : 0) + (hasTTDAlert ? 1 : 0);

    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF185FA5), Color(0xFF2A79C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Teks kiri ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $name!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Tetap semangat menjaga kesehatan buah hati!",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Bell notifikasi ──
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) {
                if (value == 'imunisasi') onOpenImunisasi();
                if (value == 'kontrol') onOpenKontrol?.call();
                if (value == 'ttd') onOpenTTD?.call();
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white),
                  if (totalAlert > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              itemBuilder: (context) {
                final List<PopupMenuEntry<String>> items = [];

                // ── Item imunisasi ──
                if (overdueCount > 0) {
                  items.add(PopupMenuItem(
                    value: 'imunisasi',
                    child: SizedBox(
                      width: 240,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total $overdueCount imunisasi perlu perhatian',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Ketuk untuk memilih anak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                }

                // ── Item kontrol pemeriksaan ──
                if (hasKontrolAlert) {
                  if (items.isNotEmpty) items.add(const PopupMenuDivider());
                  items.add(PopupMenuItem(
                    value: 'kontrol',
                    child: SizedBox(
                      width: 240,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.local_hospital_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jadwal Kontrol Kehamilan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kontrolAlertMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Ketuk untuk melihat detail',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                }

                // ── Item TTD / MMS ──
                if (hasTTDAlert) {
                  if (items.isNotEmpty) items.add(const PopupMenuDivider());
                  items.add(PopupMenuItem(
                    value: 'ttd',
                    child: SizedBox(
                      width: 240,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.medication_outlined,
                            color: Colors.pink,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pengingat TTD/MMS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ttdAlertMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Ketuk untuk membuka log TTD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                }

                // ── Kosong ──
                if (items.isEmpty) {
                  items.add(const PopupMenuItem(
                    value: 'kosong',
                    enabled: false,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text('Belum ada notifikasi'),
                      ],
                    ),
                  ));
                }

                return items;
              },
            ),
          ),
        ],
      ),
    );
  }
}