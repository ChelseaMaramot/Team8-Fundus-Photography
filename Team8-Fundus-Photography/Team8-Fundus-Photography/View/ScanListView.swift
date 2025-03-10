import SwiftUI

struct ScanListView: View {
    var patientID: String
    @State private var isShowingAddScanSheet = false
    @State private var newScanName = ""
    @State private var navigateToCamera = false
    @StateObject private var viewModel: ScanListViewModel
    @StateObject var storageManager = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    
    init(patientID: String) {
        //        print(patientID)
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }
    
    var body: some View {
        VStack {
            if !viewModel.scanList.isEmpty {
                List(viewModel.scanList) { scan in
                    NavigationLink(destination:
                                    ScanDetailsView(scanID: scan.id, scanName: scan.name, viewModel: viewModel)/*ScanSummary(scanID: scan.id, scanName: scan.name, viewModel: storageManager, isFromScanList: true)*/) {
                        Card(name: scan.name, isStitched: scan.isStitched)
                    }
                }
            } else {
                Text("No Scans found.")
            }
            
            Button(action: {
                isShowingAddScanSheet = true
            }) {
                Text("Add New Scan")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            NavigationLink("", destination: CameraView(), isActive: $navigateToCamera)
            
            
        }
        .onAppear {
            selectedDataManager.setPatientID(patientID)
            viewModel.fetchScans()
        }
        .sheet(isPresented: $isShowingAddScanSheet) {
            BottomSheet(
                title: "Add New Scan",
                placeholder: "Enter Scan Name"
            ) { newName in
                saveAndNavigate(scanName: newName)
                
            }
        }
    }

    func saveAndNavigate(scanName: String) {
        let newscanID = UUID().uuidString
        selectedDataManager.setScanID(newscanID)
        viewModel.addScan(patientID: patientID, scanID : newscanID, scanName: newScanName, scanDetails: "Default scan details", scanDate: Date()) { error in
            if let error = error {
                print("Error adding scan: \(error.localizedDescription)")
            } else {
                selectedDataManager.setScanName(scanName)
                navigateToCamera = true
            }
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
        
}
