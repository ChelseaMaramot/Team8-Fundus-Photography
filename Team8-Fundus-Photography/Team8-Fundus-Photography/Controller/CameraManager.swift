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



class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        completion(image)
    }
}


class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    var videoDevice: AVCaptureDevice?
    var videoDeviceInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    override init() {
            super.init()
            configureSession()
        }
    
    func configureSession(){
    
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back)
        
        // initializing input to session
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
               captureSession.canAddInput(videoDeviceInput)
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
        
        // adding input/output to session
        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(photoOutput)
    }
    
    func startSession(){
        // start camera capture session
        captureSession.startRunning()
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    // called when user taps photo capture button
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let photoSettings = AVCapturePhotoSettings()
        
        // Use optional chaining
        photoOutput?.capturePhoto(with: photoSettings, delegate: PhotoCaptureDelegate(completion: completion))
    }

}
