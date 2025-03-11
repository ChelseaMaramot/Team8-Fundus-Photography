//
//  ScanSummary.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-16.
//

// for future, only show empty postions if we are still in imaging mode
import SwiftUI

struct ScanSummary: View {
    var scanID: String
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State private var navigateToCameraView = false
    @State private var refreshID = UUID()  // Add a refreshID to force view updates
    @State private var isLoading = true
    @State private var isEditing = false
    @State private var selectedEditImages: [LabeledImage] = []
    @State private var showDeleteConfirmation = false

    var isFromScanList: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {  // Adjusted spacing between elements
                Text("Scan - \(formattedDate())")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 16)  // Adjusted padding to provide more space
                
                if !firebaseManager.imagesByPosition.isEmpty {
                    ScrollView {
                        ForEach(firebaseManager.imagesByPosition.keys.sorted(), id: \.self) { position in
                            ImageCard(
                                viewModel: firebaseManager,
                                isFromScanList: isFromScanList,
                                position: position,
                                onAddImage: {
                                    if let newQuadrant = RegionTypes(rawValue: position) {
                                        selectedDataManager.setQuadrant(newQuadrant)
                                        print("new quadrant: \(selectedDataManager.getQuadrant())")
                                    }
                                    navigateToCameraView = true
                                    print("Add image for \(position)")
                                    
                                    let imageCount = firebaseManager.imagesByPosition[position]?.count ?? 0
                                    print("Position: \(position), Total Images: \(imageCount)")
                                },
                                onSelectImage: { selectedImage in
                                    firebaseManager.setPrimaryImage(for: position, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                                    refreshID = UUID()  // Force a view update
                                },
                                isEditing: $isEditing,
                                selectedEditImages: $selectedEditImages
                            )
                        }
                    }
                    .padding(.horizontal)  // Add horizontal padding to scroll view
                } else if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                } else {
                    Text("No data available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)  // Adjust bottom padding
                } else {
                    NavigationLink(destination: isFromScanList
                                   ? AnyView(ScanListView(patientID: selectedDataManager.getPatientID()))
                                   : AnyView(NewScanView())) {
                        Text((isFromScanList) ? "Return to Scan List" : "Save Scan")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)  // Adjust bottom padding
                }
                
            }
            .padding(.top)  // Adjust top padding
        }
        .colorScheme(.light)
        .navigationBarTitle("Image Summary", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
            selectedEditImages.removeAll()
        }) {
            Text(isEditing ? "Done" : "Edit")
                .fontWeight(.bold)
        }
        .disabled(isFromScanList)
        )
        
        .onAppear {
            selectedDataManager.setScanID(scanID)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                firebaseManager.retrievePhotos(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                isLoading = false
                refreshID = UUID()  // Force a view update
            }
        }
        .navigationDestination(isPresented: $navigateToCameraView) {
            CameraView()
        }
        .confirmationDialog("Are you sure you want to delete these images?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                firebaseManager.deleteSelectedImages(selectedImages: selectedEditImages, patientID: selectedDataManager.getPatientID(), scanName: selectedDataManager.getScanID())
                selectedEditImages.removeAll()
            }
            Button("Cancel", role: .cancel) {
                selectedEditImages.removeAll()
            }
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}
