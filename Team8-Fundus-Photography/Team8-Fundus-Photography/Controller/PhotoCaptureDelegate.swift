//
//  PhotoCaptureDelegate.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-12.
//

import Foundation
import UIKit
import Photos
import AVFoundation

/*
Saving images doc:
 https://developer.apple.com/documentation/avfoundation/photo_capture/capturing_still_and_live_photos/saving_captured_photos
*/

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            // Determine if the user previously authorized read/write access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
            }
            
            return isAuthorized
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        
        Task{
            await save(photo: photo)
        }
        
    }
    
    
    func save(photo: AVCapturePhoto) async {
        // Confirm the user granted read/write access.
        guard await isPhotoLibraryReadWriteAccessGranted else { return }
        
        // Create a data representation of the photo and its attachments.
        if let photoData = photo.fileDataRepresentation() {
            PHPhotoLibrary.shared().performChanges {
                // Save the photo data.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photoData, options: nil)
            } completionHandler: { success, error in
                if let error = error {
                    print("Error saving photo: \(error.localizedDescription)")
                    return
                }
                if success {
                    print("Photo saved successfully!")
                }
            }
        }
    }
}
