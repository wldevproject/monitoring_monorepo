import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kimia/app/data/api.service.dart';
import 'package:monitoring_kimia/app/data/response.model.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeController extends GetxController {
  late final ApiService _apiService;

  final Rx<List<SensorData>> _eventData = Rx<List<SensorData>>([]);
  List<SensorData> get eventData => _eventData.value;

  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
    _setupSocketListeners();
    _apiService.socket.connect();
  }

  void _setupSocketListeners() {
    _apiService.socket.on('connect', (_) {
      print('HomeController: Connected to Socket.IO server');
      isConnected.value = true;
    });

    _apiService.socket.on('disconnect', (_) {
      print('HomeController: Disconnected from Socket.IO server');
      isConnected.value = false;
    });

    _apiService.socket.on('monitoringsensorakuarium', (data) {
      // print('HomeController: Raw data from monitoringsensorakuarium: $data');
      _processSocketData(data);
    });

    _apiService.socket.onConnectError((err) {
      print('HomeController: Connection Error: $err');
      isConnected.value = false;
    });

    _apiService.socket.onError((err) {
      print('HomeController: Socket Error: $err');
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
          print('Expected a JSON array, but got: ${decoded.runtimeType}');
          return;
        }
      } else if (rawData is List) {
        jsonList = rawData;
      } else {
        print('Unknown socket data type: ${rawData.runtimeType}');
        return;
      }

      final dataList = jsonList
          .map((e) => SensorData.fromJson(e as Map<String, dynamic>))
          .toList();

      _eventData.value = dataList;
      update();
    } catch (e) {
      print('Error processing socket data: $e');
      print('Received raw data: $rawData');
    }
  }

  void reconnectSocket() {
    if (!isConnected.value) {
      print('HomeController: Attempting to reconnect socket...');
      _apiService.socket.connect();
    }
  }

  void disconnectSocket() {
    _apiService.socket.disconnect();
  }

  void sendTombolAkuariumState({int tombol1State = 0, int tombol2State = 0}) {
    if (isConnected.value) {
      final dataMap = {
        "tombol1": tombol1State,
        "tombol2": tombol2State,
      };
      print('HomeController: Emitting "tombol-akuarium" with data: $dataMap');
      _apiService.socket.emit('tombol-akuarium', dataMap);

      Get.snackbar(
        "Sukses",
        "Data tombol akuarium dikirim: ${jsonEncode(dataMap)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      print('HomeController: Cannot emit. Socket is not connected.');
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
    print('HomeController: Closing connection.');
    disconnectSocket();
    super.onClose();
  }
}
