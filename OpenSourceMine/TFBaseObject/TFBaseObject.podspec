Pod::Spec.new do |s|
  s.name     = 'TFBaseObject'
  s.version  = '0.1.2'
  s.license  = 'SLJ'
  s.summary  = 'TFBaseObject'
  s.homepage = 'SLJ'
  s.author   = { 'SLJ' => 'shenlujia@gmail.com' }
  s.source = { :svn => 'https://10.7.12.91/repo/EHDiOS/trunk/EHDComponentRepo/TFBaseObject', :tag => s.version.to_s }
  s.source_files = 'TFBaseObject/**/*.{h,m}'

  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '8.0'
  
  s.dependency 'MJExtension'
  
end