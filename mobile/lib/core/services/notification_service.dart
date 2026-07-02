import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/imunisasi_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/ubah_jadwal.dart';
import 'package:ta_pa2_pa3_project/features/kader/kunjungan/services/kunjungan_service.dart';
import 'package:ta_pa2_pa3_project/features/kader/screens/detail_kunjungan_imunisasi.dart' show AnakImunisasiDetailScreen;
import '../../firebase_options.dart';
import '../routes/navigator_key.dart' as nav;

const _androidChannel = AndroidNotificationChannel(
  'generasi_sehat_channel',
  'Notifikasi Generasi Sehat',
  description: 'Notifikasi pengingat imunisasi dan layanan KIA',
  importance: Importance.max,
);

const _actionLihat = 'lihat';
const _actionUbahJadwal = 'ubah_jadwal';
const _actionSudahDikunjungi = 'sudah_dikunjungi';
const _actionJadwalkanUlang = 'jadwalkan_ulang';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
) async {

  debugPrint("======================");
  debugPrint("BACKGROUND MESSAGE");
  debugPrint(message.data.toString());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.showLocalNotificationFromRemote(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse response,
) {
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  static Future<void> initialize() async {
    // Skip notification setup on web
    if (kIsWeb) {
      debugPrint('NotificationService: Skipping on web platform');
      return;
    }

    // Request permissions — Android 13+ also needs explicit permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'imunisasi_reminder',
          actions: [
            DarwinNotificationAction.plain(_actionLihat, 'Lihat'),
            DarwinNotificationAction.plain(_actionUbahJadwal, 'Ubah Jadwal'),
          ],
        ),
        DarwinNotificationCategory(
          'kunjungan_imunisasi_reminder',
          actions: [
            DarwinNotificationAction.plain(
              _actionSudahDikunjungi,
              'Sudah Dikunjungi',
            ),
            DarwinNotificationAction.plain(
              _actionJadwalkanUlang,
              'Jadwalkan Ulang',
            ),
          ],
        ),
      ],
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

await _localNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) async {

    final payload = response.payload ?? '';
    final actionId = response.actionId;

    await _handleAction(
      payload,
      actionId,
    );
  },

  onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
FirebaseMessaging.onMessage.listen((RemoteMessage message) {

  debugPrint("======================");
  debugPrint("ON MESSAGE");
  debugPrint(message.data.toString());

  showLocalNotificationFromRemote(message);
});

    // When app opened from notification (terminated)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleRemoteMessageNavigation(message, null);
      }
    });

    // When user taps a notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteMessageNavigation(message, null);
    });
  }

  static Future<void> showLocalNotificationFromRemote(RemoteMessage message) async {
    final data = message.data;
    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    final isImunisasiReminder = data['type'] == 'reminder_imunisasi';
    final isKunjunganReminder = data['type'] == 'kunjungan_imunisasi_reminder';

    List<AndroidNotificationAction>? androidActions;
    String iosCategory = '';

    if (isImunisasiReminder) {
      androidActions = const [
        AndroidNotificationAction(_actionLihat, 'Lihat', showsUserInterface: true),
        AndroidNotificationAction(_actionUbahJadwal, 'Ubah Jadwal', showsUserInterface: true),
      ];
      iosCategory = 'imunisasi_reminder';
    } else if (isKunjunganReminder) {
      androidActions = const [
        AndroidNotificationAction(_actionSudahDikunjungi, 'Sudah Dikunjungi', showsUserInterface: true),
        AndroidNotificationAction(_actionJadwalkanUlang, 'Jadwalkan Ulang', showsUserInterface: true),
      ];
      iosCategory = 'kunjungan_imunisasi_reminder';
    }

final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
  'generasi_sehat_channel',
  'Notifikasi Generasi Sehat',

  channelDescription: _androidChannel.description,

  importance: Importance.max,

  priority: Priority.high,

  playSound: true,

  category: AndroidNotificationCategory.reminder,

  visibility: NotificationVisibility.public,

  actions: androidActions,
);

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        categoryIdentifier: iosCategory.isEmpty ? null : iosCategory,
      ),
    );
debugPrint("SHOW NOTIFICATION");
    await _localNotificationsPlugin.show(
      message.hashCode & 0x7FFFFFFF,
      title,
      body,
      platformDetails,
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );
  }

  static void _handleRemoteMessageNavigation(RemoteMessage message, String? actionId) {
    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
    if (payload != null) {
      _handleAction(payload, actionId);
    }
  }

  static Future<void> _handleAction(String payload, String? actionId) async {
    if (payload.isEmpty) return;

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = data['type'] as String? ?? '';

    if (type == 'reminder_imunisasi') {
      final anakId = int.tryParse(data['anak_id']?.toString() ?? '');
      final jadwalId = int.tryParse(data['jadwal_id']?.toString() ?? '');

      if (actionId == _actionUbahJadwal && jadwalId != null) {
        nav.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => UbahJadwalScreen(jadwalId: jadwalId),
          ),
        );
      } else if (anakId != null) {
        nav.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ImunisasiScreen(
              anakId: anakId,
              namaAnak: '',
            ),
          ),
        );
      }
    }

    if (type == 'kunjungan_imunisasi_reminder') {
      final kunjunganId = int.tryParse(data['kunjungan_id']?.toString() ?? '');

if (actionId == _actionSudahDikunjungi &&
    kunjunganId != null) {

    await KunjunganImunisasiService()
        .updateStatusKunjungan(kunjunganId, 3);

} else if (actionId == _actionJadwalkanUlang &&
           kunjunganId != null) {

    nav.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AnakImunisasiDetailScreen(
          kunjunganId: kunjunganId,
        ),
      ),
    );

} else if (kunjunganId != null) {

    nav.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            AnakImunisasiDetailScreen(
              kunjunganId: kunjunganId,
            ),
      ),
    );

}
    }
  }

  /// Helper to get FCM token (optional)
  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
