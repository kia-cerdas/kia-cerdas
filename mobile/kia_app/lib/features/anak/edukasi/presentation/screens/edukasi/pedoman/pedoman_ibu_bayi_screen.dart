import 'package:flutter/material.dart';

import 'pedoman_0_6_bulan_screen.dart';
import 'pedoman_6_12_bulan_screen.dart';
import 'pedoman_12_24_bulan_screen.dart';
import 'pedoman_2_6_tahun_screen.dart';

class PedomanIbuBayiScreen extends StatefulWidget {
  const PedomanIbuBayiScreen({Key? key}) : super(key: key);

  @override
  State<PedomanIbuBayiScreen> createState() => _PedomanIbuBayiScreenState();
}

class _PedomanIbuBayiScreenState extends State<PedomanIbuBayiScreen> {
  int selectedIndex = 0;

  final List<String> usiaList = [
    "0-6 Bulan",
    "6-12 Bulan",
    "12-24 Bulan",
    "2-6 Tahun",
  ];

  final List<Widget> pages = const [
    Pedoman06BulanScreen(),
    Pedoman612BulanScreen(),
    Pedoman1224BulanScreen(),
    Pedoman26TahunScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Pedoman ${usiaList[selectedIndex]}"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // FILTER USIA
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: usiaList.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: Text(
                        usiaList[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}