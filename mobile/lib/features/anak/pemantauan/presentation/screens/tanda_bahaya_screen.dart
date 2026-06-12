import 'package:flutter/material.dart';

class TandaBahayaScreen extends StatefulWidget {
  const TandaBahayaScreen({Key? key}) : super(key: key);

  @override
  State<TandaBahayaScreen> createState() => _TandaBahayaScreenState();
}

class _TandaBahayaScreenState extends State<TandaBahayaScreen> {
  final Map<String, bool> _gejala0_28 = {
    'Tidak mau menyusu': false,
    'Kejang': false,
    'Sesak napas': false,
    'Tali pusat kemerahan / bernanah': false,
    'Mata bernanah': false,
    'Demam / Panas tinggi': false,
  }; // Diambil dari panduan buku KIA

  final Map<String, bool> _gejalaBalita = {
    'Demam tinggi': false,
    'Diare': false,
    'Kejang': false,
    'Muntah-muntah': false,
    'Sesak napas': false,
    'Pendarahan (hidung/kulit/BAB)': false,
  }; // Diambil dari panduan buku KIA

  void _submitSkrining(Map<String, bool> data) {
    bool hasBahaya = data.values.any((element) => element == true);

    if (hasBahaya) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFFFEF2F2),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('PERINGATAN!', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: const Text(
            'Terdapat tanda bahaya pada anak Anda. Segera bawa anak ke fasilitas pelayanan kesehatan / Puskesmas terdekat!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada tanda bahaya. Tetap pantau kesehatan anak.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skrining Tanda Bahaya', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: '0 - 28 Hari'),
              Tab(text: '29 Hari - 5 Thn'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListGejala(_gejala0_28),
            _buildListGejala(_gejalaBalita),
          ],
        ),
      ),
    );
  }

  Widget _buildListGejala(Map<String, bool> gejalaMap) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: gejalaMap.keys.map((gejala) {
              return CheckboxListTile(
                title: Text(gejala),
                value: gejalaMap[gejala],
                activeColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    gejalaMap[gejala] = val ?? false;
                  });
                },
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _submitSkrining(gejalaMap),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cek Hasil Skrining', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        )
      ],
    );
  }
}