// ignore: library_prefixes
import 'dart:async';

import 'package:get/get.dart';
import 'package:monitoring_kimia/app/data/api.service.dart';
import 'package:monitoring_kimia/app/data/app.env.dart';
import 'package:monitoring_kimia/app/data/response.model.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService extends GetxService implements ControllerRemoteDataSource {
  final String _socketBaseUrl = AppEnv.socketBaseUrl;
  IO.Socket? _socket;

  IO.Socket get socket {
    _socket ??= IO.io(_socketBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    return _socket!;
  }

  void disposeSocket() {
    _socket?.dispose();
    _socket = null;
  }

  // StreamController untuk data sensor
  final StreamController<List<SensorData>> _sensorDataStreamController =
      StreamController<List<SensorData>>.broadcast();

  // StreamController untuk status koneksi
  final StreamController<bool> _connectionStatusStreamController =
      StreamController<bool>.broadcast();

  final RxBool _isConnected = false.obs;

  @override
  void connectSocket() {
    // TODO: implement connectSocket
  }

  @override
  void disconnectSocket() {
    // TODO: implement disconnectSocket
  }

  @override
  void emitEvent(String event, data) {
    // TODO: implement emitEvent
  }

  @override
  Stream<bool> getConnectionStatusStream() {
    // TODO: implement getConnectionStatusStream
    throw UnimplementedError();
  }

  @override
  Stream<List<SensorData>> getSensorDataStream() {
    // TODO: implement getSensorDataStream
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
