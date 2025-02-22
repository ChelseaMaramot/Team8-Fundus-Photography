

import SwiftUI

struct NewScanView: View {
    @Environment(\.presentationMode) var presentationMode
    var patientID: String
//    @StateObject private var viewModel = ScanListViewModel()
    @State  var scanName: String = ""
    @State  var scanDetails: String = ""
    @State  var scanDate: Date = Date()
    @State  var isSaving: Bool = false
    @State  var showAlert: Bool = false
    @State  var navToScanList: Bool = false
    @StateObject var viewModel: ScanListViewModel
    @State  var alertMessage: String = ""
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }
    
    var body: some View {
        NavigationView { // Embed in NavigationView for toolbar
            VStack { // Use VStack for main layout
                Text("Scan Summary") // Title at the top
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                // Eye Diagram View (replace with your actual implementation)
                PrimaryImagesQuadrantView()
                    .frame(height: 200) // Adjust height as needed
                    .padding(.vertical)

                // Form Inputs
                VStack(alignment: .leading) { // Align labels to the left
                    Text("Scan Name")
                        .padding(.bottom, 5)
                    TextField("scan name", text: $scanName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)

                    Text("Session Comments")
                        .padding(.bottom, 5)
                    TextField("Session Comments", text: $scanDetails)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                            
                }
                .padding(.horizontal) // Add horizontal padding to the form fields

                Spacer() // Push button to the bottom
                
                NavigationLink("", destination: ScanListView(patientID: selectedDataManager.getPatientID()), isActive: $navToScanList)

                
                // Scan List Button
                Button(action: saveScan){
                    HStack {
                        if isSaving {
                            ProgressView()
                        }
                        Text("Done")
                            .bold()
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom) // Add padding at the bottom
                .onAppear(){
                    scanName = selectedDataManager.getScanName()
                }
            }
            
        }
    }

    private func saveScan() {
        isSaving = true
       
        
        viewModel.updateScan(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID(), scanName: scanName, scanDetails: scanDetails, scanDate: scanDate) { error in
            isSaving = false
            if let error = error {
                alertMessage = "Failed to save: \(error.localizedDescription)"
                showAlert = true
            } else {
                navToScanList = true
            }
        }
    }
}

// Placeholder for Eye Diagram View (replace with your actual view)
struct PrimaryImagesQuadrantView: View {
    var body: some View {
        // Replace with your custom eye diagram drawing code
        // This example uses a ZStack with circles for the points
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: -50, y: -50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: 50, y: -50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: -50, y: 50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: 50, y: 50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(y: -70) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(y: 70) // Example position
        }
    }
}


#Preview {
//    NewScanView()
}
