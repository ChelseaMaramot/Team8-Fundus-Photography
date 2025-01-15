//
//  FirebaseManager.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-08.
//

import Foundation
import FirebaseStorage
import Foundation
import AVFoundation
import UIKit


// Change to an observable object class
class FirebaseManager: ObservableObject {
    @Published var patients: [String] = []
    
    
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
    
    
    func fetchPatientList() {
        let storage = Storage.storage();
        let storageRef = storage.reference().child("patients")
        
        storageRef.listAll{(result, error) in
            if let error = error {
                print("Error while listing all files: ", error)
            }
            DispatchQueue.main.async {
                          self.patients = result?.prefixes.map { $0.name } ?? []
                          print("Fetched Patient Names: \(self.patients)")
                      }
        }
    }
    
    
    
    func fetchScansForPatient(patientID: String) {
        
    }
    
    func fetchImagesForScan(scanID: String) {
        
    }
}
