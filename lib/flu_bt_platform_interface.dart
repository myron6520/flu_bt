import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flu_bt_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
