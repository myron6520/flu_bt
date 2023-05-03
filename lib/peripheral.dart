// ignore_for_file: constant_identifier_names

class Peripheral {
  static const int STATE_DISCONNECTED = 0;
  static const int STATE_CONNECTING = 1;
  static const int STATE_CONNECTED = 2;
  static const int STATE_DISCONNECTING = 3;
  late String name;
  late String uuid;
  late int rssi;
  late int state;
  Peripheral();
  Peripheral.fromMap(Map info) {
    name = info["name"] ?? "";
    uuid = info["uuid"] ?? "";
    rssi = int.tryParse("${info['rssi']}") ?? 0;
    state = int.tryParse("${info['state']}") ?? STATE_DISCONNECTED;
  }
  void makeValue(Map info) {
    name = info["name"] ?? "";
    uuid = info["uuid"] ?? "";
    rssi = int.tryParse("${info['rssi']}") ?? 0;
    state = int.tryParse("${info['state']}") ?? STATE_DISCONNECTED;
  }
}
