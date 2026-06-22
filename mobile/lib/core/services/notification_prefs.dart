import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  static const _keyDismissedImunisasi = 'dismissed_imunisasi_keys';

  static Future<Set<String>> getDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyDismissedImunisasi)?.toSet() ?? {};
  }

  static Future<void> addDismissed(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyDismissedImunisasi) ?? [];

    if (!list.contains(key)) {
      list.add(key);
      await prefs.setStringList(_keyDismissedImunisasi, list);
    }
  }

  static String makeKey(int anakId, int jadwalId) {
    return '$anakId-$jadwalId';
  }
}