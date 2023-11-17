import 'package:flutter/material.dart';
import 'package:qm_dart_ex/qm_dart_ex.dart';
import 'package:qm_widget/qm_widget.dart';

class AppColor {
  static const COLOR_10EAD7 = Color(0xFF10EAD7);
  static const COLOR_59EC7F = Color(0xFF59EC7F);

  static const COLOR_0F191B = Color(0xFF0F191B);
  static const COLOR_1A1A1A = Color(0xFF1A1A1A);
  static const COLOR_22252C = Color(0xFF22252C);
  static const COLOR_1D252A = Color(0xFF1D252A);
  static const COLOR_384045 = Color(0xFF384045);
  static const COLOR_2B3238 = Color(0xFF2B3238);
  static const COLOR_858585 = Color(0xFF858585);
  static const COLOR_030604 = Color(0xFF030604);

  static const COLOR_A6AAAD = Color(0xFFA6AAAD);

  static const COLOR_F9F9F9 = Color(0xFFF9F9F9);
  static const COLOR_EEEEEE = Color(0xFFEEEEEE);
  static const COLOR_FF9B0A = Color(0xFFFF9B0A);
  static const COLOR_03C878 = Color(0xFF03C878);

  static const COLOR_F14931 = Color(0xFFF14931);
  static const COLOR_FF4545 = Color(0xFFFF4545);
  static const COLOR_576487 = Color(0xFF576487);
  static const COLOR_FEEDC5 = Color(0xFFFEEDC5);
  static const COLOR_049BE2 = Color(0xFF049BE2);
  static const COLOR_01ACE2 = Color(0xFF01ACE2);
  static const COLOR_AAAAAA = Color(0xFFAAAAAA);
}

class AppStyle {
  static double padding = 12;
  static BoxDecoration gradientDecoration({
    double radius = 0,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.COLOR_10EAD7,
            AppColor.COLOR_59EC7F,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      );
  static BoxDecoration highGradientDecoration({
    double radius = 0,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.COLOR_10EAD7.applyOpacity(0.7),
            AppColor.COLOR_59EC7F.applyOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      );
  static Widget buildTitleWidget(String title) => title.toText(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  static Widget buildThemeBtn(
    String title, {
    BuildContext? context,
    double? height,
    double? width,
    double borderRadius = 6,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.bold,
    Function()? onClick,
    Color textColor = AppColor.COLOR_030604,
  }) {
    Widget child = title.toText(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    return BaseButton(
      height: height,
      width: width,
      padding: EdgeInsets.zero,
      descBuilder: (state) {
        if (state == ButtonState.normal)
          return ButtonDesc(
              child: child,
              decoration: AppStyle.gradientDecoration(radius: borderRadius));
        if (state == ButtonState.highlight)
          return ButtonDesc(
              child: child,
              decoration:
                  AppStyle.highGradientDecoration(radius: borderRadius));
        return null;
      },
      onClick: onClick,
    );
  }

  static Widget buildNormalBtn(
    String title, {
    BuildContext? context,
    double? height,
    double? width,
    double borderRadius = 6,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.bold,
    Function()? onClick,
    Color textColor = Colors.white,
  }) {
    Widget child = title.toText(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    return BaseButton(
      height: height,
      width: width,
      padding: EdgeInsets.zero,
      descBuilder: (state) {
        if (state == ButtonState.normal)
          return ButtonDesc(
              child: child,
              decoration: BoxDecoration(
                  color: AppColor.COLOR_A6AAAD,
                  borderRadius: BorderRadius.circular(borderRadius)));
        if (state == ButtonState.highlight)
          return ButtonDesc(
              child: child,
              decoration: BoxDecoration(
                  color: AppColor.COLOR_A6AAAD.applyOpacity(0.7),
                  borderRadius: BorderRadius.circular(borderRadius)));
        return null;
      },
      onClick: onClick,
    );
  }

  static Widget buildBorderBtn(
    String title, {
    BuildContext? context,
    double? height,
    double? width,
    double borderRadius = 100,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Function()? onClick,
  }) {
    Widget child = title.toText(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    return BaseButton(
      height: height,
      width: width,
      padding: EdgeInsets.zero,
      descBuilder: (state) {
        if (state == ButtonState.normal)
          return ButtonDesc(
            child: child,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.COLOR_10EAD7,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
        if (state == ButtonState.highlight)
          return ButtonDesc(
            child: child,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.COLOR_10EAD7.applyOpacity(0.7),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
        return null;
      },
      onClick: onClick,
    );
  }
}
