#
#  Be sure to run `pod spec lint SYLogManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  s.name         = "SYLogManager"
  s.version      = "1.3.3"
  s.summary      = "SYLogManager is used show log message."
  s.homepage     = "https://github.com/potato512/SYLogManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/potato512/SYLogManager.git", :tag => s.version.to_s }
  s.source_files = 'SYLogManager/*.{h,m}'
  s.requires_arc = true
  s.frameworks = 'UIKit', 'CoreFoundation'

end
