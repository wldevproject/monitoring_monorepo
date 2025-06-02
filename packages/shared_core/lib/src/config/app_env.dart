import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static Future<void> load() async {
    // Idealnya, nama file .env bisa berbeda per sub-proyek jika diperlukan,
    // atau sub-proyek memanggil ini dengan path spesifik jika file .env
    // ada di root sub-proyek.
    // Untuk contoh ini, kita asumsikan dotenv.load() dipanggil di main.dart sub-proyek.
  }

  // Contoh cara mengambil nilai dari .env
  // Sub-proyek bertanggung jawab memuat file .env mereka sendiri
  static String get apiUrl =>
      dotenv.env['API_URL'] ??
      '[https://default.api.com](https://default.api.com)';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Atau menggunakan String.fromEnvironment untuk --dart-define
  // static const String apiUrlFromDefine = String.fromEnvironment('API_URL', defaultValue: 'N/A');
}
