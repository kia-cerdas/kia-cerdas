import 'package:flutter/material.dart';

class SyncProvider extends ChangeNotifier {
  int _syncVersion = 0;
  int get syncVersion => _syncVersion;

  // Fungsi ini dipanggil OLEH LISTENER INTERNET kamu (bukan oleh tombol)
  // ketika SyncService sukses menembak API backend
  void notifyDataSynced() {
    _syncVersion++;
    notifyListeners(); // Otomatis menyuruh semua halaman UI yang terbuka untuk reload
  }
}