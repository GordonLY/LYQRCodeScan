//
//  ScanWrapper.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit
import AVFoundation

open class ScanWrapper: NSObject {
    
    private var session: AVCaptureSession
    private var device: AVCaptureDevice
    private var input: AVCaptureDeviceInput
    private var photoOutput: AVCapturePhotoOutput
    private var dataOutput: AVCaptureMetadataOutput
    private var previewLayer: AVCaptureVideoPreviewLayer
    
    private var isNeedCaptureImage:Bool
    private var completion: ([ScanResult]) -> Void
    private var isNeedScanResult: Bool = true
    private var resultArr = [ScanResult]()

    /// 初始化设备
    ///
    /// - Parameter videoPreView: 视频显示UIView
    /// - Parameter objType: 识别码的类型,缺省值 QR二维码
    /// - Parameter isCaptureImg: 识别后是否采集当前照片
    /// - Parameter cropRect: 识别区域
    /// - Parameter completion: 返回识别信息
    public static func wrapper(preView: UIView,
                 objType: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.qr],
                 isCaptureImg: Bool = false,
                 cropRect: CGRect = .zero,
                 completion: @escaping ([ScanResult]) -> Void) -> ScanWrapper? {
        guard
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video),
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
            else { return nil }
        let wrapper = ScanWrapper(preView: preView,
                                  device: captureDevice,
                                  input: deviceInput,
                                  objType: objType,
                                  isCaptureImg: isCaptureImg,
                                  cropRect: cropRect,
                                  completion: completion)
        return wrapper
    }
    private init(preView: UIView,
                 device: AVCaptureDevice,
                 input: AVCaptureDeviceInput,
                 objType: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.qr],
                 isCaptureImg: Bool = false,
                 cropRect: CGRect = .zero,
                 completion: @escaping ([ScanResult]) -> Void) {
        
        self.isNeedCaptureImage = isCaptureImg
        self.completion = completion
        
        // 1. 创建会话
        self.session = AVCaptureSession()
        self.session.sessionPreset = .high
        // 2. 创建输入设备
        self.device = device
        // 3. 创建输入源
        self.input = input
        // 4. 创建图像输出
        self.photoOutput = AVCapturePhotoOutput()
        self.dataOutput = AVCaptureMetadataOutput()
        // 5. 连接输入与会话
        if self.session.canAddInput(self.input) {
            self.session.addInput(self.input)
        }
        // 6. 连接输出与会话
        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
        }
        if self.session.canAddOutput(self.dataOutput) {
            self.session.addOutput(self.dataOutput)
        }
        // 7. 预览画面
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.frame = preView.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        preView.layer.insertSublayer(self.previewLayer, at: 0)
        
        super.init()
        
        // 8. 参数设置
        dataOutput.setMetadataObjectsDelegate(self, queue: .main)
        dataOutput.metadataObjectTypes = objType
        if cropRect != .zero {
            dataOutput.rectOfInterest = cropRect
        }
        
        if device.isFocusPointOfInterestSupported &&
            device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try input.device.lockForConfiguration()
                input.device.focusMode = .continuousAutoFocus
                input.device.unlockForConfiguration()
            }
            catch let error {
                print("device.lockForConfiguration().error: \(error)")
            }
        }
    }
}

// MARK: - ********* MetadataOutputDelegate
extension ScanWrapper: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        p_captureOutput(output, didOutputMetadataObjects: metadataObjects, from: connection)
    }
}
// MARK: - ********* PhotoCaptureDelegate
extension ScanWrapper: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        stop()
        if #available(iOS 11.0, *) {
            guard
                let imgData = photo.fileDataRepresentation(),
                let scanImg = UIImage(data: imgData)
                else { return }
            for idx in 0 ..< resultArr.count {
                resultArr[idx].image = scanImg
            }
            completion(resultArr)
        }
    }
    @available(iOS 10.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        stop()
        guard
            let sampleBuffer = photoSampleBuffer,
            let imgData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let scanImg = UIImage(data: imgData)
            else { return }
        for idx in 0 ..< resultArr.count {
            resultArr[idx].image = scanImg
        }
        completion(resultArr)
    }
}

// MARK: - ********* Public method
public extension ScanWrapper {
    func start() {
        if !session.isRunning {
            isNeedScanResult = true
            session.startRunning()
        }
    }
    func stop() {
        if session.isRunning {
            isNeedScanResult = false
            session.stopRunning()
        }
    }
    ///  切换识别区域
    func changeScanRect(cropRect: CGRect) {
        /// 待测试，不知道是否有效
        stop()
        dataOutput.rectOfInterest = cropRect
        start()
    }
    
    ///  切换识别码的类型
    func changeScanType(objType: [AVMetadataObject.ObjectType]) {
        /// 待测试中途修改是否有效
        dataOutput.metadataObjectTypes = objType
    }
    ///  打开或关闭闪关灯
    func setTorch(isOn: Bool) {
        guard isGetFlash else { return }
        do {
            try input.device.lockForConfiguration()
            input.device.torchMode = isOn ? .on : .off
            input.device.unlockForConfiguration()
        } catch let error {
            print("error setTorch : \(error)")
        }
    }
    ///  改变闪光灯的状态
    func changeTorchState() {
        guard isGetFlash else { return }
        do {
            try input.device.lockForConfiguration()
            switch input.device.torchMode {
            case .auto, .off:
                input.device.torchMode = .on
            case .on:
                input.device.torchMode = .off
            }
            input.device.unlockForConfiguration()
        } catch let error {
            print("error setTorch : \(error)")
        }
    }
    
    ///  系统默认支持的码的类型
    static var defaultMetaDataObjectTypes: [AVMetadataObject.ObjectType] {
        return [.qr, .upce, .code39, .code39Mod43, .ean13,
                .ean8, .code93, .code128, .pdf417, .aztec,
                .interleaved2of5, .itf14, .dataMatrix]
    }
    
}

// MARK: - ********* Private method
private extension ScanWrapper {
    /// 二维码
    func p_captureOutput(_ output: AVCaptureMetadataOutput, didOutputMetadataObjects metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if !isNeedScanResult { return }
        isNeedScanResult = false
        resultArr.removeAll()
        
        //识别扫码类型
        for current in metadataObjects where current.isKind(of: AVMetadataMachineReadableCodeObject.self)
        {
            guard
                let code = current as? AVMetadataMachineReadableCodeObject
                else { continue }
            let result = ScanResult
                .init(content: code.stringValue ?? "",
                 image: nil,
                 barCodeType: code.type,
                 arrayCorner: code.corners)
            resultArr.append(result)
        }
        if resultArr.count > 0 {
            if isNeedCaptureImage {
                p_captureImage()
            } else {
                stop()
                completion(resultArr)
            }
        } else {
            isNeedScanResult = true
        }
    }
    ///  拍照
    func p_captureImage() {
        
        var format = [String: Any]()
        if #available(iOS 11.0, *) {
            format = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        } else {
            format = [AVVideoCodecKey: AVVideoCodecJPEG]
        }
        let photoSettings = AVCapturePhotoSettings(format: format)
        var flashMode = AVCaptureDevice.FlashMode.off
        switch input.device.torchMode {
        case .auto, .off:
            flashMode = .off
        case .on:
            flashMode = .on
        }
        photoSettings.flashMode = flashMode
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    ///  检测是否有闪光灯
    private var isGetFlash: Bool {
        return device.hasFlash && device.hasTorch
    }
}


// MARK: - ********* 识别图像中的二维码
public extension ScanWrapper {
    
    static func recognizeQRImage(image: UIImage) ->[ScanResult] {
        var results = [ScanResult]()
        guard
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]),
            let img = CIImage(image: image)
            else { return [] }
        let features = detector.features(in: img, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        for feature in features where feature.isKind(of: CIQRCodeFeature.self) {
            guard
                let qrcodeFeature = feature as? CIQRCodeFeature
                else { continue }
            let result = ScanResult(content: qrcodeFeature.messageString ?? "",
                                image: image,
                                barCodeType: .qr,
                                arrayCorner: nil)
            results.append(result)
        }
        return results
    }
}
