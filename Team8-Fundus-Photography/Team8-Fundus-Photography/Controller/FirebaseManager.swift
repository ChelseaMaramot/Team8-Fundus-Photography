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
    @Published var patients: [Patient] = []
    
    
    // add images here
    struct Scan: Hashable {
        var scanName: String
    }

    struct Patient: Hashable {
        var name: String
        var scanCount: Int
        var scanList: [Scan]
    }
    
    
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
    
    // we are using dispatch group to make async calls
    // without it, patient list will be empty as it doesnt wait for it to finish getting data
    func fetchPatientList() {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("patients")
        let dispatchGroup = DispatchGroup()
        
        storageRef.listAll { result in
            if case .failure(let error) = result {
                print("Error while listing all patients: \(error)")
                return
            }
            

            if case .success(let storageListResult) = result {
                var patientList: [Patient] = []
                
           
                for patient in storageListResult.prefixes {
                    
                    dispatchGroup.enter()
                    
                    let patientId = patient.name
                    self.fetchScansForPatient(patientID: patientId) { scanDetails in
                        
                        let newPatient = Patient(name: patientId, scanCount: scanDetails.count, scanList: scanDetails)
                        
                        patientList.append(newPatient)
                    
                        dispatchGroup.leave()
                        
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                             self.patients = patientList
                            
                         }
            }
        }
    }


    func fetchScansForPatient(patientID: String, completion: @escaping ([Scan]) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("patients/\(patientID)/scans")
        
        storageRef.listAll { result in
            switch result {
            case .failure(let error):
                print("Error while fetching scans for patient \(patientID): ", error)
                completion([])
                
                
            case .success(let storageListResult):
                var scanDetails: [Scan] = []
                
                for prefix in storageListResult.prefixes {
                    let scan = Scan(scanName: prefix.name)
                    scanDetails.append(scan)
                }
                completion(scanDetails)
            }
        }
    }
        

    func fetchImagesForScan(scanID: String) {
        
    }
}
