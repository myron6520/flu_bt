import 'package:flu_bt/flu_writer.dart';
import 'package:flu_bt/message.dart';
import 'package:flu_bt/peripheral.dart';
import 'package:flu_bt/result.dart';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flu_bt/flu_bt.dart';
import 'package:flu_bt/flu_bt_platform_interface.dart';
import 'package:flu_bt/flu_bt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluBtPlatform with MockPlatformInterfaceMixin implements FluBtPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Result> connect(String uuid) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<Result> disconnect(String uuid) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<Result> startScan() {
    // TODO: implement startScan
    throw UnimplementedError();
  }

  @override
  Future<Result> stopScan() {
    // TODO: implement stopScan
    throw UnimplementedError();
  }

  @override
  Future<Result> write(String uuid, String characteristicUUID, Uint8List data) {
    // TODO: implement write
    throw UnimplementedError();
  }

  @override
  Future<int> getCentralState() {
    // TODO: implement getCentralState
    throw UnimplementedError();
  }

  @override
  // TODO: implement connectedPeripheral
  List<Peripheral> get connectedPeripheral => throw UnimplementedError();

  @override
  // TODO: implement centralStateStream
  Stream<int> get centralStateStream => throw UnimplementedError();

  @override
  // TODO: implement peripheralStateStream
  Stream<Peripheral> get peripheralStateStream => throw UnimplementedError();

  @override
  // TODO: implement scanStream
  Stream<List<Peripheral>> get scanStream => throw UnimplementedError();

  @override
  // TODO: implement msgStream
  Stream<Message> get msgStream => throw UnimplementedError();

  @override
  Future<void> gotoSettings() {
    // TODO: implement gotoSettings
    throw UnimplementedError();
  }
}

void main() {
  final FluBtPlatform initialPlatform = FluBtPlatform.instance;

  test('$MethodChannelFluBt is the default instance', () {
    var singleton1 = FluWriter();
    var singleton2 = FluWriter.instance;

    // 验证两个实例是否相同
    print(identical(singleton1, singleton2));
    expect(initialPlatform, isInstanceOf<MethodChannelFluBt>());
  });

  test('getPlatformVersion', () async {
    FluBt fluBtPlugin = FluBt();
    MockFluBtPlatform fakePlatform = MockFluBtPlatform();
    FluBtPlatform.instance = fakePlatform;

    expect(await fluBtPlugin.getPlatformVersion(), '42');
  });
}
