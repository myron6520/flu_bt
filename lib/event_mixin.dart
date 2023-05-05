import 'dart:async';

import 'package:flu_bt/peripheral.dart';

import 'message.dart';

mixin EventMixin {
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
}
