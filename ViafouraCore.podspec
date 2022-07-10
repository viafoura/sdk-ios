#
# Be sure to run `pod lib lint Spot.IM-Core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ViafouarCore'
  s.version          = '0.0.1'
  s.swift_versions = ['5.0']
  s.summary          = 'Viafoura SDK'
  s.description      = 'This SDK allows you to integrate Viafoura tools into your iOS app.'
  s.homepage        = "https://www.viafoura.com"
  s.license      = { :type => 'BSD' }
  s.author          = { 'Martin De Simone' => 'martin.desimone@viafoura.com' }
  s.platform        = :ios
  s.ios.deployment_target = '10.3'
  # Setting pod `BUILD_LIBRARY_FOR_DISTRIBUTION` to `YES`
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

# the Pre-Compiled Framework:
  s.source          = { :git => 'https://github.com/viafoura/sdk-ios.git', :branch => "develop", :tag => s.version.to_s }
  s.ios.vendored_frameworks = 'ViafouraSDK.xcframework'
end
