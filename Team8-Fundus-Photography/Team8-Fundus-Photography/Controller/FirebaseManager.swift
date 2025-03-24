//
//  FirebaseManager.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-08.
//
import Foundation
import FirebaseStorage
import AVFoundation
import UIKit
import FirebaseFirestore

// Change to an observable object class
class FirebaseManager: ObservableObject {
    
    @Published var patients: [Patient] = []
    @Published var imagesByPosition: [String: [LabeledImage]] = [:] // Store images by position
    
    func saveToFirebase(image: UIImage, patientID: String, scanID: String, region: String, completion: @escaping () -> Void) {
        print("Saving to Firebase images collection...")
        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()
        let dispatchGroup = DispatchGroup()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return
        }
        
        let imageID = UUID().uuidString
        let url = "patients/\(patientID)/scans/\(scanID)/\(region)/\(imageID).jpg"
        print("This is the image URL: \(url)")
        
        let fileRef = storageRef.child(url)
        
        // Upload image to Firebase Storage
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            dispatchGroup.enter()
            
            // Check if there's already a primary image in this region
            let imagesRef = db.collection("images")
            imagesRef.whereField("patientID", isEqualTo: patientID)
                .whereField("scanID", isEqualTo: scanID)
                .whereField("position", isEqualTo: region)
                .whereField("isPrimary", isEqualTo: true)
                .getDocuments { (snapshot, error) in
                    
                    var isPrimary = false
                    
                    if let error = error {
                        print("Error checking for existing primary image: \(error.localizedDescription)")
                    } else if snapshot?.documents.isEmpty == true {
                        print("No existing primary image found, setting this as primary.")
                        isPrimary = true
                    } else {
                        print("Primary image already exists, not setting this one as primary.")
                    }
                    
                    // Save the image metadata to Firestore
                    let imageRef = db.collection("images").document(imageID)
                    let docData: [String: Any] = [
                        "isPrimary": isPrimary,  // Set the first image as primary if needed
                        "patientID": patientID,
                        "position": region,
                        "scanID": scanID,
                        "url": url
                    ]
                    
                    imageRef.setData(docData) { error in
                        if let error = error {
                            print("Failed to save image path to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Successfully saved image path to Firestore.")
                        }
                        
                        dispatchGroup.leave()
                    }
                    
                    // Update local storage
                    let labeledImage = LabeledImage(id: imageID, isPrimary: isPrimary, position: region, image: image)
                    if self.imagesByPosition[region] != nil {
                        self.imagesByPosition[region]?.append(labeledImage)
                    } else {
                        self.imagesByPosition[region] = [labeledImage]
                    }
                }
        }
        
       
        dispatchGroup.notify(queue: .main) {
            print("Done saving image to Firebase!")
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
                completion(image)
            } else {
                print("no image to download: nil")
                completion(nil)
            }
        }
    }
    
    func updateImageComment(imageID: String, newComment: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let imageRef = db.collection("images").document(imageID)

        imageRef.updateData([
            "comment": newComment
        ]) { error in
            if let error = error {
                print("❌ Failed to update comment: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Comment updated successfully.")
                completion(true)
            }
        }
    }

    
    // Uses Anjola's images collection
    func retrievePhotos(patientID: String, scanID: String) {
        print("Starting image retrieval")
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")
        let dispatchGroup = DispatchGroup()
        var fetchedImagesByPosition: [String: [LabeledImage]] = [
            "Central": [],
            "Superior": [],
            "Nasal": [],
            "Temporal": [],
            "Inferior": []
        ]
        print("pID: ", patientID)
        print("sID: ", scanID)
        
        imagesRef.whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        dispatchGroup.enter()
                        
                        let data = document.data()
                        
                        if let imageURLString = data["url"] as? String,
                           let position = data["position"] as? String,
                           let isPrimary = data["isPrimary"] as? Bool,
                           let imageID = document.documentID as? String,
                           let imageURL = URL(string: imageURLString) {
                           let comment = data["comment"] as? String ?? ""
                            self.downloadImage(from: imageURLString, position: position) { image in
                                let labeledImage = LabeledImage(id: imageID,
                                                                isPrimary: isPrimary, position: position, image: image, comment: comment)
                                
                                if fetchedImagesByPosition[position] != nil {
                                    fetchedImagesByPosition[position]?.append(labeledImage)
                                } else {
                                    fetchedImagesByPosition[position] = [labeledImage]
                                }
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self.imagesByPosition = fetchedImagesByPosition
                    }
                } else {
                    print("No documents found")
                }
            }
    }
    
    func setPrimaryImage(for position: String, image: LabeledImage, patientID: String, scanID: String) {
        print("Setting new primary image for \(image)")
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
            updateImagePrimaryStatus(patientID: patientID, scanID: scanID, imageID: image.id, isPrimary: true) { success in
                if !success {
                    print("Failed to update primary status for image ID: \(image.id)")
                }
                dispatchGroup.leave()
            }
            
            for otherImage in images {
                if otherImage.id != image.id {
                    dispatchGroup.enter()
                    updateImagePrimaryStatus(patientID: patientID, scanID: scanID, imageID: otherImage.id, isPrimary: false) { success in
                        if !success {
                            print("Failed to update primary status for image ID: \(otherImage.id)")
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
    
    
    
    func fetchPrimaryLabeledImages(patientID: String, scanID: String, completion: @escaping ([LabeledImage]) -> Void) {
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")
        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()
        
        var labeledImages: [LabeledImage] = []

        imagesRef.whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanID)
            .whereField("isPrimary", isEqualTo: true)
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching primary images: \(error?.localizedDescription ?? "unknown error")")
                    completion([])
                    return
                }

                for doc in snapshot.documents {
                    let data = doc.data()
                    let id = doc.documentID
                    let position = data["position"] as? String ?? "Unknown"
                    let isPrimary = data["isPrimary"] as? Bool ?? false
                    let comment = data["comment"] as? String
                    let url = data["url"] as? String

                    guard let imagePath = url else { continue }

                    dispatchGroup.enter()
                    let imageRef = storageRef.child(imagePath)
                    imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                        var image: UIImage? = nil
                        if let data = data {
                            image = UIImage(data: data)
                        } else {
                            print("Failed to load image for \(position): \(error?.localizedDescription ?? "unknown error")")
                        }

                        let labeled = LabeledImage(id: id, isPrimary: isPrimary, position: position, image: image, comment: comment)
                        labeledImages.append(labeled)

                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    completion(labeledImages)
                }
            }
    }

//    func fetchPrimaryImages(patientID: String, scanID: String, completion: @escaping ([String: UIImage]) -> Void) {
//        let db = Firestore.firestore()
//        let imagesRef = db.collection("images")
//        var primaryImages: [String: UIImage] = [
//            "Central": UIImage(),
//            "Superior": UIImage(),
//            "Nasal": UIImage(),
//            "Temporal": UIImage(),
//            "Inferior": UIImage()
//        ]
//        
//        let storageRef = Storage.storage().reference()
//        let dispatchGroup = DispatchGroup()
//        
//        imagesRef.whereField("patientID", isEqualTo: patientID)
//            .whereField("scanID", isEqualTo: scanID)
//            .whereField("isPrimary", isEqualTo: true) // Only fetch primary images
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print("Error fetching primary images: \(error.localizedDescription)")
//                    completion(primaryImages)
//                    return
//                }
//                
//                guard let snapshot = snapshot, !snapshot.isEmpty else {
//                    print("No primary images found for this scan.")
//                    completion(primaryImages)
//                    return
//                }
//                
//                for document in snapshot.documents {
//                    let data = document.data()
//                    
//                    if let imageURLString = data["url"] as? String,
//                       let position = data["position"] as? String {
//                        
//                        dispatchGroup.enter()
//                        
//                        let imageRef = storageRef.child(imageURLString)
//                        imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
//                            if let error = error {
//                                print("Error downloading image for \(position): \(error.localizedDescription)")
//                            } else if let data = data, let image = UIImage(data: data) {
//                                primaryImages[position] = image
//                            }
//                            dispatchGroup.leave()
//                        }
//                    }
//                }
//                
//                dispatchGroup.notify(queue: .main) {
//                    completion(primaryImages)
//                }
//            }
//    }
//    
    
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
    
    // Will need to see what happens if deletion from one of the sites fail.
    func deleteSelectedImages(selectedImages: [LabeledImage], patientID: String, scanName: String) {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()
        
        for image in selectedImages {
            let url = "patients/\(patientID)/scans/\(scanName)/\(image.position)/\(image.id).jpg"
            print("deleting from storage \(url)")
            let imageRef = storageRef.child(url)
            
            // Delete the image from Firebase Storage
            imageRef.delete { error in
                dispatchGroup.enter()
                if let error = error {
                    print("Error deleting image from Firebase Storage: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted image from Firebase Storage.")
                }
                dispatchGroup.leave()
            }
            
            // Delete the image document from Firestore
            let imageDocRef = db.collection("images").document(image.id)
            imageDocRef.delete { error in
                dispatchGroup.enter()
                if let error = error {
                    print("Error deleting image document from Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted image document from Firestore.")
                }
                dispatchGroup.leave()
            }
            
            if var images = self.imagesByPosition[image.position] {
                self.imagesByPosition[image.position] = images.filter { $0.id != image.id }
            }
            
            
            if image.isPrimary {
                dispatchGroup.enter()
                assignPrimaryImage(patientID: patientID, scanName: scanName, position: image.position) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All selected images have been deleted from Firebase and Firestore.")
        }
    }
    
    func assignPrimaryImage(patientID: String, scanName: String, position: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")
        
        imagesRef
            .whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanName)
            .whereField("position", isEqualTo: position)
            .order(by: "url") // Sort to pick the first available image
            .limit(to: 1)
            .getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print("Error fetching new primary image: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                if let newPrimaryDoc = snapshot?.documents.first {
                    let newPrimaryID = newPrimaryDoc.documentID
                    let newPrimaryRef = db.collection("images").document(newPrimaryID)
                    
                    newPrimaryRef.updateData(["isPrimary": true]) { error in
                        if let error = error {
                            print("Error updating new primary image: \(error.localizedDescription)")
                        } else {
                            print("New primary image set: \(newPrimaryID)")
                            if var images = self.imagesByPosition[position] {
                                if let index = images.firstIndex(where: { $0.id == newPrimaryID }) {
                                    images[index].isPrimary = true
                                    self.imagesByPosition[position] = images
                                }
                            }
                        }
                        completion()
                    }
                } else {
                    print("No remaining images for this position, no new primary assigned.")
                    completion()
                }
            })
    }
}
