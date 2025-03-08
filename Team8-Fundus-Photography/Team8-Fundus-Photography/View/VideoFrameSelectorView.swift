import SwiftUI
import AVKit

struct VideoFrameSelectorView: View {
    let videoURL: URL
    @State private var currentTime: CMTime = .zero
    @State private var extractedImage: UIImage? = nil
    @State private var player: AVPlayer
    @State private var thumbnailImages: [UIImage] = []
    @State private var isLoading: Bool = false  // Added loading state

    init(videoURL: URL) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        VStack {
            // Video Player
            VideoPlayer(player: player)
                .frame(height: 300)
                .onAppear {
                    print("Initializing player with URL: \(videoURL)")
                    player = AVPlayer(url: videoURL)
                    player.seek(to: currentTime)
                    loadThumbnails()
                }
            
            // Show loader while thumbnails are being loaded
            if isLoading {
                ProgressView("Loading Thumbnails...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            // Thumbnails displayed horizontally
            ScrollView(.horizontal) {
                HStack(spacing: 1) {
                    ForEach(thumbnailImages.indices, id: \.self) { index in
                        Button(action: {
                            let selectedTime = CMTime(seconds: Double(index), preferredTimescale: 600)
                            player.seek(to: selectedTime)
                            currentTime = selectedTime
                            extractFrame(from: videoURL, at: selectedTime) { image in
                                extractedImage = image
                            }
                        }) {
                            Image(uiImage: thumbnailImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
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

    private func loadThumbnails() {
        isLoading = true  // Start loading indicator
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        // Ensure the asset is properly loaded
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            if status == .loaded {
                let durationInSeconds = CMTimeGetSeconds(asset.duration)
                let thumbnailInterval: Double = 0.1
                let numberOfThumbnails = Int(durationInSeconds / thumbnailInterval)
                print("number of Thumbnails: \(numberOfThumbnails)")

                var thumbnails: [UIImage] = []

                // Ensure we're not over-generating thumbnails for very short videos
                for index in 0..<min(numberOfThumbnails, 100) { // Limit to a maximum of 100 thumbnails
                    let time = CMTime(seconds: Double(index) * thumbnailInterval, preferredTimescale: 600)
                    do {
                        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                        let uiImage = UIImage(cgImage: cgImage)
                        thumbnails.append(uiImage)
                    } catch {
                        print("Error generating thumbnail for time \(Double(index) * thumbnailInterval): \(error)")
                    }
                }

                // Update the state on the main thread
                DispatchQueue.main.async {
                    self.thumbnailImages = thumbnails
                    self.isLoading = false  // End loading indicator
                }
            } else {
                print("Failed to load asset duration: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false  // End loading indicator
                }
            }
        }
    }

    // Extracts a frame from the video at the selected time
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
