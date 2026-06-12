import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_theme.dart';
import 'package:ta_pa2_pa3_project/features/ibu/nifas/presentation/screens/checklist_pemantauan_ibu_nifas_screen.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';

/// Model untuk satu hari nifas beserta status verifikasinya.
class FilledDayStatus {
  final int hariNifas;
  final bool terverifikasi;
  final String namaKader;
  final String? tanggalVerifikasi;

  const FilledDayStatus({
    required this.hariNifas,
    required this.terverifikasi,
    this.namaKader = '',
    this.tanggalVerifikasi,
  });

  factory FilledDayStatus.fromJson(Map<String, dynamic> json) {
    return FilledDayStatus(
      hariNifas: (json['hari_nifas'] as num).toInt(),
      terverifikasi: json['terverifikasi'] as bool? ?? false,
      namaKader: json['nama_kader'] as String? ?? '',
      tanggalVerifikasi: json['tanggal_verifikasi'] as String?,
    );
  }
}

class NifasScreen extends StatefulWidget {
  const NifasScreen({super.key});

  @override
  State<NifasScreen> createState() => _NifasScreenState();
}

class _NifasScreenState extends State<NifasScreen> {
  bool isLoading = true;

  /// List hari nifas yang sudah diisi beserta status verifikasi.
  List<FilledDayStatus> filledDaysStatus = [];

  /// Shortcut: hanya int day (untuk dikirim ke ChecklistScreen).
  List<int> get filledDays =>
      filledDaysStatus.map((e) => e.hariNifas).toList();

  @override
  void initState() {
    super.initState();
    _loadFilledDays();
  }

  Future<void> _loadFilledDays() async {
    setState(() => isLoading = true);
    try {
      final token = AuthSession.token;
      if (token == null || token.isEmpty) {
        setState(() {
          filledDaysStatus = [];
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.checklistNifasFilledDays}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as List<dynamic>? ?? [];
        setState(() {
          // Backend baru return array of object; fallback ke int jika lama.
          filledDaysStatus = data.map((e) {
            if (e is Map<String, dynamic>) {
              return FilledDayStatus.fromJson(e);
            }
            // Kompatibilitas dengan backend lama yang masih return int.
            return FilledDayStatus(
              hariNifas: int.parse(e.toString()),
              terverifikasi: false,
            );
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openChecklist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChecklistPemantauanIbuNifasScreen(filledDays: filledDays),
      ),
    );
    if (result == true) _loadFilledDays();
  }

  @override
  Widget build(BuildContext context) {
    final progress = filledDays.length / 42;
    final verifiedCount =
        filledDaysStatus.where((e) => e.terverifikasi).length;

    return Scaffold(
      backgroundColor: TrimesterTheme.background,
      appBar: AppBar(
        title: const Text(
          'Menu Nifas',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFilledDays,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCard(progress, verifiedCount),
              const SizedBox(height: 16),
              _menuCard(
                title: 'Checklist Pemantauan Ibu Nifas',
                subtitle:
                    'Isi checklist Nifas A dan B satu kali setiap hari',
                icon: Icons.checklist_rounded,
                onTap: _openChecklist,
              ),
              const SizedBox(height: 22),
              const Text(
                'Riwayat Pengisian',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _filledDaysView(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Summary Card ─────────────────────────────────────────────────

  Widget _summaryCard(double progress, int verifiedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemantauan Masa Nifas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filledDays.length}/42 hari telah diisi',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.18),
              valueColor:
                  const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (filledDays.isNotEmpty)
                _statBadge(
                  icon: Icons.verified_outlined,
                  label: '$verifiedCount terverifikasi',
                  bg: Colors.white.withOpacity(0.18),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge({
    required IconData icon,
    required String label,
    required Color bg,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─── Filled Days List ──────────────────────────────────────────────

  Widget _filledDaysView() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filledDaysStatus.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Belum ada checklist yang diisi.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
      );
    }

    return Column(
      children:
          filledDaysStatus.map((item) => _dayCard(item)).toList(),
    );
  }

  Widget _dayCard(FilledDayStatus item) {
    final isVerified = item.terverifikasi;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isVerified
              ? Colors.green.shade200
              : Colors.orange.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? Colors.green : Colors.orange)
                .withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon status
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isVerified
                  ? Icons.verified_rounded
                  : Icons.hourglass_top_rounded,
              color: isVerified
                  ? Colors.green.shade600
                  : Colors.orange.shade600,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Info hari
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ke-${item.hariNifas}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                if (isVerified) ...[
                  Text(
                    'Diverifikasi oleh ${item.namaKader.isNotEmpty ? item.namaKader : "Kader"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                  if (item.tanggalVerifikasi != null)
                    Text(
                      _formatTanggal(item.tanggalVerifikasi!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade500,
                      ),
                    ),
                ] else
                  Text(
                    'Menunggu verifikasi kader',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),

          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isVerified
                    ? Colors.green.shade300
                    : Colors.orange.shade300,
              ),
            ),
            child: Text(
              isVerified ? 'Terverifikasi' : 'Menunggu',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isVerified
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('d MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return iso;
    }
  }

  // ─── Menu Card ────────────────────────────────────────────────────

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF5F9FF),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9FF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.10),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}