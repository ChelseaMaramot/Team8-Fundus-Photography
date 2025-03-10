//
//  VideoFrameSelectorViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-09.
//

import AVFoundation
import SwiftUI

class VideoFrameSelectorViewModel: ObservableObject {
    @Published var extractedImages: [String: [LabeledImage]] = [:]
    @Published var isVideoReady: Bool = false
    @Published var currentTime: CMTime = .zero
    
    private var videoManager = VideoPlayerManager()
    
    func loadVideo(from url: URL, completion: @escaping (Bool) -> Void) {
        videoManager.loadVideo(from: url) {
            if let duration = self.videoManager.player?.currentItem?.duration {
                self.isVideoReady = duration.isValid
                completion(self.isVideoReady)
            }
        }
    }
    
    func extractFrame(from url: URL, at time: CMTime, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(uiImage)
                }
            } catch {
                print("Failed to extract frame: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func addImage(_ labeledImage: LabeledImage, forPosition position: String) {
        if extractedImages[position] != nil {
            extractedImages[position]?.append(labeledImage)
        } else {
            extractedImages[position] = [labeledImage]
        }
    }
}
