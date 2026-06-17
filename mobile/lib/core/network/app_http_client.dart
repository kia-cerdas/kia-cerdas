import 'package:http/http.dart' as http;
import 'token_expired_handler.dart';

class AppHttpClient extends http.BaseClient {
  final http.Client _inner;

  AppHttpClient({http.Client? inner}) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      handleTokenExpired();
    }
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
