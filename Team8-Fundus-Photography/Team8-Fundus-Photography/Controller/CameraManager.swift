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
    
    let captureSession: AVCaptureSession
    var photoSettings: AVCapturePhotoSettings?
    var videoDevice: AVCaptureDevice?
    var videoDeviceInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    

    private var permissionGranted: Bool
    private var photoCaptureDelegate: PhotoCaptureDelegate?

    
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
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    func checkPermission() {
         switch AVCaptureDevice.authorizationStatus(for: .video) {
             case .authorized: // The user has previously granted access to the camera.
                 self.permissionGranted = true
                 
             case .notDetermined: // The user has not yet been asked for camera access.
                 self.requestPermission()
                 
         // Combine the two other cases into the default case
         default:
             self.permissionGranted = false
         }
     }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    
    func configureSession(){
    
        guard permissionGranted else { return }
        
        captureSession.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) else {
            print("Unable to access back camera")
            return
        }
        
        // initializing input to session
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput)
        else {
            print("Unable to add device input to capture session")
            return
        }
        
        // intializing output to session
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput)
        else {
            print("Unable to add device output to capture session")
            return
        }
        

        self.photoOutput = photoOutput

        // adding input/output to session
        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(photoOutput)

                
        captureSession.commitConfiguration()
        
    }
    
    func startSession(){
        // start camera capture session
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
    
    // called when user taps photo capture button
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
