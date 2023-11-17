// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:flu_bt/define.dart';
import 'package:flu_bt_example/app_plugin.dart';
import 'package:flu_bt_example/ble_list_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flu_bt/flu_bt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/dialog/qm_alert_widget.dart';
import 'package:qm_widget/qm_widget.dart';
import 'package:qm_widget/widgets/qm_app_bar.dart';
import 'package:gbk_codec/gbk_codec.dart';

import 'app_color.dart';

enum PrintAlign {
  left,
  center,
  right,
}

extension PrintAlignExOnString on String {
  PrintAlign get toPrintAlign {
    switch (this.toLowerCase()) {
      case "left":
        return PrintAlign.left;
      case "right":
        return PrintAlign.right;
      case "center":
        return PrintAlign.center;
      default:
        return PrintAlign.left;
    }
  }
}

extension PrintAlignEx on PrintAlign {
  int get cmd {
    switch (this) {
      case PrintAlign.left:
        return 0x00;
      case PrintAlign.center:
        return 0x01;
      case PrintAlign.right:
        return 0x02;
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<MethodCall> methodSubscription;
  @override
  void initState() {
    super.initState();
    methodSubscription =
        AppPlugin.fluBt.methodStream.listen((method) => onMethodCall(method));
  }

  void onMethodCall(MethodCall call) {
    if (call.method == "onBluetoothReady") {
      debugPrint("onBluetoothReady");
    }
    if (call.method == "onCharacteristicWrite") {
      doSend();
    }
  }

  List<int> dataToWrite = [];
  void doSend() {
    if (dataToWrite.isNotEmpty) {
      int endIdx = min(20, dataToWrite.length);
      List<int> data = dataToWrite.sublist(0, endIdx);
      dataToWrite.removeRange(0, endIdx);
      for (var peripheral in AppPlugin.fluBt.connectedPeripheral) {
        AppPlugin.fluBt.write(peripheral.uuid, "", Uint8List.fromList(data));
      }
    }
  }

  void doPost(List<int> content) {
    dataToWrite.addAll(content);
    doSend();
  }

  Uint8List buildTextData(
    String data, {
    bool bold = false,
    PrintAlign align = PrintAlign.left,
    int size = 0,
    int weight = 0,
  }) {
    //80 48 //58 32
    List<int> content = [];

    content.add(0x1B);
    content.add(0x45);
    content.add(bold ? 0x01 : 0x00);

    content.add(0x1B);
    content.add(0x61);
    content.add(align.cmd);

    content.add(0x1D);
    content.add(0x21);
    //0-2 字符高度，4-7字符宽度
    content.add((weight << 4 & 0xFF) | size);

    content.addAll(gbk_bytes.encode(data));
    return Uint8List.fromList(content);
  }

  Uint8List buildTitle(String title, {int width = 58}) {
    ///58 标题打8个字
    int count = width == 58 ? 8 : 10;
    String cnt = title;
    List<int> content = [];
    while (cnt.length >= count) {
      String text = cnt.substring(0, count);
      cnt = cnt.substring(count);
      content.addAll(buildTextData("$text  ",
          size: 1, weight: 1, bold: true, align: PrintAlign.left));
      content.add(0X0A);
    }
    if (cnt.isNotEmpty) {
      cnt = " " * (count - cnt.length) + "$cnt";
      content.addAll(buildTextData(cnt,
          size: 1, weight: 1, bold: true, align: PrintAlign.left));
      content.add(0X0A);
    }
    return Uint8List.fromList(content);
  }

  void doTest() {
    List<int> content = [];
    content.addAll(buildTitle("微兔打印测试这个是测试是测试啊", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.addAll(buildTitle("微兔便利店", width: 58));
    content.add(0x0a);
    doPost(content);
  }

  @override
  void dispose() {
    methodSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: App.navigatorKey,
      home: Scaffold(
        appBar: QMAppBar(
          backgroundColor: AppColor.COLOR_0F191B,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Icon(
            Icons.bluetooth,
            size: 24,
            color: Colors.blue.applyOpacity(
                AppPlugin.fluBt.connectedPeripheral.isEmpty ? 0.2 : 1),
          )
              .applyPadding(EdgeInsets.symmetric(horizontal: 16))
              .onClick(click: () => readPeer()),
          titleWidget: [
            "FluBt".toText(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1),
          ].toRow(mainAxisAlignment: MainAxisAlignment.center),
        ),
        body: [
          ThemeButton(
            childBuilder: (_) => "测试".toText(),
            onClick: () => doTest(),
            width: 90,
            backgroundColor: Colors.blue,
          ).toRow(mainAxisAlignment: MainAxisAlignment.center)
        ].toColumn(mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  void readPeer() async {
    if (await checkCentralState()) {
      if (Platform.isAndroid) {
        if (!(await requestPermission())) {
          openAppSettings();
          return;
        }
      }

      App.push(BLEListPage())?.then((value) => setState(
            () {},
          ));
    }
  }

  Future<bool> checkCentralState() async {
    int state = await AppPlugin.fluBt.getCentralState();
    if (state != CENTRAL_STATE_POWER_ON) {
      if (Platform.isAndroid) {
        await AppPlugin.fluBt.makeEnable();
        state = await AppPlugin.fluBt.getCentralState();
        if (state == CENTRAL_STATE_POWER_ON) {
          return true;
        }
      }
      showDialog(
          context: context,
          builder: (_) => QMAlertWidget(
                title: "提示",
                message: "蓝牙未开启，请开启蓝牙",
                handles: [
                  QMHandleStyle.primary(title: "去设置"),
                ],
                onHandleItemClick: (idx, _) {
                  AppPlugin.fluBt.gotoSettings();
                },
              ).applyUnconstrainedBox());
      return false;
    }
    return true;
  }

  Future<bool> requestPermission() async {
    PermissionStatus bleStatus = await Permission.bluetooth.status;
    if (!bleStatus.isGranted) {
      bleStatus = await Permission.bluetooth.request();
    }
    PermissionStatus bluetoothScan = await Permission.bluetoothScan.status;
    if (!bluetoothScan.isGranted) {
      bluetoothScan = await Permission.bluetoothScan.request();
    }
    PermissionStatus locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
    }
    PermissionStatus bluetoothConnectStatus =
        await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    }

    return bleStatus.isGranted &&
        bluetoothScan.isGranted &&
        bluetoothConnectStatus.isGranted &&
        locationStatus.isGranted;
  }
}
