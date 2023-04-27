import 'package:flutter_test/flutter_test.dart';
import 'package:flu_bt/flu_bt.dart';
import 'package:flu_bt/flu_bt_platform_interface.dart';
import 'package:flu_bt/flu_bt_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluBtPlatform
    with MockPlatformInterfaceMixin
    implements FluBtPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FluBtPlatform initialPlatform = FluBtPlatform.instance;

  test('$MethodChannelFluBt is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFluBt>());
  });

  test('getPlatformVersion', () async {
    FluBt fluBtPlugin = FluBt();
    MockFluBtPlatform fakePlatform = MockFluBtPlatform();
    FluBtPlatform.instance = fakePlatform;

    expect(await fluBtPlugin.getPlatformVersion(), '42');
  });
}
