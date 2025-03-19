#
# Be sure to run `pod lib lint Spot.IM-Core.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ViafouraCore'
  s.version          = '1.2.7'
  s.swift_versions = ['5.0']
  s.summary          = 'Viafoura SDK'
  s.description      = 'This SDK allows you to integrate Viafoura tools into your iOS app.'
  s.homepage        = "https://www.viafoura.com"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

  s.author          = { 'Martin De Simone' => 'martin.desimone@viafoura.com' }
  s.platform        = :ios
  s.ios.deployment_target = '10.3'
  # Setting pod `BUILD_LIBRARY_FOR_DISTRIBUTION` to `YES`
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }


# the Pre-Compiled Framework:
  s.source          = { :git => 'https://github.com/viafoura/sdk-ios.git', :tag => s.version.to_s }
  s.ios.vendored_frameworks = 'ViafouraSDK.xcframework'
end
