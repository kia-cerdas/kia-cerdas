import 'package:flutter/material.dart';

class DetailPertumbuhanScreenDummy extends StatelessWidget {
  final Map<String, dynamic> anak;

  const DetailPertumbuhanScreenDummy({
    super.key,
    required this.anak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anak["nama"],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Detail Pertumbuhan",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text("Grafik pertumbuhan nanti di sini"),
      ),
    );
  }
}