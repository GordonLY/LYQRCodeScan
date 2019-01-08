Pod::Spec.new do |s|
  s.name = "LYQRCodeScan"
  s.version = "1.0.0"
  s.swift_version = "4.2"
  s.summary = "文字跑马灯"
  s.homepage = "https://github.com/GordonLY/LYQRCodeScan"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.authors = "Gordon"
  s.ios.deployment_target = "10.0"
  s.source = { :git => "https://github.com/GordonLY/LYQRCodeScan.git", :tag => s.version }
  s.framework = "UIKit", "AVFoundation", "Photos", "AssetsLibrary"

  s.subspec "LYQRCodeScan" do |ss|
    ss.source_files  = "LYMarqueeLabel/*"
  end
end
