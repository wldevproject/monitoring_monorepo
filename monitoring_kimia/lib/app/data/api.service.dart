// ignore: library_prefixes
import 'package:shared_core/shared_core.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  final String _socketUrl = AppEnv.apiUrl;
  IO.Socket? _socket;
  final path = '/api/v1/sensor-testing/akuarium-ilham';

  // Getter untuk socket, inisialisasi jika belum ada
  IO.Socket get socket {
    _socket ??= IO.io(_socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    return _socket!;
  }

  void disposeSocket() {
    _socket?.dispose(); // Panggil saat service tidak lagi digunakan
    _socket = null;
  }
}

// class AlphaDataService {
//   final ApiClient _apiClient = ApiClient();

//   Future<void> fetchData() async {
//     try {
//       final data = await _apiClient.get('contoh-endpoint');
//       print('Data diterima: $data');
//     } on Exception catch (e) {
//       // Menangkap Exception umum
//       print('Terjadi kesalahan saat mengambil data: ${e.toString()}');
//       // Tampilkan pesan error ke pengguna, misalnya:
//       // showSnackBar('Error: ${e.toString()}');
//     }
//   }
// }
