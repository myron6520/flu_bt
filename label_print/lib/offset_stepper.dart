import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/pub/scale_util.dart';
import 'package:qm_widget/qm_widget.dart';

class OffsetStepper extends StatefulWidget {
  final bool isVertical;
  final int value;
  final void Function(int)? onChanged;
  const OffsetStepper({
    super.key,
    this.isVertical = false,
    this.value = 0,
    this.onChanged,
  });

  @override
  State<OffsetStepper> createState() => _OffsetStepperState();
}

class _OffsetStepperState extends State<OffsetStepper> {
  @override
  Widget build(BuildContext context) {
    return [
      buildHandleBtn(widget.isVertical ? 3 : 2)
          .applyTapWidget(
              normalColor: Color(0xFFF2F2F2),
              highlightColor: Color(0xFFE2E2E2),
              onClick: () {
                widget.isVertical ? value++ : value--;
                setState(() {});
                widget.onChanged?.call(value);
              })
          .applyRadius(4.s),
      "$value"
          .toText(
              fontSize: 12.fs,
              color: QMColor.COLOR_030319,
              height: 20 / 12,
              textAlign: TextAlign.center)
          .expanded
          .toRow()
          .applyBackground(
            width: 52.s,
          ),
      buildHandleBtn(widget.isVertical ? 1 : 0)
          .applyTapWidget(
              normalColor: QMColor.COLOR_F2F2F2,
              highlightColor: Color(0xFFE2E2E2),
              onClick: () {
                widget.isVertical ? value-- : value++;
                setState(() {});
                widget.onChanged?.call(value);
              })
          .applyRadius(4.s),
    ].toRow();
  }

  final String arrow =
      ''''<svg width="5" height="9" viewBox="0 0 5 9" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4.66699 4.05664L0.666992 8.05664V0.0566406L4.66699 4.05664Z" fill="#030319"/>
</svg>
''';
  Widget buildHandleBtn(int quarterTurns) => RotatedBox(
        quarterTurns: quarterTurns,
        child: SvgPicture.string(
          arrow,
          width: 4.s,
          height: 8.s,
        ),
      ).applyUnconstrainedBox().applyBackground(
            width: 24.s,
            height: 24.s,
          );

  late int value = widget.value;
}
