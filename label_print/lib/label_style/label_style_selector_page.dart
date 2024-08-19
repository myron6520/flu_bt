import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/pub/scale_util.dart';
import 'package:qm_widget/qm_widget.dart';
import 'package:qm_widget/style/qm_icon.dart';
import 'package:qm_widget/wetool/wetool.dart';

import 'label_style.dart';

class LabelStyleSelectorPage extends StatefulWidget {
  final List<LabelStyle> styles;
  final LabelStyle? style;
  final void Function(LabelStyle style)? didSelected;
  const LabelStyleSelectorPage(
      {super.key, this.styles = const [], this.style, this.didSelected});

  @override
  State<LabelStyleSelectorPage> createState() => _LabelStyleSelectorPageState();
}

class _LabelStyleSelectorPageState extends State<LabelStyleSelectorPage> {
  Widget buildLabelStyleWidget(LabelStyle style) => [
        SvgPicture.asset(
          style.iconAsset,
          width: style.size.width * 2.5.s,
          height: style.size.height * 2.5.s,
          package: "label_print",
        ).applyBackground(
          alignment: Alignment.center,
          color: QMColor.COLOR_F2F4F5,
          height: 120.s,
        ),
        16.s.inColumn,
        [
          SvgPicture.string(
              style == this.style ? WTIcon.CHECKED_ROUND : WTIcon.UNCHECK_ROUND,
              width: 24.s,
              height: 24.s),
          12.s.inRow,
          [
            style.name.toText(
              color: Colors.black,
              fontSize: 16.fs,
              height: 24 / 16,
            ),
            '${style.size.width.awesome()}x${style.size.height.awesome()}mm'
                .toText(
              color: Colors.black,
              fontSize: 12.fs,
              height: 18 / 12,
            ),
          ]
              .toColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
              )
              .expanded,
        ].toRow().applyBackground(padding: EdgeInsets.all(16.s)),
      ]
          .toColumn()
          .applyBackground(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.s),
              ))
          .onTouch(onTap: () {
        if (this.style != style) {
          this.style = style;
          setState(() {});
          widget.didSelected?.call(style);
        }
      });
  @override
  Widget build(BuildContext context) {
    return WTScaffold(
      title: "标签样式",
      appBarBackgroundColor: Colors.white,
      backgroundColor: QMColor.COLOR_F7F9FA,
      body: [
        12.s.inColumn,
        ...styles.expand((element) => [
              buildLabelStyleWidget(element),
              12.s.inColumn,
            ]),
      ]
          .toColumn()
          .applyBackground(padding: EdgeInsets.symmetric(horizontal: 16.s))
          .toScrollView()
          .toSafe(),
    );
  }

  late List<LabelStyle> styles = widget.styles.isNotEmpty
      ? widget.styles
      : [
          LabelStyle.style1,
          LabelStyle.style2,
          // LabelStyle.style3,
          // LabelStyle.style4,
          LabelStyle.style5,
        ];
  late LabelStyle? style = widget.style;
}
