import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/trimester_menu_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/hasil_evaluasi_kesehatan_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/absensi_kelas_ibu_hamil_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/log_ttd_mms_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/presentation/screens/proses_melahirkan_screens.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

class JourneyScreen extends StatefulWidget {
  final int currentWeek;
  final int gravida;
  final int paritas;
  final int abortus;
  final String hplText;
  final String hphtText;
  final DateTime hpht;

  const JourneyScreen({
    super.key,
    required this.currentWeek,
    required this.gravida,
    required this.paritas,
    required this.abortus,
    required this.hplText,
    required this.hphtText,
    required this.hpht,
  });

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  static const int totalWeeks = 40;

  String get currentTrimesterLabel {
    if (widget.currentWeek <= 12) return 'Trimester I';
    if (widget.currentWeek <= 27) return 'Trimester II';
    return 'Trimester III';
  }

  double get progressValue {
    return (widget.currentWeek / totalWeeks).clamp(0.0, 1.0);
  }

  TrimesterStatus _statusForTrimester(int trimester) {
    if (trimester == 1) {
      return widget.currentWeek <= 12
          ? TrimesterStatus.active
          : TrimesterStatus.completed;
    }

    if (trimester == 2) {
      if (widget.currentWeek <= 12) return TrimesterStatus.locked;
      if (widget.currentWeek <= 27) return TrimesterStatus.active;
      return TrimesterStatus.completed;
    }

    if (widget.currentWeek <= 27) return TrimesterStatus.locked;
    return TrimesterStatus.active;
  }

  void _openComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title akan disambungkan setelah migrasi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrimesterTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemeriksaan Kehamilan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'G${widget.gravida}P${widget.paritas}A${widget.abortus}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildStatusHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _buildFeatureCard(
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.primary,
                  iconBackground: const Color(0xFFEAF4FF),
                  title: 'Evaluasi Kesehatan Ibu',
                  subtitle: 'Lihat hasil evaluasi awal kehamilan',
                  borderColor: const Color(0xFFB7DBFF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HasilEvaluasiKesehatanScreen(),
                      ),
                    );
                  },
                ),
                // const SizedBox(height: 14),
                // _buildFeatureCard(
                //   icon: Icons.summarize_outlined,
                //   iconColor: const Color(0xFFE0A300),
                //   iconBackground: const Color(0xFFFFF5D6),
                //   title: 'Keterangan Lahir',
                //   subtitle: 'Lihat ringkasan ibu bersalin, nifas, dan bayi saat lahir',
                //   borderColor: const Color(0xFFFFE3A3),
                //   // onTap: () => _openComingSoon('Ringkasan Pelayanan Proses Melahirkan'),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       // builder: (_) => const RingkasanPelayananProsesMelahirkanScreen(),
                //       builder: (_) => const KeteranganLahirScreen(),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 14),
                // _buildFeatureCard(
                //   icon: Icons.fact_check_outlined,
                //   iconColor: const Color(0xFFE0A300),
                //   iconBackground: const Color(0xFFFFF5D6),
                //   title: 'Absensi Kelas Ibu Hamil',
                //   subtitle: 'Isi tanggal hadir sampai 9 sesi dan paraf kader',
                //   borderColor: const Color(0xFFFFE3A3),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => const AbsensiKelasIbuHamilScreen(),
                //       ),
                //     );
                //   },
                // ),
                // const SizedBox(height: 14),
                // _buildFeatureCard(
                //   icon: Icons.medication_liquid_outlined,
                //   iconColor: AppColors.primary,
                //   iconBackground: const Color(0xFFEAF4FF),
                //   title: 'Log TTD/MMS',
                //   subtitle: 'Checklist harian minum tablet tambah darah atau MMS',
                //   borderColor: const Color(0xFFB7DBFF),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => LogTTDMMSScreen(hpht: widget.hpht,),
                //       ),
                //     );
                //   },
                // ),
                const SizedBox(height: 24),
                _buildJourneyStep(
                  trimester: 1,
                  title: 'Trimester I',
                  desc: 'Ukuran Plum · ±5 cm',
                  weeks: 'Minggu 1-12',
                  status: _statusForTrimester(1),
                ),
                _buildJourneyStep(
                  trimester: 2,
                  title: 'Trimester II',
                  desc: 'Ukuran Pepaya · ±30 cm',
                  weeks: 'Minggu 13-27',
                  status: _statusForTrimester(2),
                ),
                _buildJourneyStep(
                  trimester: 3,
                  title: 'Trimester III',
                  desc: 'Ukuran Semangka · ±48 cm',
                  weeks: 'Minggu 28-40',
                  status: _statusForTrimester(3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, left: 24, right: 24, top: 10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderTopRow(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${widget.currentWeek}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Minggu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            Text(
              'HPL: ${widget.hplText} • HPHT: ${widget.hphtText}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mgg 1', style: TextStyle(color: Colors.white60, fontSize: 10)),
                const Text('Mgg 12', style: TextStyle(color: Colors.white60, fontSize: 10)),
                Text(
                  'Mgg ${widget.currentWeek} ◀',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Mgg 40', style: TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'USIA KEHAMILAN SAAT INI',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            currentTrimesterLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStep({
    required int trimester,
    required String title,
    required String desc,
    required String weeks,
    required TrimesterStatus status,
  }) {
    final isLocked = status == TrimesterStatus.locked;
    final mainColor = TrimesterTheme.getThemeColor(trimester);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade300 : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked ? Colors.transparent : mainColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isLocked
                        ? Icons.lock
                        : status == TrimesterStatus.completed
                            ? Icons.check
                            : Icons.radio_button_checked,
                    size: 14,
                    color: isLocked ? Colors.white : mainColor,
                  ),
                ),
              ),
              Expanded(
                child: Container(width: 2, color: Colors.grey.shade300),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isLocked
                    ? null
                    : Border.all(
                        color: mainColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isLocked
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrimesterMenuScreen(trimester: trimester),
                          ),
                        );
                      },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isLocked
                                ? Colors.grey.shade100
                                : mainColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLocked
                                ? Icons.lock_outline
                                : status == TrimesterStatus.completed
                                    ? Icons.verified_user
                                    : Icons.favorite,
                            color: isLocked ? Colors.grey : mainColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isLocked ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: TextStyle(
                                  color: isLocked ? Colors.grey : Colors.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weeks,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLocked)
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}