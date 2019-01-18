# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

project 'EAO.xcodeproj'
platform :ios, '9.0'
use_frameworks!

def shared_pods
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Parse'
  pod 'Alamofire'
  pod 'AlamofireObjectMapper'
  pod 'ObjectMapper'
  pod 'RealmSwift'
  pod 'IQKeyboardManager'
  pod 'SwiftLint'
end

target 'Field Insp' do
    shared_pods
end

target 'Field Insp TEST' do
    shared_pods
end

target 'EAOUITests' do
    shared_pods
    inherit! :search_paths
end
