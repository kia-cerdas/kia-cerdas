import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/lembar_pemantauan_screen.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/presentation/screens/skrining/riwayat_skrining_tanda_bahaya_screen.dart';

class PemantauanMenuScreen extends StatefulWidget {
  final Map<String, dynamic>? anak;

  const PemantauanMenuScreen({super.key, this.anak});

  @override
  State<PemantauanMenuScreen> createState() => _PemantauanMenuScreenState();
}

class _PemantauanMenuScreenState extends State<PemantauanMenuScreen> {
  String get namaAnak => widget.anak?['nama'] ?? 'Si Kecil';
  String get usiaAnak => widget.anak?['usia_teks'] ?? 'Usia tidak diketahui';

  int get _selectedAgeIndex => _resolveAgeIndex(usiaAnak);

  static const List<_AgeCardSpec> _ageCards = [
    _AgeCardSpec(
      rentangNama: '0-28 Hari',
      label: '0 - 28 Hari',
      detail: 'Pemantauan harian bayi baru lahir dan tanda bahaya awal.',
      accent: Color(0xFF2563EB),
      icon: Icons.child_care_rounded,
    ),
    _AgeCardSpec(
      rentangNama: '29 Hari - 3 Bulan',
      label: '29 Hari - 3 Bulan',
      detail: 'Skrining mingguan untuk tumbuh kembang awal bayi.',
      accent: Color(0xFF0EA5E9),
      icon: Icons.baby_changing_station_rounded,
    ),
    _AgeCardSpec(
      rentangNama: '3-6 Bulan',
      label: '3 - 6 Bulan',
      detail: 'Pantau perkembangan gerak, nafsu minum, dan respons bayi.',
      accent: Color(0xFF14B8A6),
      icon: Icons.radar_rounded,
    ),
    _AgeCardSpec(
      rentangNama: '6-12 Bulan',
      label: '6 - 12 Bulan',
      detail: 'Cek tanda bahaya, makan, tidur, dan kemampuan duduk/merangkak.',
      accent: Color(0xFFF59E0B),
      icon: Icons.sports_handball_rounded,
    ),
    _AgeCardSpec(
      rentangNama: '12-24 Bulan',
      label: '12 - 24 Bulan',
      detail: 'Pantau kata, jalan, berat badan, serta kemampuan interaksi.',
      accent: Color(0xFF8B5CF6),
      icon: Icons.directions_run_rounded,
    ),
    _AgeCardSpec(
      rentangNama: '2-6 Tahun',
      label: '2 - 6 Tahun',
      detail: 'Pemantauan perkembangan balita dan kesiapan aktivitas harian.',
      accent: Color(0xFFEF4444),
      icon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildHeader(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildAgeInfoCard(),
                    const SizedBox(height: 20),
                    _buildSummaryStrip(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(),
                    const SizedBox(height: 14),
                    _buildAgeGrid(),
                    const SizedBox(height: 18),
                    _buildSecondaryActions(),
                    const SizedBox(height: 18),
                    _buildPrimaryAction(),
                    const SizedBox(height: 12),
                    _buildHistoryAction(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Skrining Tanda Bahaya Anak',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false, // biar rata kiri seperti gambar
    );
  }

  Widget _buildAgeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFD7ECFF),
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: Color(0xFF185FA5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaAnak,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Usia: $usiaAnak',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sistem akan otomatis menyesuaikan lembar pemantauan dengan usia anak Anda saat ini.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Kelompok Usia',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ageCards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 190,
      ),
      itemBuilder: (context, index) {
        final card = _ageCards[index];
        return _buildAgeCard(card);
      },
    );
  }

  Widget _buildAgeCard(_AgeCardSpec card) {
    final isSelected =
        _ageCards[_selectedAgeIndex].rentangNama == card.rentangNama;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: card.accent.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isSelected ? card.accent : card.accent.withOpacity(0.14),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: card.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(card.icon, color: card.accent, size: 24),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: card.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sesuai usia',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: card.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            card.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.touch_app_rounded, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ketuk tombol "Skrining sekarang" di bawah ini untuk mulai mengisi.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAction() {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RiwayatSkriningTandaBahayaScreen(
                anak: widget.anak,
              ),
            ),
          );
        },
        icon: const Icon(Icons.history_rounded),
        label: const Text('Lihat riwayat skrining'),
      ),
    );
  }

  Widget _buildPrimaryAction() {
    final selectedCard = _ageCards[_selectedAgeIndex];

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LembarPemantauanScreen(
                anak: widget.anak,
                initialRentangNama: selectedCard.rentangNama,
              ),
            ),
          );
        },
        icon: const Icon(Icons.playlist_add_check_rounded),
        label: const Text('Skrining sekarang'),
      ),
    );
  }

  int _resolveAgeIndex(String usiaText) {
    final normalized = usiaText.toLowerCase();
    final match =
        RegExp(r'(\d+)\s*(tahun|bulan|hari)').allMatches(normalized).toList();

    int years = 0;
    int months = 0;
    int days = 0;
    for (final item in match) {
      final value = int.tryParse(item.group(1) ?? '') ?? 0;
      final unit = item.group(2) ?? '';
      if (unit.contains('tahun')) {
        years = value;
      } else if (unit.contains('bulan')) {
        months = value;
      } else if (unit.contains('hari')) {
        days = value;
      }
    }

    final totalDays = (years * 365) + (months * 30) + days;
    if (totalDays <= 28) return 0;
    if (totalDays <= 90) return 1;
    if (totalDays <= 180) return 2;
    if (totalDays <= 365) return 3;
    if (totalDays <= 730) return 4;
    return 5;
  }
}

class _AgeCardSpec {
  final String rentangNama;
  final String label;
  final String detail;
  final Color accent;
  final IconData icon;

  const _AgeCardSpec({
    required this.rentangNama,
    required this.label,
    required this.detail,
    required this.accent,
    required this.icon,
  });
}
