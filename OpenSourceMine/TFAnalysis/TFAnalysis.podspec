
Pod::Spec.new do |s|
  s.name             = 'TFAnalysis'
  s.version          = '0.0.1'
  s.summary          = 'summary'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'www.shenlujia.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'shenlujia'
  s.source           = { :svn => 'https://10.7.12.91/repo/EHDiOS/trunk/EHDComponentRepo/TFAnalysis', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  
  s.subspec "Base" do |ss|
    ss.source_files = 'TFAnalysis/**/*.{m,mm,h}'
  end
  
end
