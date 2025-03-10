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
    
    // Saving to images collection
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
            
            imageRef.setData(docData) { error in
                if let error = error {
                    print("Failed to save image path to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully saved image path to Firestore.")
                }
                
                dispatchGroup.leave()
            }
        }
        
        // Fetch latest images from Firestore
        self.retrievePhotos(patientID: patientID, scanID: scanName)
        let labeledImage = LabeledImage(id: imageID,
                                        isPrimary: false, position: region, image: image)
        self.imagesByPosition[region]?.append(labeledImage)
        
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
                            
                            self.downloadImage(from: imageURLString, position: position) { image in
                                let labeledImage = LabeledImage(id: imageID,
                                                                isPrimary: isPrimary, position: position, image: image)
                                
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
        }

        dispatchGroup.notify(queue: .main) {
            print("All selected images have been deleted from Firebase and Firestore.")
        }
    }
}
