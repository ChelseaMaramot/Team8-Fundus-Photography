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
import FirebaseFirestore


// Change to an observable object class
class FirebaseManager: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var imagesByPosition: [String: [LabeledImage]] = [:] // Store images by position
    
    
    // add images here
    struct Scan: Hashable {
        var name: String
        var createdDate: Date
        var isStitched: Bool
    }

    struct Patient: Hashable {
        var name: String
        var scanCount: Int
    }
    
    
    func saveToFirebase(image: UIImage) {
        
        let storageRef = Storage.storage().reference()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let patientID = "testPatient1" // Replace with real patient ID
        let scanID = "testScan1" // Replace with real scan ID
        let viewType = "Central" // Replace with real view type
        let path = "patients/\(patientID)/scans/\(scanID)/\(viewType)/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url": path, "position": viewType, "isPrimary": true])

            }
        }
        
    }
    
    func retrievePhotos(){
//        let photosRef = db.collection("patients").document(patientID).collection("scans").document(scanID).collection("images") // future code?
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        self.imagesByPosition["Nasal"] = []
        self.imagesByPosition["Superior"] = []
        self.imagesByPosition["Central"] = []
        self.imagesByPosition["Inferior"] = []

        db.collection("images").getDocuments() { snapshot, error in
            if error == nil && snapshot != nil {
                var paths = [String]()
                
                for doc in snapshot!.documents {
                    let path = doc["url"] as! String
                    let fileRef = storageRef.child(path)
//                    paths.append(doc["url"] as! String)
                    let position = doc["position"] as! String
                    if self.imagesByPosition[position] == nil {
                        self.imagesByPosition[position] = []
                    }
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if error == nil && data != nil{
                            let image = UIImage(data: data!)!
                            
                            DispatchQueue.main.async {
                                let labeledImage = LabeledImage(image: image, isPrimary: doc["isPrimary"] as! Bool)
                                self.imagesByPosition[position]?.append(labeledImage)
                            }
                        }
                    }
                    
                }
                
//                for path in paths{
//                    let storageRef = Storage.storage().reference()
//                    let fileRef = storageRef.child(path)
//                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
//                        if error == nil && data != nil{
//                            let image = UIImage(data: data!)!
//                            
//                            DispatchQueue.main.async {
//                                imagesByPosition[position]?.append(image)
//                            }
//                        }
//                    }
//                }
                
            }
        }
        
    }
    
  


}
