Pod::Spec.new do |s|

  s.name         = "SYLogManager"
  s.version      = "1.0.1"
  s.summary      = "SYLogManager is used show log message."
  s.homepage     = "https://github.com/potato512/SYLogManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/potato512/SYLogManager.git", :tag => "#{s.version}" }
  s.source_files  = "SYLogManager/*.{h,m}"
  s.frameworks = 'UIKit', 'CoreFoundation'
  s.requires_arc = true

end