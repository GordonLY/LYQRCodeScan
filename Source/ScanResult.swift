//
//  ScanResult.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit
import AVFoundation

public struct ScanResult {
    /// 码内容
    public var content = ""
    /// 扫描图像
    public var image: UIImage?
    /// 码的类型
    public var barCodeType: AVMetadataObject.ObjectType
    /// 码在图像中的位置
    public var arrayCorner: [CGPoint]?
}


