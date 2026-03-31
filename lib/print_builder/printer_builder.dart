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

typedef _FreeNative = ffi.Void Function(ffi.Pointer<ffi.Uint8>);
typedef _FreeDart = void Function(ffi.Pointer<ffi.Uint8>);

class PrintBuilder {
  late final ffi.DynamicLibrary _lib;
  late final _BuildDart _build;
  late final _FreeDart _free;

  PrintBuilder() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Only Android supported');
    }
    _lib = ffi.DynamicLibrary.open('libprint.so');
    _build =
        _lib.lookupFunction<_BuildNative, _BuildDart>('BuildFromPageJSONRaw');
    _free = _lib.lookupFunction<_FreeNative, _FreeDart>('FreeBuffer');
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
}
