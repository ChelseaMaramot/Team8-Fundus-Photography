//
//  NewScanView.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-21.
//

import SwiftUI
import UIKit

extension Color {
    static let lightBlue = Color(red: 236/255, green: 241/255, blue: 255/255)
}

import SwiftUI

struct NewScanView: View {
    @State private var scanName: String = ""
    @State private var scanDetails: String = ""
    @State private var scanDate: Date = Date()
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navToScanList: Bool = false
//    @State private var images: [String: UIImage] = [:]
    @State private var images: [LabeledImage] = []

    @State private var keyboardHeight: CGFloat = 0
    @State private var commentHeight: CGFloat = 50  // Start with default height
    
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @StateObject var viewModel: ScanListViewModel
    @StateObject var storageManager = FirebaseManager()
    
    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Scan Summary")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Display primary images in quadrants
                PrimaryImagesQuadrantView(images: images)
                    .frame(width: 350, height: 300)
                    .padding(.vertical)
                    .background(Color.lightBlue)
                    .cornerRadius(16)

                // Form Inputs
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scan Name").fontWeight(.bold)
                    TextField("Scan name", text: $scanName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.lightBlue)
                        .padding(.bottom)

                    Text("Session Comments").fontWeight(.bold)
                        .padding(.bottom, 4)

                    ResizableTextField(text: $scanDetails)
                        .frame(minHeight: 50, maxHeight: 150)
                        .background(Color.lightBlue)
                        
                }
                .padding(.horizontal)

                Spacer()

                NavigationLink("", destination: ScanListView(patientID: selectedDataManager.getPatientID()), isActive: $navToScanList)

                Button(action: saveScan) {
                    HStack {
                        if isSaving {
                            ProgressView()
                        }
                        Text("Done")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height - 100
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
                storageManager.fetchPrimaryLabeledImages(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID()) { fetchedImages in
                    self.images = fetchedImages
                }
                scanName = selectedDataManager.getScanName()

//                storageManager.fetchPrimaryImages(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID()) { fetchedImages in
//                    self.images = fetchedImages
//                }
//                scanName = selectedDataManager.getScanName()
            }
            .animation(.easeOut(duration: 0.3))
        }
    }

    private func saveScan() {
        isSaving = true
        let patientID = selectedDataManager.getPatientID()
        let scanID = selectedDataManager.getScanID()

        viewModel.addScan(patientID: patientID, scanID: scanID, scanName: scanName, scanDetails: "", scanDate: scanDate) { error in
            if let error = error {
                alertMessage = "Failed to add scan: \(error.localizedDescription)"
                showAlert = true
                isSaving = false
            } else {
                print("Scan added successfully, now updating details...")
                viewModel.updateScan(patientID: patientID, scanID: scanID, scanName: scanName, scanDetails: scanDetails, scanDate: scanDate) { updateError in
                    isSaving = false

                    if let updateError = updateError {
                        alertMessage = "Failed to update scan details: \(updateError.localizedDescription)"
                        showAlert = true
                    } else {
                        print("Scan successfully updated!")
                        navToScanList = true
                    }
                }
            }
        }
    }
}
