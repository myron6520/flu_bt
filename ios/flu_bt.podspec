#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flu_bt.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  # Fail fast with a clear message — this path is relative to this podspec (ios/).
  libprint_a = File.join(__dir__, 'Assets', 'libprint.a')
  unless File.file?(libprint_a)
    raise "flu_bt: native library missing at #{libprint_a}. " \
          'Copy libprint.a (and libprint.h) into ios/Assets/, commit or restore them, then run pod install again.'
  end

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
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.vendored_libraries = 'Assets/libprint.a'

  # Dart FFI does not create native undefined symbols at link time, so ld would
  # skip every .o inside libprint.a unless we force-load the whole archive.
  # PODS_TARGET_SRCROOT is the pod directory (this ios/ folder).
  #
  # Simulator: Assets/libprint.a must contain the simulator slice (e.g. arm64
  # for Apple Silicon sim). A device-only .a will fail to link for iphonesimulator.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '$(inherited) -force_load "$(PODS_TARGET_SRCROOT)/Assets/libprint.a"',
  }
end
