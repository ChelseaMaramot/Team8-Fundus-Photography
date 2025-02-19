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
    
    
    // saving to images collection
    func saveToFirebase(image: UIImage, patientID: String, scanName: String, region: String, completion: @escaping () -> Void) {
        print("saving to firebase images collection...")
        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()
        let dispatchGroup = DispatchGroup()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let imageID = UUID().uuidString
        let url = "patients/\(patientID)/scans/\(scanName)/\(region)/\(imageID).jpg"
        print("This is the image url: \(url)")
        
        let fileRef = storageRef.child(url)
        
        // Upload image data to Firebase Storage
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            dispatchGroup.enter()
            
            // Successfully uploaded the image, now save the URL to Firestore
            let imageRef = db.collection("images").document(imageID)
            print("adding image to this firestore path:")
            print(imageRef.path)
            
            let docData: [String: Any] = [
                
                "isPrimary": false,
                "patientID": patientID,
                "position": region,
                "scanID": scanName,
                "url": url
            ]
            
            
            imageRef.setData(docData){ error in
                if let error = error {
                    print("Failed to save image path to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully saved image path to Firestore.")
                }
                
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("done saving image to firebase!")
            completion()
        }
    }
    
    func downloadImage(from path: String, position: String, completion: @escaping (UIImage?) -> Void) {
        
        let modifiedPath = path.replacingOccurrences(of: "regions", with: position)
        let storageRef = Storage.storage().reference(withPath: modifiedPath)
        
        
        storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                //print("image downloaded")
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
                        
                        
                        if let imageURLString = data["url"] as? String,
                           let position = data["position"] as? String,
                           let isPrimary = data["isPrimary"] as? Bool,
                           let imageURL = URL(string: imageURLString) {
                            
                            self.downloadImage(from: imageURLString, position: position) { image in
                                let labeledImage = LabeledImage(image: image, isPrimary: isPrimary, position: position)
                                
                                if imagesByPosition[position] != nil {
                                    imagesByPosition[position]?.append(labeledImage)
                                } else {
                                    imagesByPosition[position] = [labeledImage]
                                }
                                dispatchGroup.leave()
                                
                                
                            }
                        }else{
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self.imagesByPosition = imagesByPosition
                    }
                } else {
                    print("No documents found")
                }
                
                
            }
        
    }
    
    func setPrimaryImage(for position: String, image: LabeledImage, patientID: String, scanID: String) {
        print("Setting new primary image")
        if var images = imagesByPosition[position] {
            let dispatchGroup = DispatchGroup()

      
            for index in images.indices {
                if images[index].id == image.id {
                    images[index].isPrimary = true
                } else {
                    images[index].isPrimary = false
                }
            }

     
            dispatchGroup.enter()
            updateImagePrimaryStatus(patientID: patientID, scanID: scanID, imageID: image.id.uuidString, isPrimary: true) { success in
                if !success {
                    print("Failed to update primary status for image ID: \(image.id.uuidString)")
                }
                dispatchGroup.leave()
            }

   
            for otherImage in images {
                if otherImage.id != image.id {
                    dispatchGroup.enter()
                    updateImagePrimaryStatus(patientID: patientID, scanID: scanID, imageID: otherImage.id.uuidString, isPrimary: false) { success in
                        if !success {
                            print("Failed to update primary status for image ID: \(otherImage.id.uuidString)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.imagesByPosition[position] = images
                print("Done setting new primary image")
            }
        }
    }

    
    
    
    func updateImagePrimaryStatus(patientID: String, scanID: String, imageID: String, isPrimary: Bool, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        print("Updating isPrimary for image ID: \(imageID)")
        let imageRef = db.collection("images").document(imageID)

        imageRef.getDocument { (document, error) in
            var success = true

            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                success = false
                completion(success)
            }

          
            if let document = document, document.exists {
                imageRef.updateData([
                    "isPrimary": isPrimary
                ]) { error in
                    if let error = error {
                        print("Error updating isPrimary field: \(error.localizedDescription)")
                        success = false
                    } else {
                        print("Primary status updated successfully for image ID: \(imageID)")
                    }
                }
            } else {
                success = false
                print("Image document with ID \(imageID) does not exist.")
            }

            completion(success)
        }
    }

}


  



