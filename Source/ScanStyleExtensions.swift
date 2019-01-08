//
//  ScanStyleExtensions.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/8.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit

public extension ScanViewStyle {
    
    static var alipayStyle: ScanViewStyle {
        
        var style = ScanViewStyle()
        style.centerUpOffset = 60
        style.xScanRetangleOffset = 30
        
        if UIScreen.main.bounds.size.height <= 480 {
            style.centerUpOffset = 40
            style.xScanRetangleOffset = 20
        }
        style.color_NotRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
        style.photoframeAngleStyle = .inner
        style.photoframeLineW = 2.0
        style.photoframeAngleW = 16
        style.photoframeAngleH = 16
        style.isNeedShowRetangle = false
        
        style.anmiationStyle = .netGrid
        style.animationImage = Bundle.getImage(byName: "qrcode_scan_full_net")
        return style
    }
    
    static var qqStyle: ScanViewStyle {
        var style = ScanViewStyle()
        style.animationImage = Bundle.getImage(byName: "qrcode_scan_light_green")
        return style
    }
}
