import 'package:monitoring_kimia/app/data/response.model.dart';

abstract class ControllerRemoteDataSource {
  Stream<List<SensorData>> getSensorDataStream();
  Stream<bool> getConnectionStatusStream();
  void connectSocket();
  void disconnectSocket();
  void emitEvent(String event, dynamic data);
  void dispose();
}
