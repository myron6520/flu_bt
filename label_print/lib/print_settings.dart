import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:label_print/label_print.dart';

enum PrintProtocol {
  TSPL,
  CPCL,
}

extension PrintProtocolExOnString on String {
  PrintProtocol? get toPrintProtocol {
    switch (this) {
      case "TSPL":
        return PrintProtocol.TSPL;
      case "CPCL":
        return PrintProtocol.CPCL;
      default:
        return null;
    }
  }
}

extension PrintProtocolEx on PrintProtocol {
  String get strVal {
    switch (this) {
      case PrintProtocol.TSPL:
        return "TSPL";
      case PrintProtocol.CPCL:
        return "CPCL";
    }
  }
}

class PrintSettings {
  PrintProtocol protocol = PrintProtocol.TSPL;
  LabelStyle style = LabelStyle.style1;
  bool reverse = false;
  Offset offset = Offset.zero;
  String toJoin() {
    return json.encode({
      "protocol": protocol.strVal,
      "style": style.mapForSave,
      "reverse": reverse,
      "offset": {
        "dx": offset.dx,
        "dy": offset.dy,
      },
    });
  }

  static PrintSettings? fromJoin(String join) {
    try {
      var map = json.decode(join);
      return PrintSettings()
        ..protocol = (map["protocol"] as String).toPrintProtocol!
        ..style = LabelStyle.fromMapForSave(map["style"])
        ..reverse = bool.tryParse('${map["reverse"]}') ?? false
        ..offset = Offset(map["offset"]["dx"], map["offset"]["dy"]);
    } catch (e) {
      return null;
    }
  }
}
