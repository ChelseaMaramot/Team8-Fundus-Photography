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
    @State private var isVideoReady: Bool = false
    @State private var isCapturingFrame: Bool = false
    @State private var sliderValue: Double = 0.0
    @State private var refreshID = UUID()
    @State private var showDeleteConfirmation = false
    @State private var showAlert = false
    @State private var navigateToScanSummary = false
    @State private var isEditing = false
    @State private var selectedEditImages: [LabeledImage] = []
    
    let videoURL: URL
    let elapsedTime: TimeInterval
    
    init(videoURL: URL, elapsedTime: TimeInterval) {
        self.videoURL = videoURL
        self.elapsedTime = elapsedTime
    }
    
    var body: some View {
        VStack {
            videoPlayerSection
            
            sliderSection
            
            imageDisplaySection
            
            actionButtonsSection
        }
        .onAppear { loadVideo() }
        .onChange(of: currentTime) { newTime in
            sliderValue = CMTimeGetSeconds(newTime)
        }
        .navigationTitle("Select Frames from Video")
        .navigationBarItems(trailing: editButton)
        .confirmationDialog("Are you sure you want to delete these images?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                firebaseManager.deleteSelectedImages(selectedImages: selectedEditImages, patientID: selectedDataManager.getPatientID(), scanName: selectedDataManager.getScanID())
                selectedEditImages.removeAll()
                if let images = firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue], images.isEmpty {
                    isEditing = false
                }
            }
            
            Button("Cancel", role: .cancel) {
                // Do nothing, just dismiss the dialog
            }
        }
        .alert(isPresented: $showAlert) {
            alert
        }
    }
    
    // Video Player Section
    private var videoPlayerSection: some View {
        Group {
            if isVideoReady, let player = videoManager.player {
                VideoPlayer(player: player)
                    .onAppear { player.seek(to: currentTime) }
            } else {
                ProgressView("Loading video...")
                    .frame(height: 300)
            }
        }
    }
    
    // Slider Section
    private var sliderSection: some View {
        VStack{
            Text("Select Frame with Slider ")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 5)
            Slider(value: $sliderValue, in: 0...elapsedTime, step: 0.001)
                .onChange(of: sliderValue) { newValue in
                    let newTime = CMTime(seconds: newValue, preferredTimescale: 600)
                    videoManager.player?.seek(to: newTime)
                    currentTime = newTime
                }
                .padding()
        }
    }
    
    // Image Display Section
    private var imageDisplaySection: some View {
        VStack {
            if let images = firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue], !images.isEmpty {
                VStack{
                    ImageCard(
                        viewModel: firebaseManager,
                        isFromScanList: true,
                        position: selectedDataManager.getQuadrant().rawValue,
                        onAddImage: {},
                        onSelectImage: { selectedImage in
                            firebaseManager.setPrimaryImage(for: selectedDataManager.getQuadrant().rawValue, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                        },
                        isEditing: $isEditing,
                        selectedEditImages: $selectedEditImages
                    )
                }
            } else {
                Text("No frames captured yet")
                    .foregroundColor(.gray)
            }
            
//            Text("Debug: \(firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue]?.count)")
//                      .foregroundColor(.red)
//                      .padding()
//    
        }

    }
    
    // Capture/Save Buttons Section
    private var actionButtonsSection: some View {
        VStack {
            if isEditing {
                deleteImagesButton
            } else {
                captureFrameButton
            }
            
            saveButton
        }
    }
    
    // Delete Images Button
    private var deleteImagesButton: some View {
        Button(action: { showDeleteConfirmation = true }) {
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
    }
    
    // Capture Frame Button
    private var captureFrameButton: some View {
        Button(action: captureFrame) {
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
    
    // Save Button
    private var saveButton: some View {
        Button(action: { navigateToScanSummary = true }) {
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
            NavigationLink(destination: ScanSummary(isFromScanList: false, patientID: selectedDataManager.getPatientID()), isActive: $navigateToScanSummary) {
                EmptyView()
            }
        )
    }
    
    // Edit Button
    private var editButton: some View {
        Button(action: { isEditing.toggle() }) {
            Text(isEditing ? "Done" : "Edit")
                .font(.system(size: 16, weight: .bold))
        }
        .disabled(!isEditing && (firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue]?.isEmpty ?? true))
    }
    
    // Alert
    private var alert: Alert {
        Alert(
            title: Text("Limit Reached"),
            message: Text("You cannot capture more than 4 images for this position. Delete images to continue."),
            dismissButton: .default(Text("OK"))
        )
    }
    
    // Load Video
    private func loadVideo() {
        print("VideoFrameSelectorView appeared. Loading video from URL: \(videoURL)")
        videoManager.loadVideo(from: videoURL) {
            if let duration = videoManager.player?.currentItem?.duration {
                isVideoReady = duration.isValid
            }
        }
    }
    
    // Capture Frame
    private func captureFrame() {
        print("CAPTURING FRAME")
        let currentPosition = selectedDataManager.getQuadrant().rawValue
        if let images = firebaseManager.imagesByPosition[currentPosition], images.count >= 4 {
            showAlert = true
        } else {
            extractFrame(from: videoURL, at: currentTime) { image in
                if let image = image {
                    videoManager.addVideoImageToSelected(image: image, position: currentPosition, firebaseManager: firebaseManager, selectedDataManager: selectedDataManager){
                        refreshID = UUID()
                        print("images by pos after capturing frame: \(firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue]?.count)")
                      
                    }
    
                }
            }
        }
    }
    
    // Extract Frame
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
