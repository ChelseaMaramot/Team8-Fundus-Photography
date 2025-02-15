//
//  CameraManager.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-04.
//

import Foundation
import AVFoundation
import UIKit

/*
 * @description: this class  configures and manages AVCaptureSession
 * useful sources:
 * https://developer.apple.com/documentation/avfoundation/capture_setup/choosing_a_capture_device
 */


class CameraManager: NSObject, ObservableObject {
    
    private var captureSession: AVCaptureSession
    private var videoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var permissionGranted: Bool
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoSettings: AVCapturePhotoSettings?
//    @Published private var flashMode: AVCaptureDevice.FlashMode = .off


    override init(){
        
        self.captureSession = AVCaptureSession()
        self.permissionGranted = true
        
        super.init()

        self.checkPermission()
        self.configureSession()
    }
    
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    
    func getSession() -> AVCaptureSession {
        return self.captureSession
    }
    
    
    func setVideoInput(){
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access back camera")
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput)
        else {
            print("Unable to add device input to capture session")
            return
        }
        captureSession.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
    }
    
    
    func setPhotoOutput(){
        let photoOutput = AVCapturePhotoOutput()
    
        if captureSession.canAddOutput(photoOutput){
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        else {
            print("Unable to add device output to capture session")
            return
        }
    }
    
    
    func checkPermission() {
         switch AVCaptureDevice.authorizationStatus(for: .video) {
             case .authorized:
                 self.permissionGranted = true
                 
             case .notDetermined:
                 self.requestPermission()
                 
         default:
             self.permissionGranted = false
         }
     }
    
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    
    func configureSession(){
        guard permissionGranted else { return }
        
        self.captureSession.beginConfiguration()
        
        self.setVideoInput()
        
        self.setPhotoOutput()
        
        self.captureSession.commitConfiguration()
        
        // automatically have the camera set to 3 by default
        // at the beginning of each session
        self.setZoomScale(factor: 3.0)
    }
    
    
    func startSession(){
        if !captureSession.isRunning {
            print("Capture session has started running")
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }

        }
    }
    
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            print("Capture session has stopped running")
        }
    }
    
    
    func setZoomScale(factor: CGFloat){
        
        guard let device = self.videoDeviceInput?.device else { return }
    
        do{
            try device.lockForConfiguration()
            
            device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, max(factor, device.minAvailableVideoZoomFactor))
            device.unlockForConfiguration()
            
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func setFocusOnTap(devicePoint: CGPoint){
        guard let device = self.videoDeviceInput?.device else {return}
        
        print("Focusing")
        
        do {
            try device.lockForConfiguration()

            // check if device supports auto focus
            if device.isFocusModeSupported(.autoFocus){
                device.focusMode = .autoFocus
                device.focusPointOfInterest = devicePoint
            }
            
            // set exposure point
            device.exposurePointOfInterest = devicePoint
            device.exposureMode = .autoExpose
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()
            
        }catch {
            print("Failed to configure focus: \(error)")
        }
        
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        
        print("\(self.captureSession.isRunning)")
        
        if !self.captureSession.isRunning  {
                print("Capture session is not running")
            DispatchQueue.global(qos: .userInitiated).async {
                            self.captureSession.startRunning()
                        }
// why is photo nil?
          
            
//                completion(nil)
//                return
        }
        
        guard let photoOutput = self.photoOutput else {
            print("No photo output available")
            completion(nil)
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = photoCaptureDelegate
            
            
            print("Taking a picture...")
            photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
            print("Done taking a picture")
        }
}

// fake fix, double capture eveything
