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
    @ObservedObject var viewModel: FirebaseManager
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State private var navigateToCameraView = false
    @State private var refreshID = UUID()  // Add a refreshID to force view updates
    @State private var isLoading = true
    var isFromScanList: Bool
    
    var body: some View {
        
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Scan - \(formattedDate())")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                
                if !viewModel.imagesByPosition.isEmpty {
                    ScrollView {
                        ForEach(viewModel.imagesByPosition.keys.sorted(), id: \.self) { position in
                            ImageCard(
                                
                                viewModel: viewModel,
                                isFromScanList: isFromScanList,
                                position: position,
                                onAddImage: {
                                    print("adding image")
                                    navigateToCameraView = true
                                    print("Add image for \(position)")
                                    let imageCount = viewModel.imagesByPosition[position]?.count ?? 0
                                    print("Position: \(position), Total Images: \(imageCount)")
                                }, onSelectImage: { selectedImage in
                                    viewModel.setPrimaryImage(for: position, image: selectedImage, patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                                    refreshID = UUID()  // Force a view update
                                }
                            )
                        }
                    }
                } else {
                    ProgressView() // Or ActivityIndicator for older iOS
                                        .progressViewStyle(.circular) // Customize if needed
                                        .scaleEffect(1.5) // Adjust size
                }

                Button(action: {
                    print("Navigate to Scan List")
                }) {
                    Text("Scan List")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
 
            .padding(.top)
        }
        .colorScheme(.light)
        .navigationBarTitle("Image Summary", displayMode: .inline)
        
        .onAppear {
            selectedDataManager.setScanID(scanID)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                print("starting delayed action")
                viewModel.retrievePhotos(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                isLoading = false
                print("forcing view update")
                refreshID = UUID()  // F
                print("Delayed action executed!")
                            }
        }
        .navigationDestination(isPresented: $navigateToCameraView) {
            CameraView()  // Navigate to your CameraView with any necessary parameters
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}
