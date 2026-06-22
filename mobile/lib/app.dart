import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_session.dart';
import 'core/services/unauthorized_handler.dart';
import 'core/themes/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/kader/presentation/dashboard_screen.dart';
import 'core/routes/navigator_key.dart';
import 'db/sync_provider.dart';
import 'main.dart'; // Memastikan initBackgroundSyncListener terbaca
import 'package:flutter_localizations/flutter_localizations.dart';


class KiaApp extends StatefulWidget {
  const KiaApp({super.key});

  @override
  State<KiaApp> createState() => _KiaAppState(); // BERSIH: Tidak ada logika di sini
}

class _KiaAppState extends State<KiaApp> {
  @override
  void initState() {
    super.initState();
    
    // PERBAIKAN UTAMA: Menunggu 1 frame sampai widget tree selesai dirender sempurna 
    // agar Provider terikat ke context sebelum dibaca oleh _checkAndActivateSync()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndActivateSync();
    });
  }

  void _checkAndActivateSync() {
    // 1. Pastikan pengguna sudah login dan role-nya adalah Ibu
    final bool isIbu = AuthSession.isLoggedIn && 
        AuthSession.role?.trim().toLowerCase() == 'ibu';

    if (isIbu) {
      // 2. Ambil token JWT dari session
      String? tokenJwt = AuthSession.token; 

      if (tokenJwt != null && tokenJwt.isNotEmpty) {
        // 3. Ambil SyncProvider dari root context (Sekarang aman dari ProviderNotFoundError)
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);

        // 4. Aktifkan background sync listener
        initBackgroundSyncListener(syncProvider, tokenJwt);
        print("🎉 [Sobat Imun] Background Sync untuk Ibu berhasil diaktifkan dari app.dart");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
return MaterialApp(
  title: 'Aplikasi Generasi Sehat',
  debugShowCheckedModeBanner: false,
  navigatorKey: navigatorKey,
  theme: AppTheme.lightTheme,

  locale: const Locale('id', 'ID'),

  supportedLocales: const [
    Locale('id', 'ID'),
    Locale('en', 'US'),
  ],

  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  home: _buildHome(),
);
  }

  Widget _buildHome() {
    /// Belum login
    if (!AuthSession.isLoggedIn) {
      return const LoginScreen();
    }

    final role = AuthSession.role?.trim().toLowerCase();

    /// Redirect berdasarkan role
    switch (role) {
      case 'kader':
        return const DashboardKaderScreen();

      case 'ibu':
        return const DashboardScreen();

      default:
        return const LoginScreen();
    }
  }
}