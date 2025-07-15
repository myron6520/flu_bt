import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:label_print/label_print.dart';
import 'package:print_cmd/tsc/label_command.dart';
import 'package:print_cmd/tsc/label_helper.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:common_lang/common_lang.dart';

class LabelStyle {
  static LabelStyle style1 = LabelStyle(
    uuid: "_style1",
    name: S.current.super_market_template_a,
    iconAsset: "assets/style1.svg",
    size: Size(70, 38),
    reverseEnable: true,
  );
  static LabelStyle style2 = LabelStyle(
    uuid: "_style2",
    name: S.current.super_market_template_b,
    iconAsset: "assets/style2.svg",
    size: Size(70, 38),
    reverseEnable: true,
  );
  static LabelStyle style3 = LabelStyle(
    uuid: "_style3",
    name: S.current.white_label,
    iconAsset: "assets/style3.svg",
    size: Size(70, 38),
    reverseEnable: true,
  );
  static LabelStyle style4 = LabelStyle(
    uuid: "_style4",
    name: S.current.white_label,
    iconAsset: "assets/style4.svg",
    size: Size(70, 38),
    reverseEnable: true,
  );
  static LabelStyle style5 = LabelStyle(
    uuid: "_style5",
    name: S.current.white_label,
    iconAsset: "assets/style5.svg",
    size: Size(40, 30),
    reverseEnable: true,
  );

  final String uuid;
  final String name;
  final String iconAsset;
  final Size size;
  final bool reverseEnable;

  const LabelStyle({
    required this.uuid,
    required this.name,
    required this.iconAsset,
    required this.size,
    required this.reverseEnable,
  });
  Map get mapForSave => {
        "uuid": uuid,
        "name": name,
        "iconAsset": iconAsset,
        "size": {
          "width": size.width,
          "height": size.height,
        },
        "reverseEnable": reverseEnable,
      };
  LabelStyle.fromMapForSave(Map map)
      : uuid = '${map["uuid"] ?? ''}',
        name = '${map["name"] ?? ''}',
        iconAsset = '${map["iconAsset"] ?? ''}',
        size = Size(double.tryParse('${map["size"]?["width"]}') ?? 0,
            double.tryParse('${map["size"]?["height"]}') ?? 0),
        reverseEnable = bool.tryParse('${map["iconAsset"] ?? ''}') ?? false;
  @override
  operator ==(Object other) =>
      other is LabelStyle && name == other.name && iconAsset == other.iconAsset;
  Future<Uint8List> buildPrintCmd({
    required String shopName,
    required String name,
    required String barcode,
    required String spec,
    required double sellPrice,
    required PrintSettings settings,
  }) async {
    int offsetX = settings.offset.dx.toInt();
    int offsetY = settings.offset.dy.toInt();
    if (uuid == "_style1") {
      LabelCommand cmd = LabelCommand();
      if (settings.protocol == PrintProtocol.CPCL) {
        cmd.addStr("! 0 200 200 300 1\r\n");
        cmd.addStr("PW 560\r\n");
        cmd.addStr("TONE 0\r\n");
        cmd.addStr("SPEED 4\r\n");
        cmd.addStr("SETBOLD 1\r\n");
        cmd.addStr("LEFT\r\n");
        if (settings.reverse) {
          cmd.addStr(
              "TEXT180 4 0 ${280 + offsetX} ${248 + offsetY} $shopName\r\n");
          cmd.addStr("TEXT180 4 0 ${440 + offsetX} ${192 + offsetY} $name\r\n");
          cmd.addStr("SETBOLD 0\r\n");
          cmd.addStr("TEXT180 4 0 ${480 + offsetX} ${110 + offsetY} $spec\r\n");
          cmd.addStr("SETBOLD 0\r\n");
          cmd.addStr(
              "TEXT180 4 2 ${150 + offsetX} ${60 + offsetY} ${sellPrice.awesome()}\r\n");
          cmd.addStr(
              "BARCODE 128 1 2 50 ${240 + offsetX} ${20 + offsetY} $barcode\r\n");
        } else {
          cmd.addStr("TEXT 4 0 ${260 + offsetX} ${0 + offsetY} $shopName\r\n");
          cmd.addStr("TEXT 4 0 ${100 + offsetX} ${40 + offsetY} $name\r\n");
          cmd.addStr("TEXT 4 0 ${80 + offsetX} ${130 + offsetY} $spec\r\n");
          cmd.addStr(
              "TEXT 4 2 ${380 + offsetX} ${200 + offsetY} ${sellPrice.awesome()}\r\n");
          cmd.addStr(
              "BARCODE 128 1 2 50 ${80 + offsetX} ${170 + offsetY} $barcode\r\n");
        }
        cmd.addStr("FORM\r\n");
        cmd.addStr("PRINT\r\n");
        return cmd.command;
      }
      if (settings.protocol == PrintProtocol.TSPL) {
        cmd.addSize(70, 38);
        if (settings.reverse) {
          cmd.addText(shopName, 320 + offsetX, 280 + offsetY, rotation: 180);
          cmd.addText(name, 464 + offsetX, 224 + offsetY, rotation: 180);
          cmd.addText(spec, 496 + offsetX, 144 + offsetY, rotation: 180);
          cmd.addBarcode(barcode, 496 + offsetX, 104 + offsetY, 56, false,
              rotation: 180);
          cmd.addText(sellPrice.awesome(), 192 + offsetX, 80 + offsetY,
              scale: 2, rotation: 180);
        } else {
          cmd.addText(shopName, 320 + offsetX, 24 + offsetY);
          cmd.addText(name, 136 + offsetX, 76 + offsetY);
          cmd.addText(spec, 112 + offsetX, 160 + offsetY);
          cmd.addBarcode(barcode, 112 + offsetX, 200 + offsetY, 56, false);
          cmd.addText(sellPrice.awesome(), 416 + offsetX, 224 + offsetY,
              scale: 2);
        }
        cmd.addPrint();
        return cmd.command;
      }
    }
    if (uuid == "_style5") {
      if (settings.protocol == PrintProtocol.TSPL) {
        return LabelHelper.build4030TsplRetail(
          shopName: shopName,
          name: name,
          barcode: barcode,
          spec: spec,
          sellPrice: sellPrice.awesome(),
          offsetX: settings.offset.dx.toInt(),
          offsetY: settings.offset.dy.toInt(),
        );
      }
      if (settings.protocol == PrintProtocol.CPCL) {
        return LabelHelper.build4030CpclRetail(
          shopName: shopName,
          name: name,
          barcode: barcode,
          spec: spec,
          sellPrice: sellPrice.awesome(),
          offsetX: settings.offset.dx.toInt(),
          offsetY: settings.offset.dy.toInt(),
        );
      }
    }
    return Uint8List(0);
  }
}
