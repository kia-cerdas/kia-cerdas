import 'package:flutter/material.dart';

class CatatanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const CatatanDetailScreen({super.key, required this.data, this.title = 'Detail Catatan'});

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFF9CA3AF);
    final lower = status.toLowerCase();
    if (lower == 'normal' || lower.contains('rendah') || lower.contains('tidak')) {
      return const Color(0xFF10B981);
    } else if (lower.contains('perhatian') || lower.contains('sedang') || lower.contains('ada')) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF2F80ED),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF7B8798),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, String? status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF7B8798),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
              ),
              child: Text(
                status ?? '-',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is dental health record or general health record
    bool isDentalRecord = data.containsKey('jumlahGigi');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF172033)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === INFO DASAR ===
              _buildSection(
                'Informasi Dasar',
                [
                  _buildInfoRow('Tanggal', data['date']),
                  if (data.containsKey('kategoriUmur'))
                    _buildInfoRow('Kategori Usia', data['kategoriUmur']),
                  if (data.containsKey('bulanke'))
                    _buildInfoRow('Usia', '${data['bulanke']} bulan'),
                  if (data.containsKey('periode'))
                    _buildInfoRow('Periode', data['periode']),
                ],
              ),

              // === UNTUK CATATAN KESEHATAN ANAK (NON-GIGI) ===
              if (!isDentalRecord) ...[
                // Pemeriksaan Klinis
                _buildSection(
                  'Pemeriksaan Klinis',
                  [
                    _buildInfoRow('Jenis Pelayanan', data['jenis']),
                    _buildInfoRow('Lokasi', data['tempat']),
                    _buildInfoRow('Tenaga Kesehatan', data['tenaga']),
                    if (data.containsKey('bb') && data['bb'] != null)
                      _buildInfoRow('Berat Badan', data['bb']),
                    if (data.containsKey('tb') && data['tb'] != null)
                      _buildInfoRow('Tinggi Badan', data['tb']),
                    if (data.containsKey('lk') && data['lk'] != null)
                      _buildInfoRow('Lingkar Kepala', data['lk']),
                  ],
                ),

                // Status Pertumbuhan
                if (data.containsKey('bbU_status') || 
                    data.containsKey('tbU_status') ||
                    data.containsKey('imtU_status') ||
                    data.containsKey('bbTb_status') ||
                    data.containsKey('lkU_status'))
                  _buildSection(
                    'Status Pertumbuhan (WHO Z-Score)',
                    [
                      if (data.containsKey('bbU_status'))
                        _buildStatusBadge('BB menurut Usia (BB-U)', data['bbU_status']),
                      if (data.containsKey('tbU_status'))
                        _buildStatusBadge('TB menurut Usia (TB-U)', data['tbU_status']),
                      if (data.containsKey('imtU_status'))
                        _buildStatusBadge('IMT menurut Usia (IMT-U)', data['imtU_status']),
                      if (data.containsKey('bbTb_status'))
                        _buildStatusBadge('BB menurut TB (BB-TB)', data['bbTb_status']),
                      if (data.containsKey('lkU_status'))
                        _buildStatusBadge('Lingkar Kepala (LK-U)', data['lkU_status']),
                    ],
                  ),

                // Skrining Perkembangan
                if (data.containsKey('kpsp') || 
                    data.containsKey('mchat') ||
                    data.containsKey('actrs'))
                  _buildSection(
                    'Skrining Perkembangan',
                    [
                      if (data.containsKey('kpsp'))
                        _buildStatusBadge('KPSP (Usia 3-72 bulan)', data['kpsp']),
                      if (data.containsKey('mchat'))
                        _buildStatusBadge('M-CHAT Revised (16-30 bulan)', data['mchat']),
                      if (data.containsKey('actrs'))
                        _buildStatusBadge('ACTRS', data['actrs']),
                    ],
                  ),
              ],

              // === UNTUK CATATAN KESEHATAN GIGI ===
              if (isDentalRecord)
                _buildSection(
                  'Pemeriksaan Gigi',
                  [
                    _buildInfoRow('Jumlah Gigi', '${data['jumlahGigi']} gigi'),
                    _buildStatusBadge('Gigi Berlubang', '${data['gigiBerlubang']} gigi'),
                    _buildStatusBadge('Status Plak', data['statusPlak']),
                    _buildStatusBadge('Risiko Karies', data['resikoGigiBerlubang']),
                    _buildStatusBadge('Kondisi Umum', data['kondisi']),
                  ],
                ),

              // === CATATAN & REKOMENDASI (UNTUK SEMUA) ===
              _buildSection(
                'Catatan Klinis',
                [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data['catatan'] ?? '-',
                        style: const TextStyle(
                          color: Color(0xFF172033),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (data.containsKey('rekomendasi') && data['rekomendasi'] != null)
                _buildSection(
                  'Rekomendasi Tindak Lanjut',
                  [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F80ED).withOpacity(0.05),
                          border: Border.all(
                            color: const Color(0xFF2F80ED).withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data['rekomendasi'],
                          style: const TextStyle(
                            color: Color(0xFF172033),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              if (data.containsKey('tindakan') && data['tindakan'] != null)
                _buildSection(
                  'Tindakan',
                  [
                    _buildInfoRow('Tindakan', data['tindakan']),
                  ],
                ),

              // === ACTION BUTTONS ===
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur edit sedang dikembangkan')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF9CA3AF)),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          color: Color(0xFF172033),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
