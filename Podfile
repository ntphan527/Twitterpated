# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Twitterpated' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Twitterpated
  pod 'AFNetworking', '3.0.0'
  pod 'BDBOAuth1Manager', '2.0.0'
  pod 'MBProgressHUD', '~> 0.9.1'
  post_install do |installer|
     installer.pods_project.targets.each do |target|
       target.build_configurations.each do |config|
         config.build_settings['SWIFT_VERSION'] = '3.2'
       end
     end
   end
end
