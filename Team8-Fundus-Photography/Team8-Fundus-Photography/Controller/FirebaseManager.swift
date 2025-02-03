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
        
    func saveToFirebase(image: UIImage, viewType: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let newPatientID = UUID()
        let newScanID = UUID()
        
        uploadPhotoToFirebaseStorage(patientID: newPatientID, scanID: newScanID, viewType: viewType, photoData: imageData) { url in
            if let url = url {
                print("Uploaded photo URL: \(url)")
                
                self.saveImageMetadatatoFirestore(patientID: newPatientID, scanID: newScanID, viewType: viewType, imageURL: url) {success in
                    if success {
                        print("Successfully saved image metadata to Firestore.")
                    } else {
                        print("Failed to save image metadata to Firestore.")
                        
                    }
                }
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
    
    func uploadPhotoToFirebaseStorage(patientID: UUID, scanID: UUID, viewType: String, photoData: Data, completion: @escaping (String?) -> Void) {
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
    
//    // we are using dispatch group to make async calls
//    // without it, patient list will be empty as it doesnt wait for it to finish getting data
//    func fetchPatientList(completion: @escaping ([Patient]) -> Void) {
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child("patients")
//        let dispatchGroup = DispatchGroup()
//        
//        storageRef.listAll { result in
//            switch result {
//            case .failure(let error):
//                print("Error while listing all patients: \(error)")
//                completion([]) 
//                return
//            case .success(let storageListResult):
//                var patientList: [Patient] = []
//                
//                for patient in storageListResult.prefixes {
//                    dispatchGroup.enter()
//                    
//                    let patientId = patient.name
//                    let patientScanRef = storageRef.child("\(patientId)/scans")
//                    
//                    patientScanRef.listAll { result in
//                        switch result {
//                        case .failure(let error):
//                            print("Error while listing scans for patient \(patientId): \(error)")
//                            dispatchGroup.leave()
//                        case .success(let scanListResult):
//                            let scanCount = scanListResult.prefixes.count
//                            let newPatient = Patient(id: UUID(), name: patientId)
//                            patientList.append(newPatient)
//                            dispatchGroup.leave()
//                        }
//                    }
//                }
//                
//                dispatchGroup.notify(queue: .main) {
//                    completion(patientList)
//                }
//            }
//        }
//    }


    func fetchScanListForPatient(patientID: UUID, completion: @escaping ([Scan]) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("patients/\(patientID)/scans")
        let dispatchGroup = DispatchGroup()
        
        storageRef.listAll { result in
            switch result {
            case .failure(let error):
                print("Error while fetching scans for patient \(patientID): ", error)
                completion([])
            case .success(let storageListResult):
                var scanList: [Scan] = []
                
                print("getting scans...")
                
                for prefix in storageListResult.prefixes {
                    dispatchGroup.enter()
                    
                    prefix.getMetadata() {
                        metadata, error in let createdDate = metadata?.timeCreated ?? Date()
                        let scan = Scan(id: UUID(), createdDate: createdDate, name: prefix.name, regions: ScanRegions(), isStitched: false)
                        scanList.append(scan)
                        print(scanList)
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
               
                    completion(scanList)
                }
            }
        }
    }
    
    
    func addPatientToFirebase(name: String, completion: @escaping (Bool) -> Void) {
        
        print("Attempting to add patient: \(name)")
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("patients/\(name)/ignore.txt")

        let dummyImageData = Data()
    
        storageRef.putData(dummyImageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error adding patient: \(error)")
                completion(false)
            } else {
                print("Patient added successfully")
                completion(true)
            }
        }
    }
    
    func addScanToFirebase(patientId: UUID, scanName: String, completion: @escaping (Bool) -> Void) {
        
        print("Attempting to add scan: \(scanName)")
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("patients/\(patientId)/scans/\(scanName)/ignore.txt")

        let dummyImageData = Data()
    
        storageRef.putData(dummyImageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error adding scan: \(error)")
                completion(false)
            } else {
                print("Scan added successfully")
                completion(true)
            }
        }
    }

    func fetchImagesForScan(scanID: String) {
        
    }
}
