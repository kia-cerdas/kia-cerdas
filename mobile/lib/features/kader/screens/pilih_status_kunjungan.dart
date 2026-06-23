import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/models/kunjungan_model.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/daftar_kunjungan.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/kunjungan_by_status.dart';

class PilihStatusKunjunganScreen extends StatefulWidget {
  const PilihStatusKunjunganScreen({
    super.key,
  });

  @override
  State<PilihStatusKunjunganScreen> createState() =>
      _PilihStatusKunjunganScreenState();
}

class _PilihStatusKunjunganScreenState
    extends State<PilihStatusKunjunganScreen> {
  final KunjunganImunisasiService _service = KunjunganImunisasiService();

  late Future<List<StatusKunjunganCountModel>> _statusFuture;

  @override
  void initState() {
    super.initState();

    _statusFuture = _service.getJumlahKunjunganByStatus();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Status Kunjungan Imunisasi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1.0,
          ),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<List<StatusKunjunganCountModel>>(
        future: _statusFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Gagal memuat status kunjungan',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _statusFuture = _service.getJumlahKunjunganByStatus();
                        });
                      },
                      child: const Text(
                        'Coba Lagi',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final statusList =
              snapshot.data ?? const <StatusKunjunganCountModel>[];

          if (statusList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(
                  24,
                ),
                child: Text(
                  'Belum ada data status kunjungan.',
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(
              16,
            ),
            itemCount: statusList.length,
            itemBuilder: (
              context,
              index,
            ) {
              final status = statusList[index];

              return _buildItem(
                context,
                status,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    StatusKunjunganCountModel status,
  ) {
    final config = _getStatusConfig(
      status.statusKunjungan,
    );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: _HoverStatusCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KunjunganByStatusScreen(
                statusId: status.statusId,
                statusName: status.statusKunjungan,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: config.color.withOpacity(
                0.15,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: config.color.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  config.icon,
                  color: config.color,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.statusKunjungan,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(
                          0xFF1E293B,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      '${status.jumlahKunjungan} kunjungan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(
    String status,
  ) {
    switch (status.toLowerCase().trim()) {
      case 'terjadwal':
        return _StatusConfig(
          color: const Color(
            0xFFF59E0B,
          ),
          icon: Icons.calendar_month_rounded,
        );

      case 'perlu tindak lanjut':
        return _StatusConfig(
          color: const Color(
            0xFFEF4444,
          ),
          icon: Icons.medical_services_rounded,
        );

      case 'selesai':
        return _StatusConfig(
          color: const Color(
            0xFF10B981,
          ),
          icon: Icons.check_circle_rounded,
        );

      case 'dibatalkan':
        return _StatusConfig(
          color: const Color(
            0xFF64748B,
          ),
          icon: Icons.cancel_rounded,
        );

      default:
        return _StatusConfig(
          color: Colors.blue,
          icon: Icons.vaccines_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.icon,
  });
}

class _HoverStatusCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverStatusCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverStatusCard> createState() => _HoverStatusCardState();
}

class _HoverStatusCardState extends State<_HoverStatusCard> {
  bool _isHovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isHovered = false;
          });
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(
            milliseconds: 120,
          ),
          scale: _isHovered ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                18,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(
                    _isHovered ? 0.08 : 0.03,
                  ),
                  blurRadius: _isHovered ? 18 : 10,
                  offset: const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
