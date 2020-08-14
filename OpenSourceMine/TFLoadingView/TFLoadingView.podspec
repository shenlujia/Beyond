Pod::Spec.new do |s|
  s.name     = 'TFLoadingView'
  s.version  = '1.0.0'
  s.license  = 'SLJ'
  s.summary  = '加载控件'
  s.homepage = 'SLJ'
  s.author   = { 'SLJ' => 'shenlujia@gmail.com' }
  s.source = { :svn => 'https://10.7.12.91/repo/EHDiOS/trunk/EHDComponentRepo/TFLoadingView', :tag => s.version.to_s }
  s.source_files = 'TFLoadingView/**/*.{h,m}'
  s.requires_arc = true
  
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '8.0'
  
  s.dependency 'TFAppearance'
  s.dependency 'TFBaseObject'
  
  s.resource_bundles = {
      'TFLoadingView' => ['TFLoadingView/Assets/*']
  }

end