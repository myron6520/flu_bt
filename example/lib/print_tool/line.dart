import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'page.dart';
import 'package:gbk_codec/gbk_codec.dart';

enum LineType {
  text,
  cut,
  barcode,
  divider,
  cashBox,
  newline,
  multiText,
  textSpan,
}

abstract class Line {
  final LineType type;
  Line({required this.type});
  Uint8List build(PageWidth pageWidth) => throw UnimplementedError();
}

enum Align {
  left,
  center,
  right,
}

extension AlignExOnString on String {
  Align? toAlign() {
    switch (this) {
      case 'left':
        return Align.left;
      case 'center':
        return Align.center;
      case 'right':
        return Align.right;
      default:
        return null;
    }
  }
}

class Cut extends Line {
  Cut() : super(type: LineType.cut);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x6D);
    return Uint8List.fromList(res);
  }
}

class Divider extends Line {
  final String character;
  Divider({this.character = "-"}) : super(type: LineType.divider);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x45);
    res.add(0x00);
    res.add(0x1D);
    res.add(0x21);
    res.add(0x00);

    int char = 0x2D;
    if (character.isNotEmpty) {
      char = utf8.encode(character.substring(0, 1))[0];
    }
    for (int j = 0; j < (pageWidth == PageWidth.p80 ? 48 : 32); j++) {
      res.add(char);
    }
    res.add(0x0A);
    return Uint8List.fromList(res);
  }
}

class CashBox extends Line {
  CashBox() : super(type: LineType.cashBox);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x70);
    res.add(0x00);
    res.add(0x30);
    res.add(0xFF);
    return Uint8List.fromList(res);
  }
}

class Barcode extends Line {
  final Align align;
  final int height;
  final int lineWidth;
  final bool isShowText;
  final String content;
  final bool needCodeB;
  Barcode({
    this.align = Align.center,
    this.height = 3 * 24,
    this.lineWidth = 2,
    this.isShowText = true,
    this.needCodeB = false,
    required this.content,
  }) : super(type: LineType.barcode);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x61);
    switch (align) {
      case Align.left:
        res.add(0x00);
        break;
      case Align.center:
        res.add(0x01);
        break;
      case Align.right:
        res.add(0x02);
        break;
    }

    res.add(0x1D);
    res.add(0x68);
    res.add(height);
    if (isShowText) {
      res.add(0x1D);
      res.add(0x48);
      res.add(0x02);
    }
    res.add(0x1D);
    res.add(0x77);
    res.add(lineWidth);

    res.add(0x1D);
    res.add(0x6B);
    res.add(0x49);
    final datas = utf8.encode(needCodeB ? "{B$content" : content);
    res.add(datas.length);
    res.addAll(datas);
    res.add(0x0A);
    return Uint8List.fromList(res);
  }
}

class NewLine extends Line {
  NewLine() : super(type: LineType.newline);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x45);
    res.add(0x00);
    res.add(0x1D);
    res.add(0x21);
    res.add(0x00);
    res.add(0x0A);
    return Uint8List.fromList(res);
  }
}

class Text extends Line {
  final String text;
  final Align align;
  final int size;
  final int bold;
  final int weight;
  Text({
    required this.text,
    this.align = Align.left,
    this.size = 0,
    this.bold = 0,
    this.weight = 0,
  }) : super(type: LineType.text);
  @override
  Uint8List build(PageWidth pageWidth) {
    List<int> res = [];
    res.add(0x1B);
    res.add(0x45);
    res.add(bold == 1 ? 0x01 : 0x00);
    res.add(0x1D);
    res.add(0x21);
    res.add((weight << 4 & 0xFF) | size);
    res.add(0x1B);
    res.add(0x61);
    switch (align) {
      case Align.left:
        res.add(0x00);
        break;
      case Align.center:
        res.add(0x01);
        break;
      case Align.right:
        res.add(0x02);
        break;
    }
    res.addAll(utf8.encode(text));
    res.add(0x0A);
    return Uint8List.fromList(res);
  }
}

class TextSpan {
  final String text;
  final Align align;
  final int width;
  final int flex;
  TextSpan(
      {required this.text,
      this.align = Align.left,
      this.width = 0,
      this.flex = 0});
}

class MultiText extends Line {
  final List<TextSpan> spans;
  final int weight;
  final int size;
  final int bold;
  MultiText(
      {required this.spans, this.weight = 0, this.size = 0, this.bold = 0})
      : super(type: LineType.multiText);
  @override
  Uint8List build(PageWidth pageWidth) {
    int total = 32;
    switch (weight) {
      case 0:
        total = 32;
        break;
      case 1:
        total = 16;
        break;
      case 2:
        total = 8;
        break;
    }
    if (pageWidth == PageWidth.p80) {
      switch (weight) {
        case 0:
          total = 48;
          break;
        case 1:
          total = 24;
          break;
        case 2:
          total = 12;
          break;
      }
    }
    List<int> res = [];
    String text = "";
    int totalFlex = 0;
    int totalWidth = 0;
    for (var span in spans) {
      totalFlex += span.width <= 0 ? span.flex : 0;
      totalWidth += span.width <= 0 ? 0 : span.width;
    }
    for (var span in spans) {
      int width = span.width;
      if (width == 0) {
        double ratio = span.flex / totalFlex;
        width = ((total - totalWidth) * ratio).toInt();
      }
      if (span.text.length > width) {
        text += span.text;
      } else {
        int white = width - span.text.length;
        switch (span.align) {
          case Align.left:
            text += span.text + " " * white;
            break;
          case Align.center:
            int len = max(white ~/ 2, 1);
            text += " " * len + span.text + " " * len;
            break;
          case Align.right:
            text += " " * white + span.text;
            break;
        }
      }
    }
    print("text: $text");
    res.addAll(Text(
      text: text,
      weight: weight,
      size: size,
      bold: bold,
      align: Align.left,
    ).build(pageWidth));
    return Uint8List.fromList(res);
  }
}
