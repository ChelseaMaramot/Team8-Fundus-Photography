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
    private var patientID: String
    private var scanID: String
    private var quadrant: String
    
    init(patientID: String, scanID: String, quadrant: String) {
        self.patientID = patientID
        self.scanID = scanID
        self.quadrant = quadrant
    }

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
    
    func addVideoImageToSelected(image: UIImage, position: String, firebaseManager: FirebaseManager){
        let labeledImage = LabeledImage(id: UUID().uuidString, isPrimary: false, position: position, image: image)
           
        if firebaseManager.imagesByPosition[position] == nil {
            firebaseManager.imagesByPosition[position] = []
           }
  
        firebaseManager.imagesByPosition[position]?.append(labeledImage)
        firebaseManager.saveToFirebase(image: image, patientID: patientID, scanName: scanID, region: quadrant) {}
    }
}


struct VideoFrameSelectorView: View {
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @StateObject private var videoManager =  VideoPlayerManager
    @EnvironmentObject var firebaseManager: FirebaseManager
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
    
    let videoURL: URL
    let elapsedTime: TimeInterval

    // Initialize videoManager here instead of in the init method
    init(videoURL: URL, elapsedTime: TimeInterval) {
        self.videoURL = videoURL
        self.elapsedTime = elapsedTime
        
        _videoManager = StateObject(wrappedValue: VideoPlayerManager(
            patientID: selectedDataManager.getPatientID(),
            scanID: selectedDataManager.getScanID(),
            quadrant: selectedDataManager.getQuadrant().rawValue
        ))
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
                if let images = firebaseManager.imagesByPosition[selectedDataManager.getQuadrant().rawValue], !images.isEmpty {
                    ScrollView {
                        ImageCard(
                            viewModel: firebaseManager,
                            isFromScanList: true,
                            position: selectedDataManager.getQuadrant().rawValue,
                            onAddImage: {
                                
                            }, onSelectImage: { selectedImage in
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
            }
            
            if isEditing {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Images")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isEditing && selectedEditImages.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(selectedEditImages.isEmpty)
                .padding(.bottom, 20)
            } else {
                Button(action: {
                    let currentPosition = selectedDataManager.getQuadrant().rawValue
                    if let images = firebaseManager.imagesByPosition[currentPosition], images.count >= 4 {
                        showAlert = true
                        print("too many pics")
                    } else {
                        extractFrame(from: videoURL, at: currentTime) { image in
                            if let image = image {
                                videoManager.addVideoImageToSelected(
                                    image: image,
                                    position: currentPosition,
                                    firebaseManager: firebaseManager
                                )
                            }
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
        .navigationTitle("Select Frames from Video")
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
        }) {
            Text(isEditing ? "Done" : "Edit")
                .font(.system(size: 16, weight: .bold))
        }
            .disabled(firebaseManager.imagesByPosition.isEmpty)
        )
        .confirmationDialog("Are you sure you want to delete these images?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                firebaseManager.deleteSelectedImages(selectedImages: selectedEditImages, patientID: selectedDataManager.getPatientID(), scanName: selectedDataManager.getScanID())
                selectedEditImages.removeAll()
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
