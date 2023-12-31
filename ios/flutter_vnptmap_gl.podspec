#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_vnptmap_gl.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_vnptmap_gl'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project plugin'
  s.description      = <<-DESC
  A Flutter plugin that provides a VNPTMapView widget
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'VNPT-IT KV2' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  
  # Config for Mapbox custome build
  # s.preserve_paths = 'Mapbox.xcframework/**/*'
  # s.xcconfig = { 'OTHER_LDFLAGS' => '-framework Mapbox' }
  # s.vendored_frameworks = 'Mapbox.xcframework'

  # Config for MapLibre Remote URL
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MapLibre', '5.14.0-pre3'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
