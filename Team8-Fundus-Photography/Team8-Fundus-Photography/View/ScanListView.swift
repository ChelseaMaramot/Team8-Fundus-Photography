import SwiftUI

struct ScanListView: View {
    var patientID: String
    @StateObject private var viewModel: ScanListViewModel
    @StateObject var storageManager = FirebaseManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    @State private var showConfirmationModal = false
    @State private var scanIDsToDelete: [String] = []
    @State private var isEditing = false
    @State private var sortAscending = true
    
    var colors = cardColors()

    // Initializer
    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }

    var body: some View {
        VStack {
            HStack{
                Text("Sort By")
                    .fontWeight(.light)
                    .font(.system(size: 12))
                
                Button(action: {
                    
                }) {
                    Text("A->Z")
                        .fontWeight(.medium)
                        .font(.system(size: 12))
                        .padding(5)
                        .background(colors.cardBackground)
                        .foregroundColor(colors.cardMainText)
                        .cornerRadius(13)
                }
            }
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
            scanListView
            addScanButton
        }
        .onAppear {
            selectedDataManager.setPatientID(patientID)
            viewModel.fetchScans()
        }
        .toolbar { toolbarContent() }
        .confirmationDialog(
            "Are you sure you want to delete these scans?",
            isPresented: $showConfirmationModal,
            titleVisibility: .visible
        ) {
            deleteConfirmationDialog
        }
    }
        
}

// MARK: - UI Components
extension ScanListView {

    private var scanListView: some View {
        Group {
            if !viewModel.scanList.isEmpty {
                List {
                    ForEach(sortedScans) { scan in
                        scanRow(for: scan)
                    }
                    .onDelete(perform: swipeToDelete)
                }
                .frame(maxWidth: .infinity)
                .listStyle(PlainListStyle()) 
            } else {
                Text("No Scans found.")
            }
        }
    }
    
    private var sortedScans: [Scan] {
        sortAscending
        ? viewModel.scanList.sorted { $0.name.lowercased() < $1.name.lowercased() }
        : viewModel.scanList.sorted { $0.name.lowercased() > $1.name.lowercased() }
    }
    
    private func scanRow(for scan: Scan) -> some View {
        HStack {
            if isEditing {
                selectionIndicator(for: scan)
            }
            NavigationLink(destination: ScanSummary(scanID: scan.id, viewModel: storageManager, isFromScanList: true)) {
                Card(name: scan.name, isStitched: scan.isStitched)
            }
        }
    }

    private func selectionIndicator(for scan: Scan) -> some View {
        Image(systemName: scanIDsToDelete.contains(scan.id) ? "checkmark.circle.fill" : "circle")
            .onTapGesture {
                toggleSelection(for: scan)
            }
    }

    private var addScanButton: some View {
        Group {
            if !isEditing {
                NavigationLink(destination: CameraView()) {
                    Text("Add New Scan")
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                addNewScan()
                            }
                        )
                }
            }
        }
    }

    private func addNewScan() {
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
}

// MARK: - Toolbar
extension ScanListView {

    private func toolbarContent() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Spacer()
            }
            ToolbarItemGroup(placement: .principal) {
                Text("Scans")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue)
            
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                editButton
            }
            

            if isEditing && !scanIDsToDelete.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    deleteButton
                }
            }
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            sortAscending.toggle()
        }) {
            Image(systemName: sortAscending ? "arrow.up.arrow.down" : "arrow.down.arrow.up")
                .foregroundColor(.blue)
        }
    }
    

    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            isEditing.toggle()
            if !isEditing {
                scanIDsToDelete.removeAll()
            }
        }
    }

    private var deleteButton: some View {
        Button("Delete", role: .destructive) {
            showConfirmationModal = true
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

// MARK: - Delete Confirmation
extension ScanListView {

    private var deleteConfirmationDialog: some View {
        Group {
            Button("Delete", role: .destructive) {
                for scanID in scanIDsToDelete {
                    viewModel.deleteScan(scanID: scanID)
                }
                scanIDsToDelete.removeAll()
                isEditing = false
            }
            Button("Cancel", role: .cancel) {
                scanIDsToDelete.removeAll()
            }
        }
    }
}

// MARK: - Helper Methods
extension ScanListView {

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
            scanIDsToDelete.append(scan.id)
            showConfirmationModal = true
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
}
