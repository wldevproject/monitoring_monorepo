import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_core/src/config/app_env.dart'; // Untuk Timeout

class ApiClient {
  final String _baseUrl = AppEnv.apiUrl; // Diambil dari .env sub-proyek
  final String _apiKey = AppEnv.apiKey; // Diambil dari .env sub-proyek
  final http.Client _httpClient;

  // Constructor bisa menerima http.Client untuk testing atau menggunakan default.
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Helper untuk header standar
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (_apiKey.isNotEmpty) {
      headers['Authorization'] =
          'Bearer $_apiKey'; // Sesuaikan dengan skema Auth Anda
    }
    return headers;
  }

  // Method GET
  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final uri =
        Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await _httpClient
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response, endpoint);
    } on TimeoutException catch (_) {
      // Melempar Exception umum untuk timeout
      throw Exception(
          'Request timeout ke $endpoint. Periksa koneksi internet Anda.');
    } catch (e) {
      // Untuk error koneksi lain sebelum response diterima (misal, DNS lookup failed)
      // Melempar Exception umum
      throw Exception('Gagal terhubung ke server untuk endpoint $endpoint: $e');
    }
  }

  // Method POST
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await _httpClient
          .post(uri, headers: _getHeaders(), body: json.encode(body))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response, endpoint);
    } on TimeoutException catch (_) {
      // Melempar Exception umum untuk timeout
      throw Exception(
          'Request timeout ke $endpoint. Periksa koneksi internet Anda.');
    } catch (e) {
      // Melempar Exception umum
      throw Exception('Gagal terhubung ke server untuk endpoint $endpoint: $e');
    }
  }

  // Tambahkan method PUT, DELETE, dll. sesuai kebutuhan
  // Future<dynamic> put(String endpoint, {dynamic body}) async { ... }
  // Future<dynamic> delete(String endpoint) async { ... }

  // Helper untuk memproses response
  dynamic _handleResponse(http.Response response, String endpoint) {
    final String responseBody = response.body;
    final dynamic decodedBody;

    try {
      decodedBody = responseBody.isNotEmpty ? json.decode(responseBody) : null;
    } catch (e) {
      // Melempar Exception umum jika parsing JSON gagal
      throw Exception(
          'Format respons tidak valid dari $endpoint (Status: ${response.statusCode}). Error: $e. Body: $responseBody');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody ??
          {}; // Kembalikan map kosong jika body kosong tapi sukses
    } else {
      // Penanganan error umum berdasarkan status code
      String serverMessage = 'Terjadi kesalahan.';
      if (decodedBody != null && decodedBody is Map<String, dynamic>) {
        serverMessage = decodedBody['message'] ??
            decodedBody['error'] ??
            'Error dari server: ${decodedBody.toString()}';
      } else if (decodedBody is String && decodedBody.isNotEmpty) {
        serverMessage = decodedBody;
      }

      // Melempar Exception umum dengan pesan yang mencakup status code dan pesan dari server (jika ada)
      throw Exception(
          'Panggilan API ke $endpoint gagal (Status: ${response.statusCode}). Pesan: $serverMessage');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
