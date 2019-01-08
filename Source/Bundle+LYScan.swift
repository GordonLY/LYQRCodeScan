//
//  Bundle+LYScan.swift
//  LYQRCodeScanDemo
//
//  Created by 李扬 on 2019/1/8.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit
class ScanBundleClass { }
extension Bundle {
    
    static var qrCodeBundle: Bundle? {
        let bundle = Bundle(for: ScanBundleClass.self)
        guard
            let url = bundle.url(forResource: "LYQRCodeScan", withExtension: "bundle"),
            let b = Bundle(url: url)
            else { return nil }
        return b
    }
    static func getImage(byName name: String) -> UIImage? {
        return UIImage.init(named: name, in: qrCodeBundle, compatibleWith: nil)
    }
}



