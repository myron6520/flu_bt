// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:typed_data';

import 'package:flu_bt/message.dart';
import 'package:flu_bt/peripheral.dart';
import 'package:flu_bt/result.dart';
import 'package:flutter/services.dart';

import 'define.dart';
import 'event_mixin.dart';
import 'flu_bt_platform_interface.dart';

class FluBt {
  late MethodChannel methodChannel = const MethodChannel('flu_bt')
    ..setMethodCallHandler((call) async {
      switch (call.method) {
        case "didDiscoverPeripheral":
          List arguments = call.arguments;
          for (var e in arguments) {
            String uuid = e['uuid'] ?? "";
            Peripheral peripheral = _peripherals[uuid] ?? Peripheral();
            peripheral.makeValue(e);
            _peripherals[uuid] = peripheral;
          }
          List<Peripheral> devices = _peripherals.values.toList();
          devices.sort((a, b) => b.rssi.compareTo(a.rssi));
          _peripheralController.sink.add(devices);
          break;
        case "peripheralStateChanged":
          Map arguments = call.arguments;
          String uuid = arguments['uuid'] ?? "";
          Peripheral? peripheral = _peripherals[uuid];
          if (peripheral != null) {
            int state = int.tryParse("${arguments['state']}") ??
                Peripheral.STATE_DISCONNECTED;
            peripheral.state = state;
            _peripheralStateController.sink.add(peripheral);
          }
          break;
        case "centralStateChanged":
          int state =
              int.tryParse("${call.arguments}") ?? CENTRAL_STATE_UNKNOWN;
          _centralStateController.sink.add(state);
          break;
        case "didReceiveData":
          Map info = call.arguments;
          String uuid = info["uuid"];
          String characteristicUUID = info["characteristicUUID"];
          Uint8List data = info["data"];
          _msgController.sink.add(Message(uuid, characteristicUUID, data));
          break;
        // case "onBluetoothReady":
        //   break;
        // case "onCharacteristicWrite":
        //   break;
        default:
          _methodController.sink.add(call);
          break;
      }
    });

  late final StreamController<List<Peripheral>> _peripheralController =
      StreamController.broadcast();
  Stream<List<Peripheral>> get scanStream => _peripheralController.stream;
  late final StreamController<Peripheral> _peripheralStateController =
      StreamController.broadcast();
  Stream<Peripheral> get peripheralStateStream =>
      _peripheralStateController.stream;
  late final StreamController<int> _centralStateController =
      StreamController.broadcast();
  Stream<int> get centralStateStream => _centralStateController.stream;
  late final StreamController<Message> _msgController =
      StreamController.broadcast();
  Stream<Message> get msgStream => _msgController.stream;
  late final StreamController<MethodCall> _methodController =
      StreamController.broadcast();
  Stream<MethodCall> get methodStream => _methodController.stream;

  late final Map<String, Peripheral> _peripherals = {};
  List<Peripheral> get connectedPeripheral => _peripherals.values
      .where((element) =>
          element.state == Peripheral.STATE_CONNECTING ||
          element.state == Peripheral.STATE_CONNECTED)
      .toList();

  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<int> getCentralState() async {
    int result = await methodChannel.invokeMethod("getCentralState") ??
        CENTRAL_STATE_UNKNOWN;
    return result;
  }

  Future<Result> startScan() async {
    _peripherals.removeWhere((key, value) =>
        value.state == Peripheral.STATE_DISCONNECTED ||
        value.state == Peripheral.STATE_DISCONNECTING);
    Map result = await methodChannel.invokeMethod("startScan");
    return Result.fromMap(result);
  }

  Future<Result> stopScan() async {
    Map result = await methodChannel.invokeMethod("stopScan");
    return Result.fromMap(result);
  }

  Future<Result> connect(String uuid) async {
    Map result = await methodChannel.invokeMethod("connect", {"uuid": uuid});
    return Result.fromMap(result);
  }

  Future<Result> disconnect(String uuid) async {
    Map result = await methodChannel.invokeMethod("disconnect", {"uuid": uuid});
    return Result.fromMap(result);
  }

  Future<Result> write(
      String uuid, String characteristicUUID, Uint8List data) async {
    Map result = await methodChannel.invokeMethod("write", {
      "uuid": uuid,
      "characteristicUUID": characteristicUUID,
      "data": data,
    });
    return Result.fromMap(result);
  }

  Future<void> gotoSettings() async =>
      await methodChannel.invokeMethod("gotoSettings");
  Future<bool> makeEnable() async {
    bool enable = await methodChannel.invokeMethod<bool>("makeEnable") ?? false;
    return enable;
  }
}
