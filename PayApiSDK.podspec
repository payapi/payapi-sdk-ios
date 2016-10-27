Pod::Spec.new do |s|
  s.name = 'PayApiSDK'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'PayApi SDK for iOS - Swift 3'
  s.homepage = 'https://payapi.io'
  s.authors = { 'PayApi' => 'hello@payapi.io' }
  s.source = { :git => 'https://github.com/payapi/payapi-sdk-ios.git', :branch => "master", :tag => s.version }
  s.dependency 'JSONWebToken'
  s.ios.deployment_target = '8.0'

  s.source_files = 'PayapiSDK/*.swift'
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'PayapiSDK/*.swift'
  s.resources = 'PayapiSDK/Assets.xcassets/*'

end