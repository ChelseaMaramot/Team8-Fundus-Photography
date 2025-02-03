import SwiftUI

struct ScanListView: View {
    var patientID: String
    @StateObject private var viewModel: ScanListViewModel
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    init(patientID: String) {
        print(patientID)
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }
  
    var body: some View {
        VStack {
            if !viewModel.scanList.isEmpty {
                List(viewModel.scanList) { scan in
                    NavigationLink(destination: ImageView()) {
                        Card(name: scan.name, isStitched: scan.isStitched)
                    }
                }
            } else {
                Text("No Scans found.")
            }

            NavigationLink {
                CameraView()
            } label: {
                Text("Add New Scan")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .onAppear {
            selectedDataManager.setPatientID(patientID)
            viewModel.fetchScans()
        }
        .sheet(isPresented: $viewModel.isShowingAddScanSheet) {
            BottomSheet(
                title: "Add New Scan",
                placeholder: "Enter Scan Name"
            ) { newScanName in
                viewModel.addScan(patientID: selectedDataManager.getPatientID(), scanName: newScanName)
            }
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
        
}
