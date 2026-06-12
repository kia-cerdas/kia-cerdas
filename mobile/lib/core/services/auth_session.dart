import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static const String _tokenKey = 'auth_access_token';

  static const String _nameKey = 'auth_user_name';

  static const String _roleKey = 'auth_user_role';

  static const String _redirectRouteKey = 'auth_redirect_route';

  static const String _reminderShownKey = 'auth_tumbuh_reminder_shown';

  static String? token;
  static String? userName;
  static String? role;
  static String? redirectRoute;

  static bool isReminderShown = false;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString(
      _tokenKey,
    );

    userName = prefs.getString(
      _nameKey,
    );

    role = prefs.getString(
      _roleKey,
    );

    redirectRoute = prefs.getString(
      _redirectRouteKey,
    );

    isReminderShown = prefs.getBool(
          _reminderShownKey,
        ) ??
        false;
  }

  static Future<void> save({
    required String accessToken,
    String? name,
    String? userRole,
    String? redirect,
  }) async {
    token = accessToken;
    userName = name;
    role = userRole;
    redirectRoute = redirect;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      accessToken,
    );

    isReminderShown = false;

    await prefs.setBool(
      _reminderShownKey,
      false,
    );

    if (name != null) {
      await prefs.setString(
        _nameKey,
        name,
      );
    }

    if (userRole != null) {
      await prefs.setString(
        _roleKey,
        userRole,
      );
    }

    if (redirect != null) {
      await prefs.setString(
        _redirectRouteKey,
        redirect,
      );
    }
  }

  static Future<void> clear() async {
    token = null;
    userName = null;
    role = null;
    redirectRoute = null;
    isReminderShown = false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(
      _tokenKey,
    );

    await prefs.remove(
      _nameKey,
    );

    await prefs.remove(
      _roleKey,
    );

    await prefs.remove(
      _redirectRouteKey,
    );

    await prefs.remove(
      _reminderShownKey,
    );
  }

  static Future<void> markReminderShown() async {
    isReminderShown = true;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _reminderShownKey,
      true,
    );
  }
}
