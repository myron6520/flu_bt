import 'dart:io';

import 'package:flu_bt/define.dart';
import 'package:flu_bt/flu_writer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:label_print/label_print.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/dialog/qm_alert_widget.dart';
import 'package:qm_widget/pub/scale_util.dart';
import 'package:qm_widget/qm_widget.dart';
import 'package:qm_widget/style/qm_icon.dart';
import 'package:qm_widget/wetool/wetool.dart';

import 'label_print_config.dart';
import 'offset_stepper.dart';

class LabelPrintSettingsPage extends StatefulWidget {
  final PrintSettings? settings;
  final void Function()? doNext;
  final void Function(PrintSettings settings)? onChanged;
  const LabelPrintSettingsPage(
      {super.key, this.settings, this.onChanged, this.doNext});

  @override
  State<LabelPrintSettingsPage> createState() => _LabelPrintSettingsPageState();
}

class _LabelPrintSettingsPageState extends State<LabelPrintSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return WTScaffold(
      title: '价签打印',
      backgroundColor: QMColor.COLOR_F7F9FA,
      appBarBackgroundColor: QMColor.COLOR_F7F9FA,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: QMColor.COLOR_F7F9FA,
      ),
      body: [
        [
          8.s.inColumn,
          "打印机管理"
              .toText(
                color: QMColor.COLOR_8F92A1,
                fontSize: 14.fs,
                height: 20 / 14,
              )
              .applyBackground(
                padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
              ),
          [
            [
              "连接蓝牙设备"
                  .toText(
                    color: QMColor.COLOR_030319,
                    fontSize: 16.fs,
                    height: 24 / 16,
                  )
                  .expanded,
              (LabelPrintConfig.instance.fluBt.connectedPeripheral.isNotEmpty
                      ? LabelPrintConfig
                          .instance.fluBt.connectedPeripheral.first.name
                      : '')
                  .toText(
                color: QMColor.COLOR_00B276,
                fontSize: 14.fs,
                height: 20 / 14,
              ),
              SvgPicture.asset(
                "assets/arrow.svg",
                package: "label_print",
                width: 24.s,
                height: 24.s,
              )
            ]
                .toRow()
                .applyBackground(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                )
                .onClick(click: () async {
              if (await checkCentralState()) {
                if (Platform.isAndroid) {
                  if (!(await requestPermission())) {
                    showNoPermissionAlert(context);
                    return;
                  }
                }
              } else {
                return;
              }
              await LabelPrintConfig.instance.gotoConnectBluetooth?.call();
              setState(() {});
            }),
            // SRStyle.COLOR_F2F2F2.toDivider(),
            [
              "打印指令"
                  .toText(
                    color: QMColor.COLOR_030319,
                    fontSize: 16.fs,
                    height: 24 / 16,
                  )
                  .expanded,
              settings.protocol.name.toText(
                color: QMColor.COLOR_8F92A1,
                fontSize: 14.fs,
                height: 20 / 14,
              ),
              SvgPicture.asset(
                "assets/arrow.svg",
                package: "label_print",
                width: 24.s,
                height: 24.s,
              )
            ]
                .toRow()
                .applyBackground(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                )
                .onClick(click: () => showCmdTypeSelector())
          ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .applyBackground(
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.s),
                    color: Colors.white,
                  )),
          "价签打印"
              .toText(
                color: QMColor.COLOR_8F92A1,
                fontSize: 14.fs,
                height: 20 / 14,
              )
              .applyBackground(
                padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
              ),
          [
            [
              "价签样式"
                  .toText(
                    color: QMColor.COLOR_030319,
                    fontSize: 16.fs,
                    height: 24 / 16,
                  )
                  .expanded,
              settings.style.name.toText(
                color: QMColor.COLOR_8F92A1,
                fontSize: 14.fs,
                height: 20 / 14,
              ),
              SvgPicture.asset(
                "assets/arrow.svg",
                package: "label_print",
                width: 24.s,
                height: 24.s,
              )
            ]
                .toRow()
                .applyBackground(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                )
                .onClick(click: () {
              Navigator.of(context)
                  .push(CupertinoPageRoute(
                builder: (context) => LabelStyleSelectorPage(
                  style: settings.style,
                  didSelected: (p) {
                    settings.style = p;
                    setState(() {});
                    Navigator.of(context).pop();
                    onSettingsChanged();
                  },
                ),
              ))
                  .then((value) {
                setState(() {});
              });
            }),
            settings.style.reverseEnable.toWidget(
              () => [
                "反向标签"
                    .toText(
                      color: QMColor.COLOR_030319,
                      fontSize: 16.fs,
                      height: 24 / 16,
                    )
                    .expanded,
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                      value: settings.reverse,
                      activeColor: Color(0xFF2ECC72),
                      onChanged: (_) {
                        settings.reverse = !settings.reverse;
                        setState(() {});
                        onSettingsChanged();
                      }),
                )
              ].toRow().applyBackground(
                    padding: EdgeInsets.symmetric(vertical: 12.s),
                  ),
            )
          ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .applyBackground(
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.s),
                    color: Colors.white,
                  )),
          "纸张设置"
              .toText(
                color: QMColor.COLOR_8F92A1,
                fontSize: 14.fs,
                height: 20 / 14,
              )
              .applyBackground(
                padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
              ),
          [
            [
              "水平偏移"
                  .toText(
                    color: QMColor.COLOR_030319,
                    fontSize: 16.fs,
                    height: 24 / 16,
                  )
                  .expanded,
              OffsetStepper(
                key: ValueKey(settings.offset.dx),
                value: settings.offset.dx.toInt(),
                onChanged: (value) {
                  settings.offset =
                      Offset(value.toDouble(), settings.offset.dy);
                  onSettingsChanged();
                },
              ),
            ].toRow().applyBackground(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                ),
            [
              "垂直偏移"
                  .toText(
                    color: QMColor.COLOR_030319,
                    fontSize: 16.fs,
                    height: 24 / 16,
                  )
                  .expanded,
              OffsetStepper(
                key: ValueKey(settings.offset.dy),
                isVertical: true,
                value: settings.offset.dy.toInt(),
                onChanged: (value) {
                  settings.offset =
                      Offset(settings.offset.dx, value.toDouble());
                  onSettingsChanged();
                },
              ),
            ].toRow().applyBackground(
                  padding: EdgeInsets.symmetric(vertical: 16.s),
                ),
          ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .applyBackground(
                  padding: EdgeInsets.symmetric(horizontal: 16.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.s),
                    color: Colors.white,
                  )),
        ]
            .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
            .applyBackground(
              padding: EdgeInsets.symmetric(horizontal: 16.s),
            )
            .toScrollView()
            .expanded,
        ThemeButton(
          height: 44.s,
          childBuilder: (_) =>
              (widget.doNext != null ? '保存并打印' : '测试打印').toText(
            fontSize: 16.fs,
            height: 24 / 16,
            color: Colors.white,
          ),
          borderRadius: 8.s,
          backgroundColor: QMColor.COLOR_00B276,
          highlightColor: QMColor.COLOR_00B276.applyOpacity(0.4),
          onClick: () {
            (widget.doNext ?? doTest).call();
          },
        ).applyPadding(
          EdgeInsets.all(16.s),
        )
      ].toColumn().toSafe(),
    );
  }

  late PrintSettings settings = widget.settings ?? PrintSettings();
  Future<bool> checkCentralState() async {
    int state = await LabelPrintConfig.instance.fluBt.getCentralState();
    if (state != CENTRAL_STATE_POWER_ON) {
      if (Platform.isAndroid) {
        await LabelPrintConfig.instance.fluBt.makeEnable();
        state = await LabelPrintConfig.instance.fluBt.getCentralState();
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
                  LabelPrintConfig.instance.fluBt.gotoSettings();
                },
              ).applyUnconstrainedBox());
      return false;
    }
    return true;
  }

  Future<void> showNoPermissionAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => Material(
          color: Colors.transparent,
          child: QMAlertWidget(
            title: "提示",
            message: "需要您的授权才能进行下一步操作",
            handles: [
              QMHandleStyle.gray(),
              QMHandleStyle.primary(title: "去授权"),
            ],
            onHandleItemClick: (idx, _) {
              if (idx == 1) {
                LabelPrintConfig.instance.fluBt.gotoSettings();
              }
            },
          ).applyUnconstrainedBox()),
    );
  }

  Future<bool> requestPermission() async {
    PermissionStatus bleStatus = await Permission.bluetooth.status;

    PermissionStatus bluetoothScan = await Permission.bluetoothScan.status;

    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.status;

    PermissionStatus locationStatus = await Permission.location.status;

    return bleStatus.isGranted &&
        bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        locationStatus.isGranted;
  }

  void showCmdTypeSelector() {
    final list = [PrintProtocol.TSPL, PrintProtocol.CPCL];
    WTBottomSheetContailer(
        title: "选择打印指令",
        child: WTSelectorWidget(
          length: 2,
          getTitleFunc: (idx) => list[idx].strVal,
          getIsSelectedFunc: (idx) => settings.protocol == list[idx],
          onSelected: (idx) {
            settings.protocol = list[idx];
            setState(() {});
            onSettingsChanged();
          },
        )).show(context);
    return;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => [
        6.s.inColumn,
        Container(
          height: 4.s,
          width: 36.s,
          decoration: BoxDecoration(
            color: QMColor.COLOR_F2F2F2,
            borderRadius: BorderRadius.circular(100.s),
          ),
        ),
        6.s.inColumn,
        16.s.inColumn,
        "选择打印指令"
            .toText(
              color: QMColor.COLOR_030319,
              fontSize: 18.fs,
              height: 24 / 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            )
            .expanded
            .toRow(),
        16.s.inColumn,
        ...([PrintProtocol.TSPL, PrintProtocol.CPCL]
            .expand(
              (e) => [
                [
                  e.strVal
                      .toText(
                        color: QMColor.COLOR_030319,
                        fontSize: 16.fs,
                        height: 24 / 16,
                      )
                      .expanded,
                  (settings.protocol == e).toWidget(() => SvgPicture.string(
                        WTIcon.CHECKED_ROUND,
                        width: 20.s,
                        height: 20.s,
                      )),
                ]
                    .toRow()
                    .applyPadding(
                        EdgeInsets.symmetric(horizontal: 24.s, vertical: 16.s))
                    .onClick(click: () {
                  settings.protocol = e;
                  Navigator.of(context).pop();
                  setState(() {});
                  onSettingsChanged();
                }),
                QMColor.COLOR_F7F9FA
                    .toContainer(height: 1.s)
                    .applyPadding(EdgeInsets.symmetric(horizontal: 24.s)),
              ],
            )
            .toList()
          ..removeLast()),
        32.s.inColumn,
      ].toColumn(mainAxisSize: MainAxisSize.min).toSafe().applyBackground(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.s)),
            ),
          ),
    );
  }

  void onSettingsChanged() {
    widget.onChanged?.call(settings);
  }

  void doTest() async {
    if (LabelPrintConfig.instance.fluBt.connectedPeripheral.isEmpty) {
      EasyLoading.showError('请连接打印机');
      return;
    }

    Uint8List cmd = await settings.style.buildPrintCmd(
      shopName: "微兔便利店",
      name: "测试商品",
      barcode: "93123823131310",
      spec: "500ml",
      sellPrice: 12.45,
      settings: settings,
    );
    if (cmd.isNotEmpty) {
      EasyLoading.show();
      FluWriter().doWrite(
          cmd, LabelPrintConfig.instance.fluBt.connectedPeripheral.first.uuid,
          interval: Duration(milliseconds: 500));
      EasyLoading.dismiss();
    }
  }
}
