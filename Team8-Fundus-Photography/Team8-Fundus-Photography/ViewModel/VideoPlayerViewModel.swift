//
//  VideoPlayerViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-10.
//

import Foundation
import SwiftUICore
import AVKit

class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer? = nil

    func loadVideo(from videoURL: URL, completion: @escaping () -> Void) {
        print("in load video...")
        
        if FileManager.default.fileExists(atPath: videoURL.path) {
            print("URL exists: \(videoURL)")
            DispatchQueue.main.async {
                self.player = AVPlayer(url: videoURL)
                completion()
            }
        } else {
            print("url does not exist")
            DispatchQueue.global(qos: .background).async {
                while !FileManager.default.fileExists(atPath: videoURL.path) {
                    print("waiting for video to save")
                    usleep(100_000)
                }
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: videoURL)
                    completion()
                }
            }
        }
    }
    
    func addVideoImageToSelected(image: UIImage, position: String, firebaseManager: FirebaseManager, selectedDataManager: SelectedDataManager, completion: @escaping () -> Void){
        let labeledImage = LabeledImage(id: UUID().uuidString, isPrimary: false, position: position, image: image)
           
        if firebaseManager.imagesByPosition[position] == nil {
            firebaseManager.imagesByPosition[position] = []
           }
        
        let patientID = selectedDataManager.getPatientID()
        let scanID = selectedDataManager.getScanID()
        let quadrant = selectedDataManager.getQuadrant().rawValue
  
        //firebaseManager.imagesByPosition[position]?.append(labeledImage)
        firebaseManager.saveToFirebase(image: image, patientID: patientID, scanName: scanID, region: quadrant) {
            print("new list: \(firebaseManager.imagesByPosition[position]?.count)")
            completion()
        }
    }
}
