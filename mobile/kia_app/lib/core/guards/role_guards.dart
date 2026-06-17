import 'package:flutter/material.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';

class RoleGuard extends StatelessWidget {
  final String allowedRole;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.allowedRole,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final role = AuthSession.role;

    if (role != allowedRole) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 72,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Akses Ditolak',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Halaman ini '
                  'khusus untuk role '
                  '$allowedRole.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text(
                      'Kembali',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
