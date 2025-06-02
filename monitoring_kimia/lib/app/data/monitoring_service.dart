// Contoh di dalam sebuah service class di project_alpha

import 'package:shared_core/shared_core.dart';

class AlphaDataService {
  final ApiClient _apiClient = ApiClient();

  Future<void> fetchData() async {
    try {
      final data = await _apiClient.get('contoh-endpoint');
      print('Data diterima: $data');
    } on Exception catch (e) {
      // Menangkap Exception umum
      print('Terjadi kesalahan saat mengambil data: ${e.toString()}');
      // Tampilkan pesan error ke pengguna, misalnya:
      // showSnackBar('Error: ${e.toString()}');
    }
  }
}
