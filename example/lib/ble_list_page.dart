// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flu_bt/peripheral.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/app.dart';
import 'package:qm_widget/qm.dart';
import 'package:qm_widget/widgets/qm_app_bar.dart';

import 'app_color.dart';
import 'app_plugin.dart';

class BLEListPage extends StatefulWidget {
  BLEListPage({Key? key}) : super(key: key);

  @override
  State<BLEListPage> createState() => _BLEListPageState();
}

class _BLEListPageState extends State<BLEListPage> {
  Widget buildItemWidget(Peripheral peripheral) => [
        [
          (peripheral.name.isNotEmpty ? peripheral.name : "未命名").toText(
            color: Colors.white,
            fontSize: 16,
          ),
          4.inColumn,
          "RSSI:${peripheral.rssi}".toText(
            color: Colors.white,
            fontSize: 12,
          ),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded,
        12.inColumn,
        AppStyle.buildThemeBtn(
            peripheral.state == Peripheral.STATE_CONNECTED ? "断开连接" : "连接",
            width: 70,
            height: 35, onClick: () {
          if (peripheral.state == Peripheral.STATE_CONNECTED) {
            AppPlugin.fluBt.disconnect(peripheral.uuid);
            setState(() {});
          } else {
            AppPlugin.fluBt.stopScan();
            QM.showLoading(msg: "连接中");
            peripheralToConnect = peripheral;
            AppPlugin.fluBt.connect(peripheral.uuid);
          }
        }),
      ].toRow().applyBackground(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColor.COLOR_1D252A,
          );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QMAppBar(
        title: "请选择您的设备",
        tintColor: Colors.white,
        backgroundColor: AppColor.COLOR_0F191B,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: AppColor.COLOR_0F191B,
      body: ListView.separated(
          itemBuilder: (_, idx) => buildItemWidget(peripherals[idx]),
          separatorBuilder: (_, __) => AppColor.COLOR_0F191B.toDivider(),
          itemCount: peripherals.length),
    );
  }

  late StreamSubscription<List<Peripheral>> subscription;
  late StreamSubscription<Peripheral> peripheralSubscription;
  List<Peripheral> peripherals = [];
  Peripheral? peripheralToConnect;
  @override
  void initState() {
    super.initState();
    subscription = AppPlugin.fluBt.scanStream.listen((event) => setState(() {
          peripherals = event.where((e) => e.name.isNotEmpty).toList();
        }));
    peripheralSubscription =
        AppPlugin.fluBt.peripheralStateStream.listen((peripheral) {
      if (peripheral.uuid == peripheralToConnect?.uuid) {
        if (peripheral.state == Peripheral.STATE_CONNECTED) {
          QM.dismissLoading();
          setState(() {});
          App.tryToPop();
        }
        if (peripheral.state == Peripheral.STATE_DISCONNECTED) {
          setState(() {});
        }
      }
    });
    AppPlugin.fluBt.startScan();
  }

  @override
  void dispose() {
    subscription.cancel();
    peripheralSubscription.cancel();
    AppPlugin.fluBt.stopScan();
    super.dispose();
  }
}
