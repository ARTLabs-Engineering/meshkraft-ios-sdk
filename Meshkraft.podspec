Pod::Spec.new do |s|
  s.name             = 'Meshkraft'
  s.version          = '0.1.1'
  s.summary          = 'Meshkraft iOS SDK'
  s.description      = <<-DESC
  Meshkraft SDK allows any app to connect to Meshkraft platform and start AR sessions in just few lines
                       DESC
  s.homepage         = 'https://artlabs.ai/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ARTLabs' => 'engineering@artlabs.ai' }
  s.source           = { :git => 'https://github.com/ARTLabs-Engineering/meshkraft-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  s.source_files = 'Meshkraft/Classes/**/*'
end
