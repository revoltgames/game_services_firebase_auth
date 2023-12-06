#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint game_services_firebase_auth.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'game_services_firebase_auth'
  s.version          = '2.0.0'
  s.summary          = 'Firebase Auth using iOS Game Center credentials.'
  s.homepage         = 'https://pub.dev/packages/game_services_firebase_auth'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'firebase_auth', '~> 4.15'
  s.static_framework = true
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
end
