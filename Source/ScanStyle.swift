//
//  ScanStyle.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit

/// 扫码区域动画效果
public enum ScanViewAnimationStyle {
    case lineMove   //线条上下移动
    case netGrid    //网格
    case lineStill  //线条停止在扫码区域中央
    case none       //无动画
}

/// 扫码区域4个角位置类型
public enum ScanViewPhotoframeAngleStyle {
    case inner  //内嵌，一般不显示矩形框情况下
    case outer  //外嵌,包围在矩形框的4个角
    case on     //在矩形框的4个角上，覆盖
}

public struct ScanViewStyle {
    
    /// - 中心位置矩形框
    
    /// 是否需要绘制扫码矩形框，默认YES
    public var isNeedShowRetangle:Bool = true
    /// 默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
    public var whRatio:CGFloat = 1.0
    /// 矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，如果负值表示扫码区域下移
    public var centerUpOffset:CGFloat = 44
    /// 矩形框(视频显示透明区)域离界面左边及右边距离，默认60
    public var xScanRetangleOffset:CGFloat = 60
    /// 矩形框线条颜色，默认白色
    public var colorRetangleLine = UIColor.white
    
    /// - 矩形框(扫码区域)周围4个角
    
    /// 扫码区域的4个角类型
    public var photoframeAngleStyle = ScanViewPhotoframeAngleStyle.outer
    /// 4个角的颜色
    public var colorAngle = UIColor(red: 0.0, green: 167.0/255.0, blue: 231.0/255.0, alpha: 1.0)
    /// 扫码区域4个角的宽度和高度
    public var photoframeAngleW:CGFloat = 24.0
    public var photoframeAngleH:CGFloat = 24.0
    /// 扫码区域4个角的线条宽度,默认6，建议8到4之间
    public var photoframeLineW:CGFloat = 6
    
    /// - 动画效果
    
    /// 扫码动画效果:线条或网格
    public var anmiationStyle = ScanViewAnimationStyle.lineMove
    /// 动画效果的图像，如线条或网格的图像
    public var animationImage:UIImage?
    
    
    /// 非识别区域颜色,默认 RGBA (0,0,0,0.5)，范围（0--1）
    public var color_NotRecoginitonArea:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5);
    
    public init()
    {
        
    }
}

