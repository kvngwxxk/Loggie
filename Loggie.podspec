Pod::Spec.new do |s|
  s.name             = 'Loggie'
  s.version          = '1.1.2'
  s.summary          = 'Lightweight logging and network tracking tool for iOS developers'
  s.description      = <<-DESC
    Loggie provides lightweight, thread-safe logging to the console and files,
    along with Alamofire-based network request tracking and in-app UI inspection.
  DESC
  s.homepage         = 'https://github.com/kvngwxxk/Loggie'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kangwook Lee' => 'kngwk.bsns@gmail.com' }
  s.source           = { :git => 'https://github.com/kvngwxxk/Loggie.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.9'

  s.source_files     = 'Sources/Loggie/**/*'
  s.frameworks       = 'Foundation', 'os'

  s.subspec 'Network' do |net|
    net.resources = ['Sources/LoggieNetwork/Resources/**/*']
    net.source_files = 'Sources/LoggieNetwork/**/*'
    net.dependency 'Alamofire', '~> 5.6'
    net.dependency 'Loggie'
    net.frameworks = 'Foundation', 'UIKit', 'CoreData'
  end
end

