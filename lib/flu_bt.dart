// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:flu_bt/message.dart';
import 'package:flu_bt/peripheral.dart';
import 'package:flu_bt/result.dart';

import 'flu_bt_platform_interface.dart';

class FluBt {
  Future<String?> getPlatformVersion() {
    return FluBtPlatform.instance.getPlatformVersion();
  }

  Stream<List<Peripheral>> get scanStream => FluBtPlatform.instance.scanStream;
  Stream<Message> get msgStream => FluBtPlatform.instance.msgStream;
  Stream<Peripheral> get peripheralStateStream =>
      FluBtPlatform.instance.peripheralStateStream;
  Stream<int> get centralStateStream =>
      FluBtPlatform.instance.centralStateStream;
  List<Peripheral> get connectedPeripheral =>
      FluBtPlatform.instance.connectedPeripheral;
  Future<int> getCentralState() => FluBtPlatform.instance.getCentralState();
  Future<Result> startScan() => FluBtPlatform.instance.startScan();

  Future<Result> stopScan() => FluBtPlatform.instance.stopScan();

  Future<Result> connect(String uuid) => FluBtPlatform.instance.connect(uuid);

  Future<Result> disconnect(String uuid) =>
      FluBtPlatform.instance.disconnect(uuid);

  Future<Result> write(
          String uuid, String characteristicUUID, Uint8List data) =>
      FluBtPlatform.instance.write(uuid, characteristicUUID, data);
  Future<void> gotoSettings() => FluBtPlatform.instance.gotoSettings();
}
