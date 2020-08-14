Pod::Spec.new do |s|
  s.name     = 'SSProgressHUD'
  s.version  = '0.0.1'
  s.license  = 'AHA'
  s.summary  = '加载框'
  s.homepage = 'https://github.com/shenlujia/SSProgressHUD'
  s.author   = { 'SLJ' => 'shenlujia@gmail.com' }
  s.source   = { :git => 'https://github.com/shenlujia/SSProgressHUD.git', :tag => s.version.to_s }
  s.source_files = 'SSProgressHUD/*.{h,m}'
  s.requires_arc = true

  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '7.0'
end