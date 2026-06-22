import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/imunisasi_screen.dart';
import 'package:ta_pa2_pa3_project/features/ibu/imunisasi/presentation/screens/ubah_jadwal.dart';
import '../../firebase_options.dart';

const _androidChannel = AndroidNotificationChannel(
  'kia_app_channel',
  'KIA App Notifications',
  description: 'Notifikasi pengingat imunisasi dan layanan KIA',
  importance: Importance.max,
);

const _actionLihat = 'lihat';
const _actionUbahJadwal = 'ubah_jadwal';

// Background message handler must be a top-level function
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  return;
}

class NotificationService {
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
            DarwinNotificationAction.plain(
              _actionLihat,
              'Lihat',
            ),
            DarwinNotificationAction.plain(
              _actionUbahJadwal,
              'Ubah Jadwal',
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
        _handleAction(payload, actionId);
      },
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotificationFromRemote(message);
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

  static Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? '';
    final body = notification?.body ?? '';
    final data = message.data;
    final isImunisasiReminder = data['type'] == 'reminder_imunisasi';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      priority: Priority.high,
      playSound: true,
      actions: isImunisasiReminder
          ? const [
              AndroidNotificationAction(
                _actionLihat,
                'Lihat',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                _actionUbahJadwal,
                'Ubah Jadwal',
                showsUserInterface: true,
              ),
            ]
          : null,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'imunisasi_reminder',
      ),
    );

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

  static void _handleAction(String payload, String? actionId) {
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
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => UbahJadwalScreen(jadwalId: jadwalId),
          ),
        );
      } else if (anakId != null) {
        // tombol "Lihat" atau tap body notifikasi
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ImunisasiScreen(
              anakId: anakId,
              namaAnak: '',
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
