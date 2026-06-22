import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/auth_session.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'db/sync_service.dart';
import 'db/sync_provider.dart';
import 'db/pull_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
    'id_ID',
    null,
  );
  await AuthSession.initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize notification service (FCM listeners + local notifications)
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Gagal inisialisasi Firebase/Notifikasi: $e');
  }

  runApp(const KiaApp());
}

// Fungsi initBackgroundSyncListener kamu biarkan tetap berada di bawah main.dart seperti ini
void initBackgroundSyncListener(SyncProvider syncProvider, String tokenJwt) {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
      try {
        final syncService = SyncService();
        await syncService.executeBulkSync(tokenJwt);

        final pullService = PullService();
        await pullService.executeBulkPull(tokenJwt);

        syncProvider.notifyDataSynced();
      } catch (e) {
        print("❌ Gagal menjalankan sinkronisasi otomatis background: $e");
      }
    }
  });
}

