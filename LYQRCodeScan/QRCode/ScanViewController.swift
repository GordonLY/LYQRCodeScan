//
//  LYQRCodeVC.swift
//  LYUIkits
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

open class ScanViewController: UIViewController {
    
    //相机启动提示文字
    private var readyTips: String
    /// 识别码的类型
    private var codeTypes: [AVMetadataObject.ObjectType]
    /// 启动区域识别功能 Area identification
    private var isAreaIdentification: Bool
    /// 是否需要识别后的当前图像
    private var isNeedCodeImage: Bool
    public init(readyTips: String = "loading",
                codeTypes: [AVMetadataObject.ObjectType] = [.qr],
                areaIdentification: Bool = false,
                needCodeImage: Bool = false
                ) {
        self.readyTips = readyTips
        self.codeTypes = codeTypes
        self.isNeedCodeImage = needCodeImage
        self.isAreaIdentification = areaIdentification
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Loading this view controller from a nib is unsupported")
    public required init(coder aDecoder: NSCoder) {
        fatalError("Loading this view controller from a nib is unsupported")
    }
  
    private var scanWrapper: ScanWrapper?
    private var scanView: ScanView!
    private var scanStyle = ScanViewStyle()
    private var isCameraPermitted = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        Permissions.cameraPermit { [weak self](isPermitted) in
            guard let `self` = self else { return }
            self.isCameraPermitted = isPermitted
            if isPermitted { self.p_initSubviews() }
            else { self.p_showNoPermission(.camera) }
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isCameraPermitted { startScan() }
    }
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanView.stopScanAnimation()
        scanWrapper?.stop()
    }
}

// MARK: - ********* Public method
extension ScanViewController {
    
    ///  重写此方法 处理扫码结果
    open func handleCodeScanResults(_ results: [ScanResult]) {
        guard results.count > 0 else { return }
        let result = results[0]
        p_show(message: result.content)
    }
    public func startScan() {
        scanView.deviceStopReadying()
        scanView.startScanAnimation()
    
        scanWrapper?.start()
    }
    ///  打开相册
    public func openPhotoAlbum() {
        scanWrapper?.stop()
        Permissions.photoPermit { [weak self](isPermitted) in
            guard let `self` = self else { return }
            guard isPermitted else {
                self.p_showNoPermission(.photo)
                self.scanWrapper?.start();  return
            }
            let picker  = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    /// 开关闪光灯
    ///
    /// - Returns: 当前闪光灯的状态
    public func triggerFlash(_ callback: ((AVCaptureDevice.TorchMode) -> Void)?) {
        guard let wrapper = scanWrapper else { return }
        callback?(wrapper.changeTorchState())
    }
}
// MARK: - ********* UINavigationDelegate
extension ScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 相册选择图片识别二维码
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let img = info[.editedImage] as? UIImage {
            let results = ScanWrapper.recognizeQRImage(image: img)
            handleCodeScanResults(results)
        } else {
            handleCodeScanResults([])
        }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        scanWrapper?.start()
    }
}

// MARK: - ********* Private method
private extension ScanViewController {
    func p_initSubviews() {
        
        /// scan view
        scanView = ScanView(frame: self.view.bounds, vstyle: scanStyle)
        view.addSubview(scanView)
        scanView.deviceStartReadying(readyStr: readyTips)
        
        /// scan wrapper
        var cropRect = CGRect.zero
        if isAreaIdentification {
            cropRect = ScanView.getScanRectWithPreView(preView: self.view, style: scanStyle)
        }
        scanWrapper = ScanWrapper.wrapper(preView: self.view,
                                          objType: codeTypes,
                                          isCaptureImg: isNeedCodeImage,
                                          cropRect: cropRect,
                                          completion:
            { [weak self](results) in
                guard let `self` = self else { return }
                self.scanView.stopScanAnimation()
                self.handleCodeScanResults(results)
        })
    }
    
    private func p_show(message: String) {
        
        let alert = UIAlertController(title: nil, message:message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "👌", style: .default) { (_) in }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func p_showNoPermission(_ type: PermissionType) {
        let alert = UIAlertController.init(title: "", message: type.tips, preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: "设置", style: .default) { (_) in
            Permissions.jumpToSystemPrivacySetting()
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.showDetailViewController(alert, sender: nil)
    }
}

enum PermissionType {
    case photo
    case camera
}

extension PermissionType {
    var tips: String {
        switch self {
        case .photo:
            return "请在iPhone的\"设置-隐私-照片\"选项中，允许\(appDisplayName)访问您的照片。"
        case .camera:
            return "请在iPhone的\"设置-隐私-相机\"选项中，允许\(appDisplayName)访问您的相机。"
        }
    }
}

private var appDisplayName: String {
    return (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? ""
}
