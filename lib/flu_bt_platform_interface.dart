import 'dart:typed_data';

import 'package:flu_bt/peripheral.dart';
import 'package:flu_bt/result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flu_bt_method_channel.dart';
import 'message.dart';

abstract class FluBtPlatform extends PlatformInterface {
  /// Constructs a FluBtPlatform.
  FluBtPlatform() : super(token: _token);

  static final Object _token = Object();

  static FluBtPlatform _instance = MethodChannelFluBt();

  /// The default instance of [FluBtPlatform] to use.
  ///
  /// Defaults to [MethodChannelFluBt].
  static FluBtPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FluBtPlatform] when
  /// they register themselves.
  static set instance(FluBtPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<List<Peripheral>> get scanStream =>
      throw UnimplementedError('platformVersion() has not been implemented.');
  Stream<Peripheral> get peripheralStateStream =>
      throw UnimplementedError('platformVersion() has not been implemented.');
  Stream<int> get centralStateStream =>
      throw UnimplementedError('platformVersion() has not been implemented.');
  List<Peripheral> get connectedPeripheral =>
      throw UnimplementedError('platformVersion() has not been implemented.');
  Stream<Message> get msgStream =>
      throw UnimplementedError('platformVersion() has not been implemented.');

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getCentralState() async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result> startScan() async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result> stopScan() async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result> connect(String uuid) async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result> disconnect(String uuid) async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Result> write(
      String uuid, String characteristicUUID, Uint8List data) async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> gotoSettings() async =>
      throw UnimplementedError('platformVersion() has not been implemented.');
}
