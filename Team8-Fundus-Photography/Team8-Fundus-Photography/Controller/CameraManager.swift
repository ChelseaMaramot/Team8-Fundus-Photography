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
    
    enum Status {
       case configured
       case unconfigured
       case unauthorized
       case failed
    }
    
    
    private var captureSession: AVCaptureSession
    private var videoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var permissionGranted: Bool
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoSettings: AVCapturePhotoSettings?
    private let sessionQueue = DispatchQueue(label: "com.demo.sessionQueue")
    private var dispatchGroup = DispatchGroup()
    
    private var isCameraReady: Bool = false

    
    @Published var status = Status.unconfigured
    @Published var zoomFactor: CGFloat = 3.0
//    @Published private var flashMode: AVCaptureDevice.FlashMode = .off


    override init(){
        
        self.captureSession = AVCaptureSession()
        self.permissionGranted = true
        
        super.init()

        self.checkPermission()
        self.configureSession{}
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
            status = .failed
            captureSession.commitConfiguration()
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput)
        else {
            print("Unable to add device input to capture session")
            status = .unconfigured
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(videoDeviceInput)
        
        DispatchQueue.main.async {
            self.status = .configured
            print("done setting video input")
        }
        

        self.videoDeviceInput = videoDeviceInput
    }
    
    
    func setPhotoOutput(){
        let photoOutput = AVCapturePhotoOutput()
    
        if captureSession.canAddOutput(photoOutput){
            captureSession.addOutput(photoOutput)
            
            DispatchQueue.main.async {
                self.status = .configured
                print("done setting photo output")
            }
            
            self.photoOutput = photoOutput
        }
        else {
            print("Unable to add device output to capture session")
            status = .failed
            captureSession.commitConfiguration()
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
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.configureSession{}
                } else {
                    DispatchQueue.main.async {
                        self?.status = .unauthorized
                    }
                }
            }
        }
    }

    
    func configureSession(completion: @escaping () -> Void) {
        print("configuring cam session")
        
        dispatchGroup.enter()
        
        sessionQueue.async { [weak self] in
            guard let self, self.status == .unconfigured else { return }
            
            
            guard permissionGranted else { return }
            
            self.captureSession.beginConfiguration()
            
            self.setVideoInput()
            
            
            self.setPhotoOutput()
            
            self.captureSession.commitConfiguration()
         
            self.setZoomScale(factor: 3.0)
            
            DispatchQueue.main.async {
                self.isCameraReady = true
                self.dispatchGroup.leave()
                completion()
            }
        }
    }
    
    
    func startSession(completion: @escaping () -> Void) {
        

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            print("Camera session started successfully.")
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async {
            // Ensure the session is running before capturing a photo
            if !self.captureSession.isRunning {
                print("Session not running, attempting to start session.")
                self.startSession {
                    // Once session starts, proceed with capturing photo
                    self.capturePhotoInternal(completion: completion)
                }
            } else {
                self.capturePhotoInternal(completion: completion)
            }
        }
    }

    private func capturePhotoInternal(completion: @escaping (UIImage?) -> Void) {
        let photoSettings = AVCapturePhotoSettings()
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = photoCaptureDelegate

        guard let photoOutput = self.photoOutput else {
            print("No photo output available")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    }

    
    
    func stopSession() {
//        if captureSession.isRunning {
//            captureSession.stopRunning()
//            print("Capture session has stopped running")
//        }
        
        sessionQueue.async { [weak self] in
              guard let self else { return }

              if self.captureSession.isRunning {
                 self.captureSession.stopRunning()
              }
           }
    }
    
    
    func setZoomScale(factor: CGFloat){
        
        guard let device = self.videoDeviceInput?.device else { return }
        

        do{
            try device.lockForConfiguration()
            
            let clampedFactor = max(device.minAvailableVideoZoomFactor, min(factor, device.maxAvailableVideoZoomFactor))
            device.videoZoomFactor = clampedFactor
            self.zoomFactor = clampedFactor
            device.unlockForConfiguration()
            
        }catch {
            print(error.localizedDescription)
        }
    }

    func getCurrentZoomScale() -> CGFloat? {
        guard let device = self.videoDeviceInput?.device else { return nil }
        return device.videoZoomFactor
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
    

}

// fake fix, double capture eveything
