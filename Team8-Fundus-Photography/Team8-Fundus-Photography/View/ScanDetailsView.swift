//
//  ScanDetailsView.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-10.
//

//import SwiftUI
//
//struct ScanDetailsView: View {
//    var scanID: String
//    var scanName: String
////    @ObservedObject var viewModel: FirebaseManager
////    @EnvironmentObject var selectedDataManager: SelectedDataManager
//    @State private var images: [String: UIImage] = [:]
//    @State private var scanDetails: String = ""
//    @State private var isLoading = true
////    @State private var scanDate: Date?
//    @EnvironmentObject var selectedDataManager: SelectedDataManager
//    @StateObject var viewModel: ScanListViewModel
//    @StateObject var storageManager = FirebaseManager()
//    
//    init(patientID: String) {
//        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
//    }
//
//    var body: some View {
//        ZStack {
//            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                Text("\(scanName)")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.blue)
//                    .padding(.top, 10)
//
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(.circular)
//                        .scaleEffect(1.5)
//                } else {
//                    ScrollView {
//                        // Display Scan Details
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Scan Notes")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                            
//                            Text(scanDetails.isEmpty ? "No notes available." : scanDetails)
//                                .font(.body)
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.white)
//                                .cornerRadius(10)
//                                .shadow(radius: 2)
//                        }
//                        .padding(.horizontal)
//
//                        // Display Primary Images in Quadrants
//                        if !images.isEmpty {
//                            Text("Primary Images")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .padding(.top)
//
//                            PrimaryImagesQuadrantView(images: images)
//                                .frame(width: 350, height: 300)
//                                .padding(.vertical)
//                                .background(Color.lightBlue)
//                                .cornerRadius(16)
//                        } else {
//                            Text("No primary images available.")
//                                .foregroundColor(.gray)
//                                .padding(.top, 20)
//                        }
//                    }
//                }
//                
//                Spacer()
//                
//                // Return Button
//                Button(action: {
//                    selectedDataManager.setScanID("")
//                }) {
//                    Text("Return to Scan List")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom, 20)
//            }
//            .padding(.top)
//        }
//        .onAppear {
//            selectedDataManager.setScanID(scanID)
//            fetchScanDetails()
//        }
//        .navigationBarTitle("Scan Details", displayMode: .inline)
//    }
//
//    // Fetch scan details and primary images
//    // Fetch scan details and primary images
//        private func fetchScanDetails() {
//            let patientID = selectedDataManager.getPatientID()
//            
//            // Fetch scan name, details, and date
//            viewModel.fetchScanDetails(scanID: scanID) { name, details, date in
//                self.scanDetails = details
//                self.scanDate = date
//                self.isLoading = false
//            }
//            
//            // Fetch primary images
//            storageManager.fetchPrimaryImages(patientID: patientID, scanID: scanID) { fetchedImages in
//                self.images = fetchedImages
//            }
//        }
//
//        private func formattedDate(_ date: Date) -> String {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd @ h:mm a"
//            return formatter.string(from: date)
//        }
//}

import SwiftUI

struct ScanDetailsView: View {
    var scanID: String
    var scanName: String
    @ObservedObject var viewModel: ScanListViewModel
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @StateObject var storageManager = FirebaseManager()
    
    @State private var images: [String: UIImage] = [:]
    @State private var scanDetails: String = "Loading..."
    @State private var scanDate: Date?
    @State private var isLoading = true
    @State private var navToScanList = false
    @State private var navToImageSelection = false
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(scanName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                if let scanDate = scanDate {
                    Text("Date: \(formattedDate(scanDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        // Display Scan Details
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Scan Notes")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(scanDetails)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .padding(.horizontal)

                        // Display Primary Images in Quadrants
                        if !images.isEmpty {
                            Text("Primary Images")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.top)

                            PrimaryImagesQuadrantView(images: images)
                                .frame(width: 350, height: 300)
                                .padding(.vertical)
                                .background(Color.lightBlue)
                                .cornerRadius(16)
                        } else {
                            Text("No primary images available.")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                    }
                }
                
                Spacer()
                
                NavigationLink(
                    destination: ScanSummary(isFromScanList: true, patientID: selectedDataManager.getPatientID())
                ) {
                    Text("View All Images / Change Primary")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)

                
                NavigationLink(
                    destination: ScanListView(patientID: selectedDataManager.getPatientID()),
                    isActive: $navToScanList
                ) {
                    // Return Button
                    Button(action: {
                        selectedDataManager.setScanID("")
                        navToScanList = true
                    }) {
                        Text("Return to Scan List")
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
            }
            .padding(.top)
        }
        .onAppear {
            selectedDataManager.setScanID(scanID)
            selectedDataManager.setScanName(scanName)
            fetchScanDetails()
        }
        .navigationBarTitle("Scan Details", displayMode: .inline)
    }

    // Fetch scan details and primary images
    private func fetchScanDetails() {
        let patientID = selectedDataManager.getPatientID()
        
        // Fetch scan name, details, and date
        viewModel.fetchScanDetails(scanID: scanID) { name, details, date in
            self.scanDetails = details
            self.scanDate = date
            self.isLoading = false
        }
        
        // Fetch primary images
        storageManager.fetchPrimaryImages(patientID: patientID, scanID: scanID) { fetchedImages in
            self.images = fetchedImages
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @ h:mm a"
        return formatter.string(from: date)
    }
}
