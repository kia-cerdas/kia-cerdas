import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/features/edukasi/data/models/edukasi_anak_item.dart';

class DetailKontenEdukasiAnakScreen extends StatelessWidget {
  final EdukasiAnakItem item;

  const DetailKontenEdukasiAnakScreen({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: item.thumbnailUrl.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        item.thumbnailUrl,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: item.kategori,
                backgroundColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF334155),
              ),
              _Badge(
                label: item.displayTipe,
                backgroundColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF334155),
              ),
              if (item.displayAgeText.isNotEmpty)
                _Badge(
                  label: item.displayAgeText,
                  backgroundColor: const Color(0xFFE2E8F0),
                  textColor: const Color(0xFF334155),
                ),
              _Badge(
                label: '⏱ ${item.displayDurationText}',
                backgroundColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF334155),
              ),
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

          // ===== Ringkasan Section =====
          if (item.ringkasan.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Ringkasan',
              child: Text(
                item.ringkasan,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.7,
                ),
              ),
            ),
          ],

          // ===== Tutorial Edukasi (Numbered Steps) =====
          Builder(builder: (_) {
            final steps = _parseNumberedSteps(item.konten);
            if (steps.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Tutorial Edukasi',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      steps.length,
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
                                steps[i],
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
                  ),
                ),
              ],
            );
          }),

          // ===== Konten Section (for Pola Asuh / Perawatan that have plain text) =====
          Builder(builder: (_) {
            final steps = _parseNumberedSteps(item.konten);
            // Only show plain konten if there are no numbered steps and konten is available
            if (steps.isNotEmpty ||
                item.konten.trim().isEmpty ||
                item.ringkasan.trim().isNotEmpty && item.konten == item.ringkasan) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Konten',
                  child: Text(
                    item.konten,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            );
          }),

          // ===== Yang Perlu Diingat Section =====
          if (item.yangPerluDiingat.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Yang Perlu Diingat',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parseReminderItems(item.yangPerluDiingat)
                    .map(
                      (reminder) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3, right: 10),
                              child: Icon(Icons.lightbulb_outline,
                                  size: 18, color: Color(0xFF2563EB)),
                            ),
                            Expanded(
                              child: Text(
                                reminder,
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
                    )
                    .toList(),
              ),
            ),
          ],

          // ===== Fallback reminders from konten =====
          if (item.yangPerluDiingat.trim().isEmpty) ...[
            Builder(builder: (_) {
              final reminders = _parseReminders(item.konten);
              if (reminders.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Yang Perlu Diingat',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: reminders
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key + 1}. ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                      height: 1.6,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
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
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      item.isVideo ? Icons.play_circle_outline : Icons.menu_book_rounded,
      size: 72,
      color: AppColors.primary,
    );
  }

  List<String> _parseNumberedSteps(String text) {
    if (text.trim().isEmpty) return [];
    final regex = RegExp(r"^\s*\d+\.\s*(.+)", multiLine: true);
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(1)!.trim()).toList();
    }
    return [];
  }

  List<String> _parseReminderItems(String text) {
    final lines = text
        .split(RegExp(r"\n+"))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r"^[-•*\d\.)\\s]+"), ''))
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines : _parseReminders(text);
  }

  List<String> _parseReminders(String text) {
    if (text.trim().isEmpty) return [];
    final lines = text.split(RegExp(r"\n+"));
    final reminders = <String>[];
    for (final l in lines.reversed) {
      final t = l.trim();
      if (t.startsWith('-') || t.startsWith('•') || t.startsWith('*')) {
        reminders.add(t.replaceFirst(RegExp(r"^[-•*]\s*"), ''));
      }
      if (reminders.length >= 5) break;
    }
    if (reminders.isEmpty) {
      final parts = text
          .split(RegExp(r"\n\s*\n"))
          .map((s) => s.trim())
          .where((s) => s.length < 200)
          .toList();
      for (final p in parts.reversed) {
        if (p.isNotEmpty) reminders.add(p);
        if (reminders.length >= 3) break;
      }
    }
    return reminders.reversed.toList();
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
