

Pod::Spec.new do |s|



# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.name         = "KalturaPlayerSDK"
s.version      = "2.4.9"
s.summary      = "The Kaltura player-sdk-native component enables embedding the kaltura player into native environments."

#s.description  = <<-DESC
#                 The Kaltura player-sdk-native component enables embedding the kaltura player into native environments.
#                 DESC
s.homepage     = "https://github.com/kaltura/player-sdk-native-ios"




# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.license      = { :type => 'AGPLv3', :text => 'AGPLv3' }



# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.authors             = { "Eliza Sapir" => "eliza.sapir@gmail.com", "Nissim Pardo" => "nissim.pardo@kaltura.com" }





# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.source       = { :git => 'https://github.com/kaltura/player-sdk-native-ios.git', :tag => 'v' + s.version.to_s }
s.libraries      = 'stdc++', 'z', 'System', 'xml2.2', 'c++', 'xml2'
s.framework    = 'MediaPlayer', 'SystemConfiguration', 'QuartzCore', 'CoreFoundation', 'AVFoundation', 'AudioToolbox', 'CFNetwork', 'AdSupport', 'WebKit', 'MessageUI', 'Social', 'MediaAccessibility', 'Foundation', 'CoreGraphics', 'UIKit'

s.requires_arc = true


s.subspec 'Core' do |sp|
    sp.source_files  = "**/*.{h,m}", "PlayerSDK/KALTURAPlayerSDK/**/*.{h,m}"
    sp.resource_bundle = { 'KALTURAPlayerSDKResources' => 'KALTURAPlayerSDK/*.{xib,plist}' }
end

s.subspec 'Widevine' do |sp|
    sp.libraries = 'WViPhoneAPI'
    sp.vendored_library = 'libWViPhoneAPI.a'
    sp.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'GCC_PREPROCESSOR_DEFINITIONS'=>'WIDEVINE_ENABLED=1' }
end

end



