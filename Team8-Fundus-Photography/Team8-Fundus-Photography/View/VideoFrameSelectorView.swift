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
    
    func addVideoImageToSelected(image: UIImage, position: String, viewModel: FirebaseManager){
        let labeledImage = LabeledImage(id: UUID().uuidString, isPrimary: false, position: position, image: image)
           
        if viewModel.imagesByPosition[position] == nil {
            viewModel.imagesByPosition[position] = []
           }
  
        viewModel.imagesByPosition[position]?.append(labeledImage)
    }
}


struct VideoFrameSelectorView: View {
    let videoURL: URL
    let elapsedTime: TimeInterval
    
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @ObservedObject private var videoManager = VideoPlayerManager()
    @ObservedObject var viewModel = FirebaseManager()
    @State private var currentTime: CMTime = .zero
    @State private var extractedImages: [UIImage] = []
    @State private var isVideoReady: Bool = false

    @State private var navigateToCameraView = false
    @State private var refreshID = UUID()

    init(videoURL: URL, elapsedTime: TimeInterval) {
        self.videoURL = videoURL
        self.elapsedTime = elapsedTime
    }

    var body: some View {
        VStack {
            if isVideoReady, let player = videoManager.player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.seek(to: currentTime)
                    }
            } else {
                ProgressView("Loading video...")
                    .frame(height: 300)
            }
            
            Slider(value: Binding(
                get: { CMTimeGetSeconds(currentTime) },
                set: { newValue in
                    let newTime = CMTime(seconds: newValue, preferredTimescale: 600)
                    videoManager.player?.seek(to: newTime)
                    currentTime = newTime
                }
            ), in: 0...elapsedTime)
            .padding()
            
            
            VStack {
                if !viewModel.imagesByPosition.isEmpty {
                    ScrollView {
                        ForEach(viewModel.imagesByPosition.keys.sorted(), id: \.self) { position in
                            ImageCard(
                                viewModel: viewModel,
                                isFromScanList: true,
                                position: position,
                                onAddImage: {
                                    
                                }, onSelectImage: { selectedImage in
                                    viewModel.setPrimaryImage(for: position, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                                },
                                isEditing: .constant(false),
                                selectedEditImages: .constant([])
                            )
                        }
                    }
                }else{
                    Text("No frames captured yet")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            print("VideoFrameSelectorView appeared. Loading video from URL: \(videoURL)")
            videoManager.loadVideo(from: videoURL) {
                if let duration = videoManager.player?.currentItem?.duration {
                    isVideoReady = duration.isValid
                }
            }
        }
        
        Button(action: {
            extractFrame(from: videoURL, at: currentTime) { image in
                if let image = image {
                    videoManager.addVideoImageToSelected(image: image, position: selectedDataManager.getQuadrant().rawValue, viewModel: viewModel)
                    print(viewModel.imagesByPosition)
                }

            }
            
        }) {
            Text("Capture Frame")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding()
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
    VideoFrameSelectorView(videoURL: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!, elapsedTime: 10)
}
