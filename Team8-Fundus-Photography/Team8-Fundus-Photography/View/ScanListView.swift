import SwiftUI

struct ScanListView: View {
    
    @StateObject private var viewModel = ScanListViewModel()
    
    var patientID: UUID
    
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    var body: some View {
        VStack {
            if !viewModel.scans.isEmpty {
                List(viewModel.scans) { scan in
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
            viewModel.fetchScans(for: patientID)
        }
        .sheet(isPresented: $viewModel.isShowingAddScanSheet) {
            BottomSheet(
                title: "Add New Scan",
                placeholder: "Enter Scan Name"
            ) { newScanName in
                viewModel.addScan(patientID: patientID, scanName: newScanName)
            }
        }
    }
}

#Preview {
    ScanListView(patientID: UUID(uuidString: "E20F0761-41EE-45AB-998A-456308F97E55")!)
        .environmentObject(SelectedDataManager())
}
