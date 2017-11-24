//
//  ScanningVC.swift
//  Lazy Typing
//
//  Created by nhatlee on 11/22/17.
//  Copyright © 2017 nhatlee. All rights reserved.
//

import UIKit
import SwiftOCR
import AVFoundation
import PopupDialog

extension UIImage {
    func detectOrientationDegree () -> CGFloat {
        switch imageOrientation {
        case .right, .rightMirrored:    return 90
        case .left, .leftMirrored:      return -90
        case .up, .upMirrored:          return 180
        case .down, .downMirrored:      return 0
        }
    }
}

class ScanningVC: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var finderView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var lblText: UILabel!
    // MARK: - Private Properties
    fileprivate var stillImageOutput: AVCaptureStillImageOutput!
    fileprivate let captureSession = AVCaptureSession()
    fileprivate let device  = AVCaptureDevice.default(for: AVMediaType.video)
    private let ocrInstance = SwiftOCR()
    
    var instruction: ScanningInstruction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //instruction
        if (UserDefaults.standard.value(forKey: Keys.userPressInstructionScaning) == nil){
            setupInstruction()
        }
        // start camera init
        DispatchQueue.global(qos: .userInitiated).async {
            if self.device != nil {
                self.configureCameraForUse()
            }
        }
    }
    
    func setupInstruction() {
        instruction = ScanningInstruction(parentViewController: self)
        instruction.findingView = finderView
        instruction.btnCapture = btnCapture
        instruction.slider = slider
        instruction.startTour()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderChange(_ sender: Any) {
        do {
            try device!.lockForConfiguration()
            var zoomScale = CGFloat(slider.value * 10.0)
            let zoomFactor = device?.activeFormat.videoMaxZoomFactor
            
            if zoomScale < 1 {
                zoomScale = 1
            } else if zoomScale > zoomFactor! {
                zoomScale = zoomFactor!
            }
            
            device?.videoZoomFactor = zoomScale
            device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
    }
    
    @IBAction func captureTap(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let capturedType = self.stillImageOutput.connection(with: AVMediaType.video) else {
                return
            }
            
            self.stillImageOutput.captureStillImageAsynchronously(from: capturedType) { [weak self] optionalBuffer, error -> Void in
                guard let buffer = optionalBuffer else {
                    return
                }
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData!)
                
                let croppedImage = self?.prepareImageForCrop(using: image!)
                self?.ocrInstance.recognize(croppedImage!) { [weak self] recognizedString in
                    DispatchQueue.main.async {
                        self?.lblText.text = recognizedString
                        print(self?.ocrInstance.currentOCRRecognizedBlobs ?? "Recoginzed Blob is empty")
                        
                        self?.openPopup(recognizedString)
                    }
                }
                
            }
        }
    }
    
    func openPopup(_ string: String) {
        let popVC = self.storyboard?.instantiateViewController(withIdentifier: "PopupVC") as! PopupVC
        popVC.recognizeString = string
        let popup = PopupDialog(viewController: popVC, buttonAlignment: .vertical, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = CancelButton(title: "Dismiss", height: 60) {
//            self.label.text = "You canceled the rating dialog"
        }
//
//        // Create second button
//        let buttonTwo = DefaultButton(title: "RATE", height: 60) {
////            self.label.text = "You rated "
//        }

        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        present(popup, animated: true, completion: nil)
    }

}

extension ScanningVC {
    // MARK: AVFoundation
    fileprivate func configureCameraForUse () {
        self.stillImageOutput = AVCaptureStillImageOutput()
        let fullResolution = UIDevice.current.userInterfaceIdiom == .phone && max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) < 568.0
        
        if fullResolution {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        } else {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        self.captureSession.addOutput(self.stillImageOutput)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.prepareCaptureSession()
        }
    }
    
    private func prepareCaptureSession () {
        do {
            self.captureSession.addInput(try AVCaptureDeviceInput(device: self.device!))
        } catch {
            print("AVCaptureDeviceInput Error")
        }
        
        // layer customization
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        DispatchQueue.main.async {
            previewLayer.frame.size = self.cameraView.frame.size
        }
        previewLayer.frame.origin = CGPoint.zero
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // device lock is important to grab data correctly from image
        do {
            try self.device?.lockForConfiguration()
            self.device?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            self.device?.focusMode = .continuousAutoFocus
            self.device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
        
        //Set initial Zoom scale
        do {
            try self.device?.lockForConfiguration()
            
            let zoomScale: CGFloat = 2.5
            
            if zoomScale <= (device?.activeFormat.videoMaxZoomFactor)! {
                device?.videoZoomFactor = zoomScale
            }
            
            device?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
        
        DispatchQueue.main.async(execute: {
            self.cameraView.layer.addSublayer(previewLayer)
            self.captureSession.startRunning()
        })
    }
    
    // MARK: Image Processing
    fileprivate func prepareImageForCrop (using image: UIImage) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        let imageOrientation = image.imageOrientation
        let degree = image.detectOrientationDegree()
        let cropSize = CGSize(width: 400, height: 110)
        
        //Downscale
        let cgImage = image.cgImage!
        
        let width = cropSize.width
        let height = image.size.height / image.size.width * cropSize.width
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        let context = CGContext(data: nil,
                                width: Int(width),
                                height: Int(height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace!,
                                bitmapInfo: bitmapInfo.rawValue)
        
        context!.interpolationQuality = CGInterpolationQuality.none
        // Rotate the image context
        context?.rotate(by: degreesToRadians(degree));
        // Now, draw the rotated/scaled image into the context
        context?.scaleBy(x: -1.0, y: -1.0)
        
        //Crop
        switch imageOrientation {
        case .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: -height, y: 0, width: height, height: width))
        case .left, .leftMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: -width, width: height, height: width))
        case .up, .upMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        case .down, .downMirrored:
            context?.draw(cgImage, in: CGRect(x: -width, y: -height, width: width, height: height))
        }
        
        let calculatedFrame = CGRect(x: 0, y: CGFloat((height - cropSize.height)/2.0), width: cropSize.width, height: cropSize.height)
        let scaledCGImage = context?.makeImage()?.cropping(to: calculatedFrame)
        
        
        return UIImage(cgImage: scaledCGImage!)
    }
    
}
