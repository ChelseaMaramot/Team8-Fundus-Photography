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
    @State private var showSearchField = false
    @State private var searchQuery = ""
    
    var colors = cardColors()

    init(patientID: String) {
        _viewModel = StateObject(wrappedValue: ScanListViewModel(patientID: patientID))
        self.patientID = patientID
    }

    var body: some View {
        VStack {
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
        VStack {
            searchField
            if !viewModel.scanList.isEmpty {
                Spacer()
                filters
                List {
                    ForEach(sortedScans) { scan in
                        scanRow(for: scan)
                    }
                    .onDelete(perform: swipeToDelete)
                }
                .frame(maxWidth: .infinity)
                .listStyle(PlainListStyle()) 
            } else {
                Spacer()
                Text("No Scans found.")
                Spacer()
            }
        }
        .padding(.top)
    }
    
    
    private var searchField: some View {
        VStack{
            TextField("Search Scans", text: $searchQuery)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(13)
                .padding(.horizontal)
                .onChange(of: searchQuery) { _ in
                      viewModel.searchScans(query: searchQuery)
                }
        }
        .padding(15)
        .background(Color.blue)
    }
    
    private var filters: some View {
        HStack{
            Text("Sort By")
                .fontWeight(.light)
                .font(.system(size: 12))
            
            Button(action: {
                sortAscending.toggle()
            }) {
                Text(sortAscending ? "A->Z" : "Z->A")
                    .fontWeight(.medium)
                    .font(.system(size: 12))
                    .padding(5)
                    .background(colors.cardBackground)
                    .foregroundColor(colors.cardMainText)
                    .cornerRadius(13)
            }
        }
        .padding(.leading, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
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
            let scan = sortedScans[index]
            scanIDsToDelete.append(scan.id)
            showConfirmationModal = true
        }
    }
}

#Preview {
    ScanListView(patientID: UUID().uuidString)
        .environmentObject(SelectedDataManager())
}
