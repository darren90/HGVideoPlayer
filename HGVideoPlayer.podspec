#
# Be sure to run `pod lib lint HGVideoPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HGVideoPlayer'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HGVideoPlayer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/1005052145@qq.com/HGVideoPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1005052145@qq.com' => '1005052145@qq.com' }
  s.source           = { :git => 'https://github.com/1005052145@qq.com/HGVideoPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'


  s.source_files = 'HGVideoPlayer','HGVideoPlayer/Classes/HGVideoPlayer/*.{h,m}' , 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h'
# 'HGVideoPlayer/Classes/**/*',  ,'HGVideoPlayer/Classes/**/*'
# 'HGVideoPlayer/Classes/HGVideoPlayer/**/*.{h,m}'

  ## 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h','HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h',
  s.public_header_files = 'HGVideoPlayer/Classes/HGVideoPlayer/*.h', 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h'
  # s.private_header_files = 

  s.resources = 'HGVideoPlayer/Assets/*.png','HGVideoPlayer/Classes/HGVideoPlayer/**/*.{xib,nib}'
#   s.resource_bundles = {
#     'HGVideoPlayer'=> ['HGVideoPlayer/Assets/*.png','HGVideoPlayer/Classes/**/*.xib']
# }

 # 参考  https://github.com/Phelthas/LXMThirdLoginManager/blob/master/LXMThirdLoginManager.podspec

  s.requires_arc = true
  # s.frameworks   = 'VideoToolbox'
  # s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2',"stdc++"
  # s.ios.vendored_frameworks  = 'HGVideoPlayer/Classes/framework/vod/*.framework'

  #s.ios.resource = "HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework"
  #s.ios.source_files        = 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h'
  #s.ios.public_header_files = 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/*.h'
  # s.default_subspec = 'KSYMediaPlayer_vod'

  s.vendored_frameworks = 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework'
  s.default_subspec = 'KSYMediaPlayer_vod'

  s.subspec 'KSYMediaPlayer_vod'  do |sub| 
    sub.vendored_frameworks = 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework'
    sub.library = 'z', 'iconv', 'stdc++.6', 'bz2',"stdc++"
    sub.source_files =  'KSYMediaPlayer', 'HGVideoPlayer/Classes/framework/**/*', 'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/Headers/**/*.h' #'HGVideoPlayer/Classes/framework/vod/KSYMediaPlayer.framework/**/*'
    sub.frameworks   = 'VideoToolbox'
    sub.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  end
  # s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

    #   s.default_subspec = 'Core'

    # s.subspec 'Core' do |core|
    #     core.source_files = "LXMThirdLoginManager", "LXMThirdLoginManager/**/*.{h,m}"
    #     core.frameworks = "Photos", "Foundation", "UIKit", "CoreGraphics", "CoreText", "CoreTelephony", "Security", "ImageIO", "QuartzCore", "SystemConfiguration"
    #     core.libraries = "stdc++", "sqlite3", "iconv", "c++", "sqlite3.0", "z"
    #     core.vendored_libraries = "LXMThirdLoginManager/**/*.{a}"
    #     core.vendored_frameworks = "LXMThirdLoginManager/**/*.{framework}"
    # end



  s.dependency "Masonry", "~>  1.0.2"
  # s.dependency 'KSYMediaPlayer_iOS.podspec/KSYMediaPlayer_vod', :path => './OtherPod/KSYMediaPlayer_iOS'

  # s.resource_bundles = {
  #   'HGVideoPlayer' => ['HGVideoPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
