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
//        guard let videoDevice = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) else {
//                print("Unable to access back camera")
//            return
//        }
        
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
    }
    
    
    func startSession(){
        if !captureSession.isRunning {
            print("Capture session has started running")
            captureSession.startRunning()
        }
    }
    
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            print("Capture session has stopped running")
        }
    }
    
    func setZoom (factor: CGFloat) {
        guard let device = videoDeviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                let zoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
                device.videoZoomFactor = zoomFactor
                device.unlockForConfiguration()
            } catch {
                print("Error setting zoom: \(error)")
            }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let photoSettings = AVCapturePhotoSettings()
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = photoCaptureDelegate

        guard let photoOutput = self.photoOutput else {
                   print("No photo output available")
                   completion(nil)
                   return
               }

        print("taking a picture")
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
        print("done taking a picture")
    }
}
