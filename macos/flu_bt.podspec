Pod::Spec.new do |s|
  s.name             = 'flu_bt'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'FlutterMacOS'
  s.platform         = :osx, '10.13'
  s.swift_version    = '5.0'

  # Bundle the macOS dynamic library into app resources so dart:ffi can load it.
  s.resources        = 'Libraries/libprint.dylib'
  s.preserve_paths   = 'Libraries/libprint.dylib'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
