//
//  VideoFrameSelectorView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-07.
//


import SwiftUI
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
}

struct VideoFrameSelectorView: View {
    let videoURL: URL
    @StateObject private var videoManager = VideoPlayerManager()
    @State private var currentTime: CMTime = .zero
    @State private var extractedImage: UIImage? = nil
    @State private var isVideoReady: Bool = false
    @State private var videoDuration: Double = 0.0

    init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    var body: some View {
        VStack {
            if isVideoReady, let player = videoManager.player {
                VideoPlayer(player: player)
                    .frame(height: 300)
                    .onAppear {
                        player.seek(to: currentTime)
                    }
    
              
                Slider(value: Binding(
                               get: { CMTimeGetSeconds(currentTime) },
                               set: { newValue in
                                   let newTime = CMTime(seconds: newValue, preferredTimescale: 600)
                                   player.seek(to: newTime)
                                   currentTime = newTime
                               }
                           ), in: 0...(CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero).isNaN ? 0 : CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)))
                           .padding()
                
            } else {
                ProgressView("Loading video...")
                    .frame(height: 300)
            }
      
            Button("Capture Frame") {
                extractFrame(from: videoURL, at: currentTime) { image in
                    extractedImage = image
                }
            }
            .padding()
            
            if let image = extractedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .onAppear {
            print("VideoFrameSelectorView appeared. Loading video from URL: \(videoURL)")
            videoManager.loadVideo(from: videoURL) {
                if let duration = videoManager.player?.currentItem?.duration {
                    videoDuration = CMTimeGetSeconds(duration)
                    isVideoReady =  duration.isValid
                }
            }
        }
        .onDisappear {
            print("VideoFrameSelectorView disappeared. Pausing and releasing player.")
            videoManager.player?.pause()
            videoManager.player = nil
            isVideoReady = false
        }
    }
    
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
