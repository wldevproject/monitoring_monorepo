import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get socketBaseUrl {
    return dotenv.env['SOCKET_BASE_URL'] ?? 'http://localhost:3000';
  }

  static String get socketPath {
    return dotenv.env['SOCKET_PATH'] ?? '/socket.io';
  }
}
