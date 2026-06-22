import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/models/imunisasi_model.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/data/services/imunisasi_service.dart';

class UbahJadwalScreen extends StatefulWidget {
  final int jadwalId;

  const UbahJadwalScreen({
    super.key,
    required this.jadwalId,
  });

  @override
  State<UbahJadwalScreen> createState() => _UbahJadwalScreenState();
}

class _UbahJadwalScreenState extends State<UbahJadwalScreen> {
  final service = ImunisasiService();

  bool isLoading = true;
  bool isSubmitting = false;

  ImunisasiDetailModel? data;

  List<JadwalLayananModel> jadwalLayanan = [];

  JadwalLayananModel? selectedJadwal;

  DateTime? selectedDate;
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController alasanController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    tanggalController.dispose();
    alasanController.dispose();
    super.dispose();
  }


  Future<void> fetchData() async {
    try {
      final result = await service.getJadwalImunisasiById(
        widget.jadwalId,
      );

      final layanan = await service.getJadwalLayananUpcoming();

      final jadwalItem = result.jadwal.isNotEmpty ? result.jadwal.first : null;

      setState(() {
        data = result;
        jadwalLayanan = layanan;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> _pickDate() async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? today.add(const Duration(days: 1)),
    firstDate: today.add(const Duration(days: 1)),  // tidak bisa pilih hari ini atau sebelumnya
    lastDate: DateTime(today.year + 2),
  );

  if (picked != null) {
    setState(() {
      selectedDate = picked;
      tanggalController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
    });
  }
}


  Future<void> submitRequestPerubahan() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal baru terlebih dahulu")),
      );
      return;
    }


    if (alasanController.text.isEmpty) {
      debugPrint("❌ alasan kosong");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alasan tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

final tanggalBaru = DateFormat('yyyy-MM-dd').format(selectedDate!);
    setState(() => isSubmitting = true);

    try {
      await service.requestPerubahanJadwal(
        widget.jadwalId,
        tanggalBaru,
        alasanController.text,
      );
      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request berhasil dikirim"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("❌ ERROR REQUEST: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengirim request"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isSubmitting = false);
  }

  // ================= STATUS COLOR =================
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mendekati':
        return Colors.orange;
      case 'jatuh tempo':
        return Colors.blue;
      case 'terlewat':
        return Colors.red;
      case 'terlambat':
        return Colors.deepOrange;
      case 'krisis':
        return Colors.red;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget statusChip(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jadwalItem =
        (data?.jadwal.isNotEmpty ?? false) ? data!.jadwal.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ubah Jadwal Imunisasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (data == null || jadwalItem == null)
              ? const Center(child: Text("Data tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ================= CARD DATA =================
                      _buildCard(
                        title: "Data Anak",
                        children: [
                          _buildItem(Icons.person, "Nama Anak", data!.namaAnak),
                          _buildItem(
                              Icons.vaccines, "Dosis", jadwalItem.namaDosis),
                          Row(
                            children: [
                              const Icon(Icons.info,
                                  size: 18, color: Color(0xFF64748B)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  statusChip(jadwalItem.status),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ================= EDIT DATE =================
                      
_buildCard(
  title: "Ubah Tanggal Estimasi",
  children: [
    GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: tanggalController,
          decoration: InputDecoration(
            labelText: "Pilih Tanggal Baru",
            hintText: "Ketuk untuk memilih tanggal",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.calendar_today,
                color: Color(0xFF2563EB)),
            suffixIcon: const Icon(Icons.arrow_drop_down,
                color: Color(0xFF64748B)),
          ),
        ),
      ),
    ),
    if (selectedDate != null)
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          "Tanggal dipilih: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate!)}",
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
  ],
),

                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: TextField(
                          controller: alasanController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Tulis alasan perubahan jadwal...",
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.edit_note,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isSubmitting ? null : submitRequestPerubahan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            disabledBackgroundColor:
                                const Color(0xFF2563EB).withOpacity(0.6),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSubmitting
                                ? Row(
                                    key: const ValueKey("loading"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Memproses...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Ajukan Perubahan",
                                    key: ValueKey("text"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= INFO TEXT =================
                      const Text(
                        "Setelah tap tombol ajukan, jadwal susulan akan dikirim ke bidan untuk diproses.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
