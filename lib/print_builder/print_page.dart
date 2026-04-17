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

class LineGroup {
  final List<Line> lines;
  final String key;

  const LineGroup({
    required this.lines,
    required this.key,
  });

  factory LineGroup.fromJson(Map<String, dynamic> json) {
    return LineGroup(
      lines: ((json['lines'] ?? json['Lines']) as List<dynamic>? ?? const [])
          .map((e) => Line.fromJson(e as Map<String, dynamic>))
          .toList(),
      key: (json['key'] ?? json['Key'] ?? '') as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lines': lines.map((e) => e.toJson()).toList(),
      'key': key,
    };
  }

  bool get isDividerOnly => lines.every((e) => e.type == LineType.divider);
  List<String> get keys => [...lines.map((e) => e.key).toList(), key];
}

class Page {
  final PageWidth pageWidth;
  final List<LineGroup> lineGroups;
  final Cmd cmd;
  final String key;

  const Page({
    required this.pageWidth,
    required this.lineGroups,
    this.cmd = Cmd.esc,
    this.key = '',
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      pageWidth: PageWidth.fromValue(
        (json['pageWidth'] ?? json['PageWidth'] ?? 58) as int,
      ),
      lineGroups:
          ((json['lineGroups'] ?? json['LineGroups']) as List<dynamic>? ??
                  const [])
              .map((e) => LineGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
      cmd: Cmd.fromValue((json['cmd'] ?? json['Cmd'] ?? 0) as int),
      key: (json['key'] ?? json['Key'] ?? '') as String,
    );
  }
  List<Line> get lines => lineGroups.expand((e) => e.lines).toList();
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pageWidth': pageWidth.value,
      'lines': lines.map((e) => e.toJson()).toList(),
      'lineGroups': lineGroups.map((e) => e.toJson()).toList(),
      'cmd': cmd.value,
      'key': key,
    };
  }
}

class Line {
  late int size;
  late int weight;
  late bool bold;
  final LineType type;
  final List<Text> textList;
  final QrCode? qrCode;
  final BarCode? barCode;
  final String key;
  late bool show;

  Line({
    this.size = 0,
    this.weight = 0,
    this.bold = false,
    required this.type,
    this.textList = const [],
    this.qrCode,
    this.barCode,
    this.key = '',
    this.show = true,
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
      key: (json['key'] ?? json['Key'] ?? '') as String,
      show: (json['show'] ?? json['Show'] ?? true) as bool,
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
      'key': key,
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
  late String content;
  final int flex;
  final int width;
  final Align align;
  final String gap;

  Text({
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
