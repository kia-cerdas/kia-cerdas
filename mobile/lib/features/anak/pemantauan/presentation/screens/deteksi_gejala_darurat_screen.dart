import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/widgets/child_profile_card.dart';
import 'package:ta_pa2_pa3_project/features/anak/pemantauan/data/services/gejala_darurat_anak_api_service.dart';

class DeteksiGejalaDaruratScreen extends StatefulWidget {
  final Map<String, dynamic>? anak;

  const DeteksiGejalaDaruratScreen({super.key, this.anak});

  @override
  State<DeteksiGejalaDaruratScreen> createState() =>
      _DeteksiGejalaDaruratScreenState();
}

class _DeteksiGejalaDaruratScreenState extends State<DeteksiGejalaDaruratScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _tanggalPeriksa = DateTime.now();
  final GejalaDaruratAnakApiService _apiService = GejalaDaruratAnakApiService();

  bool _isLoading = false;
  bool _isLoadingRiwayat = false;

  final Map<String, String> _gejalaMap = {
    'Suhu di atas 39.5°C': 'suhu_c_lebih_39_5',
    'Suhu antara 38.5°C - 39.4°C': 'suhu_c_38_5_sd_39_4',
    'Demam lebih dari 3 hari': 'demam_hari_lebih_3',
    'Diare Berdarah': 'diare_berdarah',
    'Ada Tanda Dehidrasi (mata cekung, malas minum)': 'dehidrasi',
    'Diare lebih dari 5x sehari': 'diare_kali_hari_5',
    'Kejang': 'kejang',
    'Tidak Sadar / Lemas': 'tidak_sadar_lemas',
    'Napas Cepat / Sesak': 'napas_cepat_sesak',
    'Tidak mau minum / ASI': 'tidak_mau_minum_asi',
    'Ruam Menyebar': 'ruam_menyebar',
    'Kuning pada mata / kulit': 'kuning_sklera_kulit',
  };

  final Map<String, bool> _checks = {};
  List<dynamic> _riwayat = [];

  final Map<String, String> _reverseGejalaMap = {
    'suhu_c_lebih_39_5': 'Suhu di atas 39.5°C',
    'suhu_c_38_5_sd_39_4': 'Suhu antara 38.5°C - 39.4°C',
    'demam_hari_lebih_3': 'Demam lebih dari 3 hari',
    'diare_berdarah': 'Diare Berdarah',
    'dehidrasi': 'Ada Tanda Dehidrasi (mata cekung, malas minum)',
    'diare_kali_hari_5': 'Diare lebih dari 5x sehari',
    'kejang': 'Kejang',
    'tidak_sadar_lemas': 'Tidak Sadar / Lemas',
    'napas_cepat_sesak': 'Napas Cepat / Sesak',
    'tidak_mau_minum_asi': 'Tidak mau minum / ASI',
    'ruam_menyebar': 'Ruam Menyebar',
    'kuning_sklera_kulit': 'Kuning pada mata / kulit',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    for (var key in _gejalaMap.keys) {
      _checks[key] = false;
    }

    _loadRiwayat();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      _loadRiwayat();
    }
  }

  Future<void> _loadRiwayat() async {
    if (widget.anak == null) return;
    final anakIdRaw = widget.anak!['id'];
    final anakId =
        anakIdRaw is int ? anakIdRaw : int.tryParse(anakIdRaw.toString()) ?? 0;

    if (anakId <= 0) return;

    setState(() {
      _isLoadingRiwayat = true;
    });

    try {
      final riwayat = await _apiService.getRiwayat(anakId);
      if (mounted) {
        setState(() {
          _riwayat = riwayat;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat riwayat: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRiwayat = false;
        });
      }
    }
  }

  Future<void> _evaluasiGejala() async {
    final anakIdRaw = widget.anak?['id'];
    final anakId = anakIdRaw is int
        ? anakIdRaw
        : int.tryParse(anakIdRaw?.toString() ?? '0') ?? 0;

    if (anakId <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data anak tidak valid')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> daftarGejala = [];
      _checks.forEach((label, value) {
        daftarGejala.add({
          'kode_gejala': _gejalaMap[label]!,
          'is_terjadi': value,
        });
      });

      final responseData = await _apiService.submitDeteksi(
        anakId: anakId,
        tanggalPeriksa: _formatDate(_tanggalPeriksa),
        daftarGejala: daftarGejala,
      );

      final bobot = responseData['total_bobot_max'] as int;
      final tindakanString = responseData['tindakan'] as String;
      final List<String> tindakanList = tindakanString.split(' | ');

      String statusFinal = 'Normal';
      if (bobot == 3) {
        statusFinal = 'Darurat';
      } else if (bobot == 2) {
        statusFinal = 'Perlu Periksa';
      } else if (bobot == 1) {
        statusFinal = 'Pantau';
      }

      if (mounted) {
        _showResultDialog(statusFinal, tindakanList, bobot);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showResultDialog(String status, List<String> tindakan, int bobot) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (bobot == 3) {
      statusColor = const Color(0xFFA32D2D); // Red
      statusIcon = Icons.crisis_alert_rounded;
      statusTitle = 'DARURAT!';
    } else if (bobot == 2) {
      statusColor = const Color(0xFFBA7517); // Orange
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = 'PERLU PERIKSA';
    } else {
      statusColor = const Color(0xFF0F6E56); // Green
      statusIcon = Icons.check_circle_outline_rounded;
      statusTitle = 'NORMAL / PANTAU';
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tindakan yang Disarankan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tindakan
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.arrow_right_rounded,
                                        color: statusColor, size: 20),
                                    Expanded(
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: statusColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetForm();
                        _tabController.animateTo(1); // Go to history
                        _loadRiwayat(); // reload explicitly to get the new backend data
                      },
                      child: const Text('Tutup & Lihat Riwayat',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void _resetForm() {
    setState(() {
      _checks.updateAll((key, value) => false);
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deteksi Gejala Darurat',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Pemantauan gejala darurat balita',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF185FA5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF185FA5),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Isi Gejala'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildRiwayatTab(),
        ],
      ),
      bottomNavigationBar: _tabController.index == 0 ? _buildSubmitBar() : null,
    );
  }

  Widget _buildFormTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _buildAnakInfoCard(),
        const SizedBox(height: 12),
        _buildFormCard(),
        const SizedBox(height: 16),
        _buildGejalaCard(),
      ],
    );
  }

  Widget _buildSubmitBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setelah selesai mengisi, tap Simpan agar data tersimpan.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _evaluasiGejala,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnakInfoCard() {
    final nama = (widget.anak?['nama'] ?? 'Anak terpilih').toString();
    final usia =
        (widget.anak?['usia_teks'] ?? 'Usia belum tersedia').toString();

    return ChildProfileCard(nama: nama, usia: usia);
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  'Tanggal Periksa: ${_formatDate(_tanggalPeriksa)}',
                  style: const TextStyle(color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGejalaCard() {
    final checkedCount = _checks.values.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checklist Gejala ($checkedCount dipilih)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ..._checks.keys.map(
            (gejala) => CheckboxListTile(
              value: _checks[gejala] ?? false,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(gejala),
              onChanged: (value) {
                setState(() {
                  _checks[gejala] = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab() {
    if (_isLoadingRiwayat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_riwayat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat deteksi',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _riwayat.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _riwayat[index];
        final date =
            DateTime.tryParse(item['tanggal_periksa'] ?? '') ?? DateTime.now();
        final dateString = '${date.day}-${date.month}-${date.year}';

        final bobot = item['total_bobot_max'] as int? ?? 0;
        final tindakan = item['tindakan'] as String? ?? '';
        final tindakanList = tindakan.split(' | ');

        String status = 'NORMAL';
        if (bobot == 3) {
          status = 'DARURAT';
        } else if (bobot == 2) {
          status = 'PERLU PERIKSA';
        } else if (bobot == 1) {
          status = 'PANTAU';
        }

        Color color;
        IconData icon;
        if (bobot == 3) {
          color = const Color(0xFFA32D2D);
          icon = Icons.crisis_alert_rounded;
        } else if (bobot == 2) {
          color = const Color(0xFFBA7517);
          icon = Icons.warning_amber_rounded;
        } else {
          color = const Color(0xFF0F6E56);
          icon = Icons.check_circle_outline_rounded;
        }

        final detailJawaban = item['detail_jawaban'] as List<dynamic>? ?? [];
        final gejalaTerpilihRaw = detailJawaban
            .where((d) => d['is_terjadi'] == true)
            .map((d) => d['kode_gejala'] as String)
            .toList();
        final gejalaTerpilih = gejalaTerpilihRaw
            .map((k) => _reverseGejalaMap[k] ?? k)
            .toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bobot == 3 ? 'Kritis' : (bobot == 2 ? 'Peringatan' : 'Aman'),
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text('Tanggal: $dateString', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.checklist, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text('Gejala terpilih: ${gejalaTerpilih.length} item', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gejala yang ditemukan:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    ...gejalaTerpilih.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${e.key + 1}. ${e.value}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                        ),
                      );
                    }),
                    if (gejalaTerpilih.isEmpty)
                      const Text('Tidak ada gejala', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tindakan: ${tindakanList.join(", ")}',
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
