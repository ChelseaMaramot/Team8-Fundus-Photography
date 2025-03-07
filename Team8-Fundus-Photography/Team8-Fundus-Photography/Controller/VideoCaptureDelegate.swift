//
//  VideoCaptureDelegate.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-04.
//

import Foundation
import AVFoundation
import Photos

class VideoCaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    private let completion: (URL?) -> Void
    
    init(completion: @escaping (URL?) -> Void) {
        print("Initializing VideoCaptureDelegate")
        self.completion = completion
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            print("✅ Video recording started at \(fileURL.absoluteString)")
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        print("Video recording finished: \(outputFileURL.absoluteString)")
        
        Task {
            let accessGranted = await isPhotoLibraryReadWriteAccessGranted
            if accessGranted {
                await save(videoAt: outputFileURL)
                DispatchQueue.main.async {
                    self.completion(outputFileURL)
                }
            } else {
                print("No access granted for saving video.")
                DispatchQueue.main.async {
                    self.completion(nil)
                }
            }
        }
    }
    
    func save(videoAt url: URL) async {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .video, fileURL: url, options: nil)
        } completionHandler: { success, error in
            if let error = error {
                print("Error saving video: \(error.localizedDescription)")
            }
            if success {
                print("Video saved successfully!")
            }
        }
    }
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            print("Checking photo library read/write access for videos")
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
            }
            
            return isAuthorized
        }
    }
}
