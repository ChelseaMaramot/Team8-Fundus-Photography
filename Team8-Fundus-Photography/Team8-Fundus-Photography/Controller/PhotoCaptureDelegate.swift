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
import FirebaseStorage


/*
Saving images doc:
 https://developer.apple.com/documentation/avfoundation/photo_capture/capturing_still_and_live_photos/saving_captured_photos
*/

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        print("initializing photo capture delegate")
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
              print("Error capturing photo: \(error)")
              return
          }
        
        guard let data = photo.fileDataRepresentation(),
                let image = UIImage(data: data) else {
                    print("Failed to convert photo to UIImage.")
                    completion(nil)
                    return
        }
        
        Task{
            let accessGranted = await isPhotoLibraryReadWriteAccessGranted
            if accessGranted {
                  save(photo: photo)
              } else {
                  print("No access granted for photo library.")
              }
        }
        
//        let patientID = "testPatient1"
//        let scanID = "scan1"
//        let viewType = "superior" // "inferior", "central", "nasal"
//        
//        uploadPhotoToFirebase(patientID: patientID, scanID: scanID, viewType: viewType, photoData: data) { url in
//            if let url = url {
//                print("Uploaded photo to Firebase storage with URL: \(url)")
//            
//            } else {
//                print("Failed to upload photo to Firebase storage.")
//            }}
    
        completion(image)
    }
    
    
//    func uploadPhotoToFirebase(patientID: String, scanID: String, viewType: String, photoData: Data, completion: @escaping (String?) -> Void) {
//        // Create a reference to the path in Firebase Storage
//        let storageRef = Storage.storage().reference()
//        //The file name is a randomly generated UUID to ensure uniqueness
//            .child("patients/\(patientID)/scans/\(scanID)/views/\(viewType)/\(UUID().uuidString).jpg")
//        
//        // Upload photo to Firebase
//        storageRef.putData(photoData, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Error uploading photo: \(error)")
//                completion(nil)
//                return
//            }
//            
//            // Retrieve the download URL
//            storageRef.downloadURL { url, error in
//                if let url = url {
//                    completion(url.absoluteString)
//                } else {
//                    print("Failed to get download URL.")
//                    completion(nil)
//                }
//            }
//        }
//    }


    func save(photo: AVCapturePhoto){
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
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            print("checking photo library read/write access")
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
    
}
