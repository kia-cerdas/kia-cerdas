import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/auth_session.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

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
