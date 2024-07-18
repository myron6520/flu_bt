import 'dart:async';
import 'dart:math';

import 'package:flu_bt/flu_bt.dart';
import 'package:flu_bt/peripheral.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FluWriter {
  FluWriter._() {
    fluBt = FluBt();
    methodSubscription = fluBt.methodStream.listen((method) => _onMethodCall(method));
  }
  static FluWriter? _instance;
  static FluWriter get instance => _instance ??= FluWriter._();
  factory FluWriter() => instance;
  late FluBt fluBt;
  late StreamSubscription<MethodCall> methodSubscription;
  void _onMethodCall(MethodCall call) {
    if (call.method == "onBluetoothReady") {
      debugPrint("onBluetoothReady");
    }
    if (call.method == "onCharacteristicWrite") {
      Map info = call.arguments;
      String uuid = "${info['uuid']}";
      debugPrint("uuid:$uuid");
      _sendingInfos[uuid] = false;
      _doSend(uuid);
    }
  }

  Peripheral? getPeripheral(String uuid) {
    for (var peripheral in fluBt.connectedPeripheral) {
      if (peripheral.uuid == uuid) return peripheral;
    }
    return null;
  }

  final Map<String, List<FluCmd>> _buffer = {};
  final Map<String, bool> _sendingInfos = {};
  Future<void> _doSend(String uuid) async {
    if (_sendingInfos[uuid] == true) {
      return;
    }

    List<FluCmd> cmds = _buffer[uuid] ?? [];
    if (cmds.isNotEmpty) {
      Peripheral? peripheral = getPeripheral(uuid);
      if (peripheral == null) {
        _sendingInfos[uuid] = false;
        debugPrint("设备未连接");
        return;
      }
      _sendingInfos[uuid] = true;
      FluCmd cmd = cmds.first;
      List<int> dataToWrite = cmd.cmd;
      int endIdx = min(20, dataToWrite.length);
      List<int> data = dataToWrite.sublist(0, endIdx);
      fluBt.write(peripheral.uuid, "", Uint8List.fromList(data));
      dataToWrite.removeRange(0, endIdx);
      if (dataToWrite.isEmpty) {
        cmds.removeAt(0);
        if (cmd.interval > Duration.zero) {
          await Future.delayed(cmd.interval);
        }
      }
    } else {
      _sendingInfos[uuid] = false;
    }
  }

  void doWrite(
    List<int> content,
    String uuid, {
    Duration interval = Duration.zero,
  }) {
    for (var peripheral in fluBt.connectedPeripheral) {
      if (uuid.isEmpty || uuid == "*" || peripheral.uuid == uuid) {
        List<FluCmd> cmds = _buffer[uuid] ?? [];
        cmds.add(FluCmd(cmd: List.from(content), interval: interval));
        _buffer[uuid] = cmds;
        _doSend(uuid);
      }
    }
  }
}

class FluCmd {
  final List<int> cmd;
  final Duration interval;

  FluCmd({required this.cmd, this.interval = Duration.zero});
}
