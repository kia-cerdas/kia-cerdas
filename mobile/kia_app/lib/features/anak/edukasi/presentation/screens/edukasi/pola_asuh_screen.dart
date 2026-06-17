import 'package:flutter/material.dart';

class PolaAsuhScreen extends StatefulWidget {
  const PolaAsuhScreen({super.key});

  @override
  State<PolaAsuhScreen> createState() => _PolaAsuhScreenState();
}

class _PolaAsuhScreenState extends State<PolaAsuhScreen> {
  String selectedFilter = "0-18";

  final List<Map<String, String>> filters = [
    {"key": "0-18", "label": "0 - 18 Bulan"},
    {"key": "1.5-3", "label": "1,5 - 3 Tahun"},
    {"key": "3-6", "label": "3 - 6 Tahun"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          "Pola Asuh Anak",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // ✔️ FILTER BAR
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: filters.map((item) {
                final isActive = selectedFilter == item["key"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = item["key"]!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE55A4F)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      item["label"]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ✔️ CONTENT AREA
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    List<String> data = [];

    if (selectedFilter == "0-18") {
      data = [
        "ASI eksklusif sangat penting untuk bayi",
        "Stimulasi motorik dasar",
        "Tidur cukup untuk perkembangan otak"
      ];
    } else if (selectedFilter == "1.5-3") {
      data = [
        "Latih kemandirian anak",
        "Ajarkan komunikasi sederhana",
        "Batasi screen time"
      ];
    } else if (selectedFilter == "3-6") {
      data = [
        "Latih disiplin harian",
        "Dorong interaksi sosial",
        "Persiapan masuk sekolah"
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFE55A4F),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data[index],
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}