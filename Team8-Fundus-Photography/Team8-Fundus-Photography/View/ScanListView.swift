import SwiftUI

struct ScanListView: View {
    var patientID: String
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
                    NavigationLink(destination: ScanSummary(scanID: scan.id, viewModel: storageManager)) {
                        Card(name: scan.name, isStitched: scan.isStitched)
                    }
                }
            } else {
                Text("No Scans found.")
            }
            NavigationLink(destination: CameraView()) {
                Text("Add New Scan")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .simultaneousGesture(
                TapGesture().onEnded {
                    print("scan name: \(selectedDataManager.getScanID())")
                    if selectedDataManager.getScanID().isEmpty {
                        viewModel.addScan(patientID: selectedDataManager.getPatientID(), scanName: "New Scan") {  scanUUID in
                            if let uuid = scanUUID {
                                selectedDataManager.setScanID(uuid)
                                }
                        }
                        print("added new scan name: \(selectedDataManager.getScanID())")
                    }
                }
            )
        }
        .onAppear {
            selectedDataManager.setPatientID(patientID)
            viewModel.fetchScans()
        }
        // taking this out for now cause we are not using this sheet?
//        .sheet(isPresented: $viewModel.isShowingAddScanSheet) {
//            BottomSheet(
//                title: "Add New Scan",
//                placeholder: "Enter Scan Name"
//            ) { newScanName in
//                viewModel.addScan(patientID: selectedDataManager.getPatientID(), scanName: newScanName)
//            }
//        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
        
}
