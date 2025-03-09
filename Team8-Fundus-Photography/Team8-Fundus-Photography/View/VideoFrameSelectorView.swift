//
//  VideoFrameSelectorView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-07.
//

import SwiftUI
import AVKit

struct VideoFrameSelectorView: View {
    let videoURL: URL
    @State private var currentTime: CMTime = .zero
    @State private var extractedImage: UIImage? = nil
    @State private var player: AVPlayer
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(height: 300)
                .onAppear {
                    player.seek(to: currentTime)
                }
            
            // Slider to scrub through the video
            Slider(value: Binding(
                get: { CMTimeGetSeconds(currentTime) },
                set: { newValue in
                    let newTime = CMTime(seconds: newValue, preferredTimescale: 600)
                    player.seek(to: newTime)
                    currentTime = newTime
                }
            ), in: 0...(CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero).isNaN ? 0 : CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)))
            .padding()

            
            // Capture frame button
            Button("Capture Frame") {
                extractFrame(from: videoURL, at: currentTime) { image in
                    extractedImage = image
                }
            }
            .padding()
            
            // Show the extracted image
            if let image = extractedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .onDisappear {
            player.pause()
        }
    }
    
    /// Extracts a frame from the video at the selected time
    private func extractFrame(from url: URL, at time: CMTime, completion: @escaping (UIImage?) -> Void) {
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
}

#Preview {
    VideoFrameSelectorView(videoURL: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!)
}
