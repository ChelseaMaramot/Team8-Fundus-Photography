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
    
//    func retrievePtrhotos(patientID: String, scanName: String) {
//        print("starting image retrieval")
//        let db = Firestore.firestore()
//        let storageRef = Storage.storage().reference()
//        
//        let scann = "2D4F6F73-9D6A-4362-9873-57C9A7389FEC"
////        /patients/BA2901E1-5997-4218-9E7B-DC79FC0A6877/scansregions        self.imagesByPosition["Nasal"] = []
//        self.imagesByPosition["Superior"] = []
//        self.imagesByPosition["Central"] = []
//        self.imagesByPosition["Inferior"] = []
//        
//        let imageRef = db.collection("patients").document(patientID)
//            .collection("scans").document(scann)
//            .collection("regions")
//        
//        imageRef.getDocuments() { snapshot, error in
//            if let error = error {
//                print("Failed to retrieve regions: \(error.localizedDescription)")
//                return
//            }
//            print("this is image ref \(imageRef.path)")
//            print("pateint id is: \(patientID)")
//            print("scan id is: \(scann)")
//            print("Total documents retrived: \(snapshot!.documents.count)")
//          
//            
//            guard let snapshot = snapshot else { return }
//            
//            for regionDoc in snapshot.documents {
//                let region = regionDoc.documentID
//                let primaryImageID = regionDoc["primary"] as? String ?? ""
//                print("Primary image for \(region): \(primaryImageID)")
//                
//                let regionImageRef = imageRef.document(region).collection("images")
//                
//                regionImageRef.getDocuments { imageSnapshot, imageError in
//                    if let imageError = imageError {
//                        print("Failed to retrieve images for region \(region): \(imageError.localizedDescription)")
//                        return
//                    }
//                    
//                    guard let imageSnapshot = imageSnapshot else { return }
//                    print("Total images in \(region): \(imageSnapshot.documents.count)")
//                    
//                    for imageDoc in imageSnapshot.documents {
//                        let path = imageDoc["imageURL"] as! String
//                        let position = imageDoc["position"] as! String
//                        let isPrimary = (imageDoc.documentID == primaryImageID)
//                        
//                        if self.imagesByPosition[position] == nil {
//                            self.imagesByPosition[position] = []
//                        }
//                        
//                        let fileRef = storageRef.child(path)
//                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
//                            if let data = data, error == nil {
//                                let image = UIImage(data: data)!
//                                
//                                DispatchQueue.main.async {
//                                    let labeledImage = LabeledImage(image: image, isPrimary: isPrimary)
//                                    self.imagesByPosition[position]?.append(labeledImage)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }


    func downloadImage(from path: String, position: String, completion: @escaping (UIImage?) -> Void) {
        
        let modifiedPath = path.replacingOccurrences(of: "regions", with: position)
        let storageRef = Storage.storage().reference(withPath: modifiedPath)
        
        print("Downloading image")
        
        storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                print("image downloaded")
                completion(image)
            } else {
                print("no image to download: nil")
                completion(nil)
            }
        }
        
        

    }
  
              
    // Uses Anjola's images collection
    func retrievePhotos(patientID: String, scanID: String) {
        print("Starting image retrieval")
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")
        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()
        
        print("pID: ", patientID)
        print("sID: ", scanID)
        
        
        imagesRef.whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanID)
            .getDocuments{ (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var imagesByPosition: [String: [LabeledImage]] = [:]
                    
                    for document in snapshot.documents {
                        dispatchGroup.enter()
                        
                        let data = document.data()
                        
                        print("data: ", data)
                        
                        if let imageURLString = data["url"] as? String,
                           let position = data["position"] as? String,
                           let imageURL = URL(string: imageURLString) {
                
                            self.downloadImage(from: imageURLString, position: position) { image in
                                let labeledImage = LabeledImage(image: image, isPrimary: true, position: position)
                                
                                if imagesByPosition[position] != nil {
                                    imagesByPosition[position]?.append(labeledImage)
                                } else {
                                    imagesByPosition[position] = [labeledImage]
                                }
                                dispatchGroup.leave()
                            
                                print("printing array")
                                print(imagesByPosition)
                                
                            }
                        }else{
                            dispatchGroup.leave()
                        }
                    }
                                
                    dispatchGroup.notify(queue: .main) {
                        self.imagesByPosition = imagesByPosition
                        print("Done")
                        print(imagesByPosition)
                    }
                } else {
                    print("No documents found")
                }
                
                
            }

    }
}

  



