import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';

const _androidChannel = AndroidNotificationChannel(
  'kia_app_channel',
  'KIA App Notifications',
  description: 'Notifikasi pengingat imunisasi dan layanan KIA',
  importance: Importance.max,
);


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

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        _handleNotificationTap(notificationResponse.payload ?? '');
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
        _handleRemoteMessageNavigation(message);
      }
    });

    // When user taps a notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteMessageNavigation(message);
    });
  }

  static Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? '';
    final body = notification?.body ?? '';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      message.hashCode & 0x7FFFFFFF,
      title,
      body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  static void _handleRemoteMessageNavigation(RemoteMessage message) {
    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
    if (payload != null) {
      _handleNotificationTap(payload);
    }
  }

  static void _handleNotificationTap(String payload) {
    // Example: payload might contain a route or id. Implement parsing as needed.
    // For now, we'll just try to open the home screen.
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildDefaultHome()),
      (route) => false,
    );
  }

  static Widget _buildDefaultHome() {
    // This avoids import cycles; the actual app will show its own home based on AuthSession.
    return const SizedBox.shrink();
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
