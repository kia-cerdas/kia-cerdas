import 'package:flutter/material.dart';

import '../../data/models/edukasi_asi_model.dart';

/// Halaman DETAIL satu materi edukasi menyusui / ASI Eksklusif.
///
/// Dibuka saat ibu mengetuk salah satu kartu di halaman daftar.
/// Desain disamakan dengan detail edukasi Anak (DetailKontenEdukasiAnakScreen):
/// AppBar putih simpel, ilustrasi dalam kotak rounded, badge pil abu-abu,
/// judul, lalu setiap bagian (Tentang Edukasi, Manfaat, Cara, Masalah, Solusi)
/// dibungkus _SectionCard putih bertajuk dengan daftar bernomor.
class EdukasiAsiDetailScreen extends StatelessWidget {
  final EdukasiASIModel item;

  const EdukasiAsiDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Pecah tiap teks panjang menjadi daftar baris yang sudah bersih
    // (nomor di awal seperti "1. " ikut dibuang agar tidak dobel).
    final manfaatList = _splitToList(item.manfaatASI);
    final caraList = _splitToList(item.cara);
    final masalahList = _splitToList(item.masalah);
    final solusiList = _splitToList(item.solusi);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Thumbnail / Illustration Section =====
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: item.gambarUrl.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        item.gambarUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                      ),
                    )
                  : _buildFallbackIcon(),
            ),
          ),
          const SizedBox(height: 16),

          // ===== Badges Row =====
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: 'ASI Eksklusif'),
              _Badge(label: 'Menyusui'),
              _Badge(label: 'ARTIKEL'),
            ],
          ),
          const SizedBox(height: 16),

          // ===== Title =====
          Text(
            item.judul,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),

          // ===== Bagian 1: Tentang Edukasi =====
          if (item.isi.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Tentang Edukasi',
              child: Text(
                item.isi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.7,
                ),
              ),
            ),
          ],

          // ===== Bagian 2: Manfaat ASI =====
          if (manfaatList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Manfaat ASI',
              child: _NumberedList(items: manfaatList),
            ),
          ],

          // ===== Bagian 3: Cara Menyusui yang Benar =====
          if (caraList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Cara Menyusui yang Benar',
              child: _NumberedList(items: caraList),
            ),
          ],

          // ===== Bagian 4: Masalah yang Sering Terjadi =====
          if (masalahList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Masalah yang Sering Terjadi',
              child: _NumberedList(items: masalahList),
            ),
          ],

          // ===== Bagian 5: Solusi =====
          if (solusiList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Solusi',
              child: _NumberedList(items: solusiList),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<String> _splitToList(String raw) {
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.replaceAll(RegExp(r'^\d+\.\s*'), ''))
        .toList();
  }

  Widget _buildFallbackIcon() {
    return const Icon(
      Icons.child_care_rounded,
      size: 72,
      color: Color(0xFF1F5EA8),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.textColor = const Color(0xFF334155),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Daftar bernomor dengan lingkaran nomor biru, mengikuti gaya
/// "Tutorial Edukasi" pada halaman detail edukasi Anak.
class _NumberedList extends StatelessWidget {
  final List<String> items;

  const _NumberedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        items.length,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  items[i],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}