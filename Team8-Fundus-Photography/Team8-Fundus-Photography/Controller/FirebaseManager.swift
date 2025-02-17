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
    
    
    func saveToFirebase(image: UIImage, patientID: String, scanName: String, region: String) {
        
        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let path = "patients/\(patientID)/scans/\(scanName)/\(region)/\(UUID().uuidString).jpg"
        print("This is the new path: \(path)")
        let fileRef = storageRef.child(path)
        
        // Upload image data to Firebase Storage
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            // Successfully uploaded the image, now save the URL to Firestore
            let imageRef = db.collection("patients").document(patientID)
                .collection("scans").document(scanName)
                .collection("regions").document(region)
                .collection("images")
            
            imageRef.addDocument(data: ["imageURL": path]) { error in
                if let error = error {
                    print("Failed to save image path to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully saved image path to Firestore.")
                }
            }
        }
    }
    
    func retrievePtrhotos(patientID: String, scanName: String) {
        print("starting image retrieval")
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        
        let scann = "2D4F6F73-9D6A-4362-9873-57C9A7389FEC"
//        /patients/BA2901E1-5997-4218-9E7B-DC79FC0A6877/scansregions        self.imagesByPosition["Nasal"] = []
        self.imagesByPosition["Superior"] = []
        self.imagesByPosition["Central"] = []
        self.imagesByPosition["Inferior"] = []
        
        let imageRef = db.collection("patients").document(patientID)
            .collection("scans").document(scann)
            .collection("regions")
        
        imageRef.getDocuments() { snapshot, error in
            if let error = error {
                print("Failed to retrieve regions: \(error.localizedDescription)")
                return
            }
            print("this is image ref \(imageRef.path)")
            print("pateint id is: \(patientID)")
            print("scan id is: \(scann)")
            print("Total documents retrived: \(snapshot!.documents.count)")
          
            
            guard let snapshot = snapshot else { return }
            
            for regionDoc in snapshot.documents {
                let region = regionDoc.documentID
                let primaryImageID = regionDoc["primary"] as? String ?? ""
                print("Primary image for \(region): \(primaryImageID)")
                
                let regionImageRef = imageRef.document(region).collection("images")
                
                regionImageRef.getDocuments { imageSnapshot, imageError in
                    if let imageError = imageError {
                        print("Failed to retrieve images for region \(region): \(imageError.localizedDescription)")
                        return
                    }
                    
                    guard let imageSnapshot = imageSnapshot else { return }
                    print("Total images in \(region): \(imageSnapshot.documents.count)")
                    
                    for imageDoc in imageSnapshot.documents {
                        let path = imageDoc["imageURL"] as! String
                        let position = imageDoc["position"] as! String
                        let isPrimary = (imageDoc.documentID == primaryImageID)
                        
                        if self.imagesByPosition[position] == nil {
                            self.imagesByPosition[position] = []
                        }
                        
                        let fileRef = storageRef.child(path)
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let data = data, error == nil {
                                let image = UIImage(data: data)!
                                
                                DispatchQueue.main.async {
                                    let labeledImage = LabeledImage(image: image, isPrimary: isPrimary)
                                    self.imagesByPosition[position]?.append(labeledImage)
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    
  
              
    func retrievePhotos(patientID: String, scanID: String) {
        print("Starting image retrieval")
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
//        let scanID = "37E92081-00F8-43F6-AF90-DA0C60C38EC7"
        
        self.imagesByPosition = [:]
//        ["Nasal": [], "Superior": [], "Central": [], "Inferior": []]
        
        let imageRef = db.collection("patients").document(patientID)
            .collection("scans").document(scanID)
            .collection("regions")
        

        imageRef.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to retrieve regions: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                print("No regions found for scan \(scanID)")
                return
            }
            
            print("Found \(snapshot.documents.count) region(s).")
            
            let dispatchGroup = DispatchGroup()
            
            for regionDoc in snapshot.documents {
                let region = regionDoc.documentID
                let primaryImageID = regionDoc["primary"] as? String ?? ""
                print("Primary image for \(region): \(primaryImageID)")
                
                let regionImageRef = imageRef.document(region).collection("images")
                
                dispatchGroup.enter()
                regionImageRef.getDocuments { imageSnapshot, imageError in
                    if let imageError = imageError {
                        print("Failed to retrieve images for region \(region): \(imageError.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let imageSnapshot = imageSnapshot, !imageSnapshot.isEmpty else {
                        print("No images found for region \(region)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    print("Found \(imageSnapshot.documents.count) image(s) in region \(region).")
                    
                    for imageDoc in imageSnapshot.documents {
                        let path = imageDoc["imageURL"] as? String ?? ""
                        let position = region
                        let isPrimary = (imageDoc.documentID == primaryImageID)
                        
                        if self.imagesByPosition[position] == nil {
                            self.imagesByPosition[position] = []
                        }
                        
                        let fileRef = storageRef.child(path)
                        print("path to image \(fileRef) is: \(path)")
                        dispatchGroup.enter()
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let data = data, error == nil, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    print("sucessfully downloaded image")
                                    let labeledImage = LabeledImage(image: image, isPrimary: isPrimary)
                                    self.imagesByPosition[position]?.append(labeledImage)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.leave()
                }
            }
    

            
            dispatchGroup.notify(queue: .main) {
                print("All images have been retrieved and processed.")
                // Update UI or handle completion here
            }
        }
    }

  


}
