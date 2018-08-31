#
#  Be sure to run `pod spec lint RWHttpClient.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name          = "RWHttpClient"
  s.version       = "0.0.1"
  s.summary       = "A REST HTTP networking client."
  s.description   = <<-DESC
                    A client to make REST service call.
                    DESC
  s.homepage      = "https://github.com/ryanwyc/RWHttpClient"
  s.license       = "MIT"
  s.author        = { "Ryan Wu" => "ryan.wyc@gmail.com" }
  s.platform      = :ios, "10.0"
  s.ios.deployment_target = "10.0"

  s.source        = { :path => '.' }
  # s.source      = { :git => "https://github.com/ryanwyc/RWHttpClient", :tag => "#{s.version}" }
  s.source_files  = "RWHttpClient/Source/**/*.swift"
  s.resources     = "RWHttpClient/Source/**/*.{xib,png,jpg}"

  # s.framework   = "SystemConfiguration"
  # s.dependency "JSONKit", "~> 1.4"
end
