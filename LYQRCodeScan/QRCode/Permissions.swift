//
//  Permissions.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

final class Permissions {
    
    static func photoPermit(comletion: @escaping (Bool) -> Void) {
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case .authorized:
            comletion(true)
        case .denied, .restricted:
            comletion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    comletion(status == PHAuthorizationStatus.authorized ? true:false)
                }
            })
        }
    }

    static func cameraPermit(comletion: @escaping (Bool) -> Void) {
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        switch granted {
        case .authorized:
            comletion(true)
            break;
        case .denied:
            comletion(false)
            break;
        case .restricted:
            comletion(false)
            break;
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) in
                DispatchQueue.main.async {
                    comletion(granted)
                }
            })
        }
    }
    
    // MARK: === 跳转到APP系统设置权限界面
    static func jumpToSystemPrivacySetting() {
        guard
            let appSetting = URL(string:UIApplication.openSettingsURLString)
            else { return }
        UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
    }
}




