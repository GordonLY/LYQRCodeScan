Pod::Spec.new do |s|
  s.name = "LYQRCodeScan"
  s.version = "1.0.5"
  s.swift_version = "4.2"
  s.summary = "swift原生二维码扫描，based iOS10.0,"
  s.homepage = "https://github.com/GordonLY/LYQRCodeScan"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.authors = "Gordon"
  s.ios.deployment_target = "10.0"
  s.source = { :git => "https://github.com/GordonLY/LYQRCodeScan.git", :tag => s.version }
  s.framework = "UIKit", "AVFoundation", "Photos", "AssetsLibrary"
  s.source_files  = "Source/*.swift"
  s.resource_bundles = {
   'LYQRCodeScan' => ['Source/ScanResource.xcassets']
  } 
end
