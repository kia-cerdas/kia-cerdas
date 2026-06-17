// lib/features/ibu/hamil/presentation/screens/rujukan_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/themes/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class RujukanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const RujukanDetailScreen({
    super.key,
    required this.data,
  });

  String _value(String key) {
    final value = data[key];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return "-";
    }

    return value.toString();
  }

  String _dateText(String key) {
    final value = data[key];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return "-";
    }

    return value
        .toString()
        .split("T")
        .first;
  }

  // =====================================
  // KONFIRMASI HUBUNGI BIDAN
  // =====================================

// =====================================
// KONFIRMASI HUBUNGI BIDAN
// =====================================

Future<void> _showContactConfirmation(
  BuildContext context,
) async {

  const String namaBidan =
      "Bidan Desa";

  const String nomorBidan =
      "0812-6482-5931";

  final result =
      await showModalBottomSheet<String>(
    context: context,

    backgroundColor: Colors.transparent,

    builder: (_) {

      return Container(
        padding: const EdgeInsets.all(22),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),

          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,

            children: [

              // HANDLE
              Container(
                width: 46,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,

                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              // ICON
              Container(
                width: 72,
                height: 72,

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.support_agent,
                  color: Colors.green.shade600,
                  size: 36,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Hubungi Bidan",

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Ibu akan dihubungkan ke $namaBidan untuk mendapatkan bantuan dan arahan lebih lanjut.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                nomorBidan,

                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // WHATSAPP
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade600,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(
                      context,
                      "wa",
                    );
                  },

                  icon: const Icon(
                    Icons.chat,
                  ),

                  label: const Text(
                    "Chat via WhatsApp",

                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // TELEPON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors.primary,

                    side: BorderSide(
                      color:
                          AppColors.primary,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(
                      context,
                      "call",
                    );
                  },

                  icon: const Icon(
                    Icons.call_outlined,
                  ),

                  label: const Text(
                    "Telepon Bidan",

                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,

                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.blueGrey.shade50,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: Text(
                    "Batal",

                    style: TextStyle(
                      color:
                          Colors.blueGrey.shade500,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
              ),
          ),
        ),
      );
    },
  );

  // =====================================
  // AKSI SETELAH PILIH
  // =====================================

  if (result == "wa") {

    final Uri url = Uri.parse(
      'https://wa.me/6281264825931',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  if (result == "call") {

    final Uri url = Uri(
      scheme: 'tel',
      path: '081264825931',
    );

    await launchUrl(url);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),

      appBar: AppBar(
        title: const Text(
          "Detail Rujukan",
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(18),

        children: [

          // =====================================
          // HEADER CARD
          // =====================================

          Container(
            padding:
                const EdgeInsets.all(
                    22),

            decoration: BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  AppColors.primary,
                  Colors.blue.shade400,
                ],

                begin:
                    Alignment.topLeft,

                end: Alignment
                    .bottomRight,
              ),

              borderRadius:
                  BorderRadius.circular(
                      24),

              boxShadow: [
                BoxShadow(
                  color: Colors.blue
                      .withValues(
                          alpha: 0.18),

                  blurRadius: 14,

                  offset:
                      const Offset(
                          0, 6),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Container(
                  padding:
                      const EdgeInsets
                          .all(12),

                  decoration:
                      BoxDecoration(
                    color: Colors
                        .white
                        .withValues(
                            alpha:
                                0.15),

                    borderRadius:
                        BorderRadius
                            .circular(
                                16),
                  ),

                  child: const Icon(
                    Icons
                        .description_outlined,

                    color:
                        Colors.white,

                    size: 30,
                  ),
                ),

                const SizedBox(
                    height: 18),

                const Text(
                  "Surat Rekomendasi Rujukan",

                  style: TextStyle(
                    color:
                        Colors.white,

                    fontSize: 21,

                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 8),

                const Text(
                  "Berikut adalah informasi rujukan dan anjuran dari tenaga kesehatan untuk membantu Ibu mendapatkan penanganan yang sesuai.",

                  style: TextStyle(
                    color: Colors
                        .white70,

                    fontSize: 13.5,

                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================================
          // KONTAK TINDAK LANJUT
          // =====================================

          Container(
            padding:
                const EdgeInsets.all(
                    18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                      22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                          alpha:
                              0.04),

                  blurRadius: 10,

                  offset:
                      const Offset(
                          0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Row(
                  children: [

                    Icon(
                      Icons
                          .support_agent,

                      color:
                          AppColors
                              .primary,

                      size: 20,
                    ),

                    const SizedBox(
                        width: 8),

                    Text(
                      "Kontak Tindak Lanjut",

                      style:
                          TextStyle(
                        fontSize: 15,

                        fontWeight:
                            FontWeight
                                .bold,

                        color:
                            AppColors
                                .primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 12),

                Text(
                  "Ibu tidak perlu panik. Silakan hubungi bidan atau tenaga kesehatan untuk mendapatkan arahan dan bantuan lebih lanjut.",

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors
                        .grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                    height: 18),

                SizedBox(
                  width:
                      double.infinity,

                  height: 52,

                  child:
                      ElevatedButton
                          .icon(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AppColors
                              .primary,

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                    ),

                    onPressed: () {
                      _showContactConfirmation(
                        context,
                      );
                    },

                    icon: const Icon(
                      Icons.call,
                    ),

                    label: const Text(
                      "Hubungi Bidan Sekarang",

                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 12),

                Center(
                  child: Text(
                    "Nomor Bidan: 0812-6482-5931",

                    style: TextStyle(
                      fontSize: 12,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================================
          // INFORMASI RUJUKAN
          // =====================================

          _section(
            title:
                "Informasi Rujukan",

            icon: Icons
                .medical_information_outlined,
          ),

          _infoCard(
            label:
                "Resume pemeriksaan / tatalaksana",

            value: _value(
              "rujukan_resume_pemeriksaan_tatalaksana",
            ),
          ),

          _infoCard(
            label:
                "Diagnosis akhir",

            value: _value(
              "rujukan_diagnosis_akhir",
            ),
          ),

          _infoCard(
            label:
                "Alasan dirujuk ke FKRTL",

            value: _value(
              "rujukan_alasan_dirujuk_ke_fkrtl",
            ),
          ),

          // =====================================
          // RUJUKAN BALIK
          // =====================================

          const SizedBox(height: 10),

          _section(
            title:
                "Rujukan Balik",

            icon: Icons
                .assignment_return_outlined,
          ),

          _infoCard(
            label:
                "Tanggal rujukan balik",

            value: _dateText(
              "rujukan_balik_tanggal",
            ),
          ),

          _infoCard(
            label:
                "Diagnosis akhir rujukan balik",

            value: _value(
              "rujukan_balik_diagnosis_akhir",
            ),
          ),

          _infoCard(
            label:
                "Resume pemeriksaan / tatalaksana rujukan balik",

            value: _value(
              "rujukan_balik_resume_pemeriksaan_tatalaksana",
            ),
          ),

          // =====================================
          // ANJURAN
          // =====================================

          const SizedBox(height: 10),

          _section(
            title: "Anjuran",
            icon:
                Icons.favorite_outline,
          ),

          _infoCard(
            label:
                "Rekomendasi tempat melahirkan",

            value: _value(
              "anjuran_rekomendasi_tempat_melahirkan",
            ),
          ),

          const SizedBox(height: 20),

          // =====================================
          // FOOTER INFO
          // =====================================

          Container(
            padding:
                const EdgeInsets.all(
                    16),

            decoration: BoxDecoration(
              color:
                  Colors.blue.shade50,

              borderRadius:
                  BorderRadius.circular(
                      18),

              border: Border.all(
                color: Colors
                    .blue.shade100,
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Icon(
                  Icons.info_outline,
                  color:
                      AppColors.primary,
                  size: 22,
                ),

                const SizedBox(
                    width: 10),

                Expanded(
                  child: Text(
                    "Jika Ibu memiliki keluhan atau kondisi memburuk, segera hubungi tenaga kesehatan atau fasilitas kesehatan terdekat.",

                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors
                          .grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =====================================
  // SECTION TITLE
  // =====================================

  Widget _section({
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 20,
            color:
                AppColors.primary,
          ),

          const SizedBox(width: 8),

          Text(
            title,

            style: TextStyle(
              color:
                  AppColors.primary,

              fontWeight:
                  FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // INFO CARD
  // =====================================

  Widget _infoCard({
    required String label,
    required String value,
  }) {

    final bool isEmptyValue =
        value.trim() == "-" ||
        value.trim().isEmpty;

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
                    alpha: 0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Text(
            label,

            style: TextStyle(
              fontSize: 12.5,

              color: Colors
                  .grey.shade600,

              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
              height: 10),

          Text(
            isEmptyValue
                ? "Belum ada informasi tersedia"
                : value,

            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,

              color:
                  isEmptyValue
                      ? Colors.grey
                          .shade500
                      : Colors.black87,

              fontStyle:
                  isEmptyValue
                      ? FontStyle
                          .italic
                      : FontStyle
                          .normal,
            ),
          ),
        ],
      ),
    );
  }
}