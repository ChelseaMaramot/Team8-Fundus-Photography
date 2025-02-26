import SwiftUI

struct ScanListView: View {
    var patientID: String
    @StateObject private var viewModel: ScanListViewModel
    @StateObject var storageManager = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    @State private var showConfirmationModal = false
    @State private var scanToDeleteID: String? = nil
    @State private var scanToDeleteName: String? = nil

    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }

    var body: some View {
        VStack {
            if !viewModel.scanList.isEmpty {
                List {
                    ForEach(viewModel.scanList) { scan in
                        NavigationLink(destination: ScanSummary(scanID: scan.id, viewModel: storageManager, isFromScanList: true)) {
                            Card(name: scan.name, isStitched: scan.isStitched)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                scanToDeleteID = scan.id
                                scanToDeleteName = scan.name
                                showConfirmationModal = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: delete)
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
                        viewModel.addScan(patientID: selectedDataManager.getPatientID(), scanName: "New Scan") { scanUUID in
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
        .confirmationDialog("Are you sure you want to delete the scan: \(scanToDeleteName ?? "this scan")?", isPresented: $showConfirmationModal, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let scanID = scanToDeleteID {
                    viewModel.deleteScan(scanID: scanID)
                }
            }
            Button("Cancel", role: .cancel) {
                scanToDeleteID = nil
                scanToDeleteName = nil
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let scanID = viewModel.scanList[index].id
            viewModel.deleteScan(scanID: scanID)
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
}
