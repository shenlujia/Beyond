
Pod::Spec.new do |s|
  s.name             = "hundsun_audio"
  s.version          = "1.0.0"
  s.summary          = "hundsun_audio For hundsun_health 2.0"
  s.description      = <<-DESC
                       It is a hundsun_audio module used on iOS, which implement by Objective-C.
                       DESC

  s.author           = "slj"
  s.source           = { :git => "../hundsun_audio" }
  s.homepage         = "http://www.hsyuntai.com"
  s.license          = "MIT"
  s.platform         = :ios, "8.0"

  #s.source_files = 'hundsun_network/**/*'
  s.source_files = 'hundsun_audio/**/*.{mm,m,h,cpp,c}'
  #s.resources = 'hs_hos_navi/hs_hos_navi.bundle'
  #s.public_header_files = "module/hs_hos_intro.h"

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  #s.public_header_files = 'Classes/**/*.h'
  #s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'libstdc++'
end
