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

// Change to an observable object class
class FirebaseManager: ObservableObject {
    
    @Published var patients: [Patient] = []
    @Published var imagesByPosition: [String: [LabeledImage]] = [:] // Store images by position
    
    
    private let keychainKey = "encryptionKey"

        // MARK: - Key Management
        func generateAndStoreKey() {
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data(Array($0)) }

            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: keychainKey,
                kSecValueData as String: keyData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]

            SecItemDelete(query as CFDictionary) // clear old key
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                print("Encryption key saved successfully.")
            } else {
                print("Failed to store encryption key.")
            }
        }

        func getKeyFromKeychain() -> SymmetricKey? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: keychainKey,
                kSecReturnData as String: true
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            if status == errSecSuccess, let data = result as? Data {
                return SymmetricKey(data: data)
            }
            return nil
        }

        func retrieveAndPrintKey() {
            if let key = getKeyFromKeychain() {
                print("Encryption key retrieved: \(key)")
            } else {
                print("Encryption key not found.")
            }
        }

        func encrypt(data: Data) -> Data? {
            guard let key = getKeyFromKeychain() else { return nil }
            do {
                let sealedBox = try AES.GCM.seal(data, using: key)
                return sealedBox.combined
            } catch {
                print("Encryption failed: \(error.localizedDescription)")
                return nil
            }
        }

        func decrypt(data: Data) -> Data? {
            guard let key = getKeyFromKeychain() else { return nil }
            do {
                let sealedBox = try AES.GCM.SealedBox(combined: data)
                return try AES.GCM.open(sealedBox, using: key)
            } catch {
                print("Decryption failed: \(error.localizedDescription)")
                return nil
            }
        }

    
    // MARK: - Upload with Encryption
        func saveToFirebase(image: UIImage, patientID: String, scanID: String, region: String, completion: @escaping () -> Void) {
            let storageRef = Storage.storage().reference()
            let db = Firestore.firestore()
            let dispatchGroup = DispatchGroup()

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to JPEG data.")
                return
            }

            guard let encryptedData = encrypt(data: imageData) else {
                print("Encryption failed. Aborting upload.")
                return
            }

            let imageID = UUID().uuidString
            let url = "patients/\(patientID)/scans/\(scanID)/\(region)/\(imageID).jpg"
            let fileRef = storageRef.child(url)

            fileRef.putData(encryptedData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    return
                }

                dispatchGroup.enter()
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
                            isPrimary = true
                        }

                        let imageRef = db.collection("images").document(imageID)
                        let docData: [String: Any] = [
                            "isPrimary": isPrimary,
                            "patientID": patientID,
                            "position": region,
                            "scanID": scanID,
                            "url": url,
                            "encrypted": true
                        ]

                        imageRef.setData(docData) { error in
                            if let error = error {
                                print("Failed to save image path to Firestore: \(error.localizedDescription)")
                            }
                            dispatchGroup.leave()
                        }

                        let labeledImage = LabeledImage(id: imageID, isPrimary: isPrimary, position: region, image: image)
                        if self.imagesByPosition[region] != nil {
                            self.imagesByPosition[region]?.append(labeledImage)
                        } else {
                            self.imagesByPosition[region] = [labeledImage]
                        }
                    }
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    
    // MARK: - Update Cropped Image with Encryption
        func updateCroppedImageInFirebase(image: UIImage, patientID: String, scanID: String, position: String, imageID: String, completion: @escaping (Bool) -> Void) {
            let storageRef = Storage.storage().reference()
            let db = Firestore.firestore()

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to JPEG data.")
                completion(false)
                return
            }

            guard let encryptedData = encrypt(data: imageData) else {
                print("Encryption failed. Aborting upload.")
                completion(false)
                return
            }

            let path = "patients/\(patientID)/scans/\(scanID)/\(position)/\(imageID).jpg"
            let fileRef = storageRef.child(path)

            fileRef.putData(encryptedData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload cropped image: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                db.collection("images").document(imageID).updateData([
                    "url": path,
                    "encrypted": true
                ]) { error in
                    if let error = error {
                        print("Failed to update Firestore image path: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Successfully updated cropped image in Firebase.")
                        completion(true)
                    }
                }
            }
        }
    
    // MARK: - Download with Optional Decryption
        func downloadImage(from path: String, position: String, completion: @escaping (UIImage?) -> Void) {
            let storageRef = Storage.storage().reference(withPath: path)
            let db = Firestore.firestore()

            db.collection("images").whereField("url", isEqualTo: path).getDocuments { snapshot, error in
                var shouldDecrypt = false
                if let snapshot = snapshot, let doc = snapshot.documents.first {
                    shouldDecrypt = doc.data()["encrypted"] as? Bool ?? false
                }

                storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    guard let data = data else {
                        print("Downloaded data is nil")
                        completion(nil)
                        return
                    }

                    let finalData = shouldDecrypt ? self.decrypt(data: data) : data
                    if let finalData = finalData, let image = UIImage(data: finalData) {
                        completion(image)
                    } else {
                        completion(nil)
                    }
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

    // MARK: - Enhanced retrieval methods with decryption
        func retrievePhotos(patientID: String, scanID: String) {
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

            imagesRef.whereField("patientID", isEqualTo: patientID)
                .whereField("scanID", isEqualTo: scanID)
                .getDocuments { (snapshot, error) in
                    guard let documents = snapshot?.documents, error == nil else {
                        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    for doc in documents {
                        dispatchGroup.enter()
                        let data = doc.data()
                        let id = doc.documentID
                        let position = data["position"] as? String ?? "Unknown"
                        let isPrimary = data["isPrimary"] as? Bool ?? false
                        let comment = data["comment"] as? String ?? ""
                        let url = data["url"] as? String ?? ""
                        let isEncrypted = data["encrypted"] as? Bool ?? false

                        let storageRef = Storage.storage().reference(withPath: url)
                        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            var image: UIImage? = nil
                            if let data = data {
                                let finalData = isEncrypted ? self.decrypt(data: data) : data
                                image = finalData != nil ? UIImage(data: finalData!) : nil
                            }
                            let labeled = LabeledImage(id: id, isPrimary: isPrimary, position: position, image: image, comment: comment)
                            if fetchedImagesByPosition[position] != nil {
                                fetchedImagesByPosition[position]?.append(labeled)
                            } else {
                                fetchedImagesByPosition[position] = [labeled]
                            }
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        self.imagesByPosition = fetchedImagesByPosition
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
    
    func fetchImagesByPosition(patientID: String, scanID: String, position: String, completion: @escaping () -> Void) {
            let db = Firestore.firestore()
            let imagesRef = db.collection("images")
            let dispatchGroup = DispatchGroup()

            var fetchedImages: [LabeledImage] = []

            imagesRef.whereField("patientID", isEqualTo: patientID)
                .whereField("scanID", isEqualTo: scanID)
                .whereField("position", isEqualTo: position)
                .getDocuments { (snapshot, error) in
                    guard let documents = snapshot?.documents, error == nil else {
                        print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                        completion()
                        return
                    }

                    for doc in documents {
                        dispatchGroup.enter()
                        let data = doc.data()
                        let id = doc.documentID
                        let isPrimary = data["isPrimary"] as? Bool ?? false
                        let comment = data["comment"] as? String ?? ""
                        let url = data["url"] as? String ?? ""
                        let isEncrypted = data["encrypted"] as? Bool ?? false

                        let storageRef = Storage.storage().reference(withPath: url)
                        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            var image: UIImage? = nil
                            if let data = data {
                                let finalData = isEncrypted ? self.decrypt(data: data) : data
                                image = finalData != nil ? UIImage(data: finalData!) : nil
                            }
                            let labeled = LabeledImage(id: id, isPrimary: isPrimary, position: position, image: image, comment: comment)
                            fetchedImages.append(labeled)
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        self.imagesByPosition[position] = fetchedImages
                        completion()
                    }
                }
        }
    // MARK: - Fetch Primary Labeled Images
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
                        let isEncrypted = data["encrypted"] as? Bool ?? false

                        guard let imagePath = url else { continue }

                        dispatchGroup.enter()
                        let imageRef = storageRef.child(imagePath)
                        imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            var image: UIImage? = nil
                            if let data = data {
                                let finalData = isEncrypted ? self.decrypt(data: data) : data
                                if let finalData = finalData {
                                    image = UIImage(data: finalData)
                                }
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
