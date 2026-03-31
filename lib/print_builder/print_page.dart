enum PageWidth {
  width58(58),
  width80(80),
  custom(100);

  const PageWidth(this.value);
  final int value;

  static PageWidth fromValue(int value) {
    return PageWidth.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PageWidth.width58,
    );
  }
}

enum LineType {
  text(0),
  newLine(1),
  divider(2),
  barCode(3),
  qrCode(4),
  cashBox(5),
  cut(6);

  const LineType(this.value);
  final int value;

  static LineType fromValue(int value) {
    return LineType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LineType.text,
    );
  }
}

enum Cmd {
  esc(0),
  cpcl(1),
  tspl(2);

  const Cmd(this.value);
  final int value;

  static Cmd fromValue(int value) {
    return Cmd.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Cmd.esc,
    );
  }
}

enum Align {
  left(0),
  center(1),
  right(2);

  const Align(this.value);
  final int value;

  static Align fromValue(int value) {
    return Align.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Align.left,
    );
  }
}

enum ErrorCorrectionLevel {
  low(0),
  medium(1),
  quartile(2),
  high(3);

  const ErrorCorrectionLevel(this.value);
  final int value;

  static ErrorCorrectionLevel fromValue(int value) {
    return ErrorCorrectionLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ErrorCorrectionLevel.low,
    );
  }
}

class Page {
  final PageWidth pageWidth;
  final List<Line> lines;
  final Cmd cmd;

  const Page({
    required this.pageWidth,
    required this.lines,
    this.cmd = Cmd.esc,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      pageWidth: PageWidth.fromValue(
        (json['pageWidth'] ?? json['PageWidth'] ?? 58) as int,
      ),
      lines: ((json['lines'] ?? json['Lines']) as List<dynamic>? ?? const [])
          .map((e) => Line.fromJson(e as Map<String, dynamic>))
          .toList(),
      cmd: Cmd.fromValue((json['cmd'] ?? json['Cmd'] ?? 0) as int),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pageWidth': pageWidth.value,
      'lines': lines.map((e) => e.toJson()).toList(),
      'cmd': cmd.value,
    };
  }
}

class Line {
  final int size;
  final int weight;
  final bool bold;
  final LineType type;
  final List<Text> textList;
  final QrCode? qrCode;
  final BarCode? barCode;

  const Line({
    this.size = 0,
    this.weight = 0,
    this.bold = false,
    required this.type,
    this.textList = const [],
    this.qrCode,
    this.barCode,
  });

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      size: (json['size'] ?? json['Size'] ?? 0) as int,
      weight: (json['weight'] ?? json['Weight'] ?? 0) as int,
      bold: (json['bold'] ?? json['Bold'] ?? false) as bool,
      type: LineType.fromValue((json['type'] ?? json['Type'] ?? 0) as int),
      textList:
          ((json['textList'] ?? json['TextList']) as List<dynamic>? ?? const [])
              .map((e) => Text.fromJson(e as Map<String, dynamic>))
              .toList(),
      qrCode: (json['qrCode'] ?? json['QrCode']) == null
          ? null
          : QrCode.fromJson(
              (json['qrCode'] ?? json['QrCode']) as Map<String, dynamic>),
      barCode: (json['barCode'] ?? json['BarCode']) == null
          ? null
          : BarCode.fromJson(
              (json['barCode'] ?? json['BarCode']) as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'size': size,
      'weight': weight,
      'bold': bold,
      'type': type.value,
      'textList': textList.map((e) => e.toJson()).toList(),
      if (qrCode != null) 'qrCode': qrCode!.toJson(),
      if (barCode != null) 'barCode': barCode!.toJson(),
    };
  }
}

class BarCode {
  final String content;
  final bool codeB;
  final Align align;
  final int lineWidth;
  final int height;
  final bool showText;

  const BarCode({
    required this.content,
    this.codeB = false,
    this.align = Align.center,
    this.lineWidth = 2,
    this.height = 72,
    this.showText = true,
  });

  factory BarCode.fromJson(Map<String, dynamic> json) {
    return BarCode(
      content: (json['content'] ?? json['Content'] ?? '') as String,
      codeB: (json['codeB'] ?? json['CodeB'] ?? false) as bool,
      align: Align.fromValue((json['align'] ?? json['Align'] ?? 1) as int),
      lineWidth: (json['lineWidth'] ?? json['LineWidth'] ?? 2) as int,
      height: (json['height'] ?? json['Height'] ?? 72) as int,
      showText: (json['showText'] ?? json['ShowText'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'content': content,
      'codeB': codeB,
      'align': align.value,
      'lineWidth': lineWidth,
      'height': height,
      'showText': showText,
    };
  }
}

class QrCode {
  final String content;
  final int size;
  final Align align;
  final ErrorCorrectionLevel errorCorrectionLevel;

  const QrCode({
    required this.content,
    this.size = 6,
    this.align = Align.center,
    this.errorCorrectionLevel = ErrorCorrectionLevel.medium,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      content: (json['content'] ?? json['Content'] ?? '') as String,
      size: (json['size'] ?? json['Size'] ?? 6) as int,
      align: Align.fromValue((json['align'] ?? json['Align'] ?? 1) as int),
      errorCorrectionLevel: ErrorCorrectionLevel.fromValue(
        (json['errorCorrectionLevel'] ?? json['ErrorCorrectionLevel'] ?? 1)
            as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'content': content,
      'size': size,
      'align': align.value,
      'errorCorrectionLevel': errorCorrectionLevel.value,
    };
  }
}

class Text {
  final String content;
  final int flex;
  final int width;
  final Align align;
  final String gap;

  const Text({
    required this.content,
    this.flex = 0,
    this.width = 0,
    this.align = Align.left,
    this.gap = '',
  });

  factory Text.fromJson(Map<String, dynamic> json) {
    return Text(
      content: (json['content'] ?? json['Content'] ?? '') as String,
      flex: (json['flex'] ?? json['Flex'] ?? 0) as int,
      width: (json['width'] ?? json['Width'] ?? 0) as int,
      align: Align.fromValue((json['align'] ?? json['Align'] ?? 0) as int),
      gap: (json['gap'] ?? json['Gap'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'content': content,
      'flex': flex,
      'width': width,
      'align': align.value,
      'gap': gap,
    };
  }
}
