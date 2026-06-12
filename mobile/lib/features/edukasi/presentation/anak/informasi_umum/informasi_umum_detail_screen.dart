import 'package:flutter/material.dart';

import 'package:ta_pa2_pa3_project/features/edukasi/data/models/informasi_umum_model.dart';

class InformasiUmumDetailScreen extends StatelessWidget {
  final InformasiUmumModel item;

  const InformasiUmumDetailScreen({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Detail Informasi Umum',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: item.isVideo
                  ? const Color(0xFFE6EFFF)
                  : const Color(0xFFFFF0D4),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: item.tipe.toUpperCase(),
                backgroundColor: const Color(0xFFE6EFFF),
                textColor: const Color(0xFF2563EB),
              ),
              _Badge(label: item.displayAgeText),
              _Badge(label: item.displayDurationText),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.judul,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          if (item.ringkasan.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
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

          if (item.yangPerluDiingat.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
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

          const SizedBox(height: 14),
          // Tutorial Edukasi (numbered steps)
          Builder(builder: (_) {
            final steps = _parseNumberedSteps(item.konten);
            if (steps.isNotEmpty) {
              return _SectionCard(
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
                                    color: Color(0xFF2563EB)),
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
                                  height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          if (item.yangPerluDiingat.trim().isEmpty) ...[
            const SizedBox(height: 14),
            Builder(builder: (_) {
              final reminders = _parseReminders(item.konten);
              if (reminders.isEmpty) {
                return const SizedBox.shrink();
              }
              return _SectionCard(
                title: 'Yang Perlu Diingat',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reminders
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
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      item.isVideo ? Icons.play_circle_outline : Icons.menu_book_rounded,
      size: 84,
      color: item.isVideo ? const Color(0xFF3B82F6) : const Color(0xFFE2C499),
    );
  }

  List<String> _parseNumberedSteps(String text) {
    final regex = RegExp(r"^\s*\d+\.\s*(.+)", multiLine: true);
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty)
      return matches.map((m) => m.group(1)!.trim()).toList();

    // Fallback: look for short lines separated by newlines
    final lines = text.split(RegExp(r"\n{1,}"));
    final steps = <String>[];
    for (final l in lines) {
      final trimmed = l.trim();
      if (trimmed.length > 20 && trimmed.length < 160) steps.add(trimmed);
      if (steps.length >= 6) break;
    }
    return steps;
  }

  List<Map<String, String>> _parseSections(String text) {
    final parts = text.split(RegExp(r"\n\s*\n"));
    final sections = <Map<String, String>>[];
    for (final p in parts) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;
      final title = trimmed.split(RegExp(r"[\.!?\n]")).first;
      sections.add({
        "title": title.length > 40 ? title.substring(0, 40) + "..." : title,
        "body": trimmed
      });
      if (sections.length >= 6) break;
    }
    return sections;
  }

  List<String> _parseReminders(String text) {
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
      // fallback: use last short paragraphs
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

  List<String> _parseReminderItems(String text) {
    final lines = text
        .split(RegExp(r"\n+"))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r"^[-•*\d\.)\s]+"), ''))
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines : _parseReminders(text);
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
          fontWeight: FontWeight.w700,
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

class _AccordionSections extends StatefulWidget {
  final List<Map<String, String>> sections;
  const _AccordionSections({Key? key, required this.sections})
      : super(key: key);

  @override
  State<_AccordionSections> createState() => _AccordionSectionsState();
}

class _AccordionSectionsState extends State<_AccordionSections> {
  final List<bool> _open = [];

  @override
  void initState() {
    super.initState();
    _open.addAll(List.filled(widget.sections.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.sections.length, (i) {
        final s = widget.sections[i];
        return Column(
          children: [
            ListTile(
              onTap: () => setState(() => _open[i] = !_open[i]),
              contentPadding: EdgeInsets.zero,
              title: Text(s['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Icon(_open[i] ? Icons.expand_less : Icons.expand_more),
            ),
            if (_open[i])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(s['body'] ?? '',
                    style:
                        const TextStyle(color: Color(0xFF475569), height: 1.6)),
              ),
            if (i < widget.sections.length - 1) const Divider(height: 8),
          ],
        );
      }),
    );
  }
}
