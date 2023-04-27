
import 'flu_bt_platform_interface.dart';

class FluBt {
  Future<String?> getPlatformVersion() {
    return FluBtPlatform.instance.getPlatformVersion();
  }
}
