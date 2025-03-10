//
//  VideoFrameSelectorView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-07.
//

import SwiftUI
import AVKit

struct VideoFrameSelectorView: View {
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var videoManager = VideoPlayerManager()
    @State private var currentTime: CMTime = .zero
    @State private var extractedImages: [UIImage] = []
    @State private var isVideoReady: Bool = false
    @State private var isEditing = false
    @State private var selectedEditImages: [LabeledImage] = []

    @State private var navigateToCameraView = false
    @State private var refreshID = UUID()
    @State private var showDeleteConfirmation = false
    @State private var showAlert = false

    @State private var navigateToScanSummary = false
    @State private var isCapturingFrame = false
    @State private var sliderValue: Double = 0.0

    let videoURL: URL
    let elapsedTime: TimeInterval

    init(videoURL: URL, elapsedTime: TimeInterval) {
        self.videoURL = videoURL
        self.elapsedTime = elapsedTime
    }

    var body: some View {
        VStack {
            // Video Player
            if isVideoReady, let player = videoManager.player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.seek(to: currentTime)
                    }
            } else {
                ProgressView("Loading video...")
                    .frame(height: 300)
            }

            Slider(value: $sliderValue, in: 0...elapsedTime, step: 0.001)
                .onChange(of: sliderValue) { newValue in
                    let newTime = CMTime(seconds: newValue, preferredTimescale: 600)
                    videoManager.player?.seek(to: newTime)
                    currentTime = newTime
                }
                .padding()
            
            // Scroll view for captured frames
            VStack {
                if let images = firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue], !images.isEmpty {
                    ScrollView {
                        ImageCard(
                            viewModel: firebaseManager,
                            isFromScanList: true,
                            position: selectedDataManager.getQuadrant().rawValue,
                            onAddImage: {},
                            onSelectImage: { selectedImage in
                                firebaseManager.setPrimaryImage(for: selectedDataManager.getQuadrant().rawValue, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                                refreshID = UUID()
                            },
                            isEditing: $isEditing,
                            selectedEditImages: $selectedEditImages
                        )
                    }
                } else {
                    Text("No frames captured yet")
                        .foregroundColor(.gray)
                }
            }

            // Editing and Frame Capture Controls
            if isEditing {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Images")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(isEditing && selectedEditImages.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(selectedEditImages.isEmpty)
                .padding(.bottom, 20)
            } else {
                Button(action: {
                    guard !isCapturingFrame else { return }
                    isCapturingFrame = true
                    
                    let currentPosition = selectedDataManager.getQuadrant().rawValue
                    if let images = firebaseManager.imagesByPosition[currentPosition], images.count >= 4 {
                        showAlert = true
                    } else {
                        extractFrame(from: videoURL, at: currentTime) { image in
                            if let image = image {
                                videoManager.addVideoImageToSelected(
                                    image: image,
                                    position: currentPosition,
                                    firebaseManager: firebaseManager,
                                    selectedDataManager: selectedDataManager
                                )
                                refreshID = UUID()
                            }
                            isCapturingFrame = false
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
                .disabled(isCapturingFrame)
                .padding()
            }
            
            Button(action: {
                navigateToScanSummary = true
            }) {
                Text("Save")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .padding(.bottom, 20)
            .background(
                NavigationLink(destination: ScanSummary(
                    scanID: selectedDataManager.getScanID(), isFromScanList: false
                ), isActive: $navigateToScanSummary) {
                    EmptyView()
                }
            )
        }
        .onAppear {
            print("VideoFrameSelectorView appeared. Loading video from URL: \(videoURL)")
            videoManager.loadVideo(from: videoURL) {
                if let duration = videoManager.player?.currentItem?.duration {
                    isVideoReady = duration.isValid
                }
            }
        }
        .onChange(of: currentTime) { newTime in
            sliderValue = CMTimeGetSeconds(newTime)
        }
        .navigationTitle("Select Frames from Video")
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
        }) {
            Text(isEditing ? "Done" : "Edit")
                .font(.system(size: 16, weight: .bold))
        }
            .disabled(!isEditing && (firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue]?.isEmpty ?? true))
        )
        .confirmationDialog("Are you sure you want to delete these images?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                firebaseManager.deleteSelectedImages(selectedImages: selectedEditImages, patientID: selectedDataManager.getPatientID(), scanName: selectedDataManager.getScanID())
                selectedEditImages.removeAll()
                
                if let images = firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue], images.isEmpty {
                    isEditing = false
                }
            }
            Button("Cancel", role: .cancel) {
                selectedEditImages.removeAll()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Limit Reached"),
                message: Text("You cannot capture more than 4 images for this position. Delete images to continue."),
                dismissButton: .default(Text("OK"))
            )
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
    VideoFrameSelectorView(videoURL: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!, elapsedTime: 10)
}
