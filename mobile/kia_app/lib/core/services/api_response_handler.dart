// =============================================================
// HELPER: ApiResponseHandler
// -------------------------------------------------------------
// Tujuan: satu "pintu" terpusat untuk mendeteksi token expired
// (HTTP 401) di SEMUA API service, lalu otomatis mengarahkan
// user kembali ke halaman Login.
//
// Perumpamaan: ini "tombol alarm standar". Daripada menulis
// logika cek-401 berulang di tiap API service, cukup panggil
// satu baris: ApiResponseHandler.check(response);
//
// Cara pakai di API service (taruh TEPAT setelah dapat response,
// SEBELUM pengecekan error lainnya):
//
//   final response = await _client.get(uri, headers: _headers);
//   await ApiResponseHandler.check(response);   // <-- 1 baris ini
//   final body = jsonDecode(response.body) ...
//
// Kalau token expired (401), baris itu akan otomatis:
//   1. Membersihkan sesi (AuthSession.clear)
//   2. Mengarahkan ke LoginScreen
//   3. Melempar Exception supaya proses di service berhenti
// =============================================================

import 'package:http/http.dart' as http;
import 'package:ta_pa2_pa3_project/core/services/unauthorized_handler.dart';

class ApiResponseHandler {
  ApiResponseHandler._();

  // Daftar kode status yang dianggap "sesi tidak berlaku".
  // Saat ini backend hanya memakai 401, tetapi dibuat berupa
  // himpunan agar mudah ditambah (mis. 403) tanpa ubah logika.
  static const Set<int> _unauthorizedCodes = {401};

  /// Periksa response. Jika status menandakan sesi berakhir,
  /// jalankan proses logout-otomatis lalu lempar Exception.
  ///
  /// Aman dipanggil di semua jenis request (GET/POST/PUT/DELETE).
  static Future<void> check(http.Response response) async {
    if (_unauthorizedCodes.contains(response.statusCode)) {
      // "Tekan alarm": clear sesi + arahkan ke LoginScreen.
      await UnauthorizedHandler.handle();

      // Hentikan alur di API service. Pesan ini biasanya tidak
      // sempat terlihat user karena layar sudah pindah ke Login,
      // tetapi tetap penting agar 'await ... save()' berhenti.
      throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
    }
  }
}