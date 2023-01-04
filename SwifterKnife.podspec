#
# Be sure to run `pod lib lint SwifterKnife.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwifterKnife'
  s.version          = '0.1.5'
  s.summary          = 'A handy collection of Swift method and Tools to build project faster and more efficient.'

  s.description      = <<-DESC
  SwifterKnife is a collection of Swift extension method and some tools that often use in develop project, with them you might build project faster and more efficient.
                       DESC

  s.homepage         = 'https://github.com/CoderLouie/SwifterKnife'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liyang' => '18616562401@163.com' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  s.swift_version = '5.3'
  s.requires_arc = true
  s.source           = { :git => 'https://github.com/CoderLouie/SwifterKnife.git', :tag => s.version.to_s }
  
#  s.source_files =
#  'SwifterKnife/Classes/Base/**/*',
#  'SwifterKnife/Classes/Extension/**/*',
#  'SwifterKnife/Classes/Utility/**/*',
#  'SwifterKnife/Classes/Views/**/*'
  s.source_files = 'SwifterKnife/Classes/**/*'
 
  s.subspec 'Base' do |sp|
    sp.source_files = 'SwifterKnife/Classes/Base/*.swift'
  end
  # Extension Extensions
  s.subspec 'Extension' do |sp|
    sp.source_files =
    'SwifterKnife/Classes/Base/*.swift',
    'SwifterKnife/Classes/Extension/**/*.swift'
  end
  
  # Utility Extensions
  s.subspec 'Utility' do |sp|
    sp.source_files = 'SwifterKnife/Classes/Utility/**/*'
  end
  
  # Layout Extensions
  s.subspec 'Views' do |sp|
    sp.source_files =
    'SwifterKnife/Classes/Base/*.swift',
    'SwifterKnife/Classes/Views/**/*.swift' 
    
    sp.dependency 'SnapKit'
  end
  
  # s.resource_bundles = {
  #   'SwifterKnife' => ['SwifterKnife/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
