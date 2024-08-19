import 'package:flu_bt/flu_bt.dart';
import 'package:flu_bt/flu_writer.dart';

class LabelPrintConfig {
  LabelPrintConfig._();
  static LabelPrintConfig? _instance;
  static LabelPrintConfig get instance => _instance ??= LabelPrintConfig._();
  factory LabelPrintConfig() => instance;
  FluBt fluBt = FluWriter().fluBt;
  Future<void> Function()? gotoConnectBluetooth;
}
