import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'print_page.dart';

final class ByteBuffer extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

typedef _BuildNative = ByteBuffer Function(ffi.Pointer<ffi.Char>);
typedef _BuildDart = ByteBuffer Function(ffi.Pointer<ffi.Char>);

typedef _BuildTextLinePlainNative = ByteBuffer Function(
  ffi.Pointer<ffi.Char>,
  ffi.Int32,
);
typedef _BuildTextLinePlainDart = ByteBuffer Function(
  ffi.Pointer<ffi.Char>,
  int,
);

typedef _FreeNative = ffi.Void Function(ffi.Pointer<ffi.Uint8>);
typedef _FreeDart = void Function(ffi.Pointer<ffi.Uint8>);

class PrintBuilder {
  late final ffi.DynamicLibrary _lib;
  late final _BuildDart _build;
  late final _BuildTextLinePlainDart _buildTextLinePlain;
  late final _FreeDart _free;

  PrintBuilder() {
    _lib = _openLibrary();
    _build =
        _lib.lookupFunction<_BuildNative, _BuildDart>('BuildFromPageJSONRaw');
    _buildTextLinePlain =
        _lib.lookupFunction<_BuildTextLinePlainNative, _BuildTextLinePlainDart>(
      'BuildTextLinePlain',
    );
    _free = _lib.lookupFunction<_FreeNative, _FreeDart>('FreeBuffer');
  }

  ffi.DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libprint.so');
    }
    if (Platform.isMacOS) {
      final executableDir = File(Platform.resolvedExecutable).parent.path;
      final candidatePaths = <String>[
        // App bundle common locations.
        '$executableDir/../Frameworks/libprint.dylib',
        '$executableDir/../Resources/libprint.dylib',
        // Plugin framework resource locations.
        '$executableDir/../Frameworks/flu_bt.framework/Resources/libprint.dylib',
        '$executableDir/../Frameworks/flu_bt.framework/Versions/A/Resources/libprint.dylib',
        'libprint.dylib',
      ];

      Object? lastError;
      for (final path in candidatePaths) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (error) {
          lastError = error;
        }
      }

      throw ArgumentError(
        'Failed to load libprint.dylib from ${candidatePaths.join(', ')}. '
        'Last error: $lastError',
      );
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  List<int> buildFromPage(Map<String, dynamic> page) {
    final jsonStr = jsonEncode(page);
    final cJson = jsonStr.toNativeUtf8().cast<ffi.Char>();
    try {
      final out = _build(cJson);
      if (out.ptr.address == 0 || out.len <= 0) return const [];
      final bytes = out.ptr.asTypedList(out.len);
      final copied = List<int>.from(bytes); // 先拷贝，再 free
      _free(out.ptr);
      return copied;
    } finally {
      malloc.free(cJson);
    }
  }

  List<int> buildFromPageModel(Page page) {
    return buildFromPage(page.toJson());
  }

  String buildTextLinePlain(
    Map<String, dynamic> line, {
    PageWidth pageWidth = PageWidth.width58,
  }) {
    final jsonStr = jsonEncode(line);
    final cJson = jsonStr.toNativeUtf8().cast<ffi.Char>();
    try {
      final out = _buildTextLinePlain(cJson, pageWidth.value);
      if (out.ptr.address == 0 || out.len <= 0) return '';
      try {
        final bytes = out.ptr.asTypedList(out.len);
        return utf8.decode(bytes);
      } finally {
        _free(out.ptr);
      }
    } finally {
      malloc.free(cJson);
    }
  }

  String buildTextLinePlainFromModel(
    Line line, {
    PageWidth pageWidth = PageWidth.width58,
  }) {
    return buildTextLinePlain(line.toJson(), pageWidth: pageWidth);
  }
}
