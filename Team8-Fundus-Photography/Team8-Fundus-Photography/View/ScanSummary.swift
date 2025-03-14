//
//  ScanSummary.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-16.
//

// for future, only show empty postions if we are still in imaging mode
import SwiftUI

struct ScanSummary: View {
//    var scanID: String
//    var scanName: String
//    @ObservedObject var viewModel: FirebaseManager
    
    @StateObject private var viewModel = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State private var navigateToCameraView = false
    @State private var refreshID = UUID()
    @State private var isLoading = true
    @State private var isEditing = false
    @State private var selectedEditImages: [LabeledImage] = []
    @State private var showDeleteConfirmation = false
    @State private var navToScanList = false

    var isFromScanList: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var scanViewModel: ScanListViewModel
    
    init(isFromScanList: Bool, patientID: String) {
        self.isFromScanList = isFromScanList
        _scanViewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("\(selectedDataManager.getScanName()) - \(formattedDate())")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 16)  // Adjusted padding to provide more space
                
                if !viewModel.imagesByPosition.isEmpty {
                    ScrollView {
                        ForEach(viewModel.imagesByPosition.keys.sorted(), id: \.self) { position in
                            ImageCard(
                                viewModel: viewModel,
                                isFromScanList: isFromScanList,
                                position: position,
                                onAddImage: {
                                    if let newQuadrant = RegionTypes(rawValue: position) {
                                        selectedDataManager.setQuadrant(newQuadrant)
                                        print("new quadrant: \(selectedDataManager.getQuadrant())")
                                    }
                                    navigateToCameraView = true
                                    print("Add image for \(position)")
                                    
                                    let imageCount = viewModel.imagesByPosition[position]?.count ?? 0
                                    print("Position: \(position), Total Images: \(imageCount)")
                                },
                                onSelectImage: { selectedImage in
                                    viewModel.setPrimaryImage(for: position, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                                    refreshID = UUID()  // Force a view update
                                },
                                isEditing: $isEditing,
                                selectedEditImages: $selectedEditImages
                            )
                        }
                    }
                    .padding(.horizontal)
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
                } else if isFromScanList {
                    // If coming from Scan List, just go back
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // 👈 Goes back to Scan List
                    }) {
                        Text("Return to Scan Details")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                } else {
                    
                    HStack(spacing: 20) { // Side by side layout
                        // "Cancel & Delete Scan" Button
                        Button(action: {
                            deleteScan()
                        }) {
                            Text("Cancel")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 150)
                                .background(Color.red)
                                .cornerRadius(10)
                        }

                        // "Add Scan Details" Button
                        NavigationLink(destination: NewScanView(patientID: selectedDataManager.getPatientID())) {
                            Text("Add Details")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 150)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }

                    // Hidden NavigationLink that activates after deletion
                    NavigationLink(destination: ScanListView(patientID: selectedDataManager.getPatientID()), isActive: $navToScanList) {
                        EmptyView()
                    }
                    .padding(.horizontal)

                
                
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.retrievePhotos(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                isLoading = false
                refreshID = UUID()  // Force a view update
            }
        }
        .navigationDestination(isPresented: $navigateToCameraView) {
            CameraView()
        }
        .confirmationDialog("Are you sure you want to delete these images?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.deleteSelectedImages(selectedImages: selectedEditImages, patientID: selectedDataManager.getPatientID(), scanName: selectedDataManager.getScanID())
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
    
    private func deleteScan() {
        print("deleting scan")
        scanViewModel.deleteScan(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
        navToScanList = true
    }
}
