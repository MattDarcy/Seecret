platform :ios, '8.0'

target 'Seecret' do
  use_frameworks!
  pod 'ReachabilitySwift', '~> 2.4'
  pod 'Parse'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end
