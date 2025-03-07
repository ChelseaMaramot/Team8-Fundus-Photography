////
////  PhotoCaptureDelegate.swift
////  Team8-Fundus-Photography
////
////  Created by chelsea maramot on 2024-11-12.
////


import Foundation
import UIKit
import Photos
import AVFoundation
import FirebaseStorage

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private var isCapturingPhoto = false  // Prevent multiple captures
    
    init(completion: @escaping (UIImage?) -> Void) {
        print("Initializing PhotoCaptureDelegate")
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            completion(nil)
            isCapturingPhoto = false
            return
        }
        
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            print("Failed to convert photo to UIImage.")
            completion(nil)
            isCapturingPhoto = false
            return
        }
        
        Task {
            let accessGranted = await isPhotoLibraryReadWriteAccessGranted
            if accessGranted {
                await save(photo: photo)
                DispatchQueue.main.async {
                    self.completion(image)
                    self.isCapturingPhoto = false
                }
            } else {
                print("No access granted for photo library.")
                DispatchQueue.main.async {
                    self.completion(nil)
                    self.isCapturingPhoto = false
                }
            }
        }
    }
    
    func save(photo: AVCapturePhoto) async {
        guard let photoData = photo.fileDataRepresentation() else {
            print("Failed to generate photo data.")
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: photoData, options: nil)
        } completionHandler: { success, error in
            if let error = error {
                print("Error saving photo: \(error.localizedDescription)")
            }
            if success {
                print("Photo saved successfully!")
            }
        }
    }
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            print("Checking photo library read/write access")
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
            }
            
            return isAuthorized
        }
    }
}
