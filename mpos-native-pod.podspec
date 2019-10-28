
Pod::Spec.new do |s|
  s.name           = 'RNMPosNative'
  s.version        = "1.0.0"
  s.summary        = "Pagar.me MPos"
  s.description    = "React Native MPos Native Pod"
  s.license     	 = "Apache-2.0"
  s.author         = { "Alejandro" => "https://github.com/maggialejandro-rp" }
  s.homepage       = "https://github.com/maggialejandro-rp/mpos-native-pod"
  s.source         = { :git => 'https://github.com/maggialejandro-rp/mpos-native-pod', :tag => "v#{s.version}" }
  s.requires_arc   = true
  s.platform       = :ios, '9.0'
  s.source_files = 'src/*.{h,m}'

  s.dependency 'React'
end
