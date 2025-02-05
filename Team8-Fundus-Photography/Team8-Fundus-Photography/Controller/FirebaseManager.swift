//
//  FirebaseManager.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-08.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Foundation
import AVFoundation
import UIKit


// Change to an observable object class
class FirebaseManager: ObservableObject {
    @Published var patients: [Patient] = []
    
    func saveToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let patientID = "testPatient1" // Replace with real patient ID
        let scanID = "testScan1" // Replace with real scan ID
        let viewType = "superior" // Replace with real view type
        
        uploadPhotoToFirebase(patientID: patientID, scanID: scanID, viewType: viewType, photoData: imageData) { url in
            if let url = url {
                print("Uploaded photo URL: \(url)")
            } else {
                print("Failed to upload photo.")
            }
        }
    }
    
    
    
    func saveImageMetadatatoFirestore(patientID: UUID, scanID: UUID, viewType: String, imageURL: String, completion: @escaping (Bool) -> Void){
        
        let db = Firestore.firestore()
        let imageRef = db.collection("patients").document(patientID.uuidString).collection("scans").document(scanID.uuidString).collection("regions").document(viewType).collection("images")
        
        imageRef.addDocument(data:  [
            "imageURL": imageURL,
            "uploadedAt": Timestamp(date: Date()),
        ]){ error in
            if let error = error {
                print("Error saving image metadata: \(error)")
                completion(false)
            } else {
                print("Successfully saved image metadata to Firestore.")
                completion(true)
            }
        }
    }
    
    func uploadPhotoToFirebase(patientID: String, scanID: String, viewType: String, photoData: Data, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference()
            .child("patients/\(patientID)/scans/\(scanID)/\(viewType)/\(UUID().uuidString).jpg")
        
        storageRef.putData(photoData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(url.absoluteString)
                } else {
                    print("Failed to get download URL.")
                    completion(nil)
                }
            }
        }
    }
}
  
