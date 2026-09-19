// ignore_for_file: constant_identifier_names

import 'dart:io';

class Peripheral {
  static const int STATE_DISCONNECTED = 0;
  static const int STATE_CONNECTING = 1;
  static const int STATE_CONNECTED = 2;
  static const int STATE_DISCONNECTING = 3;

  static const int DEVICE_TYPE_CLASSIC = 1;
  static const int DEVICE_TYPE_DUAL = 3;
  static const int DEVICE_TYPE_LE = 2;
  static const int DEVICE_TYPE_UNKNOWN = 0;
  late String name;
  late String uuid;
  late int rssi;
  late int state;
  late int deviceType;
  Peripheral();
  Peripheral.fromMap(Map info) {
    name = info["name"] ?? "";
    uuid = info["uuid"] ?? "";
    rssi = int.tryParse("${info['rssi']}") ?? 0;
    state = int.tryParse("${info['state']}") ?? STATE_DISCONNECTED;
    deviceType = int.tryParse("${info['deviceType']}") ??
        (Platform.isIOS ? DEVICE_TYPE_LE : DEVICE_TYPE_UNKNOWN);
  }
  void makeValue(Map info) {
    name = info["name"] ?? "";
    uuid = info["uuid"] ?? "";
    rssi = int.tryParse("${info['rssi']}") ?? 0;
    state = int.tryParse("${info['state']}") ?? STATE_DISCONNECTED;
    deviceType = int.tryParse("${info['deviceType']}") ??
        (Platform.isIOS ? DEVICE_TYPE_LE : DEVICE_TYPE_UNKNOWN);
  }
}
