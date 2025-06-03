import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kimia/app/data/api.service_impl.dart';
import 'package:monitoring_kimia/app/data/response.model.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeController extends GetxController {
  late final ApiService _apiService;

  final _eventData = (List<SensorData>.of([])).obs;
  List<SensorData> get eventData => _eventData;

  final RxBool isConnected = false.obs;

  final _isiAirActive = false.obs;
  bool get isiAirActive => _isiAirActive.value;

  final _kurasAirActive = false.obs;
  bool get kurasAirActive => _kurasAirActive.value;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
    _setupSocketListeners();
    _apiService.socket.connect();
  }

  void _setupSocketListeners() {
    _apiService.socket.on('connect', (_) {
      if (kDebugMode) {
        print('HomeController: Connected to Socket.IO server');
      }
      isConnected.value = true;
    });

    _apiService.socket.on('disconnect', (_) {
      if (kDebugMode) {
        print('HomeController: Disconnected from Socket.IO server');
      }
      isConnected.value = false;
    });

    _apiService.socket.on('monitoringsensorakuarium', (data) {
      if (kDebugMode) {
        print('socket.on: Raw data from monitoringsensorakuarium: $data');
      }
      _processSocketData(data);
    });

    _apiService.socket.on('controlingakuarium', (data) {
      if (kDebugMode) {
        print('socket.on: Raw data from controlingakuarium: $data');
      }
      _processTombolAkuariumStatus(data);
    });

    _apiService.socket.onConnectError((err) {
      if (kDebugMode) {
        print('HomeController: Connection Error: $err');
      }
      isConnected.value = false;
    });

    _apiService.socket.onError((err) {
      if (kDebugMode) {
        print('HomeController: Socket Error: $err');
      }
    });
  }

  void _processSocketData(dynamic rawData) {
    try {
      List<dynamic> jsonList;

      if (rawData is String) {
        final decoded = jsonDecode(rawData);
        if (decoded is List) {
          jsonList = decoded;
        } else {
          if (kDebugMode) {
            print('Expected a JSON array, but got: ${decoded.runtimeType}');
          }
          return;
        }
      } else if (rawData is List) {
        jsonList = rawData;
      } else {
        if (kDebugMode) {
          print('Unknown socket data type: ${rawData.runtimeType}');
        }
        return;
      }

      final dataList = jsonList
          .map((e) => SensorData.fromJson(e as Map<String, dynamic>))
          .toList();

      _eventData.value = dataList;
      update();
    } catch (e) {
      if (kDebugMode) {
        print('Error processing socket data: $e');
        print('Received raw data: $rawData');
      }
    }
  }

  void _processTombolAkuariumStatus(dynamic rawData) {
    try {
      Map<String, dynamic> statusMap;

      if (rawData is String) {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          statusMap = decoded;
        } else {
          if (kDebugMode) {
            print(
                'HomeController: Expected a JSON object for status, but got: ${decoded.runtimeType}');
          }
          return;
        }
      } else if (rawData is Map<String, dynamic>) {
        statusMap = rawData;
      } else {
        if (kDebugMode) {
          print(
              'HomeController: Unknown status data type from socket: ${rawData.runtimeType}');
        }
        return;
      }

      final dataStatus = StatusData.fromJson(statusMap);
      _isiAirActive.value = dataStatus.isiAir ?? false;
      _kurasAirActive.value = dataStatus.kurasAir ?? false;

      if (kDebugMode) {
        print(
            'HomeController: Tombol akuarium status updated - Isi Air: ${_isiAirActive.value}, Kuras Air: ${_kurasAirActive.value}');
      }
      update();
    } catch (e) {
      if (kDebugMode) {
        print('HomeController: Error processing tombol akuarium status: $e');
        print('HomeController: Received raw status data: $rawData');
      }
    }
  }

  void reconnectSocket() {
    if (!isConnected.value) {
      if (kDebugMode) {
        print('HomeController: Attempting to reconnect socket...');
      }
      _apiService.socket.connect();
    }
  }

  void disconnectSocket() {
    _apiService.socket.disconnect();
  }

  void sendTombolAkuariumState({int tombolState = 0, String typeState = ''}) {
    if (isConnected.value) {
      final dataMap = {
        "tombol": tombolState,
        "type": typeState,
      };
      if (kDebugMode) {
        print('HomeController: Emitting "tombol-akuarium" with data: $dataMap');
      }
      _apiService.socket.emit('tombol-akuarium', dataMap);

      // Get.snackbar(
      //   "Sukses",
      //   "Data tombol akuarium dikirim",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } else {
      if (kDebugMode) {
        print('HomeController: Cannot emit. Socket is not connected.');
      }
      Get.snackbar(
        "Koneksi Gagal",
        "Tidak bisa mengirim data, socket tidak terhubung.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('HomeController: Closing connection.');
    }
    disconnectSocket();
    super.onClose();
  }

  void setIsiAir(bool newValue) {
    _isiAirActive.value = newValue;
    sendTombolAkuariumState(
        tombolState: isiAirActive ? 1 : 0, typeState: 'isi');
  }

  void setKurasAir(bool newValue) {
    _kurasAirActive.value = newValue;
    sendTombolAkuariumState(
        tombolState: kurasAirActive ? 1 : 0, typeState: 'kuras');
  }
}
