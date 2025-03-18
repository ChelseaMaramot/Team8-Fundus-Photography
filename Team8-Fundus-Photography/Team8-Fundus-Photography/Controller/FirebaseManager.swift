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
import CryptoKit

import CryptoKit

// Change to an observable object class
class FirebaseManager: ObservableObject {
    
    @Published var patients: [Patient] = []
    @Published var imagesByPosition: [String: [LabeledImage]] = [:] // Store images by position
    
    func saveToFirebase(image: UIImage, patientID: String, scanID: String, region: String, completion: @escaping () -> Void) {
        print("🔐 Saving encrypted image to Firebase...")

        let storageRef = Storage.storage().reference()
        let db = Firestore.firestore()

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data.")
            return
        }

        // 🔐 Fetch encryption key from Keychain
        guard let key = getKeyFromKeychain() else {
            print("❌ Failed to retrieve encryption key")
            return
        }

        do {
            // 🔐 Encrypt image using ChaChaPoly
            let sealedBox = try ChaChaPoly.seal(imageData, using: key)
            let encryptedData = sealedBox.combined

            let imageID = UUID().uuidString
            let url = "patients/\(patientID)/scans/\(scanID)/\(region)/\(imageID).jpg"
            let fileRef = storageRef.child(url)

            // Upload encrypted data to Firebase Storage
            fileRef.putData(encryptedData, metadata: nil) { metadata, error in
                if let error = error {
                    print("❌ Failed to upload encrypted image: \(error.localizedDescription)")
                    return
                }

                // Save metadata to Firestore
                let imageRef = db.collection("images").document(imageID)
                let docData: [String: Any] = [
                    "isPrimary": false,
                    "patientID": patientID,
                    "position": region,
                    "scanID": scanID,
                    "url": url
                ]

                imageRef.setData(docData) { error in
                    if let error = error {
                        print("❌ Failed to save encrypted image metadata to Firestore: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully saved encrypted image to Firebase Storage.")
                    }
                    completion()
                }
            }
        } catch {
            print("❌ Encryption failed: \(error.localizedDescription)")
        }
    }

    
    
    func saveToFirebaseold(image: UIImage, patientID: String, scanID: String, region: String, completion: @escaping () -> Void) {
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
        let storageRef = Storage.storage().reference(withPath: path)

        storageRef.getData(maxSize: 10 * 1024 * 1024) { (encryptedData, error) in
            if let error = error {
                print("❌ Error downloading encrypted image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let encryptedData = encryptedData else {
                print("❌ No encrypted image data found")
                completion(nil)
                return
            }

            // 🔐 Fetch encryption key from Keychain
            guard let key = self.getKeyFromKeychain() else {
                print("❌ Failed to retrieve encryption key")
                completion(nil)
                return
            }

            do {
                // 🔐 Decrypt image
                let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
                let decryptedData = try ChaChaPoly.open(sealedBox, using: key)

                if let image = UIImage(data: decryptedData) {
                    completion(image)
                } else {
                    print("❌ Failed to decode decrypted image")
                    completion(nil)
                }
            } catch {
                print("❌ Decryption failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    func retrieveAndPrintKey() {
        if let key = getKeyFromKeychain() {
            print("🔑 Retrieved Key: \(key.withUnsafeBytes { Data($0).base64EncodedString() })")
        } else {
            print("❌ No key found in Keychain.")
        }
    }

//    func downloadImage(from path: String, position: String, completion: @escaping (UIImage?) -> Void) {
//        let modifiedPath = path.replacingOccurrences(of: "regions", with: position)
//        let storageRef = Storage.storage().reference(withPath: modifiedPath)
//        
//        storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//            if let error = error {
//                print("Error downloading image: \(error.localizedDescription)")
//                completion(nil)
//            } else if let data = data, let image = UIImage(data: data) {
//                completion(image)
//            } else {
//                print("no image to download: nil")
//                completion(nil)
//            }
//        }
//    }
    
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

        guard let key = getKeyFromKeychain() else {
            print("❌ Failed to retrieve encryption key")
            return
        }

        if var images = imagesByPosition[position] {
            let dispatchGroup = DispatchGroup()

            for index in images.indices {
                images[index].isPrimary = (images[index].id == image.id)
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
                print("✅ Done setting new primary image")
            }
        }
    }

    func fetchPrimaryImages(patientID: String, scanID: String, completion: @escaping ([String: UIImage]) -> Void) {
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")
        var primaryImages: [String: UIImage] = [:]
        let dispatchGroup = DispatchGroup()

        guard let key = getKeyFromKeychain() else {
            print("❌ Failed to retrieve encryption key")
            completion(primaryImages)
            return
        }

        imagesRef.whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanID)
            .whereField("isPrimary", isEqualTo: true) // Only fetch primary images
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching primary images: \(error.localizedDescription)")
                    completion(primaryImages)
                    return
                }

                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    print("No primary images found for this scan.")
                    completion(primaryImages)
                    return
                }

                for document in snapshot.documents {
                    let data = document.data()

                    if let imageURLString = data["url"] as? String,
                       let position = data["position"] as? String {

                        dispatchGroup.enter()
                        self.downloadImage(from: imageURLString, position: position) { image in
                            if let decryptedImage = image {
                                primaryImages[position] = decryptedImage
                            }
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("✅ Finished fetching primary images")
                    completion(primaryImages)
                }
            }
    }

    func updateImagePrimaryStatus(patientID: String, scanID: String, imageID: String, isPrimary: Bool, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        print("Updating isPrimary for image ID: \(imageID)")

        let imageRef = db.collection("images").document(imageID)

        imageRef.getDocument { (document, error) in
            guard document?.exists == true else {
                print("❌ Image document does not exist for ID \(imageID)")
                completion(false)
                return
            }

            imageRef.updateData(["isPrimary": isPrimary]) { error in
                if let error = error {
                    print("❌ Error updating isPrimary field: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Primary status updated successfully for image ID: \(imageID)")
                    completion(true)
                }
            }
        }
    }

    
    // Will need to see what happens if deletion from one of the sites fail.
    func deleteSelectedImages(selectedImages: [LabeledImage], patientID: String, scanID: String) {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()

        for image in selectedImages {
            let url = "patients/\(patientID)/scans/\(scanID)/\(image.position)/\(image.id).jpg"
            print("🗑️ Deleting from storage: \(url)")
            let imageRef = storageRef.child(url)

            // Delete from Firebase Storage
            dispatchGroup.enter()
            imageRef.delete { error in
                if let error = error {
                    print("❌ Error deleting image from Firebase Storage: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully deleted from Firebase Storage.")
                }
                dispatchGroup.leave()
            }

            // Delete from Firestore
            dispatchGroup.enter()
            let imageDocRef = db.collection("images").document(image.id)
            imageDocRef.delete { error in
                if let error = error {
                    print("❌ Error deleting image document from Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully deleted from Firestore.")
                }
                dispatchGroup.leave()
            }

            // Remove from local cache
            if var images = self.imagesByPosition[image.position] {
                self.imagesByPosition[image.position] = images.filter { $0.id != image.id }
            }

            // If the deleted image was the primary, assign a new one
            if image.isPrimary {
                dispatchGroup.enter()
                assignPrimaryImage(patientID: patientID, scanID: scanID, position: image.position) {
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("✅ All selected images deleted from Firebase and Firestore.")
        }
    }
    
    func assignPrimaryImage(patientID: String, scanID: String, position: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let imagesRef = db.collection("images")

        guard let key = getKeyFromKeychain() else {
            print("❌ Failed to retrieve encryption key")
            completion()
            return
        }

        imagesRef
            .whereField("patientID", isEqualTo: patientID)
            .whereField("scanID", isEqualTo: scanID)
            .whereField("position", isEqualTo: position)
            .order(by: "url") // Sort to pick the first available image
            .limit(to: 1)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching new primary image: \(error.localizedDescription)")
                    completion()
                    return
                }

                guard let newPrimaryDoc = snapshot?.documents.first else {
                    print("❌ No remaining images for this position, no new primary assigned.")
                    completion()
                    return
                }

                let newPrimaryID = newPrimaryDoc.documentID
                let newPrimaryRef = db.collection("images").document(newPrimaryID)

                // 🔽 Decrypt the image before updating it in local storage 🔽
                if let imageURLString = newPrimaryDoc.data()["url"] as? String {
                    self.downloadImage(from: imageURLString, position: position) { decryptedImage in
                        guard let decryptedImage = decryptedImage else {
                            print("Failed to decrypt image. Skipping primary assignment.")
                            completion()
                            return
                        }

                        // Update Firestore to mark the image as primary
                        newPrimaryRef.updateData(["isPrimary": true]) { error in
                            if let error = error {
                                print("Error updating new primary image: \(error.localizedDescription)")
                            } else {
                                print("New primary image set: \(newPrimaryID)")

                                //  Update the local cache
                                if var images = self.imagesByPosition[position] {
                                    if let index = images.firstIndex(where: { $0.id == newPrimaryID }) {
                                        images[index].isPrimary = true
                                        images[index].image = decryptedImage
                                        self.imagesByPosition[position] = images
                                    }
                                }
                            }
                            completion()
                        }
                    }
                } else {
                    print("❌ Image URL not found in Firestore")
                    completion()
                }
            }
    }

}

extension FirebaseManager {

    /// 🔐 **Generate and store an encryption key in Keychain**
    func generateAndStoreKey() {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data(Array($0)) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "EncryptionKey",
            kSecValueData as String: keyData
        ]

        SecItemDelete(query as CFDictionary) // Remove existing key if any
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Encryption key stored in Keychain")
        } else {
            print("❌ Failed to store encryption key in Keychain")
        }
    }

    /// 🔐 **Retrieve the encryption key from Apple Keychain**
    func getKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "EncryptionKey",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            print("🔐 Successfully retrieved encryption key from Keychain.")
            return SymmetricKey(data: retrievedData)
        } else {
            print("❌ Failed to retrieve encryption key from Keychain.")
            return nil
        }
    }
}



