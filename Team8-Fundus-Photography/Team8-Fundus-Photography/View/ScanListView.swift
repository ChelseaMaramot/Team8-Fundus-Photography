import SwiftUI

struct ScanListView: View {
    var patientID: String
    @StateObject private var viewModel: ScanListViewModel
    @StateObject var storageManager = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    @State private var showConfirmationModal = false
    @State private var scanIDsToDelete: [String] = []
    @State private var isEditing = false
    

    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }

    var body: some View {
        VStack {
            if !viewModel.scanList.isEmpty {
                List {
                    ForEach(viewModel.scanList) { scan in
                        HStack{
                            if isEditing {
                                Image(systemName: scanIDsToDelete.contains(scan.id) ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        toggleSelection(for: scan)
                                    }
                            }
                            NavigationLink(destination: ScanSummary(scanID: scan.id, viewModel: storageManager, isFromScanList: true)) {
                                Card(name: scan.name, isStitched: scan.isStitched)
                            }
                            
                        }
                    }
                    .onDelete(perform: swipeToDelete)
                }
            } else {
                Text("No Scans found.")
            }
            
            if !isEditing{
                
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
        }
        .onAppear {
            selectedDataManager.setPatientID(patientID)
            viewModel.fetchScans()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                    if !isEditing {
                        scanIDsToDelete.removeAll()
                    }
                }
            }
            
            if isEditing && !scanIDsToDelete.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", role: .destructive) {
                        showConfirmationModal = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .confirmationDialog("Are you sure you want to delete these patients", isPresented: $showConfirmationModal, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                for scanID in scanIDsToDelete {
                    viewModel.deleteScan(scanID: scanID)
                }
                scanIDsToDelete.removeAll()
                isEditing = false
            }
            Button("Cancel", role: .cancel) {}
        }
    }
        

    
    private func toggleSelection(for scan: Scan) {
        if let index = scanIDsToDelete.firstIndex(of: scan.id) {
            scanIDsToDelete.remove(at: index)
        } else {
            scanIDsToDelete.append(scan.id)
        }
    }
    
    private func swipeToDelete(at offsets: IndexSet) {
        for index in offsets {
            let scan = viewModel.scanList[index]
            viewModel.deleteScan(scanID: scan.id)
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
}
