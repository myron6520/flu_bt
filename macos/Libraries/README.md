Place your macOS dynamic library here:

- `libprint.dylib`

The `macos/flu_bt.podspec` bundles this file into the host app, and
`PrintBuilder` loads it via `dart:ffi`.
