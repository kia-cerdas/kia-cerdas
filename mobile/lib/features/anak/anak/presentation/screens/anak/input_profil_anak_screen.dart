import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class InputProfilAnakScreen extends StatefulWidget {
  const InputProfilAnakScreen({super.key});

  @override
  State<InputProfilAnakScreen> createState() => _InputProfilAnakScreenState();
}

class _InputProfilAnakScreenState extends State<InputProfilAnakScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();

  bool _forbiddenForIbu = false;

  String jenisKelamin = 'Laki-laki';
  String kondisi = 'Normal';

  double berat = 3.0;
  double panjang = 50.0;

  @override
  void initState() {
    super.initState();
    final role = AuthSession.role?.trim().toLowerCase();
    _forbiddenForIbu = role == 'ibu';
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2023, 10, 12),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        tanggalLahirController.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    tanggalLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_forbiddenForIbu) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("Tambah Profil Anak"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'Akses ditolak. Penambahan profil anak hanya dapat dilakukan oleh bidan.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Tambah Profil Anak"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FOTO
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 40),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Ubah Foto Anak"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// NAMA
              const Text("Nama Lengkap Anak"),
              const SizedBox(height: 6),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: "Masukkan nama anak",
                  filled: true,
                  fillColor: const Color(0xFFF1F3F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// JENIS KELAMIN
              const Text("Jenis Kelamin"),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _genderOption("Laki-laki")),
                  const SizedBox(width: 10),
                  Expanded(child: _genderOption("Perempuan")),
                ],
              ),

              const SizedBox(height: 16),

              /// TANGGAL LAHIR
              const Text("Tanggal Lahir"),
              const SizedBox(height: 6),
              TextField(
                controller: tanggalLahirController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: "Pilih tanggal",
                  suffixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// BERAT & PANJANG (NEW)
              Row(
                children: [
                  Expanded(
                    child: _numberInput(
                      title: "Berat Lahir (kg)",
                      value: berat,
                      onIncrement: () {
                        setState(() => berat += 0.1);
                      },
                      onDecrement: () {
                        if (berat > 0) {
                          setState(() => berat -= 0.1);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _numberInput(
                      title: "Panjang Lahir (cm)",
                      value: panjang,
                      onIncrement: () {
                        setState(() => panjang += 1);
                      },
                      onDecrement: () {
                        if (panjang > 0) {
                          setState(() => panjang -= 1);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// KONDISI
              const Text("Kondisi Saat Lahir"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: kondisi,
                items: const [
                  DropdownMenuItem(value: "Normal", child: Text("Normal")),
                  DropdownMenuItem(value: "Prematur", child: Text("Prematur")),
                ],
                onChanged: (value) {
                  setState(() {
                    kondisi = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F3F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print(namaController.text);
                    print(jenisKelamin);
                    print(tanggalLahirController.text);
                    print(berat);
                    print(panjang);
                    print(kondisi);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data anak berhasil disimpan (dummy)"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// GENDER
  Widget _genderOption(String value) {
    bool isSelected = jenisKelamin == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          jenisKelamin = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F80ED) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2F80ED) : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// NUMBER INPUT (+ -)
  Widget _numberInput({
    required String title,
    required double value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
