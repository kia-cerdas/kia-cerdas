// input_catatan_pertumbuhan_screen.dart :
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/data/models/anak_search_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/models/pertumbuhan_model.dart';
import 'package:ta_pa2_pa3_project/features/anak/pertumbuhan/data/repositories/pertumbuhan_repository.dart';
import 'package:ta_pa2_pa3_project/features/anak/anak/presentation/widgets/child_info_banner.dart';

class InputCatatanPertumbuhanScreen extends StatefulWidget {
  final AnakSearchModel anak;
  final PertumbuhanRepository repository;

  const InputCatatanPertumbuhanScreen({
    Key? key,
    required this.anak,
    required this.repository,
  }) : super(key: key);

  @override
  State<InputCatatanPertumbuhanScreen> createState() =>
      _InputCatatanPertumbuhanScreenState();
}

class _InputCatatanPertumbuhanScreenState
    extends State<InputCatatanPertumbuhanScreen> {
  late DateTime _selectedDate;
  late TextEditingController _bbController;
  late TextEditingController _tbController;
  late TextEditingController _lkController;
  late TextEditingController _catatanController;

  bool _isSubmitting = false;
  double _calculatedIMT = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _selectedDate = DateTime.now();
    _bbController = TextEditingController();
    _tbController = TextEditingController();
    _lkController = TextEditingController();
    _catatanController = TextEditingController();

    _bbController.addListener(_calculateIMT);
    _tbController.addListener(_calculateIMT);
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
  }

  @override
  void dispose() {
    _bbController.dispose();
    _tbController.dispose();
    _lkController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _calculateIMT() {
    try {
      final bbText = _bbController.text.replaceAll(',', '.'); // Antisipasi koma
      final tbText = _tbController.text.replaceAll(',', '.');

      final bb = double.tryParse(bbText) ?? 0.0;
      final tb = double.tryParse(tbText) ?? 0.0;

      if (bb > 0 && tb > 0) {
        final tbMeter = tb / 100;
        final imt = bb / (tbMeter * tbMeter);
        setState(() {
          _calculatedIMT = imt;
        });
      } else {
        setState(() {
          _calculatedIMT = 0;
        });
      }
    } catch (e) {
      setState(() {
        _calculatedIMT = 0;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2563EB),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bb = double.parse(_bbController.text);
    final tb = double.parse(_tbController.text);
    final lk = double.tryParse(_lkController.text);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payload = CreatePertumbuhanRequest(
        anakId: widget.anak.id,
        tglUkur: DateFormat('yyyy-MM-dd').format(_selectedDate),
        beratBadan: bb,
        tinggiBadan: tb,
        lingkarKepala: lk,
        catatanNakes: _catatanController.text.isNotEmpty
            ? _catatanController.text
            : null,
      );

      await widget.repository.createCatatanPertumbuhan(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan pertumbuhan berhasil disimpan'),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Return true untuk refresh
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Input Catatan Pertumbuhan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child Info Banner
                ChildInfoBanner(
                  anak: widget.anak,
                  namaIbu: null,
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tanggal Pengukuran
                      const Text(
                        'Tanggal Pengukuran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('d MMMM yyyy', 'id_ID')
                                    .format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Berat Badan
                      const Text(
                        'Berat Badan (kg) *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bbController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 12.5',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'kg',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Berat badan tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          final bb = double.parse(value);
                          if (bb <= 0 || bb > 150) {
                            return 'Berat badan tidak masuk akal (0-150 kg)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Tinggi Badan
                      const Text(
                        'Tinggi/Panjang Badan (cm) *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tbController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 75.5',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'cm',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tinggi badan tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          final tb = double.parse(value);
                          if (tb <= 0 || tb > 250) {
                            return 'Tinggi badan tidak masuk akal (0-250 cm)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Lingkar Kepala
                      const Text(
                        'Lingkar Kepala (cm)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lkController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 46.5',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'cm',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Masukkan angka yang valid';
                            }
                            final lk = double.parse(value);
                            if (lk <= 0 || lk > 100) {
                              return 'Lingkar kepala tidak masuk akal (0-100 cm)';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // IMT Preview
                      if (_calculatedIMT > 0)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'IMT (Preview)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${_calculatedIMT.toStringAsFixed(2)} kg/m²',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_calculatedIMT > 0) const SizedBox(height: 20),

                      // Catatan Opsional
                      const Text(
                        'Catatan (Opsional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _catatanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Catat kondisi anak, perilaku, atau informasi lainnya...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                            ),
                          )
                        : const Text(
                            'Simpan Catatan Pertumbuhan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Batal
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
