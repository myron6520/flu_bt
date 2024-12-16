import 'dart:async';
import 'dart:io';

import 'package:flu_bt/define.dart';
import 'package:flu_bt/message.dart';
import 'package:flu_bt/peripheral.dart';
import 'package:flu_bt/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flu_bt_platform_interface.dart';

/// An implementation of [FluBtPlatform] that uses method channels.
class MethodChannelFluBt extends FluBtPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
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
          print("didReceiveDatadidReceiveDatadidReceiveData");
          Map info = call.arguments;
          String uuid = info["uuid"];
          String characteristicUUID = info["characteristicUUID"];
          Uint8List data = info["data"];
          _msgController.sink.add(Message(uuid, characteristicUUID, data));
          break;
        default:
          break;
      }
    });
  late final Map<String, Peripheral> _peripherals = {};
  late final StreamController<List<Peripheral>> _peripheralController =
      StreamController.broadcast();
  @override
  Stream<List<Peripheral>> get scanStream => _peripheralController.stream;
  late final StreamController<Peripheral> _peripheralStateController =
      StreamController.broadcast();
  @override
  Stream<Peripheral> get peripheralStateStream =>
      _peripheralStateController.stream;
  late final StreamController<int> _centralStateController =
      StreamController.broadcast();
  @override
  Stream<int> get centralStateStream => _centralStateController.stream;
  late final StreamController<Message> _msgController =
      StreamController.broadcast();
  @override
  Stream<Message> get msgStream => _msgController.stream;
  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  List<Peripheral> get connectedPeripheral => _peripherals.values
      .where((element) =>
          element.state == Peripheral.STATE_CONNECTING ||
          element.state == Peripheral.STATE_CONNECTED)
      .toList();

  @override
  Future<int> getCentralState() async {
    int result = await methodChannel.invokeMethod("getCentralState") ??
        CENTRAL_STATE_UNKNOWN;
    return result;
  }

  @override
  Future<Result> startScan() async {
    _peripherals.removeWhere((key, value) =>
        value.state == Peripheral.STATE_DISCONNECTED ||
        value.state == Peripheral.STATE_DISCONNECTING);
    Map result = await methodChannel.invokeMethod("startScan");
    return Result.fromMap(result);
  }

  @override
  Future<Result> stopScan() async {
    Map result = await methodChannel.invokeMethod("stopScan");
    return Result.fromMap(result);
  }

  @override
  Future<Result> connect(String uuid) async {
    Map result = await methodChannel.invokeMethod("connect", {"uuid": uuid});
    return Result.fromMap(result);
  }

  @override
  Future<Result> disconnect(String uuid) async {
    Map result = await methodChannel.invokeMethod("disconnect", {"uuid": uuid});
    return Result.fromMap(result);
  }

  @override
  Future<int> getMtu() async {
    if (Platform.isAndroid) {
      int result = await methodChannel.invokeMethod("getMtu") ?? 23;
      return result;
    } else {
      return 23;
    }
  }

  @override
  void requestMtu(String uuid, int mtu) async {
    await methodChannel.invokeMethod("requestMtu", {"uuid": uuid, "mtu": mtu});
  }

  @override
  Future<Result> write(
      String uuid, String characteristicUUID, Uint8List data) async {
    Map result = await methodChannel.invokeMethod("write", {
      "uuid": uuid,
      "characteristicUUID": characteristicUUID,
      "data": data,
    });
    return Result.fromMap(result);
  }

  @override
  Future<void> gotoSettings() async =>
      await methodChannel.invokeMethod("gotoSettings");
}
