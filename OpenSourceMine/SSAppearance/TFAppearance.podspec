Pod::Spec.new do |s|
  s.name     = 'TFAppearance'
  s.version  = '0.3.0'
  s.license  = 'SLJ'
  s.summary  = 'TFAppearance'
  s.homepage = 'SLJ'
  s.author   = { 'SLJ' => 'shenlujia@gmail.com' }
  s.source = { :svn => 'https://10.7.12.91/repo/EHDiOS/trunk/EHDComponentRepo/TFAppearance', :tag => s.version.to_s }
  s.source_files = 'TFAppearance/Classes/**/*.{h,m}'
  s.resource_bundles = {
      'TFAppearance' => ['TFAppearance/Assets/*']
  }

  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '8.0'
  
  s.dependency 'TFBaseObject'
  s.dependency 'TFViewDecorator'
  
end