import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flu_bt_platform_interface.dart';

/// An implementation of [FluBtPlatform] that uses method channels.
class MethodChannelFluBt extends FluBtPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flu_bt');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
