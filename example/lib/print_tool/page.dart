import 'dart:typed_data';

import './line.dart';

enum PageWidth {
  p58,
  p80,
}

extension PageWidthExOnInt on int {
  PageWidth? toPageWidth() {
    switch (this) {
      case 58:
        return PageWidth.p58;
      case 80:
        return PageWidth.p80;
      default:
        return null;
    }
  }
}

class Page {
  final PageWidth pageWidth;
  final List<Line> _lines = [];
  Page({required this.pageWidth});
  Uint8List build() {
    List<int> content = [];
    for (var line in _lines) {
      content.addAll(line.build(pageWidth));
    }
    return Uint8List.fromList(content);
  }

  void addLine(Line line) {
    _lines.add(line);
  }

  void addLines(List<Line> lines) {
    _lines.addAll(lines);
  }
}
