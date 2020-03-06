platform :ios, '13.0'

# ignore all warnings from all pods
inhibit_all_warnings!
use_modular_headers!

target 'Outside Now' do
  pod 'DeviceKit', '~> 2.0'
  pod 'CocoaLumberjack/Swift'
  pod 'Crashlytics', '~> 3.14.0'
  pod 'Fabric', '~> 1.10.2'
  pod 'Firebase/Analytics'
  pod 'SwiftFormat/CLI'
  pod 'SwiftLint'

  target 'Outside NowTests' do
    inherit! :search_paths
    pod 'SnapshotTesting', '~> 1.1'
    pod 'OHHTTPStubs/Swift'
  end

  target 'Outside NowUITests' do
    inherit! :search_paths
  end
end
