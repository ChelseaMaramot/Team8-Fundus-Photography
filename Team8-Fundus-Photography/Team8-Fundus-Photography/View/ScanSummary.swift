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
//    @ObservedObject var viewModel: FirebaseManager
    @StateObject var viewModel = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State private var navigateToCameraView = false

    var body: some View {
        NavigationStack{
            ZStack {
                
                Color(UIColor.systemGray6) // Background color
                    .edgesIgnoringSafeArea(.all) // Extend to full screen
                
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
                                    position: position,
                                    images: viewModel.imagesByPosition[position] ?? [],
                                    onAddImage: {
                                        navigateToCameraView = true
                                        print("Add image for \(position)")
                                        let imageCount = viewModel.imagesByPosition[position]?.count ?? 0
                                        print("Position: \(position), Total Images: \(imageCount)")  // Debug print

                                    }
                                )
                            }
                        }
                    } else {
                        Text("No Images found.")
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
                viewModel.retrievePhotos(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID())
                
            }
            .navigationDestination(isPresented: $navigateToCameraView) {
                            CameraView()  // Navigate to your CameraView with any necessary parameters
                        }
        
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}

