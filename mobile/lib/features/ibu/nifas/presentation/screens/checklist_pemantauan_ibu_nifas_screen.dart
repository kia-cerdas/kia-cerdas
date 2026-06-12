import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import 'package:ta_pa2_pa3_project/features/ibu/hamil/data/services/kehamilan_api_service.dart';

import '../../data/models/checklist_pemantauan_ibu_nifas_model.dart';
import '../../data/repositories/checklist_pemantauan_ibu_nifas_repository.dart';
import '../../data/services/checklist_pemantauan_ibu_nifas_service.dart';

class ChecklistPemantauanIbuNifasScreen
    extends StatefulWidget {
  final List<int> filledDays;

  const ChecklistPemantauanIbuNifasScreen({
    super.key,
    this.filledDays = const [],
  });

  @override
  State<ChecklistPemantauanIbuNifasScreen>
      createState() =>
          _ChecklistPemantauanIbuNifasScreenState();
}

class _ChecklistPemantauanIbuNifasScreenState
    extends State<
        ChecklistPemantauanIbuNifasScreen> {
  final _kehamilanService =
      KehamilanApiService();

  late ChecklistPemantauanIbuNifasRepository
      repository;

  final TextEditingController
      keluhanController =
      TextEditingController();

  int? selectedHariNifas;

  bool isLoading = false;

  bool pemeriksaanNifas = false;
  bool konsumsiVitaminA = false;
  bool pemenuhanGizi = false;
  bool demamLebih38 = false;
  bool sakitKepala = false;
  bool pandanganKabur = false;
  bool nyeriUluHati = false;
  bool masalahKesehatanJiwa = false;

  bool jantungBerdebar = false;
  bool cairanJalanLahir = false;
  bool napasPendek = false;
  bool payudaraBermasalah = false;
  bool gangguanBak = false;
  bool kelaminBermasalah = false;
  bool darahNifasBerbau = false;
  bool pendarahanBerat = false;
  bool keputihan = false;

  @override
  void initState() {
    super.initState();

    repository =
        ChecklistPemantauanIbuNifasRepository(
      ChecklistPemantauanIbuNifasService(),
    );
  }

  @override
  void dispose() {
    keluhanController.dispose();
    super.dispose();
  }

  Future<void> submitChecklist() async {
    if (isLoading) return;

    if (selectedHariNifas == null) {
      _showError(
        'Pilih hari nifas terlebih dahulu',
      );
      return;
    }

    if (widget.filledDays.contains(
      selectedHariNifas,
    )) {
      _showError(
        'Hari nifas ke-$selectedHariNifas sudah diisi',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = AuthSession.token;

      if (token == null ||
          token.isEmpty) {
        _showError(
          'Silakan login ulang',
        );
        return;
      }

      final kehamilan =
          await _kehamilanService
              .getKehamilanAktif();

      final model =
          ChecklistPemantauanIbuNifasModel(
        kehamilanId: kehamilan.id,
        hariNifas:
            selectedHariNifas!,

        pemeriksaanNifas:
            pemeriksaanNifas,
        konsumsiVitaminA:
            konsumsiVitaminA,
        pemenuhanGizi:
            pemenuhanGizi,
        demamLebih38:
            demamLebih38,
        sakitKepala:
            sakitKepala,
        pandanganKabur:
            pandanganKabur,
        nyeriUluHati:
            nyeriUluHati,
        masalahKesehatanJiwa:
            masalahKesehatanJiwa,

        jantungBerdebar:
            jantungBerdebar,
        cairanJalanLahir:
            cairanJalanLahir,
        napasPendek:
            napasPendek,
        payudaraBermasalah:
            payudaraBermasalah,
        gangguanBak:
            gangguanBak,
        kelaminBermasalah:
            kelaminBermasalah,
        darahNifasBerbau:
            darahNifasBerbau,
        pendarahanBerat:
            pendarahanBerat,
        keputihan:
            keputihan,

        keluhan:
            keluhanController.text
                .trim(),
      );

      await repository.createChecklist(
        token: token,
        model: model,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Checklist berhasil disimpan',
          ),
          backgroundColor:
              Colors.green.shade600,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showError(
        'Terjadi kesalahan: $e',
      );
    } finally {
      if (mounted) {
        setState(
          () => isLoading = false,
        );
      }
    }
  }

  void _resetChecklist() {
    pemeriksaanNifas = false;
    konsumsiVitaminA = false;
    pemenuhanGizi = false;
    demamLebih38 = false;
    sakitKepala = false;
    pandanganKabur = false;
    nyeriUluHati = false;
    masalahKesehatanJiwa = false;

    jantungBerdebar = false;
    cairanJalanLahir = false;
    napasPendek = false;
    payudaraBermasalah = false;
    gangguanBak = false;
    kelaminBermasalah = false;
    darahNifasBerbau = false;
    pendarahanBerat = false;
    keputihan = false;

    keluhanController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        title: const Text(
          'Pemantauan Ibu Nifas',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _headerCard(),

            const SizedBox(height: 18),

            _daySelector(),

            const SizedBox(height: 18),

            if (selectedHariNifas !=
                null)
              _checklistForm(),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary
                .withOpacity(0.8),
          ],
        ),

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.health_and_safety,
            color: Colors.white,
            size: 38,
          ),

          const SizedBox(height: 14),

          const Text(
            'Checklist Harian Masa Nifas',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            selectedHariNifas == null
                ? 'Pilih hari nifas'
                : 'Hari nifas ke-$selectedHariNifas',

            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySelector() {
    return _containerCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Pilih Hari Nifas',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            child: Row(
              children: List.generate(
                42,
                (index) {
                  final day =
                      index + 1;

                  final selected =
                      selectedHariNifas ==
                          day;

                  final filled =
                      widget.filledDays
                          .contains(day);

                  return GestureDetector(
                    onTap:
                        filled ||
                                isLoading
                            ? null
                            : () {
                                setState(() {
                                  selectedHariNifas =
                                      day;

                                  _resetChecklist();
                                });
                              },

                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 200,
                      ),

                      margin:
                          const EdgeInsets.only(
                        right: 10,
                      ),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      decoration:
                          BoxDecoration(
                        color: filled
                            ? Colors.green
                                .shade50
                            : selected
                                ? AppColors
                                    .primary
                                : Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border: Border.all(
                          color: filled
                              ? Colors.green
                              : selected
                                  ? AppColors
                                      .primary
                                  : Colors.grey
                                      .shade300,
                        ),
                      ),

                      child: Text(
                        'H-$day',

                        style: TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,

                          color: filled
                              ? Colors.green
                              : selected
                                  ? Colors.white
                                  : Colors
                                      .black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistForm() {
    return Column(
      children: [
        _buildExpansionSection(
          title: 'NIFAS A',
          icon:
              Icons.favorite_outline,
          children: [
            _checkItem(
              'Pemeriksaan nifas',
              pemeriksaanNifas,
              (v) => setState(
                () =>
                    pemeriksaanNifas =
                        v,
              ),
            ),

            _checkItem(
              'Konsumsi vitamin A',
              konsumsiVitaminA,
              (v) => setState(
                () =>
                    konsumsiVitaminA =
                        v,
              ),
            ),

            _checkItem(
              'Pemenuhan gizi',
              pemenuhanGizi,
              (v) => setState(
                () =>
                    pemenuhanGizi =
                        v,
              ),
            ),

            _checkItem(
              'Demam > 38°C',
              demamLebih38,
              (v) => setState(
                () =>
                    demamLebih38 =
                        v,
              ),
            ),

            _checkItem(
              'Sakit kepala',
              sakitKepala,
              (v) => setState(
                () =>
                    sakitKepala = v,
              ),
            ),

            _checkItem(
              'Pandangan kabur',
              pandanganKabur,
              (v) => setState(
                () =>
                    pandanganKabur =
                        v,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        _buildExpansionSection(
          title: 'NIFAS B',
          icon: Icons.monitor_heart,

          children: [
            _checkItem(
              'Jantung berdebar',
              jantungBerdebar,
              (v) => setState(
                () =>
                    jantungBerdebar =
                        v,
              ),
            ),

            _checkItem(
              'Cairan jalan lahir',
              cairanJalanLahir,
              (v) => setState(
                () =>
                    cairanJalanLahir =
                        v,
              ),
            ),

            _checkItem(
              'Napas pendek',
              napasPendek,
              (v) => setState(
                () =>
                    napasPendek = v,
              ),
            ),

            _checkItem(
              'Payudara bermasalah',
              payudaraBermasalah,
              (v) => setState(
                () =>
                    payudaraBermasalah =
                        v,
              ),
            ),

            _checkItem(
              'Gangguan BAK',
              gangguanBak,
              (v) => setState(
                () =>
                    gangguanBak = v,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _containerCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Keluhan Tambahan',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                    keluhanController,

                maxLines: 4,

                decoration:
                    InputDecoration(
                  hintText:
                      'Tuliskan keluhan tambahan...',

                  filled: true,

                  fillColor:
                      AppColors.primary
                          .withOpacity(
                    0.05,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 54,

          child:
              ElevatedButton.icon(
            onPressed:
                isLoading
                    ? null
                    : submitChecklist,

            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                  ),

            label: Text(
              isLoading
                  ? 'Menyimpan...'
                  : 'Simpan Checklist',
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,

              foregroundColor:
                  Colors.white,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return _containerCard(
      child: ExpansionTile(
        initiallyExpanded: true,

        tilePadding:
            EdgeInsets.zero,

        childrenPadding:
            EdgeInsets.zero,

        leading: Icon(
          icon,
          color: AppColors.primary,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 18,
            color:
                AppColors.primary,
          ),
        ),

        children: children,
      ),
    );
  }

  Widget _containerCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  Widget _checkItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      value: value,

      onChanged:
          isLoading
              ? null
              : (v) =>
                  onChanged(
                    v ?? false,
                  ),

      activeColor:
          AppColors.primary,

      contentPadding:
          EdgeInsets.zero,

      controlAffinity:
          ListTileControlAffinity
              .leading,

      title: Text(
        title,
        style: const TextStyle(
          fontWeight:
              FontWeight.w500,
        ),
      ),
    );
  }
}