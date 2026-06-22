// lib/features/ibu/profil/presentation/screens/profil_keluarga_screen.dart

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/models/profil_keluarga_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/profil/data/services/profil_keluarga_api_service.dart';

class ProfilKeluargaScreen extends StatefulWidget {
  const ProfilKeluargaScreen({super.key});

  @override
  State<ProfilKeluargaScreen> createState() => _ProfilKeluargaScreenState();
}

class _ProfilKeluargaScreenState extends State<ProfilKeluargaScreen> {
  final _service = ProfilKeluargaApiService();
  Future<List<AnggotaKeluargaModel>>? _futureKeluarga;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureKeluarga = _service.getProfilKeluarga();
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // Warna & ikon per hubungan
  Color _hubunganColor(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'kepala keluarga':
        return AppColors.primary;
      case 'istri':
        return const Color(0xFFE91E8C);
      case 'anak':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _hubunganIcon(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'kepala keluarga':
        return Icons.person;
      case 'istri':
        return Icons.woman;
      case 'anak':
        return Icons.child_care;
      default:
        return Icons.people;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _futureKeluarga == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<AnggotaKeluargaModel>>(
                    future: _futureKeluarga,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString());
                      }
                      return _buildContent(snapshot.data!);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white38, width: 1.5),
                ),
                child: const Icon(Icons.people_outline,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Keluarga',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Data anggota dalam satu kartu keluarga',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────────────
  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data keluarga',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KONTEN ────────────────────────────────────────────────────────
  Widget _buildContent(List<AnggotaKeluargaModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Belum ada data anggota keluarga.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _buildAnggotaCard(list[index], index),
    );
  }

  // ── KARTU ANGGOTA ─────────────────────────────────────────────────
  Widget _buildAnggotaCard(AnggotaKeluargaModel anggota, int index) {
    final color = _hubunganColor(anggota.hubungan);
    final icon = _hubunganIcon(anggota.hubungan);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header — nama & hubungan
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anggota.nama.isEmpty ? '-' : anggota.nama,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        anggota.nik.isEmpty ? 'NIK: -' : 'NIK: ${anggota.nik}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge hubungan
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    anggota.hubungan.isEmpty ? '-' : anggota.hubungan,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xFFEEF2F7)),

          // Detail rows
          _buildInfoRow(
            'Jenis Kelamin',
            anggota.jenisKelamin,
            Icons.wc_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Tempat, Tgl Lahir',
            (anggota.tempatLahir.isEmpty && anggota.tanggalLahir.isEmpty)
                ? '-'
                : '${anggota.tempatLahir.isEmpty ? '-' : anggota.tempatLahir}, ${_formatDate(anggota.tanggalLahir)}',
            Icons.cake_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Pendidikan',
            anggota.pendidikan,
            Icons.school_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Pekerjaan',
            anggota.pekerjaan,
            Icons.work_outline,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1, color: const Color(0xFFF1F5F9)),
    );
  }
}